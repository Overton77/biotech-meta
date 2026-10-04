# W06 fixtures and queries

## Execution record

All tags below are **run**: executed, not EXPLAIN-only.

| What | How | Result |
|---|---|---|
| Database | In-process Neo4j **5.26.31 Community** (`CALL dbms.components()` → edition `community`), started from the run harness (`EmbeddedNeo4j`, neo4j-harness 5.26.31) in a fresh directory. Statements were split by the harness `run-cypher.mjs` and each ran in its own transaction; no variable crosses a `;`. | run |
| Load order | 00 → 01 → 02 → 03 → 04 → 05 → 98, then `w06-validation.cypher` and `w06-queries.cypher` (positive state), then the baseline suite `docs/schema/neo4j/validation.cypher` (174 statements). Then 99 (negatives), `w06-validation.cypher` again, and the baseline suite again. Finally `operations.cypher`. | every statement ok (00: 9, 01: 20, 02: 10, 03: 20, 04: 8, 05: 9, 98: 1, 99: 14, validation 11, queries 9, baseline 174, operations 17) |
| Raw results | `fixtures/results/*.json` (rows, counters, timings per statement) | — |
| SDL | `sdl-fragment.graphql` parsed with graphql-js 16.14.2 and built with `@neo4j/graphql` 7.6.3 against scratch stubs for other owners' types. Build OK: 734 generated types, 45 queries, 54 mutations. Read-only fields are absent from `TreatmentCreateInput`. | parser + library build (stub-based, not the merged schema) |

Fixture conventions:

- Every node carries its primary label and its archetype label.
- Snapshots carry `contentHashBasis: 'STORED_EXCERPT_TEXT'` (a hash over the stored excerpt file), or `SYNTHETIC_FIXTURE` for the synthetic protocol source.
- uids use registered tokens, except `treatment` and `procedure`, which are requested (W06-SR-02).
- Other owners' nodes (W01, W03, W04, W09, W13, W15, W16) are minimal reference shapes.

## Fixture files and the minimal pairs they carry

| File | Content | Mandatory case covered |
|---|---|---|
| `00-shared-sources-and-referenced-identities.cypher` | 12 Sources, 12 Snapshots and 20 Locators (TEXT_QUOTE with NFC-WS1 `quoteHash`, SECTION, WHOLE_SNAPSHOT); referenced organizations, conditions, products and one substance | provenance backbone |
| `01-three-identities-exa-cel.cypher` | Treatment exa-cel (modalities CELL_THERAPY + GENE_THERAPY, identifiers for the FDA proper name and CTX001), StudyIntervention "Exa-cel" (NCT03745287, BIOLOGICAL, dose NOT_REPORTED), Product CASGEVY; `USES_COMPONENT` ADMINISTERED_PRODUCT and STARTING_MATERIAL_COLLECTION (HSC apheresis); `TARGETS_CONDITION` label restatements; W09 `FOLLOWS_INTERVENTION_DEFINITION`. No `DEVELOPS_TREATMENT`: sponsor and manufacturer assertions only. | **treatment concept vs administered StudyIntervention vs marketed Product, same drug name** |
| `02-modality-vs-registry-type-horizon.cypher` | Treatment delandistrogene moxeparvovec; HORIZON arm with two StudyInterventions (GENETIC, PROCEDURE); plasmapheresis `FOLLOWS_INTERVENTION_DEFINITION` TPE; no concept component | registry type vs modality; trial co-intervention vs concept component |
| `03-procedure-definition-offering-step.cypher` | Procedure TPE vs Procedure plasma-donation plasmapheresis (shared ICD-10-PCS codes); `OFFERS_PROCEDURE` Next Health; W15 listing, offer and price (10,000 USD); SYNTHETIC W16 protocol step `EMPLOYS` TPE; Circulate offer statement EXTRACTED (no edge); GeekWire volume literal (no occurrences) | **procedure definition vs organization offering it vs protocol step employing it** (plus study instantiation and performance-not-modeled) |
| `04-development-stage-vs-regulatory-status.cypher` | Two CASGEVY `DrugApproval` states (TDT 12+ from 2024-01-16; TDT 2+ from 2026-07-01) with approving responses; exa-cel `developmentStage` 'Approved (US)' as a CALCULATED assertion; edaravone concept with legacy 'Approved' text and RADICAVA approval captured only from a search extract (EXTRACTED) | **developmentStage text vs RegulatoryStatus APPROVAL (V-322-style guard)**; late facts (indication broadened, concept unchanged) |
| `05-orphan-designation-not-approval.cypher` | exa-cel `OrphanDesignation` 2020-04-28 "Treatment of beta-thalassemia" split from the approvals; Treeway designation and its undistinguished end; Treatment display projection naming the designation uid | **orphan designation text that must not read as approval**; missing facts (withdrawn vs revoked, end date) |
| `98-capture-fidelity-adjudications.cypher` | One CAPTURE_FIDELITY adjudication per ACCEPTED W06 assertion (INV-103) | status is capture fidelity, not truth |
| `99-negative-cases.cypher` | N1–N9 deliberate violations (uids contain `:neg-`; N8 uses a `hu:private-` uid) | negatives and leak check |

