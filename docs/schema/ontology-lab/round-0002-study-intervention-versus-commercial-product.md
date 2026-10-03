# Round 0002: Study Intervention versus Commercial Product

> **Integration decision (2026-10-03):** `ACCEPTED`. Rules R1 to R12 accepted into catalog 0.2.0; dose, duration and exposure ratio-band calibration and composite scoring DEFERRED (OPEN-QUESTIONS, evidence applicability 2). Catalog 0.2.0; see [proposal-index.md](./proposal-index.md).


Status: `ACCEPTED` (integration owner, 2026-10-03). Lane recommendation was: OPEN (Lane 2 recommendation: `ACCEPTED` for rules R1 to R12; `DEFERRED` for applicability threshold calibration)

## Header

- Round ID: 0002
- Date: 2026-10-03
- Builder: Lane 2 (organisms, compounds, mechanisms, interventions, studies, evidence applicability)
- Challenger: Lane 2 internal challenger; open to the review lane
- Owning module: `studies_and_evidence` (with seams into `substances_and_materials`, `products_and_formulations`)
- Candidate schema version: 0.2.0-candidate
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status: `ACCEPTED` (set by the integration owner on 2026-10-03; the lane recommendation is preserved below)

## Intent and competency questions

- Decision or workflow being supported: telling a reader whether a study supports a product they can buy today, on which dimensions the studied intervention and the product match, and what is missing; and telling an analyst which findings changed the evidence picture.
- In scope: binding of studied interventions to products; `EvidenceApplicability` dimensions (closes OPEN-QUESTIONS "Priority 1 evidence applicability" item 1); outcome ontology for biomarker, surrogate endpoint, intermediate clinical endpoint, clinical outcome (closes item 5); null primary results, favorable secondary and subgroup results, adverse events, shared datasets (partially closes item 4); evidence-change assessments; mapping of live `Study` registry fields to `TrialRegistration`/`RegistrationVersion`; mapping of live `Compound`/`CompoundForm`/`CONTAINS_COMPOUND_FORM`/`DoseMetadata` to catalog substance and material types.
- Out of scope: product variant vs formulation lifecycle (round 0001, Lane 3); assay comparability (round 0004); claim and speaker provenance (round 0006); correction event model (round 0007); private user applicability (round 0008). Mechanism steps are round 0003.
- Competency question IDs: `CQ-EV-04` (extended), `CQ-EV-05` (extended), `CQ-EV-06` (new), `CQ-ID-06` (new), `CQ-ST-01` to `CQ-ST-10` (new). See `lanes/lane2/competency-questions.md`.

## Case packet

