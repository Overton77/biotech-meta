# W06 model cards

Conventions used on every card:

- Privacy class is PUBLIC unless stated. No W06 element is private-personal.
- Kinds: A = asserted (a projection of one Assertion), C = curated classification, D = derived/display projection, O = operational.
- Temporal behaviour follows contract A6. Entity properties are current curated values; their history is the assertions behind them.
- Maturity is the proposed value for the final schema.

## Node: Treatment

| Field | Value |
|---|---|
| Meaning | A therapeutic intervention **concept**: a kind of intervention known by its nonproprietary or development names, with modality, components, stated intent and organization roles. |
| Not | An administered study intervention (W09). A marketed or investigational product (W04). A substance or material (W02). A regulatory standing (W13). A performance, encounter or patient record (not modeled). A result (W09). |
| Archetype, labels | Entity; `["Treatment","Entity"]`; GraphQL `Entity & EntityArchetype & SearchIndexable`. |
| uid token | `treatment` (**requested**, W06-SR-02). Format `hu:treatment:<opaque>`; `id` is the opaque segment. |
| Identity keys | `uid` only. Aliases (proper name, USAN/INN, development code) are `Identifier` records through `HAS_IDENTIFIER`. Display `name` is never identity. A merge requires an `EquivalenceAssessment` that rests on more than a shared name or code (V-W06-07). |
| CQs | CQ-ST-01 (concept link), CQ-EV-04 (guard), CQ-MF-02, CQ-AX-23; CQ-IV-C01, C03, C04. |
| Maturity | PROVISIONAL. The module is CANDIDATE (`interventions`). |

| Property | Type / null | Kind | Semantics |
|---|---|---|---|
| `id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`, `entityType` | per contract B2 | O / C | `mongoResearchRunId` is internal lineage (maps to `Activity.externalRunId`). |
| `searchText`, `searchFields`, `embeddingModel`, `embeddingDimensions`, `searchEmbedding` | String, [String!], String, Int, [Float!]; nullable | D | Regenerable; never evidence (INV-107). V-119 requires `searchFields` when `searchText` is set. |
| `modalities` | [TreatmentModality!]; null = not recorded | C | One or more concept classifications. When contested, each value is backed by a literal Assertion `HAS_TREATMENT_MODALITY` (candidate predicate) with a locator. |
| `modality` | TreatmentModality; read-only | D | Legacy projection: the only element of `modalities`, otherwise null. |
| `treatmentClass` | String | C | Display wording. |
| `routeCategory` | String | C | Concept-level display. Not an applicability input. |
| `regimenSummary` | String | C | Display. Not dose authority. |
| `targetedPopulation` | String | C | Display. Not an indication. |
| `developmentStage` | String; read-only | D | Projection of the latest live `DECLARES_DEVELOPMENT_STAGE` assertion (candidate predicate; developer-stated, registry-stated or CALCULATED with `derivationRule` `stage-from-reachable-accepted-approval-v1`, jurisdiction-qualified), or migrated legacy text. Guarded by V-W06-01 and V-W06-02. |
| `developmentStageAssertionUid` | String; read-only | D | Names the assertion projected into `developmentStage`. Null means migrated legacy text. |
| `orphanDrugDesignation` | String; read-only | D | Display projection of the W13 `OrphanDesignation` states of the concept's ADMINISTERED_PRODUCT products. Never approval (V-W06-03). |
| `orphanDesignationStatusUids` | [String!]; read-only | D | The states projected into `orphanDrugDesignation`. |

