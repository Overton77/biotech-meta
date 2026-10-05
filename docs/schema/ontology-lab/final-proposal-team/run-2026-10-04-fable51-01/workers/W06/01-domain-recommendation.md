# W06 Treatments, procedures and intervention modalities: domain recommendation

Worker W06 (Opus 5.5), run `run-2026-10-04-fable51-01`, registry row W06 and transfer placeholder T-005. Authority: frozen contract `01-shared-contract.md`; catalog 0.2.0 (digest `8fb50ff0…84f0`), where `Treatment` and `Procedure` appear only in `conventions.liveSeamTypes`; live schema digest `86b5e0b5…f112`, lines 241–260, 692, 705–718, 824–876, 1597 and 1760.

## 1. Boundary in one paragraph

W06 covers two **definitions**. `Treatment` is a therapeutic intervention concept: what kind of intervention it is. `Procedure` is a procedure definition. W06 also owns the modality classification, the source-stated intent (`TARGETS_CONDITION`), the composition (`USES_COMPONENT`) and the asserted organization roles toward these definitions. Every other aspect of an intervention belongs to another owner:

| What it is | Owner | Archetype |
|---|---|---|
| The intervention one study arm received, with dose, route, schedule and components | W09 `StudyIntervention`, `InterventionComponent` | VersionedState |
| A marketed or investigational product (CASGEVY, RADICAVA) | W04 `Product` | Entity |
| Approval, designation, indication, jurisdiction and dates | W13 `RegulatoryStatus` (`DrugApproval`, `OrphanDesignation`) | VersionedState |
| A step of a public practice or research workflow that employs a procedure | W16 `ProtocolStep` | Entity (immutable payload of an edition) |
| A listing, an offer, a price or a session bundle | W15 `MerchantListing`, `Offer`, `PriceObservation` | Entity, VersionedState, Occurrence |
| Harms | W17 `SafetySignal` / W09 `AdverseEventResult` | — |
| Benefit claims on a practice page | W21 `ClaimOccurrence` | Assertion |
| A performance, session, encounter or a person's course of treatment | **not modeled**. There is no shared patient or care-record graph (`architecture.md` §15: "Genomics and clinical care are not modeled"). Private execution stays outside the graph (INV-506, W23). | (Occurrence, private) |

The model keeps three pairs apart:

- **Treatment intent is not a result.** `TARGETS_CONDITION` records that a developer, a label restatement, a registry, an offerer or the literature says the concept is *intended* for a condition. It never says the concept works (that is W09 `StudyResult` plus W10 assessments). It is also never the approved indication (that is W13 `DrugApproval.indication`, which is jurisdiction- and time-bound).
- **A procedure definition is not a performance.** A `Procedure` node is the definition "therapeutic plasma exchange". The 1,000-plus sessions Circulate reports having delivered are not 1,000 nodes. That count is a literal assertion about the organization.
- **A treatment concept is not an administered intervention or a product.** For one drug name, the graph holds three identities that never collapse. The Treatment `exagamglogene autotemcel (exa-cel)` is the concept. The StudyIntervention "Exa-cel" is what the NCT03745287 arm received (registry type BIOLOGICAL, "a Single Dose"). The Product CASGEVY is Vertex's marketed product under STN 125787/125785 (fixture 01, query Q-01).

## 2. Subdomains

1. **Treatment concept identity.** A uid, plus nonproprietary names and development codes held as `Identifier` records. The FDA proper name "exagamglogene autotemcel" and the sponsor code "CTX001" are identifiers. "CASGEVY" is not, because it names the Product. The concept is never keyed on a tradename or a regulatory application number: STN 125787 and NDA 209176 are W13 submission identifiers.
2. **Procedure definition identity.** A uid plus classification codes. ICD-10-PCS `6A550Z3` "Pheresis of Plasma, Single" covers both donation plasmapheresis and therapeutic plasma exchange, and its Single versus Multiple axis encodes how many times the procedure was performed. A shared code is therefore never identity (V-W06-07, Q-07).
3. **Modality classification.** This is a list, because the CASGEVY label calls one concept both "an autologous genome edited hematopoietic stem cell-based gene therapy" and "a cellular gene therapy".
4. **Intent.** `TARGETS_CONDITION`, with `intentKind` and `intentBasis`.
5. **Composition.** `USES_COMPONENT`, with a required `componentRole`. Examples: the CASGEVY label's "obtained via apheresis procedure(s)" gives a STARTING_MATERIAL_COLLECTION component. The tie from proper name to tradename gives an ADMINISTERED_PRODUCT component.
6. **Roles.** `DEVELOPS_TREATMENT`, `OFFERS_TREATMENT` and `OFFERS_PROCEDURE` are asserted roles. Developing is not sponsoring, manufacturing or holding a designation. Offering is not performing, listing, hosting, recommending or being approved.
7. **Concept links from administered interventions.** These use W09's candidate relationship `FOLLOWS_INTERVENTION_DEFINITION` (StudyIntervention → `InterventionDefinitionTarget` = Procedure \| Treatment \| ProtocolEdition \| Lifestyle). W06 adopted it in place of its own earlier proposal of two separate relationship types, so that one meaning keeps one relationship type, and declares only the inverse views.
8. **Display projections.** `developmentStage`, `orphanDrugDesignation`, `regimenSummary`, `targetedPopulation`, `routeCategory`, `treatmentClass` and the Procedure summaries. All are presentation fields and none answers a regulatory or dose question.

