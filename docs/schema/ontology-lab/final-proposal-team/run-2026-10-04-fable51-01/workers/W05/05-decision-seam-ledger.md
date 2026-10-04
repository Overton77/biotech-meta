# W05 decision and seam ledger

Status values: **ACCEPTED-FOR-PROPOSAL** (W05 proposes it; Fable rules), **UNRESOLVED** (depends on another owner), **DEFERRED**. Nothing here is a ruling; no consensus with other workers is claimed. Source ids S1–S8 refer to `03-source-manifest.md`.

## Decisions

| Id | Decision | Evidence | Alternatives and why rejected | Status | Depends on |
|---|---|---|---|---|---|
| D-W05-01 | `FoodItem` is a specialization of `IngredientMaterial` (labels `FoodItem`,`IngredientMaterial`,`Entity`; uid token `material`). | Same food is used by a study arm (S4), by a product formulation (fixture 03), and carries composition (S1); catalog precedent `BotanicalPreparation: parentLabel IngredientMaterial`. | Standalone food identity (two identities, parallel composition); retire FoodItem into IngredientMaterial (loses identity text, preparation variants, search index). | ACCEPTED-FOR-PROPOSAL | W05-SR-02 |
| D-W05-02 | Live `FoodProduct` is retired; a marketed food is a W04 `Product` with `productKind CONVENTIONAL_FOOD`; migration relabels in place. | FDC Branded Foods are label data "received from food industry data providers" (S2), i.e. W04 label facts; every live FoodProduct field has a W04/W01 home. | Specialization label `["FoodProduct","Product","Entity"]` would duplicate W04 fields in a second GraphQL type with nothing food-specific. | ACCEPTED-FOR-PROPOSAL | W05-SR-15, W05-SR-16 |
| D-W05-03 | `Exposure` is an Entity: an immutable characterization tuple with `characterizationHash`; statements about it (RfD, population descriptions) are Assertions with the Exposure as subject. | IRIS characterizes "Chronic Oral Exposure" with intakes "based on lifetime exposure", a body-weight assumption and an RfD derived by UF (S5, S6). | Occurrence (privacy, brief); VersionedState (no changing state); fields for RfD on the node (would make a reference value look like a property of the exposure). | ACCEPTED-FOR-PROPOSAL | W05-SR-01, W05-SR-12, W05-SR-13 |
| D-W05-04 | `Lifestyle` is a practice concept; a named, defined regimen is a W16 `Protocol`; who reports doing versus who recommends is carried by Assertions with `speechAct`. | DICA-NUTS names a "Brazilian cardioprotective diet prescription" without content (S3); kernel forbidden implication [REPORTS_PRACTICE, RECOMMENDS]. | Lifestyle-with-components taxonomy (source-specific definitions would collide); recommendation as a Lifestyle property. | ACCEPTED-FOR-PROPOSAL | W05-SR-06, W05-SR-08, W05-SR-11 |
| D-W05-05 | The Exposure use of live `INVOLVES` is renamed `HAS_EXPOSURE_AGENT` (structural). | One type, one meaning (CL-014 precedent); W18 keeps Event `INVOLVES`. | Keep `INVOLVES` with two meanings. | ACCEPTED-FOR-PROPOSAL | W05-SR-10 |
| D-W05-06 | `CONTAINS_COMPOUND` and `HAS_INGREDIENT` are retired. Food composition uses W02 `QUANTITATIVELY_CONTAINS` / `PROVIDES_CONSTITUENT`; product composition uses the W04 component path. W05 does not define a composition property type. | S1/S2: per-100 g edible-portion basis, derivation codes, spread; live `DoseMetadata` has none of these. | W05 `FoodCompositionProperties` (two property types for one relationship type); a parallel `HAS_COMPOSITION_VALUE` edge. | ACCEPTED-FOR-PROPOSAL (fallback CANDIDATE kept) | W05-SR-04 |
| D-W05-07 | `VARIANT_OF` kept, class asserted, with `FoodVariantProperties.variantKind`. | FDC descriptions encode preparation ("dried, unblanched"); trials name only the base food (S3, S4); FDC states no base–variant link. | Structural (it is curation, so it needs an asserter); drop it (CQ-FL-C01 then cannot say "studied preparation unknown"). | ACCEPTED-FOR-PROPOSAL | none |
| D-W05-08 | Diet and lifestyle arms are composite interventions: one `InterventionComponent` per practice definition (to `Protocol`/`Lifestyle`) and per food (to `FoodItem` with amount and basis). The registry intervention type is kept verbatim and never creates a Product. | S3: "Brazilian cardioprotective diet plus 30g/day of nuts (10g of peanuts, 10g of cashew nuts and 10g of Brazil nuts)", type DIETARY_SUPPLEMENT. | One free-text component; Lifestyle composite edge. | UNRESOLVED (needs W09 edge + V-221 refinement) | W05-SR-06 |
| D-W05-09 | No universal nutrition taxonomy: `foodGroup` requires `foodGroupSystem`; no group-membership edges. | S2: "Each FoodData Central datatype uses its own food categorization system". | A shared FoodGroup node hierarchy. | ACCEPTED-FOR-PROPOSAL | none |
| D-W05-10 | Definition versus execution: StudyIntervention, ProtocolStep, Exposure and Lifestyle are definitions; a person's intake, sessions or exposure history live only in the private store. No edge relates a ProtocolStep and an Exposure. | Contract A9; negatives N2 and N7 (V-W05-06, V-W05-10). | `Exposure` with participant/time fields; step-to-exposure derivation. | ACCEPTED-FOR-PROPOSAL | W05-SR-08, W23 contract |
| D-W05-11 | `ExposureAgentTarget` omits `FoodItem`; FoodItem nodes resolve through `IngredientMaterial`. Proposed general rule: unions never list a specialization beside its parent. | Run under `@neo4j/graphql` 7.6.3 + Neo4j 5.26.31: one agent edge returned twice when both members were present; once FoodItem was removed, it returned once (`08-completion-report.md`). | Keep both and dedupe in clients. | ACCEPTED-FOR-PROPOSAL; general rule UNRESOLVED | W05-SR-09 |
| D-W05-12 | Candidate module `food_lifestyle_exposure` (FoodItem, Exposure, Lifestyle, VARIANT_OF, HAS_EXPOSURE_AGENT, four enums). | No module owns these (catalog `liveSeamTypes`; T-005). | Distribute to substances (FoodItem), safety (Exposure), protocols (Lifestyle). Possible later; keeping them together preserves the exposure/practice/food boundary tests. | ACCEPTED-FOR-PROPOSAL | Fable (T-005) |