| Edge field | Relationship (owner) | Direction, range | Cardinality | Class | Properties |
|---|---|---|---|---|---|
| `identifiers` | `HAS_IDENTIFIER` (W00) | OUT → Identifier | many | asserted | IdentifierLinkProperties |
| `targetsConditions` | `TARGETS_CONDITION` (W06) | OUT → Condition (W03) | many | asserted | TreatmentTargetProperties |
| `usesComponents` | `USES_COMPONENT` (W06) | OUT → TreatmentComponentTarget | many | asserted | TreatmentComponentProperties |
| `developedBy` | `DEVELOPS_TREATMENT` (W06) | IN ← Organization (W01) | many | asserted | AssertedEdgeProperties |
| `offeredBy` | `OFFERS_TREATMENT` (W06) | IN ← Organization | many | asserted | AssertedEdgeProperties |
| `instantiatedByStudyInterventions` | `INSTANTIATES_TREATMENT` (W06, requested) | IN ← StudyIntervention (W09) | many | asserted | AssertedEdgeProperties |
| `hasSafetySignals` | `HAS_SAFETY_SIGNAL` (W17) | OUT → SafetySignal | many | asserted | SafetyEdgeProperties |
| `supportedByDocuments` / `supportedByChunks` | W20 | OUT → Document / Chunk | many | derived (read-only) | DerivedSupportProperties |

## Node: Procedure

| Field | Value |
|---|---|
| Meaning | A procedure **definition**: a named kind of act performed with equipment or by hand. |
| Not | A performance, session or encounter. An offering, listing or price (W01 role, W15). A protocol step (W16). An administered study intervention (W09). A device (W08). A benefit claim (W21). |
| Archetype, labels | Entity; `["Procedure","Entity"]`. |
| uid token | `procedure` (**requested**, W06-SR-02). |
| Identity keys | `uid`. Classification codes (ICD-10-PCS, SNOMED CT) are `Identifier` records that may be shared by several definitions and never establish identity (Q-07, V-W06-07). |
| CQs | CQ-IV-C02, C05; CQ-ST-01 / CQ-IV-C01 (concept link). |
| Maturity | PROVISIONAL. |

| Property | Type / null | Kind | Semantics |
|---|---|---|---|
| contract B2 fields, SearchIndexable fields | as for Treatment | O / D | — |
| `procedureType`, `setting`, `deliveryRoute`, `invasiveness` | String | C | Definition-level display. `setting` is the *typical* setting, not where a performance occurred. |
| `durationSummary`, `preparationSummary`, `recoverySummary` | String | C | Definition-level display. Null = not recorded, never "none". When a source-specific characterization matters, it is an assertion attributed to that source. |

| Edge field | Relationship (owner) | Direction, range | Cardinality | Class | Properties |
|---|---|---|---|---|---|
| `identifiers` | `HAS_IDENTIFIER` (W00) | OUT → Identifier | many | asserted | IdentifierLinkProperties |
| `offeredBy` | `OFFERS_PROCEDURE` (W06) | IN ← Organization | many | asserted | AssertedEdgeProperties |
| `listedIn` | `LISTS_PROCEDURE` (W15) | IN ← MerchantListing | many | asserted | ListingEdgeProperties |
| `componentOfTreatments` | `USES_COMPONENT` (W06) | IN ← Treatment | many | asserted | TreatmentComponentProperties |
| `instantiatedByStudyInterventions` | `INSTANTIATES_PROCEDURE` (W06, requested) | IN ← StudyIntervention | many | asserted | AssertedEdgeProperties |
| `hasSafetySignals`, `supportedBy*` | as for Treatment | | | | |
| (no field) protocol step employing it | `EMPLOYS` (W16) | ProtocolStep → Procedure (requested range extension, W06-SR-04) | many | structural (part of the immutable step payload) | W16's step property type |

## Enum: TreatmentModality (owner W06; live values kept)

The values are SMALL_MOLECULE, BIOLOGIC, GENE_THERAPY, CELL_THERAPY, RNA_THERAPY, PROCEDURE, DEVICE_BASED, NUTRITIONAL, LIFESTYLE, COMBINATION, OTHER and UNKNOWN.

- **COMBINATION** means a regimen concept whose components have different modalities, and requires at least two `USES_COMPONENT` edges (V-W06-05).
- **UNKNOWN** means the source does not allow classification.
- **OTHER** means the concept was classified but no value fits.
- A **null list** means not recorded.