## Expected and observed rows

### Positive state (fixtures 00–05 + 98)

| Query | Expected = observed |
|---|---|
| V-W06-01 | 1 row: `hu:treatment:edaravone-als`, 'Approved', `APPROVAL_ONLY_FROM_UNACCEPTED_CAPTURE`. Expected: the only approval is a search extract. exa-cel does **not** appear. |
| V-W06-02 (informational) | 1 row: edaravone-als, [developmentStage, orphanDrugDesignation] |
| V-W06-03, -04, -05, -06, -07 | 0 rows each |
| V-W06-07i (informational) | 2 rows: 6A550Z3 and 6A551Z3, each [therapeutic-plasma-exchange, plasma-donation-plasmapheresis] |
| V-W06-08, V-W06-08b, QS-4a/W06 | 0 rows each |
| Q-01 three identities | 3 rows: Product `hu:product:casgevy` 'CASGEVY'; StudyIntervention `hu:intervention:nct03745287-exa-cel` 'Exa-cel'; Treatment `hu:treatment:exagamglogene-autotemcel` |
| Q-02 (CQ-ST-01 / CQ-IV-C01) | 1 row: study nct03745287, arm 'Exa-cel (single arm)', administered 'Exa-cel', registryType BIOLOGICAL, schedule 'single dose …', dose **NOT_REPORTED** |
| Q-03 (CQ-MF-02 / CQ-AX-23) | 2025-06-01: approvals in force are [US TDT aged 12+], designations [US 'Treatment of beta-thalassemia']. 2026-08-01: approvals [US TDT aged 2+, US TDT aged 12+], same designation, listed separately. |
| Q-04 (CQ-IV-C02) | 1 row: offeredBy [Next Health]; candidateOfferers [Circulate Health (unverified capture)]; listings [next-health.com URL]; priceObservations [[10000.0 USD @ 2026-10-04T01:02:00Z]]; employedByProtocolSteps [synthetic step3]; instantiatedBy [HORIZON plasmapheresis [PROCEDURE]]; componentOfTreatments [] |
| Q-05 (CQ-IV-C04, QS-7 shape) | developerState **NOT_RECORDED**; other roles: 'Vertex … manufactures CASGEVY', 'Vertex … sponsors hu:study:nct03745287' |
| Q-06 (CQ-IV-C03) | delandistrogene [GENE_THERAPY], legacy GENE_THERAPY, registry [GENETIC]; exa-cel [CELL_THERAPY, GENE_THERAPY], legacy **null**, registry [BIOLOGICAL] |
| Q-07 (CQ-IV-C05) | 2 rows (6A550Z3, 6A551Z3), each listing both definitions |
| Q-08 (CQ-EV-04 guard) | 1 row: evidenceTarget nct03745287-exa-cel, via the concept, navigated product CASGEVY, applicability **NOT_ASSESSED** |
| Q-09 (CQ-AX-23 negative) | RADICAVA: [APPROVAL [EXTRACTED]]. Treeway product: [DESIGNATION [ACCEPTED], UNSPECIFIED_END(…withdrawn or revoked…) [ACCEPTED]]. The legacy text appears beside them and is never read as approval. |
| Baseline suite (174) | All statements ok. Rows reported on W06 data: V-336 1 (RADICAVA approval without an approving response, expected: unverified capture); V-333 1 (Treeway designation end with statusKind null, expected, W06-SR-05b); V-401b 27 accepted assertions on coarse locators (informational); V-514b 39 assertions without contentHash (informational); V-118 informational. No other rows. |

