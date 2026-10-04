# W02 decision and seam ledger

**Status values:**
- ACCEPTED-FOR-PROPOSAL: W02 adopts it in the fragment; Fable may still overrule.
- REQUESTED: it depends on another owner (see `seam-requests.yaml`).
- UNRESOLVED: open.

No consensus is claimed for any other worker's position.

## Decisions

| Id | Decision | Evidence | Alternatives (and why rejected) | Status |
|---|---|---|---|---|
| D-W02-01 | `ChemicalSubstance` granularity = the structure-authority record (GSRS/UNII). Salts and stoichiometric solvates are their own substances, linked to their active moiety by `HAS_ACTIVE_MOIETY`. A self-edge means "is its own active moiety"; no edge means unknown | GSRS 8XM2XT8VWI "Salt or Solvate" vs 0I8H2M0L7N "Active Moiety", joined by PARENT->SALT/SOLVATE and ACTIVE MOIETY; PubChem CIDs 90480033 / 439924; CAS 23111-00-4 / 1341-23-7 (M-01…M-04, M-07) | (a) salt as `ChemicalForm` of the parent, as in the round 0002 prose: rejected, because MW, UNII and CAS are salt-level and the calculation needs the salt MW. (b) only the moiety as substance, with the salt as a material property: rejected, because a regulatory record (GRN 635) attaches to the salt | ACCEPTED-FOR-PROPOSAL |
| D-W02-02 | `ChemicalForm` = a physical form the authority does not split (crystal or polymorph, amorphous, particle grade) of exactly one substance | Conze: "a crystal form of NR chloride termed NIAGEN" (M-17); GSRS has no record matching NIAGEN (M-20) | Salts/hydrates as forms (see D-W02-01) | ACCEPTED-FOR-PROPOSAL |
| D-W02-03 | **CL-002 rule:** the identity authority decides the type. Chemical-structure authority → `ChemicalSubstance` (including metabolites such as NAD+). Gene/protein authority → `MolecularEntity` (W03). Role never decides. Protein/enzyme ingredients are `IngredientMaterial {PROTEIN_OR_ENZYME_PREPARATION}`, with a CANDIDATE link to MolecularEntity | ChEBI 15846: NAD+ is a chemical entity whose biological roles (cofactor, coenzyme, metabolite) are role annotations (M-18). Live `MolecularEntity` has gene/protein ids only | Metabolites as MolecularEntity: duplicates NAD+ (fx-90 N8 → V-W02-06). A role-based split: same failure | REQUESTED (SR-07 W03, SR-08 W07) |
| D-W02-04 | `REALIZES_SUBSTANCE` targets the exact substance stated. A moiety-only statement targets the moiety. Identity facts (Q-04) report `moietyOnly`, and W02 suggests SAME_SUBSTANCE_MATERIAL_UNRESOLVED for it | NRPT paper: "125 mg NR + 25 mg PT per capsule" (M-29); NR as a moiety is a cation (charge +1, M-02, M-04) and cannot be an isolated material | Assume the chloride for any "NR": invents a salt. Treat as a different form: false MISMATCH | ACCEPTED-FOR-PROPOSAL; level mapping REQUESTED (SR-09 W10) |
| D-W02-05 | `PROVIDES_CONSTITUENT` range widened to `ChemicalSubstance` (union `MaterialContentTarget`). `Constituent` is only for classes and analytical measurands | Mosaic label "providing lycopene, phytoene, phytofluene, and tocopherols" (M-08) mixes defined compounds and a class | A Constituent copy of lycopene: duplicate identity plus a new link edge | ACCEPTED-FOR-PROPOSAL (catalog range change; Fable rules) |
| D-W02-06 | A specification change is a new `SpecificationVersion`, never a new material. A new `BrandedIngredientMaterial` arises only on a change of brand owner, realized substance or form, or a re-application of the brand. A supplier change for an unbranded material is a different `IngredientMaterial` | NIAGEN 2015 (GRN 635: 95–102 wt%, water ≤1%) and 2019 (EFSA, applicant ChromaDex: ≥90 wt%, water ≤2.0%) (M-05, M-06) | One material per spec: breaks SPEC_UNRESOLVED (Q-05b needs one material with two attachments) | ACCEPTED-FOR-PROPOSAL; partial answer to OPEN-QUESTIONS P1-2 |
| D-W02-07 | Specification acceptance limits are W12 `SpecificationCriterion` and lot results are W12 `MeasuredResult`. `QUANTITATIVELY_CONTAINS` holds only standardization, definitional, typical or calculated content | The EU Union list definition "contains ≥ 90 %" (M-23) and the EFSA Table 2 are acceptance criteria. The Ph. Eur. "adjusted to 22.0–27.0%" defines the preparation (M-12) | All content as QUANTITATIVELY_CONTAINS: spec and claim would be indistinguishable, and three owners would hold one fact | REQUESTED (SR-18 W12) |
| D-W02-08 | CALCULATED active-moiety amount = an `Assertion {predicate QUANTITATIVELY_CONTAINS, basisKind CALCULATED, predicateClass QUANTITY, derivationRule, valueNumber, unitCode, quantityBasis}` with subject the W04 `IngredientComponent`, `DERIVED_FROM_ASSERTION` to its 5 inputs, `ASSERTED_BY` a calculator Agent, no locator of its own, not projected to an edge | 300 mg × 255.25/290.70 = 263.4 mg; 250 mg → 219.5 mg (M-03, M-04); KCR-L3-001; INV-307 | Calculated amount on the label declaration: forbidden (V-330). As an edge-only value: no lineage | ACCEPTED-FOR-PROPOSAL under the frozen kernel; object form REQUESTED (SR-01) |
| D-W02-09 | `QuantitativeContentProperties` with `comparator` and `quantityLow/High` for ranges and one-sided limits; V-006r | Ph. Eur. ranges (M-11, M-12); "≥ 90 wt %" (M-06) | Two assertions per range: splits one statement. Midpoint as quantity: invents a value | REQUESTED (SR-02 W00) |
| D-W02-10 | `materialKind` describes composition kind. Branding is the `BrandedIngredientMaterial` label. The legacy `BRANDED_CHEMICAL_MATERIAL` value is readable but not written | 0.2.0 fixtures; branded botanicals and probiotics exist | Keep branded-as-kind: cannot express a branded botanical | ACCEPTED-FOR-PROPOSAL |
| D-W02-11 | All IngredientMaterial specializations use uid token `material`. New tokens for taxa, strain, constituent and nutrient | Reclassification is not an identity change (fx-02) | Token per label: a uid change on reclassification | REQUESTED (SR-03) |
| D-W02-12 | **CL-001:** "NRPT" (a combination) is never a `ChemicalSubstance`. The legacy Compound is resolved by a `ResolutionHypothesis` to the study interventions (and to the product name via W04). It becomes a `MaterialMixture` only if a source states a traded pre-blended material | GSRS has no record matching "NRPT" (M-20); "NRPT … commercially known as Basis" (M-29) | NRPT as substance: V-W02-03/04 rows. NRPT as mixture: no source states such a material | ACCEPTED-FOR-PROPOSAL (fixture fx-06; negatives N3, N4) |
| D-W02-13 | **CL-005:** retire live `Material` into `IngredientMaterial` (same uid). Process role is carried on W11 edges | GRN 635 manufacture inputs (M-21) | A `ProcessMaterial` specialization: no differing property found | REQUESTED (SR-10 W11 decides) |
| D-W02-14 | Live `Ingredient` merges into `IngredientMaterial`. `ingredientRole` → W04 component role. `CONTAINS_COMPOUND` splits by presence of a quantity | Architecture §6 | Keep `Ingredient` as a second material type: two identities for one material | ACCEPTED-FOR-PROPOSAL |
| D-W02-15 | `STRAIN_OF` proposed EXCLUSIVE per subject in valid time. Older assignments stay as assertions | Patent-era L. acidophilus vs BacDive/ATCC L. rhamnosus (M-13, M-14, M-16) | Non-exclusive: species answers ambiguous | REQUESTED (SR-05) |
| D-W02-16 | One taxon identity shared with W03 `Species` by co-labelling | NCBI taxonomy id as key (M-13) | Separate nodes per role: duplicate | REQUESTED (SR-06 W03) |
| D-W02-17 | Live `Compound.molecularWeight` → literal Assertion `HAS_MOLECULAR_WEIGHT` | PubChem MW snapshots (M-03, M-04) | Keep as a node property: an uncited calculation input | REQUESTED (SR-04) |
| D-W02-18 | Nutrient vs source: a NUTRIENT_AS_NUTRIENT referent is a `Nutrient`; the source material `PROVIDES_CONSTITUENT` the Nutrient | Mosaic "Vitamin A (from Beta-Carotene) 70.8 mcg RAE" (M-08); 21 CFR 101.36(b)(2)(ii) (M-31) | Vitamin A as ChemicalSubstance: confuses retinol activity equivalents with a structure | ACCEPTED-FOR-PROPOSAL |
| D-W02-19 | Live fulltext names `CompoundSearch`/`searchCompounds` and `IngredientSearch`/`searchIngredients` are kept on `ChemicalSubstance`/`IngredientMaterial`. `casNumber` is kept as a legacy materialized key | D-015; executed `searchCompounds` against fixtures | Drop `casNumber`: breaks lookup by CAS | ACCEPTED-FOR-PROPOSAL |
| D-W02-20 | The derived mechanism fields (`modulates`, `affectsMechanisms`) on W02 types are read-only (`@settable(onCreate:false,onUpdate:false)`) with `DerivedEdgeProperties` | INV-211; live field names | Writable live fields: mechanism history bypass | REQUESTED (SR-07 confirm) |
| D-W02-21 | A GSRS code "GRAS Notification (GRN No.) 635" on a substance record is a submission number (W13), not a substance `Identifier` | M-01; INV-010 | Attach as Identifier: implies regulatory status is identity | ACCEPTED-FOR-PROPOSAL |

