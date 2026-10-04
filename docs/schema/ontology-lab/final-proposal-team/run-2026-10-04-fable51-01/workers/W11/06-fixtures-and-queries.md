# W11 Fixtures and queries

All fixtures were **run** on an embedded Neo4j **5.26.31 Community** (in-process `neo4j-harness`, single database `neo4j`, wiped with `MATCH (n) DETACH DELETE n` between scenarios) on 2026-10-04 by `scratchpad/w11/runner.mjs` (statement splitter of `validation/harness/run-cypher.mjs`; every statement in its own auto-commit transaction; validation parameters from `validation/validation-params.json`). Enterprise behaviour not tested.

| File | Content | Statements | Result |
|---|---|---|---|
| `fixtures/01-capability-promotion-filing-operating.cypher` | NAI Carlsbad: PLANNED (2021 release) -> OPERATING (Apr 2023) -> SUSPENDED (Oct 2023) -> OPERATING (May 2024); late arrival; VALIDITY_BOUNDED correction; promoted capability vs filing vs attached state; FY2026 forward-looking exit; one SUPPORT adjudication | 21 | 21 ok |
| `fixtures/02-capacity-basis-nameplate-vs-utilized.cypher` | Cyanotech NAMEPLATE 200,000 m2 (issuer 10-K FY2002), PLANNED expansion, UTILIZED ~50 % of astaxanthin ponds (Meridian 13D, 2018, unattached) | 10 | 10 ok |
| `fixtures/03-specification-versions-and-process-inputs.cypher` | Niagen spec versions 2015 (GRN 000635) and 2019 (EFSA) on one material uid; USP monograph as a separate specification with UNKNOWN criteria; two-step synthesis with ordered steps, inputs/outputs; nicotinamide one uid as process input and component material | 19 | 19 ok |
| `fixtures/04-cgmp-claim-vs-certification-registration-inspection.cypher` | NAI cGMP claims (company page), facility certification statement (10-K, PROPOSED candidate predicate), FDA 503B registration record (Navinta III, "Not yet inspected") | 12 | 12 ok |
| `fixtures/05-negative-mutations.cypher` | N1..N10 deliberate violations, each applied alone then removed | 10 + 2 cleanup | all applied |
| `fixtures/w11-validation.cypher` | V-324r, V-W11-01..13 (+02b, 07b) | 16 | 0 errors |
| `fixtures/w11-cq-queries.cypher` | 13 CQ queries | 13 | 0 errors after one fix (Q-MF04-a ORDER BY alias) |

Every statement binds its own nodes by uid; nodes carry primary and archetype labels; snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'`; quote hashes are real sha256 over NFC-WS1 text; payload hashes are real sha256 over the canonical payload JSON printed beside each state. Fixtures 01-04 load alone and together with `examples/filing-vs-capability.cypher` (shared uids `hu:material:niagen-nrc`, `hu:org:niagen-bioscience-inc`).

## Positive-state expectations (fixtures 01-04 + inherited fixture loaded together)

| Check | Expected | Observed (run 2/3) |
|---|---|---|
| Baseline suite `neo4j/validation.cypher` (174 statements) | zero failing rows; informational rows only from the inherited fixture | 0 errors; non-zero only V-331 (1, inherited NDI 882 conditions not captured), V-401b (15, inherited SECTION locators), V-514b (18, inherited assertions without contentHash), V-522 (65, inherited nodes without privacyClass). Verified by uid that none of these rows is a W11 node. V-503 fired in run 1 on the W11 bounded assertion (INFERRED bound without derivationRule): fixed by adding `derivationRule`. |
| V-324, V-324r, V-325 | 0 | 0 |
| V-W11-01..13 | 0 | 0 |
| V-W11-02b (informational) | 0 | 0 |
| V-W11-07b (informational) | 1 row: niagen-nrc governed by 2015 and 2019 versions with unknown bounds | 1 row (as expected): the open question is when the 2015 version stopped governing |

## Negative mutations (each alone; expected = observed in run 2)

| Id | Mutation | Forbidden implication / invariant | Expected rows | Observed |
|---|---|---|---|---|
| N1 | attach the promoted OPERATING Carlsbad state | PROMOTES_CAPABILITY -> OPERATES_CAPABILITY; INV-305 | V-324 1, V-324r 1 | V-324 1, V-324r 1 |
| N2 | OPERATING state with the planned target date, authorized by the PLANNED assertion | PLANNED_CAPABILITY -> OPERATING_CAPABILITY | V-W11-01 1 (OBJECT_MISMATCH, VALID_TIME_DIFFERS), V-W11-03 1; V-W11-02b review rows | V-W11-01 1, V-W11-03 1, V-W11-02b 4 |
| N3 | cGMP claim projected as CertificationScope COVERS Facility | CLAIMS_CGMP_COMPLIANCE -> CGMP_COMPLIANT | V-W11-06 1 | V-W11-06 1 |
| N4 | two Niagen spec versions definitely overlapping on one material, without assertions | EXCLUSIVE GOVERNED_BY_SPECIFICATION; asserted-edge profile | V-W11-07 1, V-W11-01 2 | V-W11-07 1, V-W11-01 2, V-W11-07b 3 |
| N5 | second material uid for the 2019 version | SPECIFICATION_VERSION_CHANGE -> MATERIAL_IDENTITY_CHANGE | V-W11-11 1 | V-W11-11 1 |
| N6 | live `Material` node as process input | D-008 / CL-005 | V-W11-12 2, V-W11-01 1 | V-W11-12 2, V-W11-01 1 |
| N7 | 120 % recorded as NAMEPLATE | capacity coherence | V-W11-05 1 | V-W11-05 1 |
| N8 | `HAS_STEP` from a ProtocolEdition | D-004 | V-W11-10 1 | V-W11-10 1 |
| N9 | criterion added in place to the 2015 version | VersionedState immutability | V-W11-09 1 | V-W11-09 1 |
| N10 | OPERATING episode inside the reported closure (Nov 2023 - Feb 2024), no assertion | EXCLUSIVE HAS_CAPABILITY_STATE per line; INV-305 | V-W11-02 1, V-W11-01 1, V-324 1, V-324r 1 | same |