All identifiers below were retrieved in this session through the ClinicalTrials.gov MCP tool, the PubMed MCP tool, or Tavily search/extract on 2026-10-03, unless marked unverified.

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| ClinicalTrials.gov NCT02678611 "A Study to Evaluate Safety and Health Benefits of Basis Among Elderly Subjects" | trial registry record (current version only) | primary outcomes: blood pressure, safety blood parameters, heart rate; secondary includes "Blood NAD+"; interventions "Basis 250", "Basis 500", "Placebo"; sponsor Elysium Health; collaborator KGK Science; enrollment 120; one listed site (London, Ontario); `has_results: false` | observed 2026-10-03 | registered design, status, outcomes as registered now; not results; not history (version history not retrievable, see REPORT) |
| PMID 29184669, doi:10.1038/s41514-017-0016-9, Dellinger et al., npj Aging Mech Dis 2017;3:17 | peer-reviewed publication | Results "Trial overview": 1X = 250 mg NR + 50 mg PT, 2X = 500 mg NR + 100 mg PT, daily 8 weeks; Methods "Intervention": 125 mg NR + 25 mg PT per capsule, four capsules daily (two bottles), gelatin capsules; Methods: "three sites ... London, Ontario (Canada), Orlando, Florida, and Irvine, California"; Methods: primary objective safety, secondary objectives NAD+ and lipids; Discussion: "The major efficacy endpoint of the trial was NAD+ concentration"; "Adverse events" section; "NRPT and lipids" (LDL-C within-group increases, baseline imbalance, BMI-stratified reanalysis); "Data availability": on request | published 2017-11-24 | what the paper reported about its intervention and results; not identity of later Basis formulations |
| PMID 30155270, doi:10.1038/s41514-018-0027-1, Author Correction | published erratum | adds "The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health (New York, NY)"; replaces reference 20 | published 2018-08-20 | the correction text; not who manufactured the NR material |
| C&EN 2018 "Firms feud over purported age-fighting molecule" (cen.acs.org/business/consumer-products/Firms-feud-over-Niagen-purported/96/i33) | trade press | "Until mid-2016, ChromaDex sold Elysium all the NR and pterostilbene it needed to make Basis, according to ChromaDex." | 2018 (issue 96/33) | that ChromaDex made this statement as reported; not that the trial lots used ChromaDex material |
| ClinicalTrials.gov NCT02712593 | trial registry | interventions "Niagen 100", "Niagen 300", "Niagen 1000", placebo; sponsor KGK Science, collaborator ChromaDex; primary outcome urinary methylnicotinamide; enrollment 140; start 2016-03-21; `has_results: false` | observed 2026-10-03 | registered design |
| PMID 31278280, doi:10.1038/s41598-019-46120-z, Conze et al., Sci Rep 2019;9:9772 | peer-reviewed publication | abstract: "A crystal form of NR chloride termed NIAGEN"; 100, 300, 1000 mg NR; whole-blood NAD+ +22%, +51%, +142%; "NR also did not elevate low density lipoprotein cholesterol" | published 2019-07-05 | reported design and results |
| truniagen.com/products/tru-niagen-300mg | manufacturer product page | Supplement Facts: serving 1 vegetarian capsule; "NIAGEN (nicotinamide riboside chloride) 300mg"; other ingredients MCC, hypromellose, vegetable magnesium stearate; site also lists Pro 1000 mg (2 capsules) and a 150 mg x2 capsule variant (third-party review, unverified) | observed 2026-10-03 | current label declaration as displayed |
| ClinicalTrials.gov NCT03464500 (ATLAS) | trial registry | title uses code "AMAZ-02"; interventions "Mitopure 500mg", "Mitopure 1000mg", placebo; primary outcome: power output on cycle ergometer at day 120; secondary includes isokinetic leg strength, 6-minute walk | observed 2026-10-03 | registered design |
| PMID 35584623, doi:10.1016/j.xcrm.2022.100633, Singh et al., Cell Rep Med 2022 (PMC9133463) | peer-reviewed publication | abstract: "do not notice a significant improvement on peak power output (primary endpoint)"; muscle strength ~12%; Methods: 4 softgels daily, 500 mg arm = 2 UA softgels + 2 placebo softgels | published 2022-05-17 | reported results and intervention |
| ClinicalTrials.gov NCT03283462 (ENERGIZE) | trial registry | primary outcomes: 6MWD change and ATPmax hand muscle; intervention "Mitopure"; title "AMAZ-02" | observed 2026-10-03 | registered design |
| PMID 35050355, doi:10.1001/jamanetworkopen.2021.44279, Liu et al., JAMA Netw Open 2022 | peer-reviewed publication | 1000 mg UA daily, 4 months, 66 adults 65 to 90; primary 6MWD and ATPmax "no significant improvement"; secondary muscle endurance improved | published 2022-01-04 | reported results |
| timeline.com/products/mitopure-softgels-vegan | manufacturer product page | "two vegan softgels daily for the recommended dose of Urolithin A (500mg of Mitopure)"; "Muscle strength increases by up to 12% after 16 weeks" | observed 2026-10-03 | current marketing and dose declaration |
| FDA "Surrogate Endpoint Resources for Drug and Biologic Development" and "Table of Surrogate Endpoints That Were the Basis of Drug Approval or Licensure" | regulatory guidance and table | definitions of surrogate endpoint (validated, reasonably likely, candidate); table row "Hypercholesterolemia / Serum LDL cholesterol / Traditional / Lipid-lowering" | observed 2026-10-03 | regulatory context-of-use for surrogate endpoints in drug approval |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "NRPT (commercially known as Basis)" | StudyIntervention (arm-level) | `hu:study-intervention:nct02678611-nrpt-1x`, `...-2x` | NCT02678611 | ACCEPTED as intervention; NOT resolved to current Basis FormulationVersion | "commercially known as" is a naming relation asserted by the sponsor-authored paper; it does not establish formulation identity in 2016 vs 2026 |
| "NR" in the 2016 trial | IngredientMaterial | `hu:material:nct02678611-nr-as-supplied` | none | UNRESOLVED; two competing `ResolutionHypothesis` records (ChromaDex NIAGEN; Elysium NR-E) | correction says Elysium provided the investigational product; C&EN reports ChromaDex's statement that it supplied Elysium's NR until mid-2016; trial ran Jan to Jul 2016 |
| "Elysium NR (Nicotinamide Riboside Chloride)" on current Basis label | BrandedIngredientMaterial | `hu:material:elysium-nr-e` (existing fixture) | none | PROPOSED | from existing Elysium fixture |
| "NIAGEN", "Niagen", "Tru Niagen" | BrandedIngredientMaterial (NIAGEN) vs Product (Tru Niagen) | `hu:material:chromadex-niagen`, `hu:product:tru-niagen` | none verified (no UNII lookup in session) | PROPOSED | brand of material and brand of product are distinct identities |
| "nicotinamide riboside chloride" | ChemicalSubstance + ChemicalForm (chloride salt; Conze: crystal form) | `hu:substance:nicotinamide-riboside-chloride`, `hu:chemical-form:nr-chloride-crystal-niagen` | UNII, PubChem not verified | PROPOSED | salt vs crystal form vs material are separate levels |
| "AMAZ-02", "Mitopure", "urolithin A" | code name, BrandedIngredientMaterial, ChemicalSubstance | `hu:material:amazentis-mitopure` | NCT03464500, NCT03283462 | PROPOSED alias AMAZ-02 = Mitopure via publication text "UA (Mitopure; Amazentis SA)" | registry title and intervention name differ inside one record |

## Builder proposal

### A. Binding rule (R1 to R3)

**R1.** The only authoritative path from a study to what was administered is
`Study -HAS_ARM-> StudyArm -ASSIGNS_INTERVENTION-> StudyIntervention -HAS_INTERVENTION_COMPONENT-> InterventionComponent -USES_INTERVENTION_MATERIAL-> IngredientMaterial | ProductLot | ProductVariant`.
The target of `USES_INTERVENTION_MATERIAL` is the material *as administered at study time*. A `ProductVariant` target is allowed only when the source asserts that a marketed variant was administered, and it carries `asReportedName`; it does not stand for the variant's current formulation.

