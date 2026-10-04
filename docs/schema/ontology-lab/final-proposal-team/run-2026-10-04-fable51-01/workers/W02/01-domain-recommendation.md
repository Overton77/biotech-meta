# W02 Substances and materials: domain recommendation

Run `run-2026-10-04-fable51-01`, worker W02 (Opus 5.5). Canonical module `substances_and_materials` (catalog 0.2.0, digest `8fb50ff0…84f0`). Rulings D-002 and D-008 are applied. Conflict records: CL-001 (supplied), CL-002 (rule proposed), CL-005 (recommendation; W11 decides).

## 1. Boundary and subdomains

The module answers one question: **what the stuff is**. That covers its chemical identity, its physical form, the actual material, the organism it came from, and what it is said to provide or contain. It does not cover amounts in context, products, doses, lots or measurements.

| Subdomain | Baseline names | Owner | Identity anchor |
|---|---|---|---|
| Chemical identity | `ChemicalSubstance` (replaces live `Compound`) | W02 | Structure authority record (GSRS/UNII granularity; PubChem CID, InChIKey, ChEBI as `Identifier`s) |
| Physical form | `ChemicalForm` (chemical part of live `CompoundForm`) | W02 | Exactly one substance plus a stated polymorph, crystal, amorphous or particle grade |
| Material identity | `IngredientMaterial` + `BrandedIngredientMaterial`, `BotanicalPreparation`, `MicrobialPreparation`, `MaterialMixture` (absorbs live `Ingredient`, `Material`) | W02 | Owner or brand, the realized substance and form, the taxon or strain, the components. A specification change is not a new identity |
| Organisms | `BotanicalTaxon`, `MicrobialTaxon`, `MicrobialStrain` | W02 (taxon identity shared with W03 `Species`, SR-06) | Taxonomy id; culture-collection deposits |
| Provision and content | `Constituent`, `Nutrient`, `PROVIDES_CONSTITUENT`, `QUANTITATIVELY_CONTAINS` + `QuantitativeContentProperties` | W02 | Class or measurand name (Constituent); nutrient concept (Nutrient) |
| Out of module | contextual amounts (`IngredientComponent` W04, `InterventionComponent` W09), dosage form (W04/W09), specification payload and limits (W11/W12), lots and measured results (W12), biological targets (`MolecularEntity` W03), regulatory status (W13) | others | — |

### Identity vs state vs artifact vs occurrence

Every W02 node type is an **Entity**. Nothing in the module is a state. What changes over time lives elsewhere:
- **Asserted edges.** A taxon reassignment (`STRAIN_OF`) and a specification attachment (`GOVERNED_BY_SPECIFICATION`, W11) are asserted edges with valid time.
- **Other modules' states.** Specification payloads are W11 `SpecificationVersion`s, and composition in context is W04's VersionedState components.
- **InformationArtifacts.** Source statements live in the kernel's InformationArtifacts (snapshot and locator).
- **No occurrences.** The module records none.

## 2. The five rules this packet proposes

1. **Substance granularity follows the structure authority (D-W02-01).** GSRS keeps two records:

   | Substance | UNII | Moiety type |
   |---|---|---|
   | Nicotinamide riboside chloride | 8XM2XT8VWI | "Salt or Solvate" |
   | Nicotinamide riboside | 0I8H2M0L7N | "Active Moiety" |

   The two records are joined by `PARENT->SALT/SOLVATE` and `ACTIVE MOIETY` (M-01, M-02). PubChem splits them the same way (CID 90480033 at 290.70; CID 439924 at 255.25), and so does CAS (23111-00-4 vs 1341-23-7). A salt is therefore its own `ChemicalSubstance`, linked by `HAS_ACTIVE_MOIETY`. `ChemicalForm` is kept for physical forms that the authority does not split, such as the NIAGEN crystal form (a GSRS search for "NIAGEN" returns 0 records, M-20).

   This resolves an inconsistency inside round 0002. Its prose says "ChemicalForm (salt, crystal, hydrate)", but its own table and fixture already model "nicotinamide riboside chloride" as a `ChemicalSubstance`. Failing case for the prose reading: the CALCULATED active-moiety mass needs the salt's molecular weight. That weight is a property of a defined structure, and every authority attaches it, with the UNII and CAS, to the salt record.
