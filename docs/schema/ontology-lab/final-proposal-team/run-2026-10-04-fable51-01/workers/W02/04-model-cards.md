# W02 model cards

## Conventions shared by every W02 card

These apply to every card below unless the card says otherwise.

- **Privacy:** class PUBLIC. No W02 element is INTERNAL or private.
- **Skeleton fields:** every node carries the contract B2 skeleton (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) plus `entityType: String!` (EntityArchetype). The cards list only the domain fields.
- **Kind codes:** `asserted` = the value comes from a source statement and is backed by an Assertion when it matters for a CQ; `calculated` = derived by rule; `operational` = service or presentation.
- **Temporal behaviour:** Entity descriptors are stable. A corrected descriptor is a new assertion plus a node update recorded through an Activity. Anything time-varying is an asserted edge with valid time.
- **Missingness:** null means unknown or not stated, never false or absent (contract A7).
- **Archetype label:** every node also stores `Entity` (D-001).
- **Maturity:** PROVISIONAL for all catalog types unless stated.
- **Source references:** M-xx rows in 03-source-manifest.md.

---

## Node cards

### N-1 IngredientMaterial

- **Meaning:** the identity of an actual material that is used as an ingredient, administered, or processed. The catalog meaning is kept. The rule that live `Ingredient` and `Material` merge here is new.
- **Labels:** `["IngredientMaterial","Entity"]`.
- **uid token:** `material`.
- **Identity:**
  - Owner or brand, plus realized substance and form, or taxon/strain, or components.
  - Display name and market name are never identity.
  - Aliases are `Identifier`s (supplier codes) and `ResolutionHypothesis` records.
  - Supplier change → a new material. Specification revision by the same owner → the same material (D-W02-06).
- **Properties:**

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `materialKind` | `MaterialKind` | not classified (migration only) | asserted | Must agree with the specialization label (V-W02-02) |
  | `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions` | String / [String!] / String / Int | not indexed | operational | SearchIndexable; INV-107 |

- **Edges:**

  | Field | Type | Direction | Range | Card. | Class | Properties | Owner |
  |---|---|---|---|---|---|---|---|
  | `realizesSubstances` | REALIZES_SUBSTANCE | OUT | ChemicalSubstance | many | asserted | AssertedEdgeProperties | W02 |
  | `chemicalForms` | HAS_CHEMICAL_FORM | OUT | ChemicalForm | many | asserted | AssertedEdgeProperties | W02 |
  | `providesConstituents` | PROVIDES_CONSTITUENT | OUT | MaterialContentTarget | many | asserted | AssertedEdgeProperties | W02 |
  | `quantitativelyContains` | QUANTITATIVELY_CONTAINS | OUT | MaterialContentTarget | many | asserted | QuantitativeContentProperties | W02 |
  | `componentOfMixtures` | HAS_MIXTURE_COMPONENT | IN | MaterialMixture | many | asserted | AssertedEdgeProperties | W02 |
  | `identifiers` | HAS_IDENTIFIER | OUT | Identifier | many | asserted | IdentifierLinkProperties | W00 |
  | `governedBySpecifications` | GOVERNED_BY_SPECIFICATION | OUT | SpecificationVersion | many | asserted | AssertedEdgeProperties | W11 |
  | `producedByProcesses` | PRODUCED_BY_PROCESS | OUT | ManufacturingProcess | many | asserted | AssertedEdgeProperties | W11 |
  | `affectsMechanisms` | AFFECTS_MECHANISM | OUT | Mechanism | many | derived, read-only | DerivedEdgeProperties | W03 |
  | `modulates` | MODULATES | OUT | MolecularEntity | many | derived, read-only | DerivedEdgeProperties | W03 |

  Incoming from others: `USES_MATERIAL` (W04), `USES_INTERVENTION_MATERIAL` (W09), `DECLARATION_IDENTIFIES_MATERIAL` (W04), `SUPPLIES_INGREDIENT_MATERIAL` (W01/W11), `INPUTS`/`OUTPUTS`/`PRODUCES` (W11, CL-005), `PROPOSES_MATCH` (W00).

- **Indexes:** `@fulltext IngredientSearch` (`searchIngredients`).
- **Sources:** M-08, M-30.

### N-2 BrandedIngredientMaterial