**R2.** The only path from study evidence to a commercial use target (`Product`, `ProductVariant`, `FormulationVersion`, `ProductLot`) is an `EvidenceApplicability` assessment:
`EvidenceApplicability -HAS_EVIDENCE_TARGET-> StudyIntervention | Assertion` (exactly one) and `-ASSESSES_APPLICABILITY_TO-> FormulationVersion | ProductVariant | Product | ProductLot | IngredientMaterial | UserContext` (exactly one), with `-HAS_DIMENSION-> ApplicabilityDimension` (one per required dimension) and `-BASED_ON_EVIDENCE-> StudyResult | Publication | Study` (zero or more).
No `Study`, `StudyArm`, `StudyResult`, or `Publication` has any direct relationship to `Product`, `ProductVariant`, or `FormulationVersion`. The live `Study -EVALUATES-> Product` edge is a seam (section G of live-schema-decisions) and must never be written for a current product.

**R3.** `Organization -PROVIDES_INVESTIGATIONAL_PRODUCT-> StudyIntervention` is a new asserted predicate. It does not imply `SUPPLIES_INGREDIENT_MATERIAL` or `MANUFACTURES_PRODUCT`. Failing case: the Author Correction (PMID 30155270) says Elysium provided the NRPT capsules; ChromaDex says (C&EN) it sold Elysium the NR until mid-2016. Both can be true; collapsing "provided" into "made the NR" deletes the supplier question that decides material identity.

### B. Applicability dimensions (R4, closes OPEN-QUESTIONS evidence applicability 1)

`EvidenceApplicability` keeps its identity and method version. Its dimension judgements move to `ApplicabilityDimension` nodes (archetype `EvidenceAssessment`), because each dimension needs its own sources, missing facts, and verdict history. The existing flat properties (`identityMatch`, `doseMatch`, ...) become a derived projection (`# CHANGE` in catalog-patch).

Every dimension has a categorical `verdict` in {`MATCH`, `PARTIAL`, `MISMATCH`, `UNKNOWN`, `NOT_ASSESSED`, `NOT_APPLICABLE`, `NOT_SCORED`}. `UNKNOWN` means assessed and the facts are missing; `NOT_ASSESSED` means nobody looked. They are never merged.

| Dimension | Class | Value fields | Verdict rule (method `applicability-v0.1`) |
|---|---|---|---|
| `MATERIAL_IDENTITY` | categorical, ordered | `identityLevel` | `SAME_LOT`, `SAME_FORMULATION_VERSION` -> MATCH; `SAME_VARIANT_FORMULATION_UNRESOLVED`, `SAME_BRANDED_MATERIAL_SAME_SPEC`, `SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED`, `SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL` -> PARTIAL; `SAME_SUBSTANCE_MATERIAL_UNRESOLVED` -> UNKNOWN; `SAME_SUBSTANCE_DIFFERENT_FORM`, `RELATED_SUBSTANCE`, `DIFFERENT` -> MISMATCH (PARTIAL only with linked bridging PK evidence) |
| `ACTIVE_COMPOSITION` | categorical | `compositionRelation` (`SAME_ACTIVES`, `EVIDENCE_SUBSET_OF_TARGET`, `TARGET_SUBSET_OF_EVIDENCE`, `DIFFERENT_ACTIVES`) | SAME_ACTIVES -> MATCH; subset -> PARTIAL; different -> MISMATCH |
| `DOSE` | continuous | `evidenceValue`, `targetValue`, `unitCode`, `evidenceQuantityBasis`, `targetQuantityBasis`, `evidenceMassBasis`, `targetMassBasis`, `ratio` | `ratio` is computed only when quantity basis (per day) and mass basis (salt, active moiety, material as is) are equal; otherwise `ratio` is null and the verdict is at most PARTIAL. Ratio bands are method-versioned (calibration deferred) |
| `DOSAGE_FORM` | categorical | `evidenceCategory`, `targetCategory` | equal -> MATCH, else MISMATCH; excipient differences go in `rationale` |
| `ROUTE` | categorical | `evidenceCategory`, `targetCategory` | equal -> MATCH |
| `SCHEDULE` | continuous + categorical | `evidenceValue`/`targetValue` doses per day; timing in `evidenceCategory` | ratio of doses per day; unknown label directions -> UNKNOWN |
| `DURATION` | continuous | `evidenceValue`, `targetValue` in days (`unitCode` `d`), `ratio` | intended use longer than studied -> PARTIAL (extrapolation); open-ended target -> PARTIAL with `targetValue` null |
| `POPULATION` | categorical + explanation | `populationRelation` (`SAME`, `OVERLAPS`, `DISJOINT`, `UNKNOWN`) | explanation lists age, sex, health status, BMI differences; person-level comparison only for `UserContext` targets (Lane 5) |
| `COMPARATOR` | categorical | `evidenceCategory` (`PLACEBO`, `ACTIVE`, `NO_TREATMENT`, `HISTORICAL`, `NONE`) | relative to the target decision |
| `OUTCOME_RELEVANCE` | categorical | `evidenceCategory` = endpoint class from `EndpointClassification` | clinical outcome -> MATCH for a clinical target; biomarker-only -> PARTIAL; no relevant outcome -> MISMATCH |
| `STUDY_DESIGN_AND_QUALITY` | categorical | reference to an `EvidenceStrengthAssessment` | copied level, never recomputed here |
| `EXPOSURE` | continuous + categorical | see round 0003 | required when the evidence target is a mechanism assertion |
| `BACKGROUND_CONTEXT` | explanation-only | `rationale` | `NOT_SCORED`; e.g. trial excluded B3 supplements and lipid-lowering drugs |
| `RECENCY_AND_CORRECTIONS` | explanation-only | `rationale` | `NOT_SCORED`; corrections, retractions, registry/publication discrepancies |

