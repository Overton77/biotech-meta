# W11 Domain recommendation: manufacturing, specifications and supply readiness

Run `run-2026-10-04-fable51-01`, worker W11 (Opus 5.5). Inputs: contract `01-shared-contract.md` (D-004, D-008, D-009), registry row W11, T-002, CL-005, CL-010, catalog 0.2.0 (`8fb50ff0…84f0`), live schema (`86b5e0b5…f112`) lines 1496-1544, round 0005, `examples/filing-vs-capability.cypher`.

## 1. Boundary

W11 answers four questions and nothing else:

1. **How is a material made?** `ManufacturingProcess` (identity of a described route) with ordered `ManufacturingStep`s and asserted inputs/outputs.
2. **Which specification governs a material, in which version?** `ManufacturingSpecification` (identity) and `SpecificationVersion` (the one immutable payload, D-009).
3. **Who can make it, where, at what stage and stated capacity, according to whom?** `ManufacturingCapability` states attached to an `Organization` or `Facility` by asserted, bitemporal `HAS_CAPABILITY_STATE` episodes.
4. **Who performs or hosts a process?** asserted `PERFORMS_PROCESS` (Organization) and `HOSTS_PROCESS` (Facility).

Out of scope, owned elsewhere and referenced by name: facilities and organizations (W01); material and substance identity (W02); formulation components (W04); criteria, lots, results, CoAs, certification listings and scope (W12); registration, inspection and regulatory status (W13); equipment and platforms (W08); supply and manufacture roles as predicates (`SUPPLIES_INGREDIENT_MATERIAL`, `MANUFACTURES_PRODUCT`, `CONTRACT_MANUFACTURES_FOR`, `OWNS_SPECIFICATION`, `CLAIMS_CGMP_COMPLIANCE`: catalog organizations predicates, W01).

Subdomains: specification governance (products_and_formulations), process description, readiness (manufacturing_readiness).

## 2. Identity, state, artifact, occurrence

| Element | Archetype | Why |
|---|---|---|
| `ManufacturingSpecification` | Entity | Enduring named specification of one owner; its content changes only by new versions. |
| `SpecificationVersion` | VersionedState | Immutable payload; identical payload hash = identical version; attached to materials through asserted episodes. |
| `ManufacturingProcess` | Entity | A described route; a different route is a different identity, not a state change. |
| `ManufacturingStep` | Entity | Structural part of exactly one process (HAS_STEP, structural, ordered). |
| `ManufacturingCapability` | VersionedState | Stage and capacity change over bounded intervals and are disputed (round 0005). |
| batch / campaign / inspection | Occurrence, not W11 | Lots are W12 `ProductLot`; inspections are W13's candidate `RegulatoryInspection` (seam W11-SR-10). |

No InformationArtifact or Assertion types are added: filings, dossiers and pages are `Source`/`SourceSnapshot`; what they state is an `Assertion`; what BellLabs relies on is an `Adjudication` (round 0005, architecture section 10).

## 3. Disposition of every live and catalog element in scope