(V-W11-07b's baseline row appears in every negative run; it is the expected informational row above.) The baseline V-504/V-505 and V-112 did **not** detect N2, N4, N6 or N10 because they list only HAS_STATE-family types or derived types; this is the failing case for W11-SR-12.

## CQ queries (fixtures loaded together; observed rows)

| Query | CQ | Expected | Observed | Tag |
|---|---|---|---|---|
| Q-MF04-a | CQ-MF-04 | 4 current episodes ordered: PLANNED 2021-08-20..2023-04-01, OPERATING 2023-04..2023-10, SUSPENDED 2023-10..2024-05, OPERATING 2024-05..null; source kinds per episode | run 3 (after alias fix) | run |
| Q-MF04-b | CQ-MF-04 | `SUSPENDED` (hu:rel:nai-carlsbad-suspended-2023) | SUSPENDED | run |
| Q-MF04-c | CQ-MF-04 (as recorded at 01:15Z) | `PLANNED`, openEnded true (the pre-10-K belief; possible, not fact) | PLANNED, e1, openEnded true | run |
| Q-MF05 | CQ-MF-05 | filing-backed OPERATING/SUSPENDED/PLANNED attached; DISCONTINUED (FUTURE, filing) not attached; OPERATING from MARKETING_PAGE not attached with verdict PARTIALLY_SUPPORTED | as expected (plus the superseded PLANNED capture, PRESS_RELEASE, not attached now) | run |
| Q-MF-C01 | CQ-MF-C01 | Cyanotech NAMEPLATE 200000 m2 attached; Meridian UTILIZED 50 % 2018-07 not attached; NAI SUSPENDED/DISCONTINUED/promoted with verbatim, NOT_REPORTED | as expected | run |
| Q-MF01 | CQ-MF-01 | producedBy: GRN 635 route; performers: []; suppliers: W.R. Grace; spec owner: Niagen Bioscience | as expected | run |
| Q-MF06-a | CQ-MF-06 | registrationStatuses 0 (unknown: not public), certification scopes 0, two cGMP claims, one PROPOSED certification claim, inspections 0 | as expected | run |
| Q-MF06-b | CQ-MF-06 | ESTABLISHMENT_REGISTRATION from 2026-02-06, verbatim row "Not yet inspected", cgmpClaims 0 | as expected | run |
| Q-MF-C02 | CQ-MF-C02 | two versions, both PARTIAL_EXCERPT, criteria listed with limit stage (2019 assay SHELF_LIFE) | as expected | run |
| Q-MF-C03 | CQ-MF-C03 | materialIdentities 1, versions 2 | 1, 2 | run |
| Q-MF-C04 | CQ-MF-C04 | step 0: 4 inputs (3 ChemicalSubstance, nicotinamide IngredientMaterial) + 1 intermediate output; step 1: 4 inputs | as expected | run |
| Q-MF-C05 | CQ-MF-C05 | usedAsProcessInput 1, usedAsComponentMaterial 1, duplicateLiveMaterialNodes 0 | 1, 1, 0 | run |
| Q-PF01-w11 | CQ-PF-01 (lineage) | 2015 RANGE 95 % NOT_STATED; 2019 GE 90 % SHELF_LIFE | as expected | run |

## Mandatory cases (brief) and where they live

| Required case | Fixture / query |
|---|---|
| promotional vs filing-disclosed vs operating state (three assertions, one adjudication) | 01: A-PROMO (marketing), A-OP2 (FY2024 10-K, attached), A-EXIT (FY2026 10-K); adjudication `hu:adjudication:nai-carlsbad-promotion-support-2026-10-04` (PARTIALLY_SUPPORTED); Q-MF05; N1 |
| planned vs operating as separate episodes | 01 (PLANNED e1/e2, OPERATING 2023 and 2024, SUSPENDED); 02 (Cyanotech PLANNED expansion); Q-MF04-a/b/c; N2 |
| specification version change without material identity change (vs new BrandedIngredientMaterial, W02) | 03 (one uid, two versions); contrast: `hu:material:niagen-nrc-pharmaceutical-grade` stays a separate material (inherited, W02 decision); Q-MF-C03; N5 |
| process input that is an IngredientMaterial under the same uid | 03 nicotinamide; Q-MF-C05; N6 (ProcessMaterial/live Material case rejected) |
| cGMP claim that must not read as certification or inspection | 04; Q-MF06-a/b; N3 |
| temporal correction / late arrival | 01 (FY2024 10-K recorded 01:20Z with 2023 valid times; PLANNED bounded by SUPERSEDES VALIDITY_BOUNDED) |
| identity collision | 03/N5 (spurious material split); inherited "TRU NIAGEN" seller account (round 0005) |
| missing facts | USP criteria UNKNOWN; capacity NOT_REPORTED + verbatim; NAI food registration not public (0 = unknown) |
| access leakage | not applicable: no private data in W11 scope; contact strings remain inside the FDA record locator only (no Person nodes) |