## Kernel-change requests (primary source + failing case)

| Request | Primary source | Failing case (executed) |
|---|---|---|
| SR-01 object + quantity on QUANTITY assertions (INV-003 / V-003) | M-06, M-12, M-03/04 | fx-91: Q-10 returns refersTo null for two literal-only calculated amounts; the object form produces a V-003 row; the Ginkgo edges carry numbers their assertions cannot hold |
| SR-02 V-006 → V-006r | M-11, M-12 | fx-91: V-006 returns 2 rows for complete BETWEEN statements; V-W02-10 returns 0 |
| SR-03 uid tokens | catalog tokens list | fx-02 reclassification |
| SR-04 predicates HAS_MOLECULAR_WEIGHT; ActivityKind CALCULATION | M-03, M-04 | fx-01 calculation inputs |
| SR-05 STRAIN_OF exclusivity | M-13, M-16 | fx-90 N13 → V-W02-09 row |

## Unresolved items (carried forward, not guessed)

1. **Material equivalence beyond identity facts** (OPEN-QUESTIONS P1-1). W02 supplies the facts (Q-04); the equivalence verdict is W10's. A certificate-of-analysis pair for NIAGEN under the two specs was not found in this run (SR-18).
2. **Native vs genuine DER basis on labels** (P1-4). EMA states a DER range; no US label in this run states its ratio basis. `extractRatio` stays verbatim.
3. **Strain-specific counts, spores, consortia** (P1-5). Viability is recorded only when stated; counts stay on components. The NCT00934453 count unit is unstated.
4. **Proprietary-blend reasoning** (P1-6). Nested amounts stay unknown (Mosaic 395 mg). Whether the Mosaic complex is a "proprietary blend" in the 101.36(c) sense is not established; the fixture uses PROPRIETARY_BLEND_TOTAL on the W04 component as the closest referent, and W04 should confirm.
5. **Whether NIAGEN is the EU novel food of EFSA 2019.** It is inferred (applicant ChromaDex; substance NR chloride), so the attachment is PROPOSED and asserted by BellLabs, not by the source.
6. **CD38 UniProt accession** is unverified (UniProt 503).
7. **Label vs science page disagreement for Mosaic** (tocopherols vs beta-carotene). Both are kept; no adjudication was made.
