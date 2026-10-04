# W02 CQ coverage matrix

Answerability codes are from `competency-questions.md`: A = answerable, Q = answerable with qualifications. Query ids are in `fixtures/queries-W02.cypher`; validator ids are in `operations.cypher`. "Executed" means the query ran on embedded Neo4j 5.26.31 Community with the W02 fixtures loaded (06-fixtures-and-queries.md).

## 1. Existing CQs

| CQ (priority, answerability) | Example answer (from fixtures) | Distinction | Evidence requirement | Node / property / edge / edge property | Query shape | Prevented failure |
|---|---|---|---|---|---|---|
| **CQ-PF-01** (Essential, A for US) | "'NIAGEN (nicotinamide riboside chloride)' 300 mg is LISTED_INGREDIENT_AS_LISTED, mass basis SALT_FORM. Realized substance NR chloride (UNII 8XM2XT8VWI). Active moiety NR (UNII 0I8H2M0L7N). NR cation 263.4 mg is CALCULATED by w02-active-moiety-mass-v1 from five input assertions (MW 290.70 and 255.25, PubChem)." | Declared vs calculated vs measured; salt vs moiety; nutrient vs source | Label locator; GSRS active-moiety record; PubChem MW snapshots | `ChemicalSubstance`, `HAS_ACTIVE_MOIETY`, `REALIZES_SUBSTANCE`, Assertion `HAS_MOLECULAR_WEIGHT` (SR-04), CALCULATED `QUANTITATIVELY_CONTAINS` assertion with `DERIVED_FROM_ASSERTION`; `Nutrient` for NUTRIENT_AS_NUTRIENT referents | Q-01 (executed) | Comparing 300 mg salt with 300 mg cation; storing a calculated amount as a label declaration (V-330, V-W02-08) |
| **CQ-ID-03** (Foundational, A) | "Mosaic tomato fruit extract PROVIDES lycopene, phytoene, phytofluene, tocopherols (label) and beta-carotene (science page). Amount of lycopene: NOT_STATED." | `DECLARATION_IDENTIFIES_MATERIAL` / `REALIZES_SUBSTANCE` / `PROVIDES_CONSTITUENT` / `QUANTITATIVELY_CONTAINS` | Verbatim label line with locator | `MaterialMixture`, `BotanicalPreparation`, `PROVIDES_CONSTITUENT` → `MaterialContentTarget`, `Constituent` (classes) | Q-02 (executed); QS-1a for the trace | Reading "providing" as "contains N mg"; a second identity for lycopene (V-W02-01, V-112) |
| **CQ-ID-04** (Foundational, Q) | "NR chloride: UNII 8XM2XT8VWI (primary), CAS 23111-00-4, PubChem 90480033, from GSRS record version 18 retrieved 2026-10-04T00:55Z. NR: UNII 0I8H2M0L7N, CAS 1341-23-7, PubChem 439924, ChEBI 15927." | Identifier vs name; authority release on the snapshot; salt identifiers vs moiety identifiers | Authority record snapshot | `Identifier` (W00) via `HAS_IDENTIFIER` (IdentifierLinkProperties); materialized `pubchemCid`, `inchikey`, `casNumber` | Q-03 (executed); QS-8 for candidates | Matching the paper's "NR" to a UNII by name; using the salt CAS for the moiety (fx-06 collision) |
| **CQ-ID-05** (Foundational, Q), material side | "NIAGEN at 2016-06-01: GRN 635 spec version (end unknown). At 2020-06-01: two candidate versions (2015; 2019, inferred) → specification unresolved. Viewed as of a recording before 2026-10-04T03:00Z: only the 2015 version." | Specification change vs material change vs supplier change | Spec documents with dates | One `BrandedIngredientMaterial`; W11 `SpecificationVersion` via `GOVERNED_BY_SPECIFICATION` (asserted, valid time) | Q-05a/b/c/d (executed) | Re-minting a material per spec (V-W02-05); a late fact rewriting the past view |
| **CQ-ID-06** (Essential, Q) | "Trial NR (NCT02678611) vs NIAGEN: same active moiety. The trial material is stated only at moiety level, so the salt is unresolved → suggested SAME_SUBSTANCE_MATERIAL_UNRESOLVED. NIAGEN vs Supplier X amorphous NRC (synthetic) → SAME_SUBSTANCE_DIFFERENT_FORM." | Branded material vs chemical form vs substance vs moiety | Intervention locator, label locator, authority records | `REALIZES_SUBSTANCE` (exact stated substance), `HAS_ACTIVE_MOIETY`, `HAS_CHEMICAL_FORM`, `ChemicalForm`; W00 `ResolutionHypothesis` for supplier | Q-04 (executed); W10 maps facts to `materialIdentityLevel` (SR-09) | Name or substance match reported as material identity (INV-008); moiety-only statement read as "different form" (false MISMATCH) |
| **CQ-ST-01** (Essential, A), material side | "LGG arm material: MicrobialPreparation HAS_STRAIN GG (ATCC 53103; CCUG 34291; LMG 18243), current species Lacticaseibacillus rhamnosus (NCBI 47715); viability NOT_STATED." | Strain vs species vs preparation; count vs viability | Registry intervention locator; culture-collection record | `MicrobialPreparation.viabilityState`, `HAS_STRAIN`, `MicrobialStrain`, `STRAIN_OF`; amounts stay on W09 `InterventionComponent` | Q-06 (executed) | Species-level evidence transferred to a strain; a count read as viable CFU |
| **CQ-ST-02** (Essential, A) | "Tru Niagen 300 mg and the NCT02712593 arm share NIAGEN (spec version unknown). Basis shares only the moiety NR, and its trial material's salt is unresolved." | Path type determines identity level | Components with locators on both sides | `USES_MATERIAL` (W04), `USES_INTERVENTION_MATERIAL` (W09), `REALIZES_SUBSTANCE`, `HAS_ACTIVE_MOIETY`, `HAS_CHEMICAL_FORM` | Q-04 path facts (executed); QS-3 in W10 | Substance-only path reported as product evidence (INV-008) |

