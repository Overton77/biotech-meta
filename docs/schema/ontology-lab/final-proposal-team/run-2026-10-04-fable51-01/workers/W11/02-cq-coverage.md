# W11 CQ coverage matrix

Existing CQs from `competency-questions.md` (round 0005). Candidates are labelled `CQ-MF-C<nn>` and are NOT existing ids. Query ids refer to `fixtures/w11-cq-queries.cypher`; observed rows are in `06-fixtures-and-queries.md`.

## Existing CQs

| CQ (priority, answerability) | Example answer (fixtures) | Distinction | Evidence requirement | Proposed element(s) | Query | Prevented failure |
|---|---|---|---|---|---|---|
| **CQ-MF-01** (Essential now, A) Who manufactures, supplies, contract-manufactures, or only markets a material or product, according to which source and when? | "Niagen NRC: produced by the two-step synthesis described in the GRN 000635 dossier (asserted by the notifier, 2015); no performer asserted; supplier W.R. Grace per FY2025 10-K; specification owner Niagen Bioscience. Owning the specification does not make Niagen the manufacturer." | supply vs manufacture vs specification ownership vs process performance | filing, dossier, assertion per role | `PRODUCED_BY_PROCESS`, `PERFORMS_PROCESS`, `HOSTS_PROCESS` (asserted); predicates SUPPLIES_INGREDIENT_MATERIAL, OWNS_SPECIFICATION (W01); forbidden `[OWNS_SPECIFICATION, PERFORMS_PROCESS]` | Q-MF01 | "brand owner manufactures its ingredient" from spec ownership or marketing |
| **CQ-MF-04** (Foundational, Q) Which capabilities are operating, piloting, planned, suspended or discontinued, asserted by whom, over which valid time? | "NAI Carlsbad powder line: PLANNED 2021-08-20..2023-04 (bounded later), OPERATING 2023-04..2023-10, SUSPENDED 2023-10..2024-05, OPERATING 2024-05..unknown (FY2024 10-K). As recorded before the 10-K arrived, the 2023-12 answer was 'possibly still PLANNED'. A planned sale (FY2026) is not attached." | stage vs source context; planned target vs valid time; current vs as-recorded | filings, releases | `ManufacturingCapability.stage`, `HAS_CAPABILITY_STATE` episodes (asserted_edge), `targetOperationalDate` PLANNED-only; `SUPERSEDES {VALIDITY_BOUNDED}` | Q-MF04-a, -b, -c | planned or promoted capability shown as operating; late fact overwriting history |
| **CQ-MF-05** (Foundational, A) What did a filing disclose versus what the same company promoted? | "10-Ks: Carlsbad is a powder blending and packaging facility (attached). Marketing page: Carlsbad expands capsule, tablet and powder capacity (captured, not attached; SUPPORT adjudication PARTIALLY_SUPPORTED). FY2026 10-K: sale planned (future tense, not attached)." | source kind; capture status vs support verdict; attached vs not | snapshots of both sources in the same period | `Source.sourceKind`, `ASSERTED_BY`, `Adjudication{SUPPORT}`, attachment check | Q-MF05 | merging filing and promotion into one "company says" |
| **CQ-MF-06** (Foundational, Q) Does registration, a cGMP claim, a GMP certification or an inspection support a quality conclusion, for which facility and period? | "NAI: two organization-level cGMP claims (company page; one adjudicated INSUFFICIENT because it calls an FDA standard a certification); one facility-scoped certification statement in the FY2025 10-K (PROPOSED, certifier listing not captured); no registration status (food facility registrations are not public, 21 CFR 1.243(a): unknown, not absent); no inspection captured. Navinta III: 503B registration from FDA's list (2026-02-06), 'Not yet inspected'." | claim vs certification vs registration vs inspection; organization vs facility scope | company page, filing, agency list, certifier listing | `CLAIMS_CGMP_COMPLIANCE` (literal Assertion, never projected; V-W11-06); W12 CertificationScope COVERS Facility; W13 RegulatoryStatus{ESTABLISHMENT_REGISTRATION} STATUS_OF Facility; W13 candidate RegulatoryInspection | Q-MF06-a, Q-MF06-b | "cGMP" read as certified, inspected or FDA-registered; registration read as CGMP |
| **CQ-PF-01** (Essential now, A for US) declared amount referent | W11 contributes lineage only: the Niagen specification's assay is wt% of NRC as is (material mass, salt form), with limit stage. | assay basis vs declared amount | specification table | `SpecificationCriterion` (W12) via `SpecificationVersion` | Q-PF01-w11 | silently converting a salt-form assay to active-moiety mass |
| **CQ-PF-03** (Essential now, A) What a certification or status attaches to | W11 contributes: which SpecificationVersion a lot was made under (W12 `MANUFACTURED_UNDER`) and which governs a material. | material-level spec vs lot-level release | spec versions | `SpecificationVersion`, `GOVERNED_BY_SPECIFICATION` | Q-MF-C02 | treating a facility or brand spec as product certification |

CQ-MF-02 and CQ-MF-03 (regulatory status and characterizations) are W13's; W11 fixtures reuse the round-0005 data unchanged.

## Candidate CQs (W11 proposals)