2. **CL-002 boundary: the identity authority decides the type, the role never does (D-W02-03).**
   - **ChemicalSubstance:** anything identified by a chemical-structure authority (GSRS chemical class, PubChem, ChEBI, InChIKey), including endogenous metabolites. NAD+ (ChEBI 15846) is one `ChemicalSubstance`, whether it is measured in whole blood, sold as an ingredient, or named as the object of "NR increases NAD+".
   - **MolecularEntity (W03):** anything identified by a gene or protein authority (HGNC, UniProt, Ensembl): genes, transcripts, proteins, enzymes and receptors such as CD38.
   - **Failing case for the alternative ("metabolites are MolecularEntity"):** NAD+ would be minted twice, once as a MolecularEntity for mechanisms and once as a ChemicalSubstance for ingredients. Live `MolecularEntity` has no chemical key, so the duplicate would be undetectable, and the question "does supplement X contain what study Y saw rise?" would fail. Fixtures fx-07 and fx-90 N8 cover this; V-W02-06 detects it.
   - **Boundary case:** protein or enzyme ingredients (nattokinase, lactoferrin) are `IngredientMaterial {materialKind: PROTEIN_OR_ENZYME_PREPARATION}`. Their gene-product identity stays a `MolecularEntity`, and the link between the two is a CANDIDATE edge (`REALIZES_MOLECULAR_ENTITY`, SR-07). It is not in the SDL because no CQ requires it yet.