- **Meaning:** a brand-owned IngredientMaterial. Branding is orthogonal to kind.
- **Labels:** `["BrandedIngredientMaterial","IngredientMaterial","Entity"]`.
- **uid token:** `material` (SR-03).
- **Fields:** all N-1 fields, plus:

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `brandName` | String | not stated | asserted | Lookup, not identity |
  | `specificationOwnerUid` | String | unknown | asserted (materialized pointer) | Authoritative = spec attachment assertion |
  | `marketedUnderMarks` | `[Trademark!]!` MARKETED_UNDER_MARK OUT, AssertedEdgeProperties | — | asserted | Owner W14 |

- **Rule:** one node per brand and owner (V-W02-05).
- **Sources:** M-05, M-06, M-17, M-30.

### N-3 BotanicalPreparation

- **Labels:** `["BotanicalPreparation","IngredientMaterial","Entity"]`.
- **uid token:** `material`.
- **Fields:** all N-1 fields, plus:

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `plantPart` | String | not stated | asserted | 'leaf', 'fruit' |
  | `preparationType` | `BotanicalPreparationType` | not stated | asserted | |
  | `extractRatio` | String | no ratio stated | asserted (verbatim) | 'DER 35-67:1' |
  | `extractRatioLow`, `extractRatioHigh` | Float (dimensionless, herbal substance : preparation) | no ratio | calculated (parse of `extractRatio`) | point ratio → low = high |
  | `solvent` | String | not stated | asserted | 'acetone 60% m/m' |
  | `derivedFromTaxa` | `[BotanicalTaxon!]!` DERIVED_FROM_TAXON OUT, AssertedEdgeProperties, one_or_more | — | asserted | Resolution from a common name is marked `extractionMethod: COMMON_NAME_RESOLUTION` |

- **Not modelled:** native versus genuine DER basis. The EMA monograph states a DER, but US labels rarely say what the ratio is relative to (OPEN-QUESTIONS P1-4 stays open). Standardization lives on QUANTITATIVELY_CONTAINS edges.
- **Sources:** M-10, M-11, M-12, M-08.

### N-4 MicrobialPreparation

- **Labels:** `["MicrobialPreparation","IngredientMaterial","Entity"]`.
- **uid token:** `material`.
- **Fields:** all N-1 fields, plus:

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `preparationType` | String (free text; no authority vocabulary found) | not stated | asserted | |
  | `viabilityState` | `ViabilityState` | not stated | asserted | never inferred from a count |
  | `strains` | `[MicrobialStrain!]!` HAS_STRAIN OUT, AssertedEdgeProperties, one_or_more | — | asserted | |

- **Not modelled:** counts live on the component (W04/W09).
- **Sources:** M-15.

### N-5 MaterialMixture

- **Labels:** `["MaterialMixture","IngredientMaterial","Entity"]`.
- **uid token:** `material`.
- **Fields:** all N-1 fields, plus:

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `mixtureKind` | `MixtureKind` | not stated | asserted | |
  | `mixtureComponents` | `[IngredientMaterial!]!` HAS_MIXTURE_COMPONENT OUT, AssertedEdgeProperties, one_or_more | — | asserted | no self-loop (V-W02-11) |

- **Not a mixture:** NRPT (D-W02-12).
- **Sources:** M-08, M-09.

### N-6 ChemicalSubstance

- **Meaning:** a defined chemical structure at GSRS/UNII granularity. It replaces live `Compound` (D-002).
- **Labels:** `["ChemicalSubstance","Entity"]`.
- **uid token:** `substance`.
- **Fields:**

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `preferredName` | String | — | operational | presentation |
  | `molecularFormula` | String | not recorded | asserted (authority) | one of the V-W02-03 anchors |
  | `pubchemCid` | String | not recorded | asserted (materialized key) | `Identifier {PUBCHEM_CID}` authoritative |
  | `inchikey` | String | not recorded | asserted (materialized key) | standard InChIKey |
  | `casNumber` | String | not recorded | asserted (legacy materialized key) | kept for `CompoundSearch` |
  | `commonName`, `compoundClass` | String | — | operational (legacy) | |
  | search fields | — | — | operational | SearchIndexable |