| Candidate | Rationale (failing case) | Example answer | Elements | Query |
|---|---|---|---|---|
| **CQ-MF-C01** What capacity does a source state, on which basis (nameplate, utilized, not reported), in which unit, and who states it? | Cyanotech FY2002 10-K gives installed pond area (200,000 m2, NAMEPLATE); Meridian's 2018 13D gives about 50 % of astaxanthin ponds empty (UTILIZED, third party); NAI FY2026 10-K says "persistent excess capacity" (NOT_REPORTED). Without basis+unit these collapse into one number. | "Cyanotech Kona: NAMEPLATE 200,000 m2 (issuer, 2002 filing, attached); UTILIZED ~50 % of astaxanthin ponds, July 2018 (Meridian, not attached); no output capacity stated." | `capacityValue`, `capacityUnitCode`, `capacityBasis`, `capacityVerbatim`; V-W11-05 | Q-MF-C01 |
| **CQ-MF-C02** Which specification version governs a material, how complete is its captured criteria set, and which criteria changed between versions? | Niagen 2015 dossier vs 2019 EFSA table: different solvent limits, assay stated on a shelf-life basis in 2019; USP monograph criteria unknown. | "Niagen spec 2015: acetone <=3000, methanol <=740 mg/kg, water <=1 %, purity 95-102 % (stage not stated). 2019: acetone <=5000, methanol <=1000 mg/kg, water <=2.0 %, NRC >=90 % [SHELF_LIFE]. Both PARTIAL_EXCERPT; when 2015 stopped governing is unknown." | SpecificationVersion fields; GOVERNED_BY_SPECIFICATION; W12 criteria + `limitStage` | Q-MF-C02 |
| **CQ-MF-C03** Did a specification change create a new material identity? | OPEN-QUESTIONS P1 ingredient item 2. | "No: one material uid governed by two versions of one specification." | SpecificationVersion vs IngredientMaterial; V-W11-11 | Q-MF-C03 |
| **CQ-MF-C04** What are a process's ordered steps and their inputs/outputs, with role? | GRN 000635 route; live INPUTS/HAS_INPUT carried DoseMetadata (intake semantics). | "Step 1: D-ribofuranose tetra-acetate (starting material), acetonitrile (solvent), HCl (reagent), nicotinamide (starting material, IngredientMaterial) -> intermediate. Step 2: intermediate, methanol, ammonium hydroxide, MTBE." | HAS_STEP orderIndex, INPUTS/OUTPUTS + ProcessIoProperties | Q-MF-C04 |
| **CQ-MF-C05** Is a process input the same material identity as an ingredient used in formulations? | CL-005, D-008: live `Material` vs `IngredientMaterial`. | "Nicotinamide: one uid, 1 process input use, 1 component use, 0 duplicate Material nodes." | one-uid rule; V-W11-12 | Q-MF-C05 |

## Element-to-CQ / invariant map (every SDL element)

| SDL element | CQ / invariant / ingestion failure |
|---|---|
| ManufacturingSpecification (+ specificationKind, documentIdentifier) | CQ-MF-C02, CQ-MF-C03, CQ-MF-01 (owner), V-W11-08 |
| SpecificationVersion (+ payloadHash, effective*, versionName, revisionIdentifier, criteria*) | CQ-MF-C02, CQ-MF-C03, CQ-PF-03, D-009, V-W11-08/09 |
| ManufacturingProcess (+ processKind, processKindVerbatim, processTechnologySummary) | CQ-MF-01, CQ-MF-04 (capability line), CQ-MF-C04, migration of live processClass |
| ManufacturingStep (+ stepKind, operationKind, environmentGrade) | CQ-MF-C04, D-004, V-W11-10 |
| ManufacturingCapability (+ stage, capacity*, targetOperationalDate*) | CQ-MF-04, CQ-MF-05, CQ-MF-C01, INV-305, V-324/V-324r, V-W11-02..05 |
| CapabilityStage, CapacityBasis | CQ-MF-04, CQ-MF-C01 |
| ProcessKind | CQ-MF-C04; live processClass migration |
| ProcessIoProperties | CQ-MF-C04, CQ-MF-C05; DoseMetadata retirement |
| GOVERNED_BY_SPECIFICATION | CQ-MF-C02/C03, V-W11-01/07/07b/11 |
| VERSION_OF_SPECIFICATION | V-W11-08 |
| PRODUCED_BY_PROCESS | CQ-MF-01, V-W11-01 |
| HAS_STEP | CQ-MF-C04, D-004, V-W11-10 |
| HAS_CAPABILITY_STATE | CQ-MF-04/05, INV-305, V-324r, V-325, V-W11-01/02/04 |
| CAPABILITY_FOR_PROCESS / CAPABILITY_FOR_MATERIAL | CQ-MF-04 (line partition for exclusivity), V-W11-02 |
| PERFORMS_PROCESS | CQ-MF-01, forbidden OWNS_SPECIFICATION -> PERFORMS_PROCESS, V-W11-01/13 |
| HOSTS_PROCESS | CQ-MF-01, CQ-MF-06 (facility scope), V-W11-01 |
| INPUTS / OUTPUTS | CQ-MF-C04/C05, V-W11-01/12 |
| ManufacturingStep.usesEquipment / usesPlatforms | live-field preservation (interoperability with W08); no W11 CQ: kept because the live API exposes them; Fable may drop if W08 objects |