Explanation-only dimensions never enter a composite. A composite `overallScore` may exist only with `methodVersion` and only when every required dimension is present (V-204, V-207).

### C. Outcome ontology (R5, closes OPEN-QUESTIONS evidence applicability 5)

Four layers, each with one owner:

1. **What was measured** (`OutcomeDefinition.measureKind`, observed from the protocol or registry): `BIOMARKER`, `PERFORMANCE_OUTCOME`, `PATIENT_REPORTED_OUTCOME`, `CLINICIAN_REPORTED_OUTCOME`, `OBSERVER_REPORTED_OUTCOME`, `CLINICAL_EVENT`. A biomarker outcome links `MEASURES_BIOMARKER -> Biomarker` (analyte in a matrix, owned by diagnostics).
2. **How the study ranked it** (priority): per-source `Assertion` with predicate `DECLARES_OUTCOME_PRIORITY` (`PRIMARY`, `SECONDARY`, `OTHER_PRESPECIFIED`, `POST_HOC`, `SAFETY`). The registered priority is a derived projection from the earliest `RegistrationVersion`. Failing case: NCT02678611 lists blood NAD+ as secondary; the paper's Methods agree; its Discussion calls NAD+ "the major efficacy endpoint". One property cannot hold both; two attributed assertions can.
3. **What role it plays in an inference** (`EndpointClassification`, an `EvidenceAssessment`): `endpointClass` in {`BIOMARKER_NOT_SURROGATE`, `SURROGATE_ENDPOINT`, `INTERMEDIATE_CLINICAL_ENDPOINT`, `CLINICAL_OUTCOME`}; for biomarkers `biomarkerCategory` (BEST categories: `SUSCEPTIBILITY_RISK`, `DIAGNOSTIC`, `MONITORING`, `PROGNOSTIC`, `PREDICTIVE`, `PHARMACODYNAMIC_RESPONSE`, `SAFETY`); for surrogates `surrogateValidationLevel` in {`VALIDATED`, `REASONABLY_LIKELY`, `CANDIDATE`, `NOT_ESTABLISHED`} plus context of use `contextDiseaseOrUse`, `contextPopulation`, `contextInterventionMechanism` (the columns of the FDA surrogate table). Surrogate status transfers only when the context of use matches.
4. **Whether it matters to a person**: "patient-important" is derived (`CLINICAL_OUTCOME` or `INTERMEDIATE_CLINICAL_ENDPOINT` that measures how a person feels, functions, or survives). Importance to a specific person is Lane 5 private context.

Minimal pair from one trial (NCT02678611): whole-blood NAD+ (+40% at 1X) is `BIOMARKER_NOT_SURROGATE`, `PHARMACODYNAMIC_RESPONSE`, no context in which it is an established surrogate; LDL-C (small within-group increase) is a `SAFETY` biomarker in this study, and the FDA table lists serum LDL-C as a surrogate endpoint for traditional approval of *lipid-lowering* drugs in hypercholesterolemia. NRPT is not a lipid-lowering drug and the population was healthy, so the classification for this study records `contextMatch: PARTIAL` and points to the FDA context rather than labeling LDL-C "a validated surrogate" outright.

### D. Null primary, favorable secondary and subgroup results, adverse events (R6, R7)

**R6.** `StudyResult` gains `analysisKind` (`PRIMARY_PRESPECIFIED`, `SECONDARY_PRESPECIFIED`, `SUBGROUP_PRESPECIFIED`, `SUBGROUP_POST_HOC`, `EXPLORATORY`, `SAFETY`), `comparisonKind` (`BETWEEN_ARM`, `WITHIN_ARM_CHANGE`, `ARM_DESCRIPTIVE` for per-arm counts such as adverse events), `statisticalConclusion` (`SIGNIFICANT_FAVORABLE`, `SIGNIFICANT_UNFAVORABLE`, `NOT_SIGNIFICANT`, `NOT_TESTED`, `NOT_REPORTED`), `multiplicityAdjusted` (boolean, null = not reported), and `RESULT_FOR_ARM -> StudyArm`. "Not significant" is not "no effect": the interpretation is a BellLabs `ResultInterpretation` assessment with `interpretation` in {`EFFECT_DETECTED`, `INCONCLUSIVE`, `EVIDENCE_OF_NO_MEANINGFUL_EFFECT`}, where the last requires a stated margin (equivalence bound or MCID with source).

Claim-level synthesis (`EvidenceSynthesis`) cites results through `INCLUDES_RESULT {inputRole}` with `inputRole` in {`CONFIRMATORY`, `SUPPORTIVE`, `HYPOTHESIS_GENERATING`, `CONTRADICTING`, `SAFETY`}. Rule: when a study's primary prespecified result is `NOT_SIGNIFICANT`, its secondary, subgroup, within-arm, or post hoc results may enter only as `SUPPORTIVE` or `HYPOTHESIS_GENERATING` (V-215, V-216).