## Objections considered (adversarial)

| Objection | Counterexample | Response |
|---|---|---|
| "A food is not an ingredient material; FoodItem as IngredientMaterial pollutes material equivalence." | Material equivalence queries (CQ-ID-06) might match a supplement's "broccoli extract" to "Broccoli, raw". | They are different materials (different uids); equivalence never follows names (V-W05-12 and W02 rules). `materialKind FOOD` lets W02 queries filter. W02 may still refuse (W05-SR-02); fallback documented in 01 §4. |
| "Exposure duplicates W03 MechanismEvidenceContext exposure fields." | Both carry amount/unit/basis/route/duration. | The W03 node is the Occurrence of one tested group linked to a mechanism assertion; Exposure is a reusable characterization not tied to a group. ExposureBasis is shared (reused, not copied). Route vocabularies are reconciled in W05-SR-05(b). |
| "Without an edge from ProtocolStep to Exposure, CQ-FL-C02 cannot compare them." | Fixture 04. | Comparison is by shared agent path (Q-FL-C02) and, for applicability, by W10 EXPOSURE dimensions (W05-SR-18); a direct edge would encode the forbidden implication. |
| "PER_100_G should go into kernel QuantityBasis." | FDC composition basis. | QuantityBasis values are dose bases (PER_DAY, PER_SERVING ...); a composition basis is a concentration referent; mixing them would let a per-100 g value pass as a dose. Kept on W02's property type (W05-SR-04). No kernel change requested. |

## Kernel-change requests

None. W05-SR-09 (union rule) and W05-SR-01 (tokens) are contract additions, not kernel semantics changes; both cite a failing case.

## Open items with closure criteria

| Item | Owner | Closure criterion |
|---|---|---|
| V-221 exemption for practice-definition components | W09 | V-221 returns no rows on fixture 02 |
| V-231 scope (MECHANISM only) | W03 | V-231 returns no rows for QUANTITY assertions on fixture 01 |
| `assertionUid` vs `projectionOfAssertionUid` on RECOMMENDS | W00/W21 | one name in contract; V-112 and V-423 read the same field |
| Composition qualifiers | W02 | W02's `QuantitativeContentProperties` contains the W05-SR-04 fields; V-W05-07 reads them |
| Physical agents, source-defined food groups | W05 (future) | a retrieved record and a failing fixture for CQ-FL-C05 |