No value is added: GENOME_EDITING and ex vivo versus in vivo are scope candidates. The enum is used as a list (`modalities`).

## Enum: TreatmentComponentRole (requested owner W06)

| Value | Meaning | Example |
|---|---|---|
| ACTIVE_COMPONENT | Substance or material that is the active agent. | edaravone substance in "edaravone for ALS" |
| ADMINISTERED_PRODUCT | A Product that embodies the concept. Navigation only: it never transfers evidence, approval or designation. | exa-cel → CASGEVY |
| STARTING_MATERIAL_COLLECTION | Procedure that collects the patient's own starting material. | label: "obtained via apheresis procedure(s)" |
| PREPARATORY_PROCEDURE | Conditioning or depletion step that is part of the concept per an authoritative description. | (not used on the trial-only HORIZON step; V-W06-06) |
| DELIVERY_PROCEDURE, DELIVERY_DEVICE | How the concept is delivered. | — |
| CO_INTERVENTION | Co-administered intervention that is part of the concept. | — |
| REGIMEN_DEFINITION | A W16 Protocol that defines the regimen. | — |
| OTHER, NOT_STATED | — | — |

## Enums: TreatmentIntentKind, TreatmentIntentBasis (requested owner W06)

- `TreatmentIntentKind`: TREATMENT, PREVENTION, SYMPTOM_RELIEF, SUPPORTIVE, NOT_STATED.
- `TreatmentIntentBasis`: DEVELOPER_PIPELINE, REGULATORY_LABEL_RESTATEMENT, TRIAL_REGISTRATION, PRACTICE_OFFERING, LITERATURE, NOT_STATED.

The basis tells a reader *whose* intent is recorded. REGULATORY_LABEL_RESTATEMENT is never the approved indication, which is read from W13 `DrugApproval.indication`.

## Union: TreatmentComponentTarget (owner W06)

`ChemicalSubstance | ChemicalForm | IngredientMaterial | Product | Device | Procedure | Protocol | Lifestyle | FoodProduct`

| Member source | Note |
|---|---|
| live Compound | becomes ChemicalSubstance |
| live CompoundForm | becomes ChemicalForm or IngredientMaterial (D-002) |
| Lifestyle, FoodProduct | pending W05 successor names |

Treatment is excluded as a member until a nesting CQ exists (SC-W06-03). Every member is an `@node` type in the final schema, subject to W05.

## Relationship-property type: TreatmentComponentProperties (owner W06)

It contains every frozen `AssertedEdgeProperties` field: `relationshipUid!`, `assertionUid!`, the valid bounds with precision and the required bases, `recordedFrom!`, `recordedTo` and `mongoResearchRunId`. It adds:

- `componentRole` (TreatmentComponentRole!)
- `roleTextVerbatim`
- `doseText`, `routeText`, `frequencyText`, `durationText` (verbatim display only)
- `orderIndex` (Int)

Live `TreatmentComponentMetadata` maps as role → `roleTextVerbatim` (and `componentRole` by curation), route → `routeText`, frequency → `frequencyText`. `confidence` and `notes` are dropped.

## Relationship-property type: TreatmentTargetProperties (requested owner W06)

It contains the frozen `AssertedEdgeProperties` fields and adds:

- `intentKind!`, `intentBasis!`
- `indicationTextVerbatim`, `patientSubsetText`
- `legacyEvidenceStrengthHint` (W10 `EvidenceStrength`; migration only, never written by new ingestion)

Live `TreatmentTargetMetadata` maps as targetRole → `intentKind`, indicationType → `intentBasis`, patientSubset → `patientSubsetText`, evidenceStrength → hint. `confidence` and `notes` are dropped.

## Relationships