Cases: ATLAS (NCT03464500) primary peak power output not significant; leg strength (~12%) secondary favorable. The Timeline product page says "Muscle strength increases by up to 12% after 16 weeks" without the primary result. ENERGIZE (NCT03283462) primary 6MWD and ATPmax not significant; secondary muscle endurance favorable. Basis trial: the paper's diastolic blood pressure, ALT, and mobility findings are `WITHIN_ARM_CHANGE` results; LDL-C differences were confounded by baseline imbalance and reanalyzed by BMI strata (`SUBGROUP_POST_HOC`).

**R7.** Adverse events are `AdverseEventResult` (label `StudyResult:AdverseEventResult`) per arm, with `eventTerm`, optional `eventTermCode` (MedDRA when reported), `participantsAffected`, `participantsAtRisk`, `eventCount`, `seriousness`, `relatednessAssessor`, and `collectionMethod` (`SYSTEMATIC`, `SPONTANEOUS`, `NOT_DESCRIBED`). "No serious adverse events were reported" is `participantsAffected: 0`, `seriousness: SERIOUS`, with the collection method stated; a paper without an AE section yields no `AdverseEventResult` and an explicit `notReported` on the synthesis, never a zero. Cross-study disagreement (Basis LDL-C increase at 250/500 mg NR + PT in 60 to 80 year olds vs Conze "did not elevate LDL" at 100 to 1000 mg NIAGEN in overweight 40 to 60 year olds) is not a contradiction until an `EvidenceSynthesis` records both with their applicability; the material, co-ingredient, and population dimensions differ.

### E. Shared datasets and non-independence (R8)

`Dataset` (Entity, live type kept) with `Study -PRODUCED_DATASET-> Dataset` and `Publication -ANALYZES_DATASET {analysisRole}-> Dataset` (`PRIMARY_REPORT`, `SECONDARY_ANALYSIS`, `POOLED_ANALYSIS`, `REANALYSIS`). Independence is derived: two results whose publications share a `Study` or a `Dataset` may not both enter a synthesis as `INDEPENDENT_REPLICATION` (V-218). The Basis paper's Data Availability says data are available on request; that becomes `Dataset {accessLevel: 'ON_REQUEST'}` with no accession `Identifier`.

### F. "Which findings from a stated period changed the evidence picture, by which criteria" (R9)