### With negatives (after fixture 99)

| Validator | Expected = observed rows |
|---|---|
| V-W06-01 | 3: edaravone-als (APPROVAL_ONLY_FROM_UNACCEPTED_CAPTURE), **neg-designation-read-as-approval (DESIGNATION_ONLY)**, **neg-stage-approved-no-status (NO_APPROVAL_STATUS)** |
| V-W06-02 | 3 (edaravone plus two negatives) |
| V-W06-03 | 1: **neg-designation-read-as-approval** |
| V-W06-04 | 1: nct03745287-exa-cel -[EVIDENCE_APPLIES_TO]-> casgevy, cited [USES_COMPONENT, FOLLOWS_INTERVENTION_DEFINITION], viaTreatmentConcept true |
| V-W06-05 | 1: **neg-combination-single-component** (0 components) |
| V-W06-06 | 1: delandistrogene-moxeparvovec PREPARATORY_PROCEDURE → TPE, sources only clinicaltrials.gov |
| V-W06-07 | 1: **neg-tpe-same-as-donation** |
| V-W06-08 | 2: neg-offers-from-listing [CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE, CITED_SUBJECT_IS_NOT_EDGE_START]; neg-uncited-targets [NO_ASSERTION_UID, NO_RECORDED_FROM, NO_VALID_TIME_BASIS] |
| V-W06-08b | 1: `hu:private-treatment:neg-my-tpe-course` (PRIVATE_PERSONAL) |
| QS-4a/W06 | 1: OFFERS_PROCEDURE geekwire → TPE [CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE, FORBIDDEN_IMPLICATION_USED_AS_PREMISE] |
| Baseline suite | Additionally V-201 (N3), V-333 (neg-designation-only: STATUS_OF count 0 because it uses DESIGNATION_FOR, which is the alias issue W06-SR-05c), V-432 (N6 uses `COMPARES_IDENTITIES`, while baseline V-432 counts `COMPARES`, a W00 naming inconsistency noted for Fable), V-521 (N8 private uid), V-522 (negative nodes without privacyClass). |

## Temporal correction and late arrival

- **Indication broadened (late fact).** The 2026-07-01 approval (aged 2+) arrives after the 2024 approval (aged 12+). Both are W13 states with their own valid time, and the Treatment concept does not change. Q-03 returns different answers at 2025-06-01 and 2026-08-01. The earlier approval is not closed, because the indication was broadened rather than replaced. The CBER page's stale meta description ("12 years and older") is not an indication record.
- **Correction path.** If a later capture of NDA 209176 yields a reproducible locator, a new ACCEPTED STATUS_OF assertion SUPERSEDES the EXTRACTED one (`EXTRACTION_FIX`). V-W06-01 then stops reporting edaravone, and `developmentStage` is re-projected with `developmentStageAssertionUid`. That change is not executed in the fixtures; it is described here only.

## Identity collision and missing facts

- **Identity collision.** One drug name gives three identities (Q-01). One ICD-10-PCS code covers two procedure definitions (Q-07, V-W06-07). One generic name covers two sponsors' products (Q-09).
- **Missing facts.** Dose NOT_REPORTED (Q-02). Developer NOT_RECORDED (Q-05). Withdrawn versus revoked, and its date, are unknown (fixture 05). The edaravone approval date is unknown (validFromBasis UNKNOWN).
- **Access leakage.** N8 is caught by V-W06-08b and baseline V-521.