| Type | Domain → range | Class / profile | Cardinality | Meaning | Forbidden implications (premise → conclusion) |
|---|---|---|---|---|---|
| `TARGETS_CONDITION` | Treatment → Condition | asserted / asserted_edge | many | A source states the concept is intended for the condition. | FI-W06-01 → effective for; FI-W06-02 → approved for; FI-W06-15: an offerer's benefit claim never creates this edge. |
| `USES_COMPONENT` | Treatment → TreatmentComponentTarget | asserted | many | The concept includes the component in the stated role. | FI-W06-09: with INSTANTIATES_TREATMENT it never yields evidence applicability to the Product. FI-W06-14: a trial co-intervention is not a concept component. |
| `DEVELOPS_TREATMENT` | Organization → Treatment | asserted | many (NONEXCLUSIVE) | The organization develops the concept, according to an explicit assertion. | FI-W06-08 SPONSORS_STUDY, FI-W06-10 MANUFACTURES_PRODUCT and FI-W06-11 designation SUBMITTED_BY never imply it. |
| `OFFERS_TREATMENT` | Organization → Treatment | asserted | many | The organization states it offers the concept as a service or practice. | FI-W06-05 listing; FI-W06-07 → recommends, approved, effective. |
| `OFFERS_PROCEDURE` | Organization → Procedure | asserted | many | The organization states it offers the procedure. | FI-W06-05 HOSTS_LISTING or LISTS_PROCEDURE → offers; FI-W06-06 offers → performs; FI-W06-07. |
| `INSTANTIATES_TREATMENT` | StudyIntervention → Treatment | asserted | zero_or_one per StudyIntervention | The administered intervention is an instance of the concept, as reported. | FI-W06-09; FI-W06-13 (registry type → modality). |
| `INSTANTIATES_PROCEDURE` | StudyIntervention → Procedure | asserted | zero_or_one | The administered intervention performs the defined procedure, as reported. | FI-W06-12 (shared code → same procedure). |

## CANDIDATE cards (not in the fragment)

| Candidate | Proposed shape | Candidate CQ / failing case | Why it is not promoted |
|---|---|---|---|
| `offeringRole` qualifier on OFFERS_* (DIRECT_PROVIDER, SERVICE_OPERATOR_FOR_PARTNER, VENUE_HOST, REFERRAL_ONLY) | edge property | CQ-IV-C02. Circulate "partners with clinics to deliver … as a turnkey … service" (search extract only). | Evidence is a SEARCH_EXTRACT. Needs a captured page and W01 agreement (W06-SR-06). |
| `cellSourceKind` {AUTOLOGOUS, ALLOGENEIC} (SC-W06-01) | Treatment property | Candidate "which cell therapies require patient-specific collection". CASGEVY label. | Already answerable through `USES_COMPONENT{STARTING_MATERIAL_COLLECTION}` → Procedure. No failing query. |
| `vectorKind` / `editingTechnology` (SC-W06-02) | Treatment properties, or W02 material identities for vectors and edited cells | Candidate "which gene therapies use AAVrh74 / CRISPR". HORIZON eligibility (AAVrh74 antibodies); label "CRISPR/Cas9". | No Essential or Foundational CQ. A proper model needs W02/W03 identities for vectors, capsids and edit targets (BCL11A enhancer). Needs a dedicated round (large-biotech horizon). |
| `ProcedurePerformance` Occurrence | Occurrence | none | Privacy and scope (architecture §15). A count is a literal assertion. |
| Predicate `DECLARES_DEVELOPMENT_STAGE` | assertedPredicate, literal valueString + jurisdiction | CQ-MF-02 display. Fixture 04. | Needs registration (W06-SR-12). |
| Predicate `HAS_TREATMENT_MODALITY` | assertedPredicate, literal | CQ-IV-C03. Fixture 01. | Needs registration. |
| Predicate `REPORTS_PROCEDURE_VOLUME` | assertedPredicate, literal valueNumber | CQ-IV-C02 (performance is out of scope). GeekWire. | Needs registration. Expansion priority. |
| `Treatment` member of TreatmentComponentTarget (SC-W06-03) | union member | Named-treatment combination regimens (ReCIPE-B1: enfortumab vedotin plus pembrolizumab) | No CQ yet. |