- **Edges:**

  | Field | Type | Direction | Range | Card. | Class |
  |---|---|---|---|---|---|
  | `forms` | FORM_OF_SUBSTANCE | IN | ChemicalForm | many | asserted |
  | `activeMoieties` | HAS_ACTIVE_MOIETY | OUT | ChemicalSubstance | zero_or_one | asserted |
  | `activeMoietyOf` | HAS_ACTIVE_MOIETY | IN | ChemicalSubstance | many | asserted |
  | `realizedByMaterials` | REALIZES_SUBSTANCE | IN | IngredientMaterial | many | asserted |
  | `providedByMaterials` | PROVIDES_CONSTITUENT | IN | IngredientMaterial | many | asserted |
  | `quantifiedInMaterials` | QUANTITATIVELY_CONTAINS | IN | IngredientMaterial | many | asserted |
  | `identifiers` | HAS_IDENTIFIER | OUT | Identifier | many | asserted |
  | `modulates`, `affectsMechanisms` | MODULATES / AFFECTS_MECHANISM (W03) | OUT | MolecularEntity / Mechanism | many | derived, read-only |

- **Molecular weight:** the literal Assertion `HAS_MOLECULAR_WEIGHT {valueNumber, unitCode 'g/mol'}` (SR-04), not a property.
- **Indexes:** `@fulltext CompoundSearch` (`searchCompounds`).
- **Rules:** V-W02-03, 04, 06, 07, 13.
- **Sources:** M-01 to M-04, M-18, M-19.

### N-7 ChemicalForm

- **Meaning:** a physical form of exactly one substance that the authority does not split.
- **Labels:** `["ChemicalForm","Entity"]`.
- **uid token:** `form` (registered alias `chemical-form` kept for the repo fixture uid).
- **Fields:**

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `formKind` | `ChemicalFormKind` | not stated | asserted | |
  | `hydrationState` | String | not stated | asserted | only where no separate hydrate substance exists |
  | `polymorph` | String | not stated | asserted | |
  | `grade` | String | not stated | asserted | |

- **Edges:**
  - `formOf`: FORM_OF_SUBSTANCE OUT, exactly_one, asserted (V-222).
  - `materials`: HAS_CHEMICAL_FORM IN.
  - `affectsMechanisms`: W03 derived, read-only.
- **Sources:** M-17.

### N-8 BotanicalTaxon

- **Labels:** `["BotanicalTaxon","Entity"]`.
- **uid token:** `botanical-taxon` (proposed, SR-03).
- **Fields:**

  | Field | Type | Null means | Kind |
  |---|---|---|---|
  | `scientificName` | String | — | asserted; presentation, may change |
  | `taxonRank` | `TaxonRank` | not stated | asserted |
  | `taxonomyId` | String | not recorded | materialized key |
  | `identifiers` | HAS_IDENTIFIER (W00 edge) | — | asserted |
  | `preparations` | DERIVED_FROM_TAXON IN | — | asserted |

- **Identity:** the taxonomy id. It is shared with W03 `Species` when one taxon plays both roles (SR-06).

### N-9 MicrobialTaxon

- **Labels:** `["MicrobialTaxon","Entity"]`.
- **uid token:** `microbial-taxon` (proposed).
- **Fields:** `scientificName`, `taxonomyId` (as N-8); `identifiers`; `strains` (STRAIN_OF IN).
- **Identity:** taxonomy id (NCBI 47715 for L. rhamnosus). A genus rename changes the name only.
- **Sources:** M-13.

### N-10 MicrobialStrain

- **Labels:** `["MicrobialStrain","Entity"]`.
- **uid token:** `microbial-strain` (proposed).
- **Fields:**

  | Field | Type | Null means | Kind | Notes |
  |---|---|---|---|---|
  | `strainDesignation` | String | — | asserted | not unique alone |
  | `depositIdentifier` | String | — | materialized primary deposit | |
  | `strainOf` | STRAIN_OF OUT, zero_or_one current, asserted | — | — | proposed EXCLUSIVE, SR-05, V-W02-09 |
  | `identifiers` | HAS_IDENTIFIER | — | asserted | |
  | `preparations` | HAS_STRAIN IN | — | asserted | |

- **Identity:** the deposit accessions. Equivalent deposits across collections are one strain; a progeny accession is an extra Identifier.
- **Sources:** M-13, M-14, M-16.

### N-11 Constituent

- **Meaning:** a class or measurand, not a defined compound.
- **Labels:** `["Constituent","Entity"]`.
- **uid token:** `constituent` (proposed).
- **Fields:** `constituentKind: ConstituentKind`; `providedByMaterials` (PROVIDES_CONSTITUENT IN); `quantifiedInMaterials` (QUANTITATIVELY_CONTAINS IN).
- **Identity:** name plus kind within a defining source (for example "ginkgo flavonoids calculated as flavone glycosides" per Ph. Eur.). Duplicates across sources are linked with an EquivalenceAssessment, never merged by name.
- **Sources:** M-08, M-11, M-12.