## 2. Candidate CQs (CANDIDATE; not existing ids)

| Id | Question | Rationale / failing case | Elements | Query |
|---|---|---|---|---|
| **CQ-ID-C01** | Is a declared ingredient a salt or solvate, and what is its active moiety according to which authority record? | GSRS splits NR chloride and NR. Without the moiety link, CQ-PF-01 cannot calculate and CQ-ID-06 cannot compare | `ChemicalSubstance`, `HAS_ACTIVE_MOIETY` (self-edge = is its own moiety; no edge = unknown) | Q-01, V-W02-07 |
| **CQ-ID-C02** | Which taxon, plant part, preparation type, drug-extract ratio and solvent define a botanical preparation, and which standardization statements apply, by which authority and edition? | EMA monograph: DER 35–67:1, acetone 60% m/m. Ph. Eur. standardization changed between editions (terpene lactones 5.0–7.0% as cited for 7.5 vs 5.4–6.6% for 10.0), and USP allows 5.4–12.0% (M-10, M-11, M-12) | `BotanicalPreparation` fields, `DERIVED_FROM_TAXON`, `BotanicalTaxon`, `QUANTITATIVELY_CONTAINS {BETWEEN}` → `Constituent {ANALYTICAL_MEASURAND}` | Q-09 |
| **CQ-ID-C03** | Which strain, identified by which deposits, does a microbial preparation contain; what is its current species; is viability stated? | GG = ATCC 53103 = CCUG 34291 = LMG 18243; BAA-3227 is accessioned progeny; the patent named L. acidophilus; genus renamed 2020 | `MicrobialStrain`, `Identifier`s, `STRAIN_OF` (one current), `MicrobialPreparation.viabilityState` | Q-06, V-W02-09 |
| **CQ-ID-C04** | Is a measured metabolite the same chemical entity as an ingredient substance? | NAD+ measured (W07) vs NAD+ ingredient vs NR→NAD+ mechanism (W03): one ChemicalSubstance | `ChemicalSubstance` with chemical keys; none on `MolecularEntity` | Q-08, V-W02-06 |