`EvidenceSynthesis` is a versioned `EvidenceAssessment` about one claim (`ASSESSES_CLAIM -> Assertion` or a live `Claim` via Lane 4's seam), with `verdict` (`adjudicationVerdict` enum), `evidenceCutoff` (latest publication date considered), `recordedAt`, `methodVersion`, and `SUPERSEDES` to the prior version. A new version records `TRIGGERED_BY {criterionCode, effectOnVerdict}` to each new `StudyResult`, `Publication` (including corrections and retraction notices), or `RegistrationVersion` that changed it. `criterionCode` is from the method's criteria list (e.g. `NEW_RANDOMIZED_PRIMARY_RESULT`, `HUMAN_DIRECT_MEASUREMENT_NULL`, `CORRECTION_OR_RETRACTION`, `REGISTRY_RESULTS_POSTED`, `OUTCOME_PRIORITY_DISCREPANCY`); `effectOnVerdict` in {`STRENGTHENED`, `WEAKENED`, `REVERSED`, `NO_CHANGE`}.

"Findings published in period P" filters `TRIGGERED_BY` targets by `publishedAt`; "what BellLabs learned in period P" filters synthesis versions by `recordedAt`. Both answers are needed and differ when evidence arrives late (Lane 5 time rules apply). Kernel-change request KCR-2a: `SUPERSEDES` between `EvidenceAssessment` nodes and `recordedAt` on `EvidenceAssessment` (today only `createdAt`). Failing case without it: the 2019 synthesis "NR improves skeletal muscle mitochondrial function in older humans" moved from `INSUFFICIENT` (mouse evidence only) to a weaker position after Elhassan et al. 2019 (PMID 31412242) measured unchanged mitochondrial respiration in aged human muscle; overwriting the assessment loses what BellLabs concluded in between.

### G. Registry fields (R10)

| Live `Study` field | Decision | Catalog home | Reason |
|---|---|---|---|
| `registryNamespace`, `registryId` | seam (materialized key) | `TrialRegistration {registry, registrationId}` + `Identifier` | one study may have several registrations (CT.gov, ISRCTN); identity lives on the registration |
| `overallStatus`, `registrySyncedAt` | move | `RegistrationVersion.overallStatus`, `.observedAt` | status changes; the Study node may hold only a derived current view with `projectionOfRegistrationVersionUid` |
| `enrollmentCount`, `sampleSizeText` | move + split | `RegistrationVersion.enrollmentCount`, `.enrollmentCountType` (`ACTUAL`, `ESTIMATED`); verbatim text on `StudyPopulation` | live field loses the actual/estimated distinction; the paper reports ITT 118 analyzed of 120 randomized for NCT02678611 |
| `hasResults` | move + rename | `RegistrationVersion.resultsPosted`, `.resultsFirstPostedAt` | `false` means "no results section on the registry as observed", not "no results exist": NCT02678611 is `false` while PMID 29184669 reports results |
| `startDate`, `primaryCompletionDate`, `completionDate` | move | `RegistrationVersion` with `*DateType` (`ACTUAL`, `ANTICIPATED`) | registered dates vs reported conduct dates are separate assertions |
| `studyType`, `allocation`, `interventionModel`, `masking`, `primaryPurpose`, `studyPhase`, `fdaRegulatedDrug`, `fdaRegulatedDevice` | move | `RegistrationVersion` | registered design; a publication's reported design is an `Assertion` |
| `countries` | move | `RegistrationVersion.siteCountries` | registry lists one Canadian site; the paper reports three sites (Canada and US). Disagreement is preserved, not overwritten |
| `pmid`, `doi`, `canonicalUrl` | merge out | `Publication -REPORTS_ON-> Study` | a study has many publications (article + correction) |
| `evidenceLevel` | move | `EvidenceStrengthAssessment {scheme, level, methodVersion}` | assessment with criteria, never a node attribute |
| `startDate` etc. as conduct facts | keep as seam | Study conduct period via `Assertion` (predicate `STUDY_CONDUCTED_DURING`) | the paper says recruitment began January 2016 and in-human phase completed by July 2016 |

What the registry can and cannot establish (CQ-ST-08): it can establish registered outcomes, arms, status, and posted results as of an observation; it cannot establish that results are unpublished, that the reported sites match, or which material was used. Registry record history was not retrievable in this session (direct ClinicalTrials.gov API access was refused by the egress proxy; the MCP tool returns only the current version). So any claim about when NCT02678611's outcomes were registered is unverified here.

### H. Live Compound and CompoundForm vs catalog substances and materials (R11)

| Live | Decision | Catalog name that wins | Reason and failing case |
|---|---|---|---|
| `Compound` (name, `casNumber`, `molecularFormula`, `molecularWeight`, `compoundClass`, `commonName`) | merge into `ChemicalSubstance`; live `Compound` stays as the GraphQL projection type for nodes that denote one defined substance; split out nodes that denote mixtures or materials | `ChemicalSubstance` | `casNumber` becomes an `Identifier` (scheme CAS); `molecularWeight` is calculated from structure authority. Failing case: a live `Compound` named "NRPT" denotes a two-active combination, not a substance |
| `CompoundForm` (`dosageForm`, `concentrationText`, `IS_FORM_OF`) | split three ways | `ChemicalForm` (salt, crystal, hydrate); `IngredientMaterial` (supplier/brand material); dosage form to `ProductVariant.dosageForm` / `StudyIntervention.dosageForm`; concentration to component quantities | Failing case: "NIAGEN" is a crystal form of NR chloride (Conze abstract) and a branded material; "Tru Niagen 300 mg capsule" is a product variant. One `CompoundForm` node cannot keep these apart |
| `IS_FORM_OF` (CompoundForm -> Compound) | refine | `FORM_OF_SUBSTANCE` (ChemicalForm -> ChemicalSubstance), `HAS_CHEMICAL_FORM` (IngredientMaterial -> ChemicalForm) | catalog had no ChemicalForm-to-substance edge; added |
| `Product -CONTAINS_COMPOUND_FORM {DoseMetadata}-> CompoundForm` | seam: derived projection only | `FormulationVersion -HAS_INGREDIENT_COMPONENT-> IngredientComponent -USES_MATERIAL-> IngredientMaterial`; derived `CONTAINS` | composition without a formulation version has no time; Lane 3 owns the product side |
| `DoseMetadata.dose`, `.doseUnit` | move | `IngredientComponent.quantity`, `.unitCode` | |
| `DoseMetadata.role`, `.componentName` | move | `IngredientComponent.role`, `.declaredAs` | |
| `DoseMetadata.standardizedTo` | move | Lane 3 standardization marker | |
| `DoseMetadata.quantity` (Int) | drop | none | ambiguous (count of units?) with no documented meaning |
| mass basis (missing in live) | add | `InterventionComponent.massBasis` (this round); `IngredientComponent.massBasis` requested from Lane 3 | NR "250 mg" in the paper vs "NR chloride 250 mg" on the label cannot be compared without it |
| `Compound -MODULATES-> MolecularEntity`, `CompoundForm -AFFECTS_MECHANISM-> Mechanism` | derived projection of mechanism `Assertion`s | round 0003 | |
| `Compound -HAS_SAFETY_SIGNAL-> SafetySignal` | seam | `safety_and_constraints` module | deferred |

### I. Where assessment-like attributes move (R12)

| Live attribute | Moves to | Kind |
|---|---|---|
| `Study.evidenceLevel` (String) | `EvidenceStrengthAssessment {scheme, level, criteria, methodVersion}` -ASSESSES-> Study or EvidenceSynthesis | evidence assessment |
| `OutcomeResult.isClinicallyMeaningful` (Boolean) | author claim: `Assertion` predicate `RESULT_CLINICALLY_MEANINGFUL` (e.g. Singh et al. "clinically meaningful improvements" on 6MWT); BellLabs: `ResultInterpretation {meaningfulnessVerdict, thresholdValue, thresholdUnit}` -USES_THRESHOLD_SOURCE-> SourceLocator | assertion vs evidence assessment |
| `EvidenceStrength` enum on `AssociationMetadata`, `SafetyMetadata`, `TreatmentTargetMetadata`, `SafetySignal`, `Claim` | `EvidenceStrengthAssessment`; edges keep the value only as a derived projection with `assessmentUid` | evidence assessment |
| `OutcomeResult.isStatisticallySignificant` | `StudyResult.statisticalConclusion` (observed from source) | observed |
| `InterventionArmMetadata.confidence`, `AssociationMetadata.citation` | confidence vector dimensions; `SUPPORTED_BY -> SourceLocator` | kernel |

### Proposed terms, owners, relationships, rules (summary)

- New nodes: `ApplicabilityDimension`, `EndpointClassification`, `ResultInterpretation`, `EvidenceSynthesis`, `EvidenceStrengthAssessment` (all `EvidenceAssessment`); `AdverseEventResult` (`InformationArtifact`, parent `StudyResult`); `Dataset` (`Entity`).
- New relationships: `HAS_EVIDENCE_TARGET`, `HAS_DIMENSION`, `RESULT_FOR_ARM`, `MEASURES_BIOMARKER`, `CLASSIFIES_OUTCOME`, `INTERPRETS_RESULT_OF` (named to avoid clash with quality `INTERPRETS_RESULT`), `INCLUDES_RESULT`, `ASSESSES_CLAIM`, `TRIGGERED_BY`, `SUPERSEDES` (KCR-2a), `PRODUCED_DATASET`, `ANALYZES_DATASET`, `FORM_OF_SUBSTANCE`, `CORRECTS`/`RETRACTS` (proposed here, ownership to confirm with Lanes 4 and 5); predicates `PROVIDES_INVESTIGATIONAL_PRODUCT`, `DECLARES_OUTCOME_PRIORITY`, `RESULT_CLINICALLY_MEANINGFUL`, `STUDY_CONDUCTED_DURING`, `ADMINISTERED_AS_COMMERCIAL_PRODUCT`.
- Identity rule: a study intervention material is identified at study time; material equivalence across time is a `ResolutionHypothesis`, never a name match.
- State/version rule: `StudyIntervention`, `InterventionComponent`, `OutcomeDefinition` are states of a study's design as reported by a source; registry design lives in `RegistrationVersion`.
- Valid-time rule: study conduct period is an assertion; registry versions carry `versionDate` (registry) and `observedAt` (BellLabs).
- Recorded-time rule: assessments carry `recordedAt`; syntheses supersede, never overwrite.
- Unknown-time rule: unknown registry history stays null; `observedAt` never substitutes for `versionDate`.
- Provenance rule: every dimension verdict other than `NOT_ASSESSED` cites `SUPPORTED_BY` locators or `CONSIDERS` assertions.
- Projection consequence: the live `EVALUATES` union edge and `CONTAINS_COMPOUND_FORM` become read-only projections; additive GraphQL types in `live-schema-decisions.md`.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| C2-01 | Ontological | The paper says NRPT is "commercially known as Basis". Isn't that enough to link the study to Basis? | high | Load fixture; run V-201. A direct `EVALUATES` edge makes the 2016 study apply to the 2026 label, whose NR material is a different named material (`NR-E`) and whose supplier in 2016 is disputed | Rejected link. Naming relation becomes an `Assertion` (`ADMINISTERED_AS_COMMERCIAL_PRODUCT` with `asReportedName`); applicability goes through `EvidenceApplicability` with `MATERIAL_IDENTITY = UNKNOWN` |
| C2-02 | Operational | Twelve dimension nodes per assessment is heavy. Keep flat enum properties | medium | Basis dose dimension must cite two sources (paper Methods; current label) and list the missing mass-basis fact. A flat `doseMatch` property cannot cite or list | Keep dimension nodes; flat properties become a derived projection for filtering |
| C2-03 | Epistemic | Conze (NIAGEN 300 mg) and Tru Niagen 300 mg share material brand and nominal dose. Is that MATCH? | high | Material identity requires the specification version at trial time; it is not recorded. Dose: abstract says "300 mg NR", label says "NR chloride 300 mg" | `SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED` -> PARTIAL; dose PARTIAL with `ratio` null. Contrast: same trial vs Basis -> `SAME_SUBSTANCE_DIFFERENT_MATERIAL` plus `ACTIVE_COMPOSITION = TARGET_SUBSET...` mismatch. Minimal pair encoded in fixture |
| C2-04 | Linguistic | "No serious adverse events were reported" vs "No adverse events occurred" (CQ catalog pair 4) | high | Represent Basis AE section: 66 AEs, 45 participants, 0 serious reported, systematic self-report collection | `AdverseEventResult` with counts and `collectionMethod`; V-217 rejects zeros without collection method |
| C2-05 | Epistemic | Registry `hasResults: false` will be read as "unpublished" | high | NCT02678611 `has_results: false`; PMID 29184669 reports results | `resultsPosted` with explicit meaning; forbidden implication FI-203 |
| C2-06 | Temporal | Registry primary outcomes may have been edited after completion; with only the current version we cannot tell | medium | Requires CT.gov history API (blocked in this session) | `RegistrationVersion` per observed version; registered priority derived from the earliest version; open question OQ-L2-03 |
| C2-07 | Ontological | Surrogate status is a property of a biomarker (LDL-C is a surrogate) | high | FDA table row is bound to disease/use, population, and drug mechanism (lipid-lowering). NRPT is none of these | `EndpointClassification` with context-of-use fields; FI-204 |
| C2-08 | Operational | Within-arm significance is what papers report; why not treat it as efficacy? | medium | Basis DBP, ALT, mobility; Basis LDL-C baseline imbalance | `comparisonKind`; V-216 |
| C2-09 | Identity | Live union `StudyIntervention` collides with catalog node `StudyIntervention` in GraphQL | medium | Additive delta cannot declare a type with the union's name | GraphQL projection type `ArmIntervention` with `@node(labels: ["StudyIntervention", "VersionedState"])`; catalog name wins in the semantic contract |
| C2-10 | Epistemic | A product page cites a secondary result as the headline ("up to 12%") | medium | Timeline page vs ATLAS primary null | Lane 4 owns the claim record; this round supplies `analysisKind` so the claim can be checked against the result's role (CQ-ST-05) |

## Linguistic analysis

- Source wording: "we report this first-in-humans clinical trial designed to assess the safety and efficacy of a repeat dose of NRPT (commercially known as Basis)"; "The major efficacy endpoint of the trial was NAD+ concentration"; "No serious adverse events were reported"; "the data suggest that NRPT 1X may improve liver function"; "The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health".
- Normalized propositions: `ADMINISTERED_AS_COMMERCIAL_PRODUCT(StudyIntervention NRPT, asReportedName 'Basis')`; `DECLARES_OUTCOME_PRIORITY(OutcomeDefinition NAD+, 'PRIMARY')` attributed to the Discussion locator, alongside `'SECONDARY'` from the registry and Methods; `AdverseEventResult(seriousness SERIOUS, participantsAffected 0)`; `PROVIDES_INVESTIGATIONAL_PRODUCT(Elysium, StudyIntervention)`.
- Negation: "no serious AEs were reported" is a reported zero under a stated collection method, not absence.
- Modality/hedging: "may improve liver function" is `basisKind: HYPOTHESIS` (round 0003), not a result.
- Quantification: "approximately 40%" is a `StudyResult.estimate` with `estimateQualifier: APPROXIMATE`.
- Scope ambiguity: "NR" in the paper does not state salt vs cation mass; recorded as `massBasis: UNSPECIFIED`.
- Presuppositions not licensed: "commercially known as Basis" presupposes that the later product is the same intervention; not licensed.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | high for doses and arms (Methods text) | manual read | PMC5701244 Methods | none |
| Resolution | UNRESOLVED for trial NR material | ResolutionHypothesis v0.1 | correction PMID 30155270; C&EN | none |
| Source reliability | registry authoritative for registered design; paper for reported results; manufacturer page for current label | source-registry 0.1 | entries in lane2 source-registry.yaml | none |
| Evidence strength | not assessed here | n/a | n/a | n/a |
| Applicability | Basis 1X -> current Basis: MATERIAL_IDENTITY UNKNOWN, DOSE PARTIAL | applicability-v0.1 | fixture | deferred (OQ evidence applicability 2) |
| Adjudication | PROPOSED | n/a | n/a | n/a |
| Decision | not in scope | n/a | n/a | n/a |

## Schema projection

- Projection request ID: `proj-req-l2-0002`
- Selected modules: `studies_and_evidence`, `substances_and_materials`, `products_and_formulations` (endpoints only), `provenance`, `identity_resolution`
- Closure additions: `Identifier`, `ResolutionHypothesis`, `SourceLocator`, `Biomarker` (endpoint only)
- Explicit exclusions: `UserContext` internals (Lane 5), `Claim` internals (Lane 4)
- Budget result: not computed (no projection tooling in this environment)
- Projection ID/digest: not generated

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/study-vs-product-mismatch.cypher` sections 1 to 6 | loads; validation queries return zero rows | statically checked only; no Neo4j in environment | not run |
| Negative fixture | commented NEGATIVE TEST block in the fixture | V-201/F-1 return rows when uncommented | statically checked | not run |
| Minimal pair | Conze NIAGEN -> Tru Niagen vs Conze NIAGEN -> Basis | different `identityLevel` and `ACTIVE_COMPOSITION` verdicts | encoded | not run |
| Temporal correction | Author Correction PMID 30155270 | `CORRECTS` edge; original assertions retained | encoded | not run |
| Identity collision | trial NR material vs current NR-E | competing hypotheses, no merge | encoded | not run |
| Extraction evaluation | none | n/a | n/a | open |
| Retrieval evaluation | CQ-EV-04, CQ-ST-05 query patterns | illustrative | written | not run |
| Migration compatibility | live-schema-decisions.md | additive delta only | written | review |

## Decision

- Outcome: recommend `ACCEPTED` for R1 to R12; `DEFERRED` for dose/duration ratio bands and composite scoring calibration.
- Accepted semantic rules: R1 to R12 above; forbidden implications FI-201 to FI-207 in `catalog-patch.yaml`.
- Rejected alternatives: (a) direct `Study -EVALUATES-> Product` with a match-quality property (fails C2-01); (b) flat dimension properties only (fails C2-02); (c) surrogate status as a `Biomarker` property (fails C2-07); (d) `Study.pmid` and `Study.hasResults` as identity-node facts (fail C2-05 and the article-plus-correction case).
- Residual uncertainty: trial-time NR supplier for NCT02678611; mass basis of "NR" doses in the Basis and Conze papers; registry history; MCID sources for ATLAS and ENERGIZE outcomes.
- Required catalog/schema changes: `lanes/lane2/catalog-patch.yaml`.
- Required ingestion changes: extract per-arm components with `massBasis`; extract outcome priority per source; extract AE tables with collection method; never write `EVALUATES` to a current product.
- Required retrieval/API/MCP changes: applicability answers must list dimensions with `UNKNOWN` and their `missingFacts`; result answers must carry `analysisKind` and `comparisonKind`.
- Changelog and migration references: coordinator to record under 0.2.0.