### N-12 Nutrient

- **Labels:** `["Nutrient","Entity"]`.
- **uid token:** `nutrient` (proposed).
- **Fields:** `nutrientKind: NutrientKind`; inverse fields as N-11.
- **Identity:** the nutrient concept (Vitamin A, niacin). Units such as RAE and NE are carried by quantities (UCUM annotations, e.g. `ug{RAE}`).
- **Sources:** M-08, M-25, M-31.

---

## Relationship cards

Every relationship below is class `asserted`, uses the asserted_edge profile, and needs an Assertion with predicate equal to the type (V-101, V-W02-01).

| Rel | Domain → Range | Card. (from source) | Properties | Meaning / rules | Sources |
|---|---|---|---|---|---|
| R-1 REALIZES_SUBSTANCE | IngredientMaterial → ChemicalSubstance | many | AssertedEdgeProperties | The material is, predominantly, the stated substance. A moiety-only statement targets the moiety (D-W02-04) | M-29, M-30 |
| R-2 HAS_CHEMICAL_FORM | IngredientMaterial → ChemicalForm | many | AssertedEdgeProperties | Physical form of the material's substance | M-17 |
| R-3 FORM_OF_SUBSTANCE | ChemicalForm → ChemicalSubstance | exactly_one | AssertedEdgeProperties | V-222 | M-17 |
| R-4 HAS_ACTIVE_MOIETY | ChemicalSubstance → ChemicalSubstance | zero_or_one (self allowed) | AssertedEdgeProperties | Self-edge = is its own moiety; target terminal (V-W02-07); at most one non-self target (V-W02-04) | M-01, M-02 |
| R-5 DERIVED_FROM_TAXON | BotanicalPreparation → BotanicalTaxon | one_or_more | AssertedEdgeProperties | V-W02-11 domain | M-10, M-08 |
| R-6 HAS_STRAIN | MicrobialPreparation → MicrobialStrain | one_or_more | AssertedEdgeProperties | Consortium = several edges | M-15 |
| R-7 STRAIN_OF | MicrobialStrain → MicrobialTaxon | zero_or_one current | AssertedEdgeProperties | Reassignment = new assertion; the old one is kept (fx-05) | M-13, M-16 |
| R-8 HAS_MIXTURE_COMPONENT | MaterialMixture → IngredientMaterial | one_or_more | AssertedEdgeProperties | No proportions (CANDIDATE) | M-08 |
| R-9 PROVIDES_CONSTITUENT | IngredientMaterial → MaterialContentTarget | many | AssertedEdgeProperties | Non-quantitative. Range widened to ChemicalSubstance (D-W02-05). Never premise of QUANTITATIVELY_CONTAINS | M-08, M-09 |
| R-10 QUANTITATIVELY_CONTAINS | IngredientMaterial → MaterialContentTarget | many | QuantitativeContentProperties | Standardization, definitional, typical or calculated content. Not spec limits, not lot results | M-11, M-12 |

A CALCULATED per-serving amount (CQ-PF-01) is an `Assertion {predicate QUANTITATIVELY_CONTAINS, basisKind CALCULATED}` whose subject is the W04 `IngredientComponent`. Under the frozen kernel it is literal-only and is not projected to an edge (fx-01; SR-01).

## Relationship-property type card

### RP-1 QuantitativeContentProperties

Contains every `AssertedEdgeProperties` field (`relationshipUid!`, `assertionUid!`, valid bounds with precision and `validFromBasis!`/`validToBasis!`, `recordedFrom!`, `recordedTo`, `mongoResearchRunId`), plus:

| Field | Type | Null | Units | Kind | Rule |
|---|---|---|---|---|---|
| `quantity` | Float | null for BETWEEN | per `unitCode` | asserted or calculated | required for EQ, APPROX, GE, GT, LE, LT |
| `quantityLow`, `quantityHigh` | Float | required for BETWEEN | per `unitCode` | asserted | low < high |
| `comparator` | `QuantityComparator!` | — | — | asserted | — |
| `unitCode` | String! | — | UCUM | asserted | V-006 |
| `basis` | `ContentBasis!` | — | — | asserted | V-006 |
| `massBasis` | `MassBasis` (W00) | not a mass or not stated | — | asserted | — |
| `expressedAs` | String | not stated | — | asserted | 'calculated as flavone glycosides' |
| `contentStatementKind` | `ContentStatementKind!` | — | — | asserted | spec limits excluded |
| `verbatimText` | String | — | — | asserted | — |

