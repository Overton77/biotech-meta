# 02 Ownership and seam report

Baseline: `02-ownership-registry.md` (v0 at freeze). This report records how each seeded conflict and transfer placeholder was resolved by the packets and Fable's rulings, and the sole-writer additions admitted at merge (decision report section C; seam-closure ledger `04-seam-closure-ledger.md`). Canonical catalog ownership changes only where a row says so; research ownership never transferred a module by itself.

## 1. Seeded conflict records (03-conflict-ledger.md)

| Id | Seam | Resolution | Evidence |
|---|---|---|---|
| CL-001 | ChemicalSubstance vs Compound | RULED (D-002). Catalog name wins; migration map and NRPT fixture by W02. | W02 fx-06; GSRS UNII records |
| CL-002 | ChemicalForm / IngredientMaterial / dosage form; MolecularEntity boundary | RULED. The identity authority decides the type: anything identified by a chemical-structure authority is `ChemicalSubstance` (NAD+, NAAD included); genome-encoded actors (genes, proteins, enzymes such as CD38) are `MolecularEntity`; compartment-specific levels are W07 `Biomarker`s. Salts are their own substance with `HAS_ACTIVE_MOIETY`; `ChemicalForm` keeps physical forms. | W02 fx-07 and V-W02-06; W03 (PubChem CID 5892 one InChIKey) |
| CL-003 | Source vs Document vs Publication vs Episode | RULED. W19 R1–R5 adopted by W00: works (`Publication`, `Episode`) vs retrieval endpoints (`Source`/`Document`); `canonicalUri` is the post-redirect page, never doi.org; a DOI is an Identifier of the Publication; a Source renders at most one work; a slide deck is not a rendition of the talk (`ACCOMPANIES_TALK` / `PRESENTED_AT`); `renditionCoverage` candidate. | W19 minimal pairs (PMID 29184669 abstract vs full text), W21 Merck JPM case, W18 session model |
| CL-004 | Claim identity vs Assertion occurrence | RULED (D-006); two-speaker split fixture. | W21 fx05 |
| CL-005 | live Material vs IngredientMaterial | RULED: `Material` retired; no `ProcessMaterial`. | W11 (GRN 000635 process inputs), W02 |
| CL-006 | StudyIntervention node vs live union | RULED (D-003, MR-05: `LEGACY_EVALUATES`). | W09 |
| CL-007 | ProtocolEdition vs study ProtocolVersion | RULED (catalog). No real "same PDF is both" case was found; W16 documents the nearest pair; W09 keeps `ProtocolVersion` as an InformationArtifact. | W16, W09 |
| CL-008 | public Observation vs DiagnosticResult vs private PersonalMeasurement | RULED. `Observation` implements the `DiagnosticResult` interface with W07's exact field names/types (MR-03), labels include `DiagnosticResult`; `PersonalMeasurement` meets the contract through uid columns in the private store and is never an `Observation` (V-W23-05 catches a copied private value). | W07, W16, W23 |
| CL-009 | assertionUid vs projectionOfAssertionUid | RULED (D-011); V-W00-02/-11. | W00 |
| CL-010 | specification ownership | RULED (D-009); `CRITERION_OF_SPECIFICATION` (W12) → `SpecificationVersion` (W11); `criterionPurpose`, `thresholdUpper`, `limitStage` on W12's criterion. | W11, W12 |
| CL-011 | media region locator vs annotation | RULED (D-010); `LOCATES_REGION` + `mediaAnnotationUid`; coordinates on the ORIGINAL rendition. | W00 V-W00-03, W22 MP5 |
| CL-012 | Source Intelligence vs provenance | RULED. W19 writes candidates only (assessment, requirement, discovery occurrence sharing the Activity label); `Source` stays W00's. | W00, W19 |
| CL-013 | HAS_STEP vs HAS_PROTOCOL_STEP | RULED (D-004); order lives on the edge; V-525/V-526 restated. | W16, W11 |
| CL-014 | HAS_VARIANT collision | RULED: `HAS_MEDIA_VARIANT`. | W22 |
| CL-015 | PhysicalLocation vs Facility | RULED: merge into `Facility` with location fields. | W01 |
| CL-016 | Person RECOMMENDS | RULED in D-011's favour: derived projection with `DerivedEdgeProperties`, licensed only by a RECOMMENDS speech-act occurrence; V-423 replaced by W21 V-W21-06. | W21 fx07 |
| CL-017 | Study.evaluates legacy | RULED: read-only (`@settable(onCreate:false,onUpdate:false)`), stored `LEGACY_EVALUATES`. | W09 |
| CL-018 | Observation edges from Person; CohortParticipant | RULED. `RECORDS`/`POSTS_RESULT` are projections of source-attributed assertions between PUBLIC records only; `HAS_PARTICIPANT_TOKEN` retired; `participantToken` only as printed by a public source. | W23, W01 |

## 2. Transfer placeholders

| Id | Concept | Ruling |
|---|---|---|
| T-001 | `Trademark` | No transfer; stays products_and_formulations; W14 writes the SDL. |
| T-002 | specification/process types | Specification pair stays in products_and_formulations; `ManufacturingProcess`, `ManufacturingStep` and their edges move to manufacturing_readiness, which is promoted from candidate to provisional in the catalog change set (W11 proposal; W04's packet raises no objection). Recorded as a catalog change in CHANGELOG at Wave 6. |
| T-003 | `DocumentTextVersion` | No transfer; W20 writes the SDL under provenance ownership. |
| T-004 | `PhysicalLocation` | Merged into `Facility` (organizations). |
| T-005 | unowned live interventions/foods | Candidate modules `interventions` (Treatment, Procedure; W06) and `food_lifestyle_exposure` (FoodItem, Exposure, Lifestyle; W05) opened as candidates; FoodProduct retired. |

## 3. Name collisions removed at merge (MR-04..MR-08)

`HAS_SNAPSHOT` (→ `HAS_STATE` for entity→state caches), `EVALUATES` (→ `LEGACY_EVALUATES`), `MENTIONS` (kernel only; retrieval mentions renamed per W00), `HAS_VARIANT` (→ `HAS_MEDIA_VARIANT`), `INVOLVES` (events only; `HAS_EXPOSURE_AGENT`), `ABOUT` (W20 retrieval; W18 `EVENT_ABOUT`/`ARC_ABOUT`), `HAS_EVENT` (conference; arcs use `ARC_INCLUDES_EVENT`), `FOR_METRIC` (one shared structural type), `MEASURED_IN` (W03 only), `IDENTIFIED_BY` (→ `HAS_IDENTIFIER`), `COMPARES` (W07) vs `COMPARES_IDENTITIES` (W00; V-432 corrected), `ASSESSES_CLAIM` (EvidenceSynthesis only; W21 uses `ASSESSES_CLAIM_EVIDENCE`).

## 4. Seam-request accounting

389 seam requests from 24 packets (`validation/inventories/seam-requests-consolidated.json`): 155 addressed to W00 (ruled in `workers/W00/09-kernel-reconciliation.md`), 70 to Fable (ruled in `03-decision-report.md` sections B–D), the rest between domain owners (answered in the owners' `05-decision-seam-ledger.md`; cross-owner field, union and enum slots closed mechanically in `04-seam-closure-ledger.md`). Unresolved items are listed in the final summary as deferred with their closure criteria; none blocks the proposal.