3. **`REALIZES_SUBSTANCE` targets the exact substance the source states (D-W02-04).** When a source names only the moiety (the 2016 NRPT paper's "NR"), the edge targets the moiety record. The identity-facts query Q-04 then reports "moiety only". The suggestion to W10 is that this yields `SAME_SUBSTANCE_MATERIAL_UNRESOLVED` (verdict UNKNOWN), not `SAME_SUBSTANCE_DIFFERENT_FORM` (verdict MISMATCH), because the salt is unknown, not different (SR-09).
4. **Provision is not content, and specification limits are not content (D-W02-05, D-W02-07).**
   - `PROVIDES_CONSTITUENT` targets `Constituent | Nutrient | ChemicalSubstance` (union `MaterialContentTarget`). The catalog range is widened to `ChemicalSubstance` so that lycopene is not minted a second time as a Constituent.
   - `QUANTITATIVELY_CONTAINS` holds only four kinds of statement: standardization claims, definitional composition, reported typical composition, and calculated content.
   - Specification acceptance limits belong to W12 `SpecificationCriterion` under a W11 `SpecificationVersion`. Lot results belong to W12 `MeasuredResult`.
5. **One branded material across specification versions (D-W02-06).** ChromaDex published two different specifications for NIAGEN:
   - **2015** (GRN 635 GRAS determination, Table 2, M-05): purity 95–102 wt%, water ≤1%.
   - **2019** (EFSA Journal 2019;17(8):5775 Table 2, "as proposed by the applicant", M-06): NR chloride ≥90 wt%, water ≤2.0%.

   These are two `SpecificationVersion`s of one `ManufacturingSpecification`, attached to one `BrandedIngredientMaterial`. A new material identity arises only when the brand owner changes, the realized substance or form changes, or the brand is put on a different material. A supplier change for an unbranded material is a different `IngredientMaterial`, which is what makes `SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL` a meaningful level. This partly answers OPEN-QUESTIONS P1-2 on the identity side.

## 3. Disposition of every live and catalog element in scope

Each live field is also listed in `migration-map.yaml`.

| Element | Origin | Disposition | Final element | Reason / failing case |
|---|---|---|---|---|
| `Compound` | live | **merge/rename** (D-002) | `ChemicalSubstance` | Live Compound mixes substances with combinations. "NRPT" must not survive as a substance (fx-06, V-W02-03, V-W02-04) |
| `Compound.casNumber` | live | **keep as materialized key** + `Identifier {CAS}` | `ChemicalSubstance.casNumber` (legacy lookup) | Keeps `searchCompounds` behaviour (D-015). The Identifier is authoritative. The fx-06 collision has name "NR" with the CAS of the chloride |
| `Compound.molecularWeight` | live | **derive** | `Assertion {predicate HAS_MOLECULAR_WEIGHT}` literal (SR-04) | It is an input to CALCULATED amounts and must cite its authority snapshot |
| `Compound.molecularFormula`, `commonName`, `compoundClass` | live | keep | same names | Presentation and legacy hints |
| `Compound.forms` (`IS_FORM_OF`, RoleMetadata) | live | **refine** | `ChemicalSubstance.forms` (`FORM_OF_SUBSTANCE` IN, AssertedEdgeProperties) | RoleMetadata carried no meaning for form-of |
| `Compound.modulates` | live | **seam (derived, read-only)** | `MODULATES` (W03) | Projection of mechanism assertions |
| `Compound.hasSafetySignals` | live | **seam** | W17 `HAS_SAFETY_SIGNAL` with `SafetySubjectTarget` | Not carried on W02 types until W17 states its property type (SR-14) |
| `Compound` `@fulltext CompoundSearch` / `searchCompounds` | live | **keep** (D-015) | on `ChemicalSubstance` | Stored fields: name, preferredName, description, commonName, casNumber, searchText |
| `Compound` `@vector CompoundSearchEmbedding` | live | **defer to Fable** (D-014) | none in fragment | Retrieval justification in 07-operations.md |
| `CompoundForm` | live | **split** (D-002) | `ChemicalForm` (physical form), `IngredientMaterial` (supplier/brand material), dosage form → `ProductVariant`/`StudyIntervention` | NIAGEN is a crystal form and a branded material, while "Tru Niagen 300 mg capsule" is a variant |
| `CompoundForm.dosageForm`, `concentrationText` | live | **move** | W04/W09 dosage form; component `quantity` + verbatim text | V-222b forbids dosage form on materials |
| `CompoundForm.formOf`, `affectsMechanisms` | live | refine / seam (derived) | `ChemicalForm.formOf` (exactly one), `affectsMechanisms` (W03 derived, read-only) | |
| `Ingredient` | live | **merge** | `IngredientMaterial` (same opaque id) | A generic ingredient record is a material identity; its role is contextual |
| `Ingredient.ingredientRole` | live | **move** | `IngredientComponent.role` (W04) | Role belongs to the component in a formulation |
| `Ingredient.containsCompounds` (`CONTAINS_COMPOUND`, DoseMetadata) | live | **split** | `QUANTITATIVELY_CONTAINS` when a dose is present, otherwise `PROVIDES_CONSTITUENT` | Forbidden implication: provides ≠ contains |
| `Ingredient` `@fulltext IngredientSearch` | live | keep | on `IngredientMaterial` (covers every specialization) | D-015 |
| `Material` | live | **retire** into `IngredientMaterial` unless W11 shows a failing case (CL-005, D-008) | `IngredientMaterial` (same opaque id) | GRN 635 process inputs are D-ribofuranose tetra-acetate, gaseous HCl and ammonium hydroxide (M-21). Each is a material identity; its process-input role belongs on W11's `INPUTS`/`HAS_INPUT` edge. No property is found that IngredientMaterial cannot carry. The name "Ingredient" is awkward for a reagent, and this is recorded as a naming cost, not a model gap |
| `Material.materialType` | live | move | `materialKind` (mapped) | |
| `Material.materialGrade` | live | move | `ChemicalForm.grade` (chemical grade) or W11 `SpecificationVersion` (owner grade) | |
| `Material.regulatoryCategoryHint` | live | seam | W13 `RegulatoryStatus` | INV-010 |
| `Material.traceabilityCode` | live | seam | W12 `ProductLot` / material lot | A lot is not a material identity |
| `Material.partOfProducts` (`PART_OF`) | live | seam (derived) | W04 `FormulationVersion → IngredientComponent → USES_MATERIAL` | INV-005 |
| `Material.supportedBy` (Chunk) | live | seam | W20 derived support | INV-404 |
| `MolecularEntity` | live, W03 | **keep (W03)**, CL-002 rule | — | Carries no chemical keys (V-W02-06) |
| `IngredientMaterial`, `BrandedIngredientMaterial`, `ChemicalSubstance`, `ChemicalForm`, `BotanicalTaxon`, `BotanicalPreparation`, `MicrobialTaxon`, `MicrobialStrain`, `MicrobialPreparation`, `MaterialMixture`, `Constituent`, `Nutrient` | catalog | **keep / refine** | same names | Properties refined as in 04-model-cards.md. `BotanicalPreparation` gains `extractRatioLow/High`. `ChemicalSubstance` gains legacy `casNumber`, `commonName`, `compoundClass` |
| `REALIZES_SUBSTANCE`, `HAS_CHEMICAL_FORM`, `FORM_OF_SUBSTANCE`, `HAS_ACTIVE_MOIETY`, `DERIVED_FROM_TAXON`, `HAS_STRAIN`, `STRAIN_OF`, `HAS_MIXTURE_COMPONENT` | catalog | keep (asserted, AssertedEdgeProperties) | same | `HAS_ACTIVE_MOIETY` self-edge semantics added. `STRAIN_OF` proposed EXCLUSIVE (SR-05) |
| `PROVIDES_CONSTITUENT` | catalog | **refine range** | `MaterialContentTarget` | Avoids a duplicate lycopene identity |
| `QUANTITATIVELY_CONTAINS` | catalog | **refine** | `QuantitativeContentProperties` (comparator, ranges, basis, statement kind) | Ranges (22.0–27.0%) and one-sided limits are the common real statements (SR-02) |
| `forbiddenImplications [PROVIDES_CONSTITUENT, QUANTITATIVELY_CONTAINS]` | catalog | keep verbatim | V-W02-01 + V-112 | fx-90 N1 |

## 4. Alternatives considered

| Question | Alternative | Why not chosen |
|---|---|---|
| Salt identity | Salt as `ChemicalForm` of the parent | Authorities split salts with distinct identifiers. The calculation needs the salt's molecular weight. Polymorphs would then need a second form level (crystal form *of* a salt form) |
| Lycopene as provided constituent | `Constituent` node "lycopene" linked to `ChemicalSubstance` lycopene | Two nodes for one defined compound, plus a new link edge |
| Range content | Two assertions (GE low, LE high) per range | One source statement split into two propositions. Kept only as the interim fallback until SR-02 is ruled |
| Quantity on QUANTITATIVELY_CONTAINS | Quantity on the edge only (current practice) | The edge then carries facts its authorizing assertion cannot hold, so rebuilding it from assertions loses the number (SR-01; fx-91) |
| Material vs ProcessMaterial | Keep a `ProcessMaterial` specialization | No property or identity rule differs. W11 may still supply a case (CL-005) |
| Spec version as new branded material | A new `BrandedIngredientMaterial` per spec | Breaks `SAME_BRANDED_MATERIAL_SAME_SPEC` vs `…_SPEC_UNRESOLVED`, which needs one material with several spec attachments (Q-05) |
| Branding as a kind | `materialKind: BRANDED_CHEMICAL_MATERIAL` (0.2.0 fixtures) | Cannot express a branded botanical (KSM-66-type) or branded probiotic. The value is kept as legacy |

## 5. Smallest recommended model

- **Twelve catalog node types**, no new node type, five of them sharing one uid token (`material`).
- **Ten catalog relationships.** Two are refined (`PROVIDES_CONSTITUENT` range; `QUANTITATIVELY_CONTAINS` properties).
- **One union:** `MaterialContentTarget`.
- **One relationship-property type:** `QuantitativeContentProperties`.
- **Eleven enums:** `MaterialKind`, `ChemicalFormKind`, `BotanicalPreparationType`, `ViabilityState`, `MixtureKind`, `ConstituentKind`, `NutrientKind`, `TaxonRank`, `ContentBasis`, `QuantityComparator`, `ContentStatementKind`.

Not in the SDL (CANDIDATE):
- `REALIZES_MOLECULAR_ENTITY` (protein ingredients)
- constituent-class membership (`MEMBER_OF_CONSTITUENT_CLASS`)
- mixture component proportions
- material-level CFU counts
- a `netCharge` substance property