| Element | Origin | Disposition | Final |
|---|---|---|---|
| `ManufacturingProcess` | live + cat | merge (same name) | `ManufacturingProcess` (`["ManufacturingProcess","Entity"]`) |
| `ManufacturingProcess.processClass` | live | rename + refine | `processKind: ProcessKind`; unmapped strings kept in `processKindVerbatim` |
| `ManufacturingProcess.qualitySystemKind` | live | retire to assertion | `CLAIMS_CGMP_COMPLIANCE` Assertion (or a W12 `CertificationListing` when a certifier record exists); never a process property |
| `ManufacturingProcess.productionScale` | live | move | `ManufacturingCapability.capacityValue/capacityUnitCode/capacityBasis/capacityVerbatim` |
| `ManufacturingProcess.processTechnologySummary` | live | keep (presentation) | same |
| `ManufacturingProcess.hasSteps` / `HAS_STEP` (OrderingMetadata) | live | keep, refine | `steps` / `HAS_STEP` structural with `StructuralEdgeProperties.orderIndex` (D-004: manufacturing only) |
| `ManufacturingProcess.inputsMaterials` / `INPUTS` (DoseMetadata) | live | refine | `inputMaterials` (IngredientMaterial) + `inputSubstances` (ChemicalSubstance), asserted, `ProcessIoProperties` |
| `ManufacturingProcess.outputsMaterials` / `OUTPUTS` | live | split | product of record -> `PRODUCED_BY_PROCESS`; intermediates and by-products -> step-level `OUTPUTS` |
| `ManufacturingProcess.producesMaterials` / `PRODUCES` | live | merge | inverse view of catalog `PRODUCED_BY_PROCESS` (IngredientMaterial -> ManufacturingProcess); one relationship, one meaning |
| `ManufacturingProcess.supportedBy` / `SUPPORTED_BY` (Chunk) | live | retire | provenance through Assertions and `SourceLocator`; chunk links are W20's derived `SUPPORTED_BY_CHUNK` (INV-404) |
| `ManufacturingStep` | live + cat | keep | `["ManufacturingStep","Entity"]` |
| `ManufacturingStep.stepClass` | live | rename | `stepKind` (controlled string, candidate `StepKind`) |
| `ManufacturingStep.operationKind`, `environmentGrade` | live | keep (verbatim) | same |
| `ManufacturingStep.hasInputMaterials` / `HAS_INPUT` | live | merge | `INPUTS` (one type for process and step level) |
| `ManufacturingStep.hasOutputMaterials` / `HAS_OUTPUT` | live | merge | `OUTPUTS` |
| `ManufacturingStep.usesEquipment`, `usesPlatforms` (UsageMetadata) | live | keep, re-type | W08 relationship types with W08 `UsageEdgeProperties` |
| `ManufacturingStep.supportedBy` | live | retire | as for process |
| `Material` | live | **retire** (CL-005, D-008) | ingredient materials -> `IngredientMaterial` same uid; non-ingredient chemical inputs and intermediates -> `ChemicalSubstance`; no `ProcessMaterial` (section 5) |
| `Material.materialType`, `materialGrade` | live | move | `IngredientMaterial.materialKind` (W02) / `ProcessIoProperties.gradeText` (per use) |
| `Material.regulatoryCategoryHint` | live | retire to W13 | `RegulatoryStatus` (round 0005 alignment) |
| `Material.traceabilityCode` | live | move to W12 | `ProductLot` / material lot identifier |
| `Material.partOfProducts` / `PART_OF` (DoseMetadata) | live | retire (derived) | composition only through `FormulationVersion -> IngredientComponent -> USES_MATERIAL` (INV-005, W04) |
| `Organization.performsProcesses` / `PERFORMS_PROCESS` (RoleMetadata) | live | keep, re-class | asserted `PERFORMS_PROCESS` with `AssertedEdgeProperties`; field slot on Organization supplied to W01 (W11-SR-06) |
| `PhysicalLocation.hostsProcesses` / `HOSTS_PROCESS` (TemporalMetadata) | live | keep, re-target | `Facility -[:HOSTS_PROCESS]-> ManufacturingProcess`, asserted (W01 merges PhysicalLocation into Facility, CL-015) |
| `LocationType.GMP_FACILITY`, `PILOT_PLANT` | live (W01 enum) | seam | GMP is a claim or a certification, piloting is a capability stage; W01 asked to deprecate both values (W11-SR-07) |
| `ManufacturingSpecification` | cat | keep | + `specificationKind`, `documentIdentifier` |
| `SpecificationVersion` | cat | keep, refine | + `revisionIdentifier`, per-bound effective precision, `criteriaCount`, `criteriaCaptureCompleteness`, `criteriaDigest`; payload rule fixed (section 4) |
| `GOVERNED_BY_SPECIFICATION` | cat | keep | asserted, EXCLUSIVE per (material, specification) (W11-SR-04) |
| `VERSION_OF_SPECIFICATION` | cat | keep | structural, exactly one |
| `PRODUCED_BY_PROCESS` | cat | keep | asserted, NONEXCLUSIVE (dual sourcing, route change) |
| `ManufacturingCapability` | cat + delta | keep, refine | + `capacityVerbatim`, `targetOperationalDatePrecision`; archetype label VersionedState (delta had none) |
| `HAS_CAPABILITY_STATE` | cat | keep | asserted_edge; delta's `AssertedTemporalMetadata` -> `AssertedEdgeProperties`; holders Organization and Facility (delta's PhysicalLocation -> Facility) |
| `CAPABILITY_FOR_PROCESS`, `CAPABILITY_FOR_MATERIAL` | cat | keep | structural, zero_or_one each |
| `CapabilityStage`, `CapacityBasis` | cat/delta | keep (frozen values) | same |
| `ProcessKind` | new values | add | catalog names the property without values (W11-SR-01) |
| `ProcessIoProperties` | new | add | successor of DoseMetadata on I/O edges |
| `ProcessMaterial` | registry candidate | **not added** | stays CANDIDATE in model cards with closure criterion |

## 4. What a SpecificationVersion payload holds (D-009, research-settled)

Captured records (03-source-manifest.md W11-S08..S10):

- The GRN 000635 notifier dossier (2015) prints a "Specifications and Batch Analyses" table: parameter, specification, method identifier (for example `99.1-CD-7.0-000115`), batch results. It states **no version label and no effective date**.
- EFSA Journal 2019;17(8):5775 prints the applicant's proposed specification table with different residual-solvent limits (acetone 5,000 vs 3,000 mg/kg; methanol 1,000 vs 740 mg/kg; water 2.0 vs 1 %) and an assay limit (>= 90 %) that EFSA says was set "to account for the degradation ... over the course of shelf-life". Again no version label.
- The USP NRCl monograph is announced as "expected to be codified and enforced in October 2026"; its text is licensed (criteria not capturable here).

Consequences, adopted in the SDL:

1. The payload is: optional source-stated `versionName` and `revisionIdentifier`, effective bounds with precision, and the **criteria set**, which W12 owns as `SpecificationCriterion` nodes. The version carries `criteriaCount`, `criteriaCaptureCompleteness` and `criteriaDigest` so that an unknown criteria set (USP) is never read as "no criteria", and so that two versions are comparable without loading W12 nodes. `payloadHash` = sha256 over canonical JSON of the version fields plus `criteriaDigest`.
2. Version identity does not depend on a public version label (neither Niagen dossier has one). Two captures with identical payload are one version.
3. A criterion's limit stage is part of the payload: the EFSA assay limit is a shelf-life limit, the dossier's is unstated. Without a `limitStage` field on `SpecificationCriterion`, a release/shelf-life difference reads as a specification change (W11-SR-03 to W12; closes part of OPEN-QUESTIONS Priority 2 quality item 2 for the representation, not for the values).
4. A range needs a lower and an upper bound (`95-102 wt%`): W12 is asked for `thresholdUpper` (W11-SR-03).

## 5. CL-005: is there a process input `IngredientMaterial` cannot carry?

The GRN 000635 dossier lists the inputs of the NR chloride synthesis: D-ribofuranose tetra-acetate, acetonitrile, gaseous hydrogen chloride, nicotinamide, the isolated intermediate nicotinamide-beta-riboside triacetate chloride, methanol, ammonium hydroxide, methyl t-butyl ether, acetone. Classification:

- **nicotinamide** is a dietary-ingredient material: one `IngredientMaterial` uid serves as process input (`INPUTS`, role STARTING_MATERIAL) and as component material (`USES_MATERIAL`). Fixture 03, Q-MF-C05.
- **solvents, reagents and the intermediate** are chemically defined and are not ingredients: they are carried by `ChemicalSubstance` (W02) with per-use role and grade on `ProcessIoProperties`. They never enter `CONTAINS` (composition goes through IngredientComponent only), and residual limits for them are W12 criteria whose analyte is a substance.

No input in the captured cases needs an identity that is neither an ingredient material nor a chemical substance. **Recommendation: retire live `Material`; do not add `ProcessMaterial`.** Closure criterion for reopening: a process input whose identity (not just grade) matters to a CQ and is neither chemically defined nor an ingredient material (for example a chromatography resin lot or a cell bank), with a source and a failing query.

## 6. T-002 proposal: module placement

- **Keep** `ManufacturingSpecification`, `SpecificationVersion`, `GOVERNED_BY_SPECIFICATION`, `VERSION_OF_SPECIFICATION` in **products_and_formulations**. Consumers are products (W04), quality criteria (W12), lots (`MANUFACTURED_UNDER`) and applicability (`materialIdentityLevel` SAME_BRANDED_MATERIAL_SAME_SPEC). Moving them into a candidate module would make provisional modules depend on a candidate one.
- **Move** `ManufacturingProcess`, `ManufacturingStep`, `HAS_STEP`, `PRODUCED_BY_PROCESS`, `INPUTS`, `OUTPUTS`, `PERFORMS_PROCESS`, `HOSTS_PROCESS` to **manufacturing_readiness**, and promote that module to provisional. Reasons: no products_and_formulations CQ (CQ-PF-01..04) needs a process; every process consumer (capability, performer, host, CQ-MF-01/04) is already in manufacturing_readiness or organizations; manufacturing_readiness already depends on products_and_formulations, so the move creates no back-dependency; a label/formulation projection no longer carries process types.
- Until Fable rules (with W04 agreement, registry T-002), the baseline assignment stands; the SDL is unaffected either way.

## 7. Alternatives considered

| Alternative | Rejected because |
|---|---|
| "Promoted" as a fifth `CapabilityStage` | round 0005 C7; promotion is source context; NAI's page and 10-Ks describe the same facility at once. |
| Capability as a property set on Facility | loses PLANNED -> OPERATING -> SUSPENDED -> OPERATING history (NAI Carlsbad 2021-2024) and disputed attribution. |
| `ProcessMaterial` label for solvents/reagents | duplicates `ChemicalSubstance`; no failing case (section 5). |
| Criteria as a JSON blob on SpecificationVersion | W12 must evaluate `MeasuredResult -> SpecificationCriterion`; blobs defeat V-W11-09 and result evaluation. |
| A spec change always creates a new BrandedIngredientMaterial | Niagen dossiers 2015/2019 differ in limits for the same branded material; identity is W02's rule on form, grade, taxon, strain. |
| A utilization ratio computed by the schema from NAMEPLATE and UTILIZED states | Cyanotech's nameplate (2002, m2) and Meridian's utilization (2018, % of astaxanthin ponds) differ in time, scope and asserter; a ratio would be fabricated. |
| Keeping live `PRODUCES` beside `PRODUCED_BY_PROCESS` | two relationship types, one meaning. |

## 8. Smallest recommended model

Five node types, three enums, one relationship-property type, eleven relationship types (`sdl-fragment.graphql`), plus requests: three uid tokens (W00), exclusivity entries (W00), criterion edge and two criterion fields (W12), field slots on Organization/Facility/IngredientMaterial (W01/W02), two candidate predicates (W01/W00), a candidate inspection occurrence (W13), and two forbidden implications (catalog).
