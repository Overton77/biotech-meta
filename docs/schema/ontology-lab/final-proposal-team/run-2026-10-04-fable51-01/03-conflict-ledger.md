# 03 Conflict ledger and seam requests

Record format (handoff section 3): id; competing representations and owners; baseline rule; affected CQ/query/failure; exact source locators; smallest failing fixture; alternatives; migration consequences; proposed ruling; resolver; status (OPEN, PROPOSED, RULED, DEFERRED). Ownership is never settled by majority or by similar naming. Unresolved conflicts are deferred with preserved public interfaces or block the dependent output; no two types ever represent one canonical identity.

Workers append structured requests to their own `seam-requests.yaml`; Fable copies them here with an id and assigns a resolver.

## Seeded records (mandatory seam checks from the handoff)

| Id | Seam | Competing representations | Baseline rule | Resolver | Status |
|---|---|---|---|---|---|
| CL-001 | ChemicalSubstance versus Compound | live `Compound` (substances and combinations mixed) vs catalog `ChemicalSubstance` | round 0002 R11: catalog name wins | W02 (W00 confirms) | RULED by D-002; W02 supplies the migration map and the "NRPT is not a substance" fixture |
| CL-002 | ChemicalForm vs IngredientMaterial vs dosage form; `MolecularEntity` placement | live `CompoundForm`; catalog three-way split; `MolecularEntity` (mechanisms) vs `ChemicalSubstance` | round 0002; mechanisms module owns `MolecularEntity` | W02 with W03, W00 | OPEN: W02 proposes the boundary (gene/protein targets stay `MolecularEntity`; small molecules are `ChemicalSubstance`) with a failing case |
| CL-003 | Source vs Document vs Publication vs Episode | four identities for "a paper", "a page", "a talk" | D-005 | W19 proposes, W20/W21/W09 respond, W00 rules | PROPOSED by D-005; workers supply minimal pairs (transcript page vs video rendition vs the work; article vs its DOI work vs PDF rendition) |
| CL-004 | Claim identity vs Assertion occurrence | live `Claim` with evidenceStrength; `ClaimOccurrence` without assertion fields | D-006; KCR-4.3 | W21 (W00 confirms) | RULED by D-006; W21 supplies the two-speaker split fixture |
| CL-005 | live `Material` vs `IngredientMaterial` | process inputs (solvents, reagents) vs ingredient identities | alignment: "same uid when a Material is an IngredientMaterial" | W02 with W11 | OPEN: W11 must show a process-input case that `IngredientMaterial` cannot carry, else `Material` is retired (D-008) |
| CL-006 | `StudyIntervention` node vs same-named live union | catalog node vs live union (`ArmIntervention` device) | D-003 | W09 | RULED by D-003; W09 writes `LegacyEvaluatedIntervention` and the read-only `Study.evaluates` |
| CL-007 | `ProtocolEdition` vs study `ProtocolVersion` | public workflow state vs study protocol document | catalog: different archetypes | W16 with W09 | RULED (catalog); workers supply the "same PDF is both" minimal pair if one exists |
| CL-008 | public `Observation` vs `DiagnosticResult` contract vs private `PersonalMeasurement` | three result kinds | round 0008; INV-506 | W16 with W07, W23 | RULED (catalog); W16 implements `Observation` as `DiagnosticResult` implementer; W23 documents the private contract |
| CL-009 | `assertionUid` vs `projectionOfAssertionUid` | asserted vs derived edge citation | D-011 | W00 | RULED |
| CL-010 | Specification ownership across W04/W11/W12 | one `SpecificationVersion` payload | D-009 | W11 | RULED; W12 references `SpecificationCriterion -> SpecificationVersion` |
| CL-011 | Media region locator vs asset annotation | `SourceLocator{IMAGE_REGION}` vs `MediaAnnotation` | D-010 | W22 with W00 | PROPOSED; W22 supplies the crop-from-label fixture |
| CL-012 | Source Intelligence research vs provenance canonical ownership | W19 candidates vs `Source` | contract A8 | W19 proposes, W00 rules | OPEN |
| CL-013 | `HAS_STEP` vs `HAS_PROTOCOL_STEP` | live `Protocol-[:HAS_STEP]->Step` vs catalog `ProtocolEdition-[:HAS_PROTOCOL_STEP]->Step`; manufacturing `HAS_STEP` | D-004 | W16 with W11 | RULED by D-004; W16 writes the projection note |
| CL-014 | `HAS_VARIANT` name used by products (Product→ProductVariant) and media (MediaAsset→MediaVariant) | same relationship type name, different meanings | one relationship type, one meaning | W22 renames to `HAS_MEDIA_VARIANT` | RULED |
| CL-015 | live `PhysicalLocation` vs catalog `Facility` | location record vs facility identity | none (seam) | W01 | OPEN |
| CL-016 | `Person.recommends` / `RECOMMENDS` | timeless edge vs projection of a RECOMMENDS speech-act occurrence | round 0008; V-423 | W21 with W01 | RULED (catalog): derived projection with `assertionUid`; W21 writes the SDL |
| CL-017 | `Study.evaluates` legacy edge | INV-201 | read-only legacy | W09 | RULED: `@settable(onCreate:false,onUpdate:false)` |
| CL-018 | `Observation` edges `Person.recordsObservations`, `CohortParticipant` | private-data risk inside shared graph | round 0008 | W16/W01 with W23 | OPEN: W23 states the public-person-only rule and the leak fixture |