## 3. Every SDL element → CQ, invariant or ingestion failure

| SDL element | Mapped to |
|---|---|
| `IngredientMaterial` (+ `materialKind`, search fields, `@fulltext IngredientSearch`) | CQ-ID-03, CQ-ID-06, CQ-ST-02; D-015 live index |
| `BrandedIngredientMaterial.brandName`, `.specificationOwnerUid`, `marketedUnderMarks` | CQ-ID-05, CQ-ID-06; V-W02-05 |
| `BotanicalPreparation.plantPart`, `.preparationType`, `.extractRatio`, `.extractRatioLow/High`, `.solvent`, `derivedFromTaxa` | CQ-ID-C02 (candidate; fixture fx-04); OPEN-QUESTIONS P1-4 |
| `MicrobialPreparation.preparationType`, `.viabilityState`, `strains` | CQ-ST-01, CQ-ID-C03 (fx-05) |
| `MaterialMixture.mixtureKind`, `mixtureComponents` | CQ-ID-03 (fx-02); OPEN-QUESTIONS P1-6 |
| `ChemicalSubstance` (`preferredName`, `molecularFormula`, `pubchemCid`, `inchikey`) | CQ-ID-04, CQ-PF-01 |
| `ChemicalSubstance.casNumber`, `.commonName`, `.compoundClass`, `@fulltext CompoundSearch` | live compatibility (D-015); ingestion failure: CAS-by-name collision (fx-06) |
| `ChemicalSubstance.activeMoieties` / `activeMoietyOf` | CQ-PF-01, CQ-ID-06, CQ-ID-C01 |
| `ChemicalSubstance.forms`, `ChemicalForm` (+ `formKind`, `hydrationState`, `polymorph`, `grade`, `formOf`, `materials`) | CQ-ID-06, CQ-ST-02; V-222, V-222b |
| `realizesSubstances`, `realizedByMaterials` | CQ-ID-03, CQ-ID-06 |
| `chemicalForms` | CQ-ID-06 |
| `providesConstituents`, `providedByMaterials` | CQ-ID-03 |
| `quantitativelyContains`, `quantifiedInMaterials`, `QuantitativeContentProperties` | CQ-ID-03, CQ-PF-01 (MARKER_CONSTITUENT), CQ-ID-C02; V-006 / V-006r |
| `componentOfMixtures` | CQ-ID-03 |
| `identifiers` (W00 edge) | CQ-ID-04, CQ-ID-C03 |
| `governedBySpecifications` (W11 edge) | CQ-ID-05, CQ-ID-06 |
| `producedByProcesses` (W11 edge) | CL-005 (process side); CQ-MF family (W11) |
| `affectsMechanisms`, `modulates` (W03 derived, read-only) | live compatibility; INV-211 |
| `BotanicalTaxon`, `MicrobialTaxon`, `MicrobialStrain` and their fields | CQ-ID-C02, CQ-ID-C03, CQ-ST-01 |
| `Constituent.constituentKind` | CQ-ID-03, CQ-ID-C02 |
| `Nutrient.nutrientKind` | CQ-PF-01 (NUTRIENT_AS_NUTRIENT referent; fx-02 vitamin A) |
| `MaterialContentTarget` | CQ-ID-03 (range of two edges) |
| Enums `MaterialKind`, `ChemicalFormKind`, `BotanicalPreparationType`, `ViabilityState`, `MixtureKind`, `ConstituentKind`, `NutrientKind`, `TaxonRank`, `ContentBasis`, `QuantityComparator`, `ContentStatementKind` | closed vocabularies of the fields above; V-W02-02, V-W02-10 |

Candidates **not** in the SDL (no CQ yet): `REALIZES_MOLECULAR_ENTITY`, `MEMBER_OF_CONSTITUENT_CLASS`, mixture proportions, material-level CFU counts, substance `netCharge`.