## 3. Disposition of every live and catalog element in scope

"Keep" means the meaning is unchanged. "Refine" means the meaning is narrowed or typed. "Seam" means another owner decides. Full old-to-new rows are in `migration-map.yaml`.

### Treatment (live 849–876)

| Element | Disposition | Final form and reason |
|---|---|---|
| type `Treatment` | **keep, refine** | `["Treatment","Entity"]`, archetype Entity, `EntityArchetype`. Meaning narrowed to the *concept*, as in §1. |
| `id`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt` | keep | `name` becomes nullable (D-013). |
| `uid`, `entityType`, `privacyClass`, `maturity`, `schemaVersion` | add (contract B2) | — |
| `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` | keep | Regenerable (INV-107). `@vector` index `TreatmentSearchEmbedding` is kept by Fable without `provider:` (D-014); the justification is in `07-operations.md`. |
| `modality: TreatmentModality` | **split, refine** | `modalities: [TreatmentModality!]` is authoritative. `modality` stays as a read-only legacy projection that is non-null only when exactly one modality exists. Failing case: CASGEVY is CELL_THERAPY and GENE_THERAPY. |
| `treatmentClass` | keep | Display wording, never an enum. |
| `developmentStage` | **refine to a read-only display projection** | Written only by the projection job. The source is the latest `DECLARES_DEVELOPMENT_STAGE` assertion, which may be CALCULATED from a reachable ACCEPTED APPROVAL, or legacy text from migration. `developmentStageAssertionUid` names the source. Guards: V-W06-01 (V-322 pattern) and V-W06-02. Regulatory standing is W13's. Failing cases: edaravone "Approved" rests only on an unverified search extract, and the CASGEVY indication age changed from 12+ to 2+ on 2026-07-01. |
| `orphanDrugDesignation` | **seam to W13, kept as a read-only display** | Projected from the `OrphanDesignation` states reachable through `USES_COMPONENT{ADMINISTERED_PRODUCT}` → Product. `orphanDesignationStatusUids` names them. It never means approval (V-W06-03). This closes the live-schema-alignment round 0005 row "`Treatment.orphanDrugDesignation` → `RegulatoryStatus:OrphanDesignation`". |
| `routeCategory` | keep (display) | It is never an applicability input. Route is a W09/W10 dimension. |
| `regimenSummary` | keep (display) | It is never dose authority. Doses live on W09 `InterventionComponent`, W16 step dose or W04 `IngredientComponent`. |
| `targetedPopulation` | keep (display) | It is not a `StudyPopulation` and not an indication. |
| `targetsConditions` / `TARGETS_CONDITION` / `TreatmentTargetMetadata` | **keep, refine** | Becomes an asserted edge with the successor property type `TreatmentTargetProperties`: AssertedEdgeProperties plus `intentKind`, `intentBasis`, `indicationTextVerbatim`, `patientSubsetText` and `legacyEvidenceStrengthHint`. `evidenceStrength` becomes a hint and its assessment goes to W10 (INV-209). `confidence` and `notes` are dropped (INV-407). |
| `usesComponents` / `USES_COMPONENT` / `TreatmentComponentMetadata` | **keep, refine** | Asserted edge with `TreatmentComponentProperties`: AssertedEdgeProperties plus the required `componentRole` and verbatim role, dose, route, frequency and duration text plus `orderIndex`. |
| union `TreatmentComponent` | **rename and remap** | Becomes `TreatmentComponentTarget` = ChemicalSubstance \| ChemicalForm \| IngredientMaterial \| Product \| Device \| Procedure \| Protocol \| Lifestyle, following D-002 for Compound and CompoundForm. Live FoodProduct is dropped because W05 retires it into W04 Product (W06-SR-07). |
| `developedBy` / `DEVELOPS_TREATMENT` (RoleMetadata) | **keep, refine** | Asserted with `AssertedEdgeProperties`. The Organization field is W01's (W06-SR-06). |
| `offeredBy` / `OFFERS_TREATMENT` (RoleMetadata) | **keep, refine** | Same as above. |
| `evaluatedInStudies` / `EVALUATES` (InterventionArmMetadata) | **retire from Treatment** | The legacy `Study.evaluates` stays read-only on W09's side (D-003, CL-017). The concept link is `StudyIntervention -[:FOLLOWS_INTERVENTION_DEFINITION]-> Treatment` (W09). |
| `hasSafetySignals` / `HAS_SAFETY_SIGNAL` (SafetyMetadata) | keep (seam W17) | `SafetyEdgeProperties` from W17 (W06-SR-09). |
| `supportedByDocuments`, `supportedByChunks` | keep, now derived read-only | Use W20's `DerivedSupportProperties`. |
| `@fulltext TreatmentSearch` | keep (D-015) | Same fields. An `orphanDrugDesignation` hit is a lookup candidate, never an answer. |

### Procedure (live 824–847)

| Element | Disposition | Final form and reason |
|---|---|---|
| type `Procedure` | **keep, refine** | `["Procedure","Entity"]`, meaning narrowed to the definition. |
| `procedureType`, `setting`, `deliveryRoute`, `invasiveness`, `durationSummary`, `preparationSummary`, `recoverySummary` | keep (display) | Definition-level and source-attributed. They never record a performance (where or how long one session took). Null means not recorded. |
| `listedIn` / `LISTS_PROCEDURE` (TemporalMetadata) | seam to W15 | `ListingEdgeProperties`. A listing is not identity and not an offer. |
| `offeredBy` / `OFFERS_PROCEDURE` (RoleMetadata) | **keep, refine** | Asserted with `AssertedEdgeProperties`. |
| `hasSafetySignals`, `supportedBy*` | as on Treatment | — |
| (new) `identifiers`, `componentOfTreatments`, `instantiatedByStudyInterventions` | add | `HAS_IDENTIFIER` (W00), the inverse view of `USES_COMPONENT`, and the inverse view of W09's `FOLLOWS_INTERVENTION_DEFINITION`. |
| `@fulltext ProcedureSearch` | keep | — |

### Enum and unions

| Element | Disposition |
|---|---|
| `TreatmentModality` (12 live values) | **keep values verbatim**. The meaning of COMBINATION is narrowed to "regimen of components of different modalities", which needs at least two components (V-W06-05). New values such as GENOME_EDITING are not proposed. |
| `TreatmentComponentRole`, `TreatmentIntentKind`, `TreatmentIntentBasis` | **add**. They successor the free-text `role` and `indicationType`. Registry assignment is requested in W06-SR-01. |
| live union `StudyIntervention` (1597) | seam to W09. It becomes `LegacyEvaluatedIntervention` (D-003); Treatment and Procedure remain members. |
| `SafetySubject`, `Recommendable`, `ProtocolResultMention`, `EventParticipant`, `EventSubject`, `EvidenceSubject`, `ClaimSubject`, `AssociationParticipant`, `EpisodeMentionable`, `MediaSubject` | seam to their owners (W17, W21/W23, W16, W18, W21, W03, W21, W22). W06 asks that `Treatment` and `Procedure` stay members where the owner keeps the union. Under INV-508, `Recommendable` must not imply a timeless recommendation. |
| `TherapeuticTarget` (1760: Condition \| Outcome \| Mechanism) | not W06. It is W16's protocol `TARGETS` range (`TherapeuticTargetTarget`). `TARGETS_CONDITION` stays Condition-only. |
| `Organization.offersProcedures`, `developsTreatments`, `offersTreatments` (live 561–563) | seam to W01 (W06-SR-06). |
| `Condition.treatedBy` (live 1224) | seam to W03 (W06-SR-11): an optional read-only inverse field. |

## 4. Alternatives considered (evidence-linked)

| Alternative | Verdict | Deciding evidence |
|---|---|---|
| A1. Merge `Treatment` into W04 `Product` | rejected | OOPD 714319 designated "exagamglogene autotemcel" on 2020-04-28, before the CASGEVY tradename was approved in 2023. OOPD 465514 and NDA 209176 show two sponsors' products under one generic concept (edaravone for ALS). One Product per concept would break per-sponsor regulatory facts. |
| A2. Make `Treatment` a VersionedState carrying development stage | rejected | Stage is jurisdiction- and indication-specific regulatory or registry state (W13 `RegulatoryStatus`, W09 `RegistrationVersion.phase`). The CASGEVY indication age changed on 2026-07-01 while the concept stayed the same. |
| A3. Drop `Treatment`; use `ChemicalSubstance` plus `StudyIntervention` | rejected for cell, gene, procedure and regimen concepts; optional for small molecules | No substance identity exists for "autologous CD34+ HSCs edited by CRISPR/Cas9" (label §11) or for "plasmapheresis with albumin plus IVIG" (AMBAR NCT01561053). For a single small molecule, a Treatment node is created only when a concept-level fact is recorded. |
| A4. Add a `ProcedurePerformance` Occurrence | rejected | No CQ needs it. A performance is a person's record (privacy, INV-506). The Circulate session count is a literal assertion. |
| A5. Keep a single-valued `modality` with COMBINATION for multi-class concepts | rejected | The CASGEVY label: "autologous genome edited hematopoietic stem cell-based gene therapy" / "a cellular gene therapy". |
| A6. Add modality-specific properties (`cellSourceKind` AUTOLOGOUS/ALLOGENEIC, `vectorKind`, `editingTechnology`) | deferred as **scope candidates** SC-W06-01/02 | The autologous-collection fact in the CASGEVY label is already expressed by `USES_COMPONENT{STARTING_MATERIAL_COLLECTION}` → Procedure. The AAVrh74 antibody restriction in HORIZON is a W09 eligibility fact. No current CQ fails without a new property. |
| A7. Add `Treatment` to the W13 `STATUS_OF`/`DESIGNATION_FOR` range | rejected | Designations and approvals are sponsor- and product-specific. Under edaravone, Treeway's designation was withdrawn or revoked and not approved, while RADICAVA's NDA 209176 was approved. A concept-level status would merge them. The concept reaches W13 only through its products. |
| A8. Widen the `TARGETS_CONDITION` range to Outcome ("accelerated aging") | rejected | The Next Health text "remove particles that are known contributors to disease and accelerated aging" is an offerer's benefit claim (W21), not intent recognized by any authority. |
| A9. Map registry InterventionType onto `TreatmentModality` | rejected | NCT03745287 types exa-cel as BIOLOGICAL, NCT06597656 types delandistrogene moxeparvovec as GENETIC, and both concepts are GENE_THERAPY. Registry type is a W09 field. |
| A10. Record a trial's co-intervention as a component of the concept | rejected (V-W06-06) | HORIZON's plasmapheresis is a study-specific preparatory step to deplete anti-AAVrh74 antibodies. It is not part of the delandistrogene moxeparvovec concept. |

## 5. Smallest recommended model

- **Two Entity types**: `Treatment` and `Procedure`. Their live fields are kept, with display fields made explicit and read-only where they are projections. No new node type.
- **One live enum kept** (`TreatmentModality`, now used as a list) and **three small enums added** (component role, intent kind, intent basis).
- **Five relationship types**, all kept from live: `TARGETS_CONDITION`, `USES_COMPONENT`, `DEVELOPS_TREATMENT`, `OFFERS_TREATMENT`, `OFFERS_PROCEDURE`. The study-side concept link reuses W09's `FOLLOWS_INTERVENTION_DEFINITION`. All five are asserted edges under the frozen `asserted_edge` profile.
- **Two relationship-property types** (`TreatmentComponentProperties`, `TreatmentTargetProperties`). Each embeds every frozen `AssertedEdgeProperties` field.
- **Ten validators** (V-W06-01 to V-W06-08b, including the informational V-W06-02 and V-W06-07i) plus QS-4a instantiated with the W06 forbidden-implication pairs.
- **Candidate CQ area `CQ-IV`** (interventions), with five candidates.
- **Home module**: catalog module `interventions`, CANDIDATE (closing T-005 for W06's types), with dependencies kernel, provenance, temporal, identity_resolution, organizations, substances_and_materials, products_and_commerce, studies_and_evidence, regulatory_and_ip and protocols. An alternative is to place the two types in `studies_and_evidence`. That is rejected because the practice-offering cases (Next Health, Circulate) are not study facts.