Temporal behaviour: one edge per recorded-time episode; a new pharmacopoeia edition is a new assertion with its own valid time. Validators: V-006 (frozen) and V-006r = V-W02-10 (proposed, SR-02).

## Union card

**U-1 MaterialContentTarget** = `Constituent | Nutrient | ChemicalSubstance`. Owner W02. It is the range of R-9 and R-10. An interface is not used because the members share no domain fields.

## Enum cards (owner W02 for all; frozen at these values once accepted)

| Enum | Values | Used by | Notes |
|---|---|---|---|
| MaterialKind | CHEMICALLY_DEFINED_MATERIAL, BOTANICAL_PREPARATION, MICROBIAL_PREPARATION, MATERIAL_MIXTURE, PROTEIN_OR_ENZYME_PREPARATION, UNRESOLVED_MATERIAL, OTHER_MATERIAL, BRANDED_CHEMICAL_MATERIAL (legacy, no new writes) | IngredientMaterial.* | The catalog listed no values; these come from the 0.2.0 fixtures and CQ-ID-06 text plus the CL-002 boundary |
| ChemicalFormKind | CRYSTAL_FORM, AMORPHOUS_FORM, PARTICLE_SIZE_GRADE, OTHER_PHYSICAL_FORM | ChemicalForm.formKind | CRYSTAL_FORM is from the 0.2.0 fixture |
| BotanicalPreparationType | POWDERED_HERBAL_SUBSTANCE, DRY_EXTRACT, SOFT_EXTRACT, LIQUID_EXTRACT, TINCTURE, ESSENTIAL_OIL, FATTY_OIL, EXPRESSED_JUICE, OTHER_PREPARATION | BotanicalPreparation | EMA monograph vocabulary (M-10 uses 'Dry extract', 'Powdered herbal substance') |
| ViabilityState | VIABLE, VIABLE_SPORES, INACTIVATED, CELL_FRACTION_OR_LYSATE | MicrobialPreparation | null = not stated |
| MixtureKind | PROPRIETARY_BLEND, NAMED_COMPLEX, PREMIX, CO_PROCESSED_MATERIAL | MaterialMixture | — |
| ConstituentKind | CHEMICAL_CLASS, ANALYTICAL_MEASURAND, NON_SPECIFIC_FRACTION | Constituent | — |
| NutrientKind | VITAMIN, MINERAL, MACRONUTRIENT, FATTY_ACID, AMINO_ACID, OTHER_NUTRIENT | Nutrient | — |
| TaxonRank | GENUS, SPECIES, SUBSPECIES, VARIETY, FORMA, CULTIVAR, OTHER_RANK | BotanicalTaxon | — |
| ContentBasis | MASS_FRACTION_W_W, VOLUME_FRACTION_V_V, AMOUNT_PER_MASS_OF_MATERIAL, ACTIVITY_PER_MASS_OF_MATERIAL, MOLAR_RATIO | RP-1.basis | — |
| QuantityComparator | EQ, APPROX, GE, GT, LE, LT, BETWEEN | RP-1.comparator | — |
| ContentStatementKind | STANDARDIZATION_CLAIM, DEFINITIONAL_COMPOSITION, TYPICAL_COMPOSITION_REPORTED, CALCULATED | RP-1 | Excludes spec limits (W12) and measurements (W12) |

Referenced, not owned: `MassBasis`, `AmountReferent` (W00 kernel), `MaterialIdentityLevel` (W10). The W02 identity facts (Q-04) are input to W10's level.

## CANDIDATE elements (cards only; not in SDL)

| Element | Why it is candidate | What would admit it |
|---|---|---|
| `REALIZES_MOLECULAR_ENTITY` (IngredientMaterial → MolecularEntity) | Protein or enzyme ingredients; no CQ yet | A CQ comparing an enzyme supplement with an enzyme target study (W03 seam SR-07) |
| `MEMBER_OF_CONSTITUENT_CLASS` (ChemicalSubstance → Constituent) | "lycopene is a carotenoid" | A CQ asking whether a class-level claim covers a substance |
| Mixture component proportion on HAS_MIXTURE_COMPONENT | Mosaic gives only a blend total | A label or spec that states component proportions |
| Material-level CFU per gram | Counts appear at component level | A strain-specific count CQ (OPEN-QUESTIONS P1-5) |
| `ChemicalSubstance.netCharge` | Would let ionic moieties be recognised without the HAS_ACTIVE_MOIETY inverse | A case where no salt record exists but the moiety is ionic |
