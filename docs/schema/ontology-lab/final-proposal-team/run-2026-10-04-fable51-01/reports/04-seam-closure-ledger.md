# 04 Seam-closure ledger

Run `run-2026-10-04-fable51-01`. Seam-closure integrator (Opus 5.5) for Fable 5.1. Written 2026-10-04T02:27Z. Scope: every cross-owner seam request in `workers/W*/seam-requests.yaml` (389 requests from 24 workers, including W10, W15, W17 and W18 files published during this pass and re-read at the end). Each request has one row with its kind and disposition; requests that ask another owner to add a relationship field, union member, enum value or property are closed by machine-applicable files, never by editing a worker fragment. Nothing here changes semantics: field direction and property type follow the owner's own declaration of the same relationship type; class, cardinality and the forbidden implications stated by the requester are carried in each field description.

Authority used, in order: frozen contract `01-shared-contract.md` (B2 skeleton, B4 property types, B6 unions), `02-ownership-registry.md`, `reports/03-decision-report.md` (MR-01..MR-12, section C admissions), W00's reconciliation (`workers/W00/09-kernel-reconciliation.md`, `seam-rulings.yaml`, `predicate-registry.yaml`, rulings W00-R-01..R-50) for everything kernel-owned, then each owner's `05-decision-seam-ledger.md`, `04-model-cards.md` and `migration-map.yaml` answers. Nothing was injected into W00 types: every kernel-owned union, enum and field request that W00 accepted is already implemented in the W00 fragment by its reconciliation pass (W00-R-08..R-22, R-30, R-40); requests W00 did not accept or that arrived after its re-scan (W00-SR-04 ResolutionStatus, W17-SR-03 PredicateClass SAFETY, W18-SR-04 statedTense FUTURE / ActivityKind CURATION) stay routed. The only kernel-ruled items closed here are those W00 ruled on other owners' types: W00-R-12 (massBasis/amountReferent on W17's ContraindicationAssertion and InteractionAssertion) and W00-R-22 (SUPPORTED_BY fields on W15's PriceObservation and AffiliateLink).

## 1. Outputs

| File | Content |
|---|---|
| `validation/harness/field-injections.json` | 93 relationship fields and 10 scalar properties on 28 types, each with its description line (class, cardinality, catalog relationship and registry owner, originating request ids). Applied by `assemble-final.mjs` as its fourth argument; names already present in a type are skipped, so an owner who later writes the field wins. |
| `validation/harness/union-additions.json` | 3 entries (4 members). Read by `assemble-final.mjs` from the injections file's directory; MR-01/MR-02 pruning runs after the additions. |
| `validation/harness/enum-additions.json` | 11 entries (14 values). |
| `validation/harness/extra-definitions.graphql` | `RecommendableTarget` (sole writer W21 per decision report C; requests W21-SR-18, W21-SR-07, W05-SR-11, W04-SR-10, W02-SR-22, W06-SR-14). Appended by `assemble-final.mjs`. |
| `validation/harness/verify-seam-closure.mjs` | Post-assembly check: every injected field is inside the named type, its target and property types exist, its property type matches the opposite-endpoint declaration of the same relationship type, and every union member / enum value requested is present. |

## 2. Summary

Primary disposition per request (first label of the row; mixed rows carry several labels):

| Disposition | Requests (primary) | Requests carrying the label |
|---|---|---|
| ALREADY_SATISFIED | 179 | 179 |
| INJECTED | 26 | 41 |
| UNION_ADDED | 5 | 7 |
| ENUM_ADDED | 7 | 10 |
| DEFERRED | 35 | 50 |
| OUT_OF_SCOPE | 137 | 156 |
| total | 389 | |

By kind: other 183, field 75, union 46, enum 39, validator 35, property 11.

Labels: ALREADY_SATISFIED = the owner's (or W00's reconciled) fragment already has the element, named in the row; INJECTED / UNION_ADDED / ENUM_ADDED = closed by the files of section 1; DEFERRED = not closed, with the reason (owner decision that differs, removal rather than addition, relationship type neither declared nor admitted, or the requester's own proposed deferral); OUT_OF_SCOPE (routed) = a request to W00 or Fable that is not a field, union or enum slot (tokens, predicates, validators, conventions, fixtures, contract text); it is listed, not ruled here. W00's rulings for these are in `workers/W00/seam-rulings.yaml`.

## 3. Ledger (one row per request)

| Id | From | To | Kind | Disposition | Element produced or reason |
|---|---|---|---|---|---|
| W00-SR-01 | W00 | Fable (contract B3, AssertionArchetype) | property | ALREADY_SATISFIED + INJECTED | W00 fragment: AssertionArchetype.massBasis/amountReferent (ruling W00-R-12); W21 ClaimOccurrence/RelationshipAssertion carry them. INJECTED the two interface fields on W17 ContraindicationAssertion and InteractionAssertion (build failed without them; MR-03) |
| W00-SR-02 | W00 | Fable (contract B2 skeleton `id: ID! @id`) | other | OUT_OF_SCOPE (routed) | Fable/W00: application rule (API creates through ingestion service); merge-build log records the INV-106 limitation |
| W00-SR-03 | W00 | W20 (Document) with Fable | other | OUT_OF_SCOPE (routed) | W20/W00 ingestion dual-write rule; no SDL slot |
| W00-SR-04 | W00 | Fable (contract B5 enums) | enum | OUT_OF_SCOPE (routed) | W00 kernel enum ResolutionStatus not defined in the W00 fragment; W00 reconciliation pass |
| W00-SR-05 | W00 | Fable (contract A2 merge redirect) | enum | ALREADY_SATISFIED | W00 EquivalenceKind.SAME_IDENTITY_MERGED and SupersessionKind.DUPLICATE_MERGE present; redirect record semantics routed to W00/Fable |
| W00-SR-06 | W00 | Fable (validation.cypher V-112) | validator | OUT_OF_SCOPE (routed) | V-112 correction (W00 validation-corrections.cypher) |
| W00-SR-07 | W00 | W04 (IDENTIFIED_BY) and W07 (Metric identifiers) | other | DEFERRED | Rename, not a slot: W00-R-20 / MR-08 fold IDENTIFIED_BY into HAS_IDENTIFIER; W04 ProductVariant/PackageConfiguration.tradeItemIdentifiers and W15 MerchantListing.tradeItemIdentifiers still declare IDENTIFIED_BY -> assembler textReplacement for Fable (section 5) |
| W00-SR-08 | W00 | W01 (OrganizationSnapshot), W04 (ProductSnapshot), Fable | other | DEFERRED | W01 ALREADY (Organization/LegalEntity.states, OrganizationSnapshot.organization use HAS_STATE); W04 Product.snapshots / ProductSnapshot.product still HAS_SNAPSHOT -> assembler textReplacement (MR-04, W00-R-16; section 5) |
| W00-SR-09 | W00 | Fable (conventions.uidTypeTokens) | other | OUT_OF_SCOPE (routed) | uid tokens (W00 uid-token-registry.yaml) |
| W00-SR-10 | W00 | Fable (conventions.normalizationVersions) | other | OUT_OF_SCOPE (routed) | normalizationVersions convention |
| W00-SR-11 | W00 | Fable (merge rule for unions and interfaces, contract B6) | union | ALREADY_SATISFIED | MR-01 union pruning in assemble-final.mjs (14 member removals in this assembly) |
| W00-SR-12 | W00 | Fable (validation.cypher V-432) | validator | OUT_OF_SCOPE (routed) | V-432 correction |
| W00-SR-13 | W00 | every domain owner with asserted relationship types; Fable | other | OUT_OF_SCOPE (routed) | ingestion contract + MR-10 migration |
| W00-SR-14 | W00 | Fable (runtime prerequisites) | other | ALREADY_SATISFIED | MR-12 (APOC Core runtime prerequisite) |
| W00-SR-15 | W00 | W03 (OBSERVED_IN_CONTEXT), W21 (INSTANCE_OF), W20 (RESOLV... | field | ALREADY_SATISFIED + INJECTED | Inverses present: MechanismEvidenceContext.observedAssertions (W03), Chunk.resolvedFromLocators (W20), MediaAnnotation.locatedBy (W22), Claim.occurrences/relationshipAssertions (W21). INJECTED Claim.assertionInstances (INSTANCE_OF IN, DerivedEdgeProperties) for generic Assertion instances |
| W00-SR-16 | W00 | W19 responses (see 05-decision-seam-ledger.md §2) | other | OUT_OF_SCOPE (routed) | W19 SourceKind/ActivityKind values: implemented in W00 fragment (SourceKind +8, ActivityKind.DISCOVERY) |
| W01-SR-01 | W01 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W01-SR-02 | W01 | W00 | property | ALREADY_SATISFIED | W00 ActorIdentity.name: String (D-013 extension) |
| W01-SR-03 | W01 | W00 | other | DEFERRED | W01 ALREADY (HAS_STATE); W15 ListingSnapshot retired (D-W15-17); W04 Product/ProductSnapshot HAS_SNAPSHOT -> assembler rename (W00-R-16, section 5) |
| W01-SR-04 | W01 | W00 | validator | OUT_OF_SCOPE (routed) | QS-2a/2b precision ladder |
| W01-SR-05 | W01 | Fable (example fixture claim-retelling-provenance.cypher;... | other | OUT_OF_SCOPE (routed) | fixture repair (decision report D) |
| W01-SR-06 | W01 | W00 (validation) and Fable (catalog) | other | OUT_OF_SCOPE (routed) | catalog organizations relationships block; V-W01-* |
| W01-SR-07 | W01 | W00 | other | OUT_OF_SCOPE (routed) | KCR statedAsOf |
| W01-SR-08 | W01 | W00 | validator | OUT_OF_SCOPE (routed) | witness = coalesce(publishedAt, observedAt) |
| W01-SR-09 | W01 | Fable (catalog enum value; W01 owns OrganizationType) | enum | ENUM_ADDED | OrganizationType.CORPORATE_GROUP (decision report C) |
| W01-SR-10 | W01 | Fable (catalog organizations module) | other | OUT_OF_SCOPE (routed) | catalog forbidden implications / canonicalization |
| W01-SR-11 | W01 | W23 | other | OUT_OF_SCOPE (routed) | W23 privacy rules (answered by W23-SR-12) |
| W01-SR-12 | W01 | W06 (with W03) | field | ALREADY_SATISFIED | WORKS_ON_CONDITION retired (declared by no fragment); W06 Treatment.developedBy (DEVELOPS_TREATMENT IN) present |
| W01-SR-13 | W01 | W11 | field | INJECTED | Facility.hostsProcesses (HOSTS_PROCESS OUT), Facility.capabilityStates and Organization.capabilityStates (HAS_CAPABILITY_STATE OUT), Organization.performsProcesses (PERFORMS_PROCESS OUT), all AssertedEdgeProperties; (a) CMO-to-material mapping is W11 capability modelling (no slot) |
| W01-SR-14 | W01 | W11 and W15 | field | ALREADY_SATISFIED | HOSTS_PRODUCT retired: declared by no fragment; routed review is a migration step |
| W01-SR-15 | W01 | W15 | other | ALREADY_SATISFIED | (a) W15 MerchantListing.availableIn -> Facility; (b) W15-SR-01(a) / D-W15-12 seller display accounts; (c) W15 role edges |
| W01-SR-16 | W01 | W22 | union | ALREADY_SATISFIED | W22 MediaSubjectTarget lists Facility, not PhysicalLocation |
| W01-SR-17 | W01 | W09 | field | INJECTED + DEFERRED | INJECTED derived read-only inverse views Organization.sponsorsStudies (SPONSORED_BY IN) and Organization.servesAsCroFor (OPERATED_BY IN), Person.investigatedStudies (INVESTIGATED_BY IN), DerivedEdgeProperties. DEFERRED fundsStudies, hostsStudySites, providesInvestigationalProduct: W09 keeps SPONSORS_STUDY/FUNDS_STUDY/... as W01 assertion predicates (W09 01 section: 'none becomes an edge'); no relationship type exists to project |
| W01-SR-18 | W01 | W12 | other | ALREADY_SATISFIED | W12 TestingLaboratory labels [TestingLaboratory, Organization, Entity]; site via OPERATES_FACILITY |
| W01-SR-19 | W01 | W14 | other | ALREADY_SATISFIED | W14-D11 (no inference rule) |
| W01-SR-20 | W01 | W08, W11, W12, W13, W15, W16, W18, W20, W21, W09 | field | INJECTED + DEFERRED | INJECTED 34 slot fields (Organization 18, Person 10, Facility 4, PseudonymousActor 1, ConsumerBrand 1) (section 4). DEFERRED: Person/PseudonymousActor/AnonymousActor.authorsReports and CohortParticipant.reportsExperiences (W21 retired AUTHORS/REPORTS and ExperienceReport -> ClaimOccurrence ASSERTED_BY, W21 04 model cards); ConsumerBrand.marketedUnderMarks (MARKETED_UNDER_MARK domain is BrandedIngredientMaterial; W14 defers product/brand-level marks); Organization.fundsStudies/hostsStudySites/providesInvestigationalProduct (see W01-SR-17) |
| W01-SR-21 | W01 | W21 | other | ALREADY_SATISFIED | W21 ledger: SPONSORS_CONTENT keeps AssertedEdgeProperties; AFFILIATED_WITH only as a hop |
| W01-SR-22 | W01 | W00 | other | OUT_OF_SCOPE (routed) | kernel question; W00-R-02 QUANTITY rule |
| W02-SR-01 | W02 | W00 | other | OUT_OF_SCOPE (routed) | KCR (W00-R-02 ruled QUANTITY object + literal) |
| W02-SR-02 | W02 | W00 | validator | OUT_OF_SCOPE (routed) | V-006r |
| W02-SR-03 | W02 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W02-SR-04 | W02 | W00 | other | OUT_OF_SCOPE (routed) | predicates (W00 predicate-registry REGISTERED); ActivityKind.CALCULATION present in W00 fragment |
| W02-SR-05 | W02 | W00 | other | OUT_OF_SCOPE (routed) | predicateExclusivity STRAIN_OF (W00-R-07 ruled) |
| W02-SR-06 | W02 | W03 | validator | DEFERRED | co-labelling rule / taxonomyId uniqueness check; W03 has not answered; no SDL slot |
| W02-SR-07 | W02 | W03 | other | ALREADY_SATISFIED | W03 D-W03-10 / W03-SR-05 same boundary; W02 derived fields read-only |
| W02-SR-08 | W02 | W07 | field | DEFERRED | analyte link: HAS_ANALYTE is not defined by W07 nor admitted to the registry (see W03-SR-03); QUANTIFIES is Metric->Biomarker and unchanged |
| W02-SR-09 | W02 | W10 | other | OUT_OF_SCOPE (routed) | W10 method inputs (applicability method card); no SDL slot |
| W02-SR-10 | W02 | W11 | field | ALREADY_SATISFIED | D-008 ruled (no ProcessMaterial); W11 INPUTS/OUTPUTS target IngredientMaterial/ChemicalSubstance; W02 GOVERNED_BY_SPECIFICATION/PRODUCED_BY_PROCESS use AssertedEdgeProperties; tokens and exclusivity routed to W00 (W00-R-07) |
| W02-SR-11 | W02 | W04 | field | ALREADY_SATISFIED | W04 IngredientComponent.material (USES_MATERIAL) and LabelDeclaration.identifiesMaterials target IngredientMaterial; fixture fix routed |
| W02-SR-12 | W02 | W05 | union | ALREADY_SATISFIED | W05 ExposureAgentTarget = IngredientMaterial \| ChemicalSubstance \| Nutrient \| Product \| ProductVariant \| Lifestyle |
| W02-SR-19 | W02 | W06 | union | ALREADY_SATISFIED | W06 TreatmentComponentTarget has ChemicalSubstance \| ChemicalForm \| IngredientMaterial |
| W02-SR-20 | W02 | W09 | union | ALREADY_SATISFIED | W09 LegacyEvaluatedIntervention has ChemicalSubstance \| ChemicalForm \| IngredientMaterial; USES_INTERVENTION_MATERIAL -> IngredientMaterial |
| W02-SR-21 | W02 | W16 | union | ALREADY_SATISFIED | W16 StepSubstanceTarget and ProtocolResultMentionTarget carry the successors |
| W02-SR-22 | W02 | W21 | union | ALREADY_SATISFIED + UNION_ADDED | W21 EpisodeMentionableTarget has IngredientMaterial; RecommendableTarget defined in extra-definitions.graphql (sole writer W21) |
| W02-SR-23 | W02 | W18 | union | ALREADY_SATISFIED | W18 EventSubjectTarget has ChemicalSubstance; EventParticipantTarget narrowed to actors by W18 (Compound removed) |
| W02-SR-24 | W02 | W00 | union | ALREADY_SATISFIED | W00 AssertionSubjectTarget lists all requested members |
| W02-SR-25 | W02 | W22 | union | ALREADY_SATISFIED | W22 MediaSubjectTarget has ChemicalSubstance \| ChemicalForm \| IngredientMaterial; ProductLabelMentionTarget retired (W22-D14) |
| W02-SR-13 | W02 | W14 | field | ALREADY_SATISFIED | W02 BrandedIngredientMaterial.marketedUnderMarks (MARKETED_UNDER_MARK OUT, AssertedEdgeProperties); W14 Trademark.markedMaterials |
| W02-SR-14 | W02 | W17 | field | INJECTED | ChemicalSubstance.hasSafetySignals, IngredientMaterial.hasSafetySignals (HAS_SAFETY_SIGNAL OUT, SafetyEdgeProperties, class structural per D-W17-02); SafetySubjectTarget already lists both |
| W02-SR-15 | W02 | W20 | field | ALREADY_SATISFIED | W02 carries no chunk field (W02 migration map); W20 SUPPORTED_BY_CHUNK derived |
| W02-SR-16 | W02 | W19 | other | OUT_OF_SCOPE (routed) | W19 source registry entries |
| W02-SR-17 | W02 | W00 | other | OUT_OF_SCOPE (routed) | fixture repair (decision report D) |
| W02-SR-18 | W02 | W12 | other | OUT_OF_SCOPE (routed) | W12 fixture content |
| W03-SR-01 | W03 | W00 | validator | OUT_OF_SCOPE (routed) | V-233r/V-234r |
| W03-SR-02 | W03 | W00 | field | ALREADY_SATISFIED | W00 Assertion.observedInContext (OBSERVED_IN_CONTEXT OUT); DERIVED_FROM_ASSERTION note routed |
| W03-SR-03 | W03 | W07 | field | DEFERRED | HAS_ANALYTE (Biomarker -> ChemicalSubstance \| MolecularEntity, structural, CANDIDATE) is declared by no fragment and not admitted to the registry; W07 has not answered. Proposed text for Fable in section 7 |
| W03-SR-04 | W03 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W03-SR-05 | W03 | W02 | field | ALREADY_SATISFIED + DEFERRED | W02 ChemicalSubstance/ChemicalForm/IngredientMaterial.affectsMechanisms and .modulates present, read-only; property type differs (W02 DerivedEdgeProperties vs W03 AssociationProjectionProperties, flagged section 7); optional ChemicalSubstance.participatesInPathways not adopted by W02 (DEFERRED) |
| W03-SR-06 | W03 | W07 | field | ALREADY_SATISFIED + DEFERRED | Metric.measuredInOrgans retired (MEASURED_IN only W03); removal of Biomarker.inPathways / expressedInOrgans (still read-only in W07) is a fragment edit -> DEFERRED to W07/Fable |
| W03-SR-07 | W03 | W16 | other | ALREADY_SATISFIED | OPERATIONALIZED_BY: W03 Outcome and W16 FunctionalGoal both StructuralEdgeProperties |
| W03-SR-08 | W03 | W17 | other | ALREADY_SATISFIED | W17-SR-10: AFFECTS_ORGAN structural, MechanismLinkProperties on Condition and AdverseEffect |
| W03-SR-09 | W03 | W09 | other | ALREADY_SATISFIED | W09 Study.studiedInSpecies kept |
| W03-SR-10 | W03 | W05 | other | ALREADY_SATISFIED | W05 Lifestyle.affectsMechanisms / associatedWith* derived read-only |
| W03-SR-11 | W03 | W10 | other | ALREADY_SATISFIED | W10 D-W10-14 |
| W03-SR-12 | W03 | W00 | field | INJECTED + OUT_OF_SCOPE (routed) | (d) INJECTED Condition.treatedBy (TARGETS_CONDITION IN, TreatmentTargetProperties), Condition.investigatedByStudies (INVESTIGATES IN), Condition.relatedSafetySignals (RELATES_TO_CONDITION IN, StructuralEdgeProperties), Condition.indicatedByBiomarkers (INDICATES IN, AssociationProjectionProperties, read-only), Species.studiedIn (STUDIED_IN IN, D-W03-13); workedOnBy DEFERRED (WORKS_ON_CONDITION retired, W01-SR-12); (a)-(c) registry/predicates/enums routed |
| W03-SR-13 | W03 | W21 | enum | ALREADY_SATISFIED | W21 Claim.claimPolarity: Polarity; AssociationPolarity retired |
| W04-SR-01 | W04 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W04-SR-02 | W04 | W00 | validator | OUT_OF_SCOPE (routed) | V-409 ordering |
| W04-SR-03 | W04 | W00 | validator | OUT_OF_SCOPE (routed) | V-108 / V-508 / V-509 |
| W04-SR-04 | W04 | W00 | other | OUT_OF_SCOPE (routed) | predicate ACTIVE_MOIETY_AMOUNT |
| W04-SR-05 | W04 | W22 | field | DEFERRED | W22 keeps ProductLabelRegion.aboutProduct -> Product by its rule LABEL-REGION-PRODUCT-1 (LABEL_FOR + HAS_VARIANT, zero_or_one); widening to ProductVariant\|PackageConfiguration would change W22's rule -> owner conflict for Fable |
| W04-SR-06 | W04 | W00 | other | DEFERRED | W00-R-16 ruled HAS_STATE; Product.snapshots / ProductSnapshot.product rename is an assembler textReplacement (section 5) |
| W04-SR-07 | W04 | W01 | field | DEFERRED | W01 kept MANUFACTURES_PRODUCT -> Product (RoleEdgeProperties); endpoint ProductVariant\|ProductLot is a semantic change for W01/Fable |
| W04-SR-08 | W04 | W08 | field | ALREADY_SATISFIED + INJECTED | W08 EMBODIES_MODEL (Device/ToolOrInstrument.embodiedByProducts); INJECTED Product.embodiesModels (see W08-SR-03) |
| W04-SR-09 | W04 | Fable | other | OUT_OF_SCOPE (routed) | registry writer of DELIVERS_LABTEST (W04 declares Product.deliversLabTests) |
| W04-SR-10 | W04 | W06, W16, W17, W18, W21, W22 (union owners) | union | UNION_ADDED + ALREADY_SATISFIED | TreatmentComponentTarget += ProductVariant; StepSubstanceTarget, ProtocolResultMentionTarget, SafetySubjectTarget already list ProductVariant (StepSubstanceTarget also FormulationVersion); RecommendableTarget includes it; W02 dosage-form vocabulary DEFERRED |
| W04-SR-11 | W04 | W15 | field | ALREADY_SATISFIED | W15 BundleComponent.componentPackage (COMPONENT_PRODUCT -> PackageConfiguration) |
| W04-SR-12 | W04 | W00 | other | OUT_OF_SCOPE (routed) | fixture repair (decision report D) |
| W04-SR-13 | W04 | Fable | validator | OUT_OF_SCOPE (routed) | validator style rule |
| W05-SR-01 | W05 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W05-SR-02 | W05 | W02 | enum | ALREADY_SATISFIED + ENUM_ADDED | FoodItem labels [FoodItem, IngredientMaterial, Entity] in W05 fragment; MaterialKind.FOOD added |
| W05-SR-03 | W05 | W02 | field | INJECTED | IngredientMaterial.derivedFromTaxa and FoodItem.derivedFromTaxa (DERIVED_FROM_TAXON OUT -> BotanicalTaxon, AssertedEdgeProperties) |
| W05-SR-04 | W05 | W02 | property | INJECTED + OUT_OF_SCOPE (routed) | QuantitativeContentProperties += portionBasis: String, valueDerivation: String (controlled values in description; enums not registered), sourceDerivationCode: String, dataPoints: Int, minValue: Float, maxValue: Float; Nutrient token routed |
| W05-SR-05 | W05 | W03 | other | ALREADY_SATISFIED | W03 D-W03-09 (Lifestyle as AFFECTS_MECHANISM subject); V-231 scope routed |
| W05-SR-06 | W05 | W09 | union | ALREADY_SATISFIED | W09 InterventionDefinitionTarget includes Protocol; LegacyEvaluatedIntervention without FoodItem/FoodProduct; V-221r routed |
| W05-SR-07 | W05 | W03 | enum | DEFERRED | ExposureBasis AMBIENT_LEVEL: requester's own proposed ruling is defer |
| W05-SR-08 | W05 | W16 | union | ALREADY_SATISFIED + DEFERRED | StepSubstanceTarget has IngredientMaterial \| ProductVariant; FoodItem/FoodProduct pruned at assembly (MR-01/MR-02). DEFERRED: removal of Exposure from StepInstrumentTarget (removal, W16 has not answered) and a Lifestyle practice target (no slot chosen by W16) |
| W05-SR-09 | W05 | W00 | union | ALREADY_SATISFIED | MR-01 |
| W05-SR-10 | W05 | W18 | other | ALREADY_SATISFIED | W05 HAS_EXPOSURE_AGENT; W18 INVOLVES Event only (MR-07) |
| W05-SR-11 | W05 | W21 | union | UNION_ADDED + OUT_OF_SCOPE (routed) | (b) RecommendableTarget (extra-definitions) includes IngredientMaterial, Product, Lifestyle, no FoodProduct; (c) W00-R-25 derived rule mode; (a) predicate routed |
| W05-SR-12 | W05 | W17 | union | ALREADY_SATISFIED | W17 SafetySubjectTarget = ChemicalSubstance \| IngredientMaterial \| Product \| ProductVariant \| Treatment \| Procedure \| Lifestyle \| Exposure |
| W05-SR-13 | W05 | W00 | union | ALREADY_SATISFIED | W00 AssertionSubjectTarget includes Exposure and Lifestyle; predicate routed (W10 D-W10-18) |
| W05-SR-14 | W05 | W06 | union | UNION_ADDED | TreatmentComponentTarget += ProductVariant (Product already a member) |
| W05-SR-15 | W05 | W01 | union | ALREADY_SATISFIED | live Producible not carried by W01 (concrete Product fields) |
| W05-SR-16 | W05 | W04 | other | ALREADY_SATISFIED | W04 productKind/USES_MATERIAL -> IngredientMaterial (FoodItem nodes carry the label) |
| W05-SR-17 | W05 | W22 | union | ALREADY_SATISFIED | FoodProduct/Ingredient absent or pruned (MR-02); FoodItem pruned beside IngredientMaterial (MR-01); Exposure/Lifestyle kept |
| W05-SR-18 | W05 | W10 | other | ALREADY_SATISFIED | W10 D-W10-14 (CALCULATED assertions via CONSIDERS; no Exposure edge) |
| W06-SR-01 | W06 | Fable (ownership registry) | other | ALREADY_SATISFIED | registry admission (decision report C) |
| W06-SR-02 | W06 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W06-SR-03 | W06 | W09 | field | ALREADY_SATISFIED | W09 StudyIntervention.definitions (FOLLOWS_INTERVENTION_DEFINITION); W06 Treatment/Procedure.instantiatedByStudyInterventions |
| W06-SR-04 | W06 | W16 | union | UNION_ADDED | StepInstrumentTarget += Procedure |
| W06-SR-05 | W06 | W13 | enum | ALREADY_SATISFIED + ENUM_ADDED + OUT_OF_SCOPE (routed) | (a) Treatment not in RegulatorySubjectTarget; (b) RegulatoryStatusKind.DESIGNATION_ENDED_UNSPECIFIED added (failing case OOPD 465514; alternative null + scopeText left to Fable); (c) V-333 alias counting routed; (d)(e) ingestion rule / FI routed |
| W06-SR-06 | W06 | W01 | field | INJECTED + OUT_OF_SCOPE (routed) | Organization.developsTreatments, offersTreatments (DEVELOPS_/OFFERS_TREATMENT OUT), offersProcedures (OFFERS_PROCEDURE OUT), AssertedEdgeProperties; predicates/FIs routed; offeringRole DEFERRED (candidate) |
| W06-SR-07 | W06 | W05 | other | ALREADY_SATISFIED | W05 D-W05-02 |
| W06-SR-08 | W06 | W15 | field | DEFERRED | W15 has not ruled on Procedure session bundles; BundleComponent.component* fields are typed Product/ProductVariant/PackageConfiguration |
| W06-SR-09 | W06 | W17 | union | ALREADY_SATISFIED | W17 SafetySubjectTarget keeps Treatment, Procedure; SafetyEdgeProperties |
| W06-SR-10 | W06 | W10 | other | ALREADY_SATISFIED | TreatmentTargetProperties.legacyEvidenceStrengthHint; FI via W10-SR-11 (W00-R-07) |
| W06-SR-11 | W06 | W03 | field | INJECTED | Condition.treatedBy (TARGETS_CONDITION IN, TreatmentTargetProperties) |
| W06-SR-12 | W06 | W00 | other | OUT_OF_SCOPE (routed) | predicate registration |
| W06-SR-13 | W06 | W02 (with W03) | other | DEFERRED | scope candidate SC-W06-02 (requester proposes defer) |
| W06-SR-14 | W06 | W21 / W23 | union | ALREADY_SATISFIED | RecommendableTarget keeps Treatment/Procedure (W21-SR-18); W21 RECOMMENDS only from a source's own speech act |
| W07-SR-01 | W07 | W00 | other | ALREADY_SATISFIED | MR-11 |
| W07-SR-02 | W07 | W16 | field | ALREADY_SATISFIED | assembly fieldRenames/fieldTypeFixes (MR-03) align Observation with DiagnosticResult |
| W07-SR-03 | W07 | W00 | enum | ALREADY_SATISFIED + DEFERRED | MR-09 ResultQualifier owned by W07; NOT_REPORTED value: no failing case of its own -> DEFERRED |
| W07-SR-04 | W07 | W16 | field | ALREADY_SATISFIED | W16 Observation.measuresMetrics StructuralEdgeProperties |
| W07-SR-05 | W07 | W16 | field | ALREADY_SATISFIED | MR-07 FOR_METRIC; both sides StructuralEdgeProperties |
| W07-SR-06 | W07 | W00 | enum | ENUM_ADDED | ReferenceIntervalDerivation.ADOPTED_FROM_GUIDELINE (decision report C) |
| W07-SR-07 | W07 | W03 | field | ALREADY_SATISFIED + INJECTED | W03-SR-06 rulings; INJECTED Condition.indicatedByBiomarkers (INDICATES IN, AssociationProjectionProperties, read-only) |
| W07-SR-08 | W07 | W08 | field | ALREADY_SATISFIED | RUNS_ON_PLATFORM StructuralEdgeProperties both sides; Device MEASURES_METRIC uses MeasurementEdgeProperties |
| W07-SR-09 | W07 | W00 | validator | OUT_OF_SCOPE (routed) | V-303r |
| W07-SR-10 | W07 | W00 | other | OUT_OF_SCOPE (routed) | COMPARED_TO ruleOnly (W00-R-23 ruled) |
| W07-SR-11 | W07 | W00 | validator | OUT_OF_SCOPE (routed) | V-302r, V-304r, V-305c, V-314..318 |
| W07-SR-12 | W07 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W07-SR-13 | W07 | W00 | other | OUT_OF_SCOPE (routed) | predicate CHANGED_BETWEEN |
| W07-SR-14 | W07 | W23 | other | OUT_OF_SCOPE (routed) | W23 privacy class confirmation |
| W07-SR-15 | W07 | W00 | validator | OUT_OF_SCOPE (routed) | V-313r |
| W07-SR-16 | W07 | W12 | union | ALREADY_SATISFIED | W12 CertificationCoverageTarget includes AssayVersion and TestingLaboratory (the performing organization as certified laboratory unit) |
| W07-SR-17 | W07 | W13 | union | ALREADY_SATISFIED | W13 RegulatorySubjectTarget includes AlgorithmVersion |
| W07-SR-18 | W07 | W01 | other | ALREADY_SATISFIED | W07 AssayVersion.operatedBy -> Organization; site via W01 OPERATES_FACILITY |
| W08-SR-01 | W08 | W07 | field | INJECTED + DEFERRED | INJECTED AssayVersion.runsOnDevices (RUNS_ON_INSTRUMENT OUT -> Device, StructuralEdgeProperties) and AssayVersion.usedByDevices (PERFORMED_WITH_ASSAY_VERSION IN, AssertedEdgeProperties). Retyping runsOnInstrument to [EquipmentModelTarget!]! is a fieldTypeFix -> DEFERRED to Fable |
| W08-SR-02 | W08 | W07 | other | DEFERRED | W07 MeasurementEdgeProperties description still names Sensor; description edit for W07/Fable |
| W08-SR-03 | W08 | W04 | field | INJECTED | Product.embodiesModels (EMBODIES_MODEL OUT -> EquipmentModelTarget, AssertedEdgeProperties) |
| W08-SR-04 | W08 | W04 | field | INJECTED | Product.runsOnDevices (RUNS_ON_DEVICE OUT -> Device, AssertedEdgeProperties) |
| W08-SR-05 | W08 | W07 | field | INJECTED | AssayVersion.runsFirmwareVersion (RUNS_FIRMWARE_VERSION OUT -> FirmwareVersion, StructuralEdgeProperties); FirmwareVersion admitted as candidate (decision report C) |
| W08-SR-06 | W08 | W00 | other | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | FirmwareVersion in W00 AssertionSubjectTarget; tokens/predicates routed |
| W08-SR-07 | W08 | W01 | field | INJECTED | Organization.developsPlatforms (DEVELOPS_PLATFORM OUT, AssertedEdgeProperties), usesPlatforms (USES_PLATFORM OUT), usesEquipment (USES_EQUIPMENT OUT), UsageEdgeProperties |
| W08-SR-08 | W08 | Fable (registry) | other | ALREADY_SATISFIED | registry admission (decision report C) |
| W08-SR-09 | W08 | W13 | union | ALREADY_SATISFIED | W13 RegulatorySubjectTarget excludes W08 types |
| W08-SR-10 | W08 | W21 | field | ALREADY_SATISFIED | W21 RelationshipAssertion.qualifiedBy; W00 Assertion.qualifiedBy/qualifies (QualificationProperties) |
| W08-SR-11 | W08 | W16 | other | ALREADY_SATISFIED | documentation (W16 StepInstrumentTarget model-level) |
| W08-SR-12 | W08 | W07 | property | DEFERRED | optional identity-defining AssayVersion configuration text: changes W07 AssayVersion identity rule, owner decision |
| W08-SR-13 | W08 | W11 | field | ALREADY_SATISFIED | W11 ManufacturingStep.usesEquipment/usesPlatforms with UsageEdgeProperties |
| W09-SR-01 | W09 | Fable (registry) | other | ALREADY_SATISFIED | registry admission (decision report C); enums in W09 fragment |
| W09-SR-02 | W09 | Fable (registry) / W00 | other | ALREADY_SATISFIED | registry admission (decision report C) |
| W09-SR-03 | W09 | W00 | union | ALREADY_SATISFIED | W00 SupportedRecordTarget includes StudyResult, RegistrationVersion, ProtocolVersion (W00-R-22) |
| W09-SR-04 | W09 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W09-SR-05 | W09 | W01 | other | OUT_OF_SCOPE (routed) + ALREADY_SATISFIED | (a)(b) predicates HOLDS_STUDY_ROLE / COLLABORATES_ON_STUDY to W00 predicate registry; (c) confirmed through W09 derived SPONSORED_BY/OPERATED_BY rules; Organization.servesAsCroFor injected under W01-SR-17 |
| W09-SR-06 | W09 | W04 (with W02) | enum | DEFERRED | new shared enums DosageForm / AdministrationRoute are not defined by any fragment and their owner is not ruled (W16-SR-09 also open) |
| W09-SR-07 | W09 | W02 (with W05) | other | ALREADY_SATISFIED | W09-D19 |
| W09-SR-08 | W09 | W08 | field | ALREADY_SATISFIED | W09 InterventionComponent.usesDevice (USES_INTERVENTION_DEVICE -> Device) |
| W09-SR-09 | W09 | W06, W16, W05, W02 | field | ALREADY_SATISFIED + DEFERRED | (a)(c) member types exist and legacy union resolved; (b) DEFERRED: W06 retired Treatment.evaluatedInStudies (W06 01/07); legacy edges stay readable from Study.evaluates (LEGACY_EVALUATES after the MR-05 rename) |
| W09-SR-10 | W09 | W17 | field | ALREADY_SATISFIED + INJECTED | W17 SafetySignal.reportedInStudies; Study.reportsSafetySignals injected per W17-SR-08(b) |
| W09-SR-11 | W09 | W10 | union | ALREADY_SATISFIED | W10 INTERPRETS_RESULT_OF/INCLUDES_RESULT/BASED_ON_EVIDENCE target StudyResult; EvidenceTargetTarget includes StudyIntervention |
| W09-SR-12 | W09 | W00 | other | OUT_OF_SCOPE (routed) | KCR qualifier carriage |
| W09-SR-13 | W09 | W00 / Fable | other | DEFERRED | MR-05 / W00-R-17 ruled LEGACY_EVALUATES; W09 Study.evaluates still declares EVALUATES -> assembler textReplacement (section 5) |
| W09-SR-14 | W09 | W19 / W00 | enum | ALREADY_SATISFIED | W00 SourceKind TRIAL_REGISTRY_RECORD, BIBLIOGRAPHIC_RECORD |
| W09-SR-15 | W09 | W13 | other | DEFERRED | W13 decides the IDE nonsignificant-risk status kind |
| W09-SR-16 | W09 | W00 (predicate registry) | other | OUT_OF_SCOPE (routed) | predicates |
| W09-SR-17 | W09 | Fable (operations, with W23) | other | ALREADY_SATISFIED | MR-12 |
| W09-CR-01 | W09 | W00 / Fable | validator | OUT_OF_SCOPE (routed) | V-217r/V-217i |
| W09-CR-02 | W09 | W00 / Fable | validator | OUT_OF_SCOPE (routed) | V-221r |
| W09-CR-03 | W09 | W00 / Fable | validator | OUT_OF_SCOPE (routed) | V-211r |
| W09-CR-04 | W09 | W10 / W00 | validator | OUT_OF_SCOPE (routed) | V-215r |
| W10-SR-01 | W10 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W10-SR-02 | W10 | W21 | field | INJECTED | ClaimEvidenceAssessment.basedOnSyntheses (CLAIM_EVIDENCE_BASED_ON OUT -> EvidenceSynthesis, property-less like the type's other CLAIM_EVIDENCE_BASED_ON fields); ASSESSES_CLAIM stays EvidenceSynthesis's |
| W10-SR-03 | W10 | Fable (registry) | other | ALREADY_SATISFIED | ContextOfUseMatch, MeaningfulnessVerdict in W10 fragment |
| W10-SR-04 | W10 | W00 | other | ALREADY_SATISFIED | W10 ApplicabilityDimension.considersAssessments uses CONSIDERS_ASSESSMENT; catalog domain change routed |
| W10-SR-05 | W10 | W00 | validator | OUT_OF_SCOPE (routed) | W10-V16b |
| W10-SR-06 | W10 | W00 (predicate registry) with W09 | other | OUT_OF_SCOPE (routed) | predicate REPORTS_POOLED_ESTIMATE |
| W10-SR-07 | W10 | W00 | other | OUT_OF_SCOPE (routed) | interface text frozen; W23-SR-03 same topic |
| W10-SR-08 | W10 | Fable (Wave 6 fixture repair) | other | OUT_OF_SCOPE (routed) | fixture repair |
| W10-SR-09 | W10 | W04 | other | OUT_OF_SCOPE (routed) | candidate predicate owned by W04 (no SDL slot) |
| W10-SR-10 | W10 | W23 | other | OUT_OF_SCOPE (routed) | W23 private-store contract |
| W10-SR-11 | W10 | W00 (forbidden implications) | other | OUT_OF_SCOPE (routed) | forbidden implications (W00-R-07) |
| W11-SR-01 | W11 | Fable (catalog conventions; enum owner W11) | enum | ALREADY_SATISFIED | W11 ProcessKind already has the eleven values |
| W11-SR-02 | W11 | Fable (catalog forbiddenImplications; V-112 implicationPa... | other | OUT_OF_SCOPE (routed) | forbidden implications |
| W11-SR-03 | W11 | W12 | property | ALREADY_SATISFIED | W12 SpecificationCriterion.upperThreshold, criterionPurpose (RELEASE\|SHELF_LIFE\|...\|IN_PROCESS\|NOT_STATED), CRITERION_OF_SPECIFICATION (D-W12-16); inverse SpecificationVersion.criteria injected under W12-SR-10 |
| W11-SR-04 | W11 | W00 (conventions.predicateExclusivity) | other | OUT_OF_SCOPE (routed) | predicateExclusivity (W00-R-07 ruled) |
| W11-SR-05 | W11 | W02 | field | ALREADY_SATISFIED + INJECTED + DEFERRED | ALREADY IngredientMaterial.governedBySpecifications / producedByProcesses (AssertedEdgeProperties). INJECTED IngredientMaterial.capabilityStates (CAPABILITY_FOR_MATERIAL IN, StructuralEdgeProperties), IngredientMaterial.usedAsProcessInput (INPUTS IN), ChemicalSubstance.usedAsProcessInput (INPUTS IN), ChemicalSubstance.producedAsProcessOutput (OUTPUTS IN), ProcessIoProperties. specificationOwnerUid projection DEFERRED to W02 |
| W11-SR-06 | W11 | W01 | field | INJECTED | Organization.performsProcesses, Organization.capabilityStates, Facility.hostsProcesses, Facility.capabilityStates (AssertedEdgeProperties) |
| W11-SR-07 | W11 | W01 | enum | DEFERRED | deprecating LocationType values is a removal/@deprecated decision for W01/Fable, not an addition |
| W11-SR-08 | W11 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W11-SR-09 | W11 | W00 / W01 (assertedPredicates) | other | OUT_OF_SCOPE (routed) | predicates |
| W11-SR-10 | W11 | W13 | other | ALREADY_SATISFIED | candidate RegulatoryInspection admitted (decision report C) |
| W11-SR-11 | W11 | Fable (catalog validation) with W00/W19 (SourceKind guida... | validator | OUT_OF_SCOPE (routed) | V-324r |
| W11-SR-12 | W11 | Fable (validation-params.json) | other | OUT_OF_SCOPE (routed) | validation-params |
| W11-SR-13 | W11 | W12 | property | ALREADY_SATISFIED | W12 ProductLot.lotCode; MANUFACTURED_UNDER -> SpecificationVersion |
| W12-SR-01 | W12 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W12-SR-02 | W12 | W00 | union | ALREADY_SATISFIED | W00 SupportedRecordTarget includes MeasuredResult, LotTestSummary, CertificateOfAnalysis (W00-R-22) |
| W12-SR-03 | W12 | W00 | enum | ALREADY_SATISFIED | W00 SourceKind.LABORATORY_REPORT |
| W12-SR-04 | W12 | W00 | other | OUT_OF_SCOPE (routed) | predicate CONFORMS_TO_SPECIFICATION |
| W12-SR-05 | W12 | W04 | field | INJECTED | Product.certifiedUnder and ProductVariant.certifiedUnder (CERTIFIED_UNDER OUT -> CertificationListing, DerivedEdgeProperties, read-only) |
| W12-SR-06 | W12 | W15 | other | ALREADY_SATISFIED | D-W15-13 (CommerceMatch RECALL_SCOPE/AUTHORIZED_CHANNEL) |
| W12-SR-07 | W12 | W00 | other | OUT_OF_SCOPE (routed) | forbidden implications |
| W12-SR-08 | W12 | W01 | enum | DEFERRED | retiring LocationType.GMP_FACILITY is a removal for W01/Fable |
| W12-SR-09 | W12 | W00 | validator | OUT_OF_SCOPE (routed) | V-503/V-505 scope |
| W12-SR-10 | W12 | W11 | field | ALREADY_SATISFIED + INJECTED | W11 adopted D-009 SpecificationVersion; INJECTED SpecificationVersion.criteria (CRITERION_OF_SPECIFICATION IN, StructuralEdgeProperties) |
| W12-SR-11 | W12 | W00 | other | OUT_OF_SCOPE (routed) + ALREADY_SATISFIED | API identity rule routed; APOC = MR-12 |
| W12-SR-12 | W12 | W07 | enum | ENUM_ADDED | ResultQualifier += BELOW_REPORTING_LIMIT, QUALITATIVE_ABSENT, QUALITATIVE_PRESENT (MR-09) |
| W13-SR-01 | W13 | W00 | other | OUT_OF_SCOPE (routed) | jurisdiction code convention |
| W13-SR-02 | W13 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W13-SR-03 | W13 | W00 | enum | ENUM_ADDED + DEFERRED | PathwayKind.NOVEL_FOOD_AUTHORISATION, RegulatoryResponseKind.NOVEL_FOOD_AUTHORISED (failing case EU 2020/16); V-336 routed; AUTHORIZATION status kind DEFERRED (decision report C) |
| W13-SR-04 | W13 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W13-SR-05 | W13 | W00 | other | OUT_OF_SCOPE (routed) | predicateExclusivity HAS_PATHWAY_VERSION (W00-R-07 ruled) |
| W13-SR-06 | W13 | W00 | enum | ENUM_ADDED | RegulatoryResponseKind.NDI_FILING_ACKNOWLEDGED (decision report C) |
| W13-SR-07 | W13 | W00 | other | OUT_OF_SCOPE (routed) | predicates / FIs |
| W13-SR-08 | W13 | W04 | field | ALREADY_SATISFIED | W04 Product.hasRegulatoryStatuses (HAS_REGULATORY_STATUS) and followsRegulatoryPathways (FOLLOWS_PATHWAY), DerivedEdgeProperties, read-only; ProductSnapshot scalar derivations are projection-job rules (routed) |
| W13-SR-09 | W13 | W06 | property | ALREADY_SATISFIED | W06 Treatment.orphanDrugDesignation @settable(false,false) |
| W13-SR-10 | W13 | W01 | field | INJECTED | Facility.regulatoryStatuses (STATUS_OF IN, AssertedEdgeProperties); W01 organizationType REGULATORY_AGENCY kept |
| W13-SR-11 | W13 | W02 | union | ALREADY_SATISFIED | RegulatorySubjectTarget lists MaterialMixture; MR-01 resolves it through IngredientMaterial at assembly |
| W13-SR-12 | W13 | W07 | union | ALREADY_SATISFIED | RegulatorySubjectTarget lists AssayVersion |
| W13-SR-13 | W13 | W12 | other | ALREADY_SATISFIED | W12 consumes; no SDL slot |
| W13-SR-14 | W13 | W10 | other | OUT_OF_SCOPE (routed) | W10 applicability (no SDL slot) |
| W13-SR-15 | W13 | W00 | validator | OUT_OF_SCOPE (routed) | V-322r/V-333r/V-334r |
| W13-SR-16 | W13 | W00 | other | ALREADY_SATISFIED | MR-12 |
| W13-SR-17 | W13 | W14 | other | ALREADY_SATISFIED | W14 carries the pair (V-W14-02) |
| W13-SR-18 | W13 | W09 | union | ALREADY_SATISFIED | RegulatorySubjectTarget lists StudyIntervention |
| W14-SR-01 | W14 | W00 | other | OUT_OF_SCOPE (routed) + ALREADY_SATISFIED | tokens routed; IpRightStatus in W00 AssertionSubjectTarget |
| W14-SR-02 | W14 | Fable 5.1 (registry) with W00 (kernel check) and W13 (INV... | other | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | IpRightStatus/IP_STATUS_OF admitted (decision report C); enum registration routed |
| W14-SR-03 | W14 | W01 | field | INJECTED + OUT_OF_SCOPE (routed) | Organization.ownsTrademarks (OWNS_TRADEMARK), assignedPatentFamilies / assignedPatentApplications / assignedGrantedPatents (ASSIGNED_PATENT; concrete targets instead of a new PatentAssignmentTarget union), licensesPatents (LICENSES_PATENT), grantsPatentLicenses (GRANTS_PATENT_LICENSE), all OUT, AssertedEdgeProperties; (a) predicate and (d) FIs routed |
| W14-SR-04 | W14 | W00 (predicate registry) with W10 (efficacy predicates) | other | OUT_OF_SCOPE (routed) | predicate PATENT_CLAIMS / implication pairs (W00-R-07) |
| W14-SR-05 | W14 | W02 | field | ALREADY_SATISFIED | W02 BrandedIngredientMaterial.marketedUnderMarks |
| W14-SR-06 | W14 | W01 (with W21 for CQ-CL-05) | other | DEFERRED | NAMED_INVENTOR (requester proposes defer) |
| W14-SR-07 | W14 | W20 (and W19) | field | ALREADY_SATISFIED | W20 Document.about (ABOUT); no W14 Document field |
| W14-SR-08 | W14 | W00 | other | OUT_OF_SCOPE (routed) | PredicateClass confirmation |
| W15-SR-01 | W15 | W01 | field | ALREADY_SATISFIED + INJECTED | (a)(b) ALREADY; (c) INJECTED Organization.hostsListings, listsOffers, sellerOfRecordFor, fulfillsOffers, affiliateForOffers (AssertedEdgeProperties), sellsProductVariants, sellsProducts (SELLS_PRODUCT, DerivedEdgeProperties, read-only); Person.affiliateForOffers; Facility.availableListings (AVAILABLE_IN IN, ListingEdgeProperties) |
| W15-SR-02 | W15 | W04 | field | INJECTED | ProductVariant.listedIn (LISTING_FOR IN), inventoryItems (INVENTORY_INSTANCE_OF IN), bundleComponents (COMPONENT_PRODUCT IN), soldBy (SELLS_PRODUCT IN, derived), commerceMatches (MATCHES_COMMERCE_ITEM IN); PackageConfiguration listedIn, inventoryItems, bundleComponents, commerceMatches; Product.bundleComponents, Product.soldBy |
| W15-SR-03 | W15 | W12 | field | INJECTED | ProductLot.units (UNIT_FROM_LOT IN, AssertedEdgeProperties), ProductLot.commerceMatches (MATCHES_COMMERCE_ITEM IN) |
| W15-SR-04 | W15 | W07 | field | INJECTED + ALREADY_SATISFIED | PanelDefinition.implementedByListings (IMPLEMENTS_PANEL IN, AssertedEdgeProperties); Product side W04 Product.implementsPanels present |
| W15-SR-05 | W15 | W06, W22 | other | ALREADY_SATISFIED | W06 Procedure.listedIn; W22 names MerchantListing |
| W15-SR-07 | W15 | W00 (catalog), Fable | union | ALREADY_SATISFIED | W15 ListingTarget includes Bundle; BundleComponent.componentPackage; CommerceItemTarget covers Offer, IndividualUnit, PackageConfiguration, Bundle, ProductLot, Organization |
| W15-SR-08 | W15 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W15-SR-09 | W15 | W00 | field | ALREADY_SATISFIED + INJECTED | W00-R-18 / W00-R-22 ruled: WAS_GENERATED_BY domain and SupportedRecordTarget extended in the W00 fragment; (b) SUPPORTED_BY edge wins over the string reference, so INJECTED PriceObservation.supportedBy and AffiliateLink.supportedBy (SUPPORTED_BY OUT -> SourceLocator, property-less kernel form); sourceLocatorUid stays as cache (V-W15-08) |
| W15-SR-10 | W15 | W00 (enum registry), Fable | enum | ALREADY_SATISFIED + DEFERRED | OfferKind, ObservedAvailability in W15 fragment; CommerceMatchKind/Outcome enums DEFERRED (decide at merge) |
| W15-SR-11 | W15 | W00 | other | OUT_OF_SCOPE (routed) | predicate / V-101 lists / implication pairs (W00-R-07) |
| W15-SR-12 | W15 | W23 | other | OUT_OF_SCOPE (routed) | W23 private-store contract |
| W15-SR-13 | W15 | W13 | other | DEFERRED | W13 recall record scope |
| W15-SR-14 | W15 | W21 | other | OUT_OF_SCOPE (routed) | W21 relevance assessment citation (no slot) |
| W15-SR-15 | W15 | W19, W00 (SourceKind owner) | enum | ALREADY_SATISFIED | W00 SourceKind BLOG_OR_REVIEW_PAGE, STOREFRONT_STRUCTURED_DATA |
| W15-SR-16 | W15 | W00 (runtime), Fable | other | ALREADY_SATISFIED | MR-12 |
| W16-SR-01 | W16 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W16-SR-02 | W16 | W00 | other | OUT_OF_SCOPE (routed) + ALREADY_SATISFIED | predicates routed; Protocol/ProtocolEdition/ProtocolStep/Observation in W00 AssertionSubjectTarget |
| W16-SR-03 | W16 | W07 | field | ALREADY_SATISFIED | MR-03 alignment applied by assembly rulings |
| W16-SR-04 | W16 | W00 | other | ALREADY_SATISFIED | MR-10 |
| W16-SR-05 | W16 | W01 | field | INJECTED | Person.recordsObservations (RECORDS OUT), Person.postsResults (POSTS_RESULT OUT), AssertedEdgeProperties, public persons only |
| W16-SR-06 | W16 | W00 | other | ALREADY_SATISFIED | W00-R-23 HAS_CURRENT_PROTOCOL_STEP ruleOnly |
| W16-SR-07 | W16 | Fable (ledger; enum owner W16) | enum | ENUM_ADDED | CadenceUnit += YEAR, MINUTE (decision report C) |
| W16-SR-08 | W16 | Fable (ledger; enum owner W16) | enum | ENUM_ADDED | ConstraintRole += REPEAT_UNTIL (decision report C) |
| W16-SR-09 | W16 | W00 with W09 | enum | DEFERRED | shared route enum owner (W09 or W00) not ruled |
| W16-SR-10 | W16 | W09 | other | ALREADY_SATISFIED | W09 confirms CL-007 |
| W16-SR-11 | W16 | W23 | other | OUT_OF_SCOPE (routed) | W23 private-store contract |
| W16-SR-12 | W16 | W02 | union | DEFERRED | no substance-class identity type exists for ConstraintBasisTarget |
| W16-SR-13 | W16 | W10 | union | UNION_ADDED + OUT_OF_SCOPE (routed) | ApplicabilityUseTarget += ProtocolStep, ProtocolEdition; EvidenceTargetTarget already has Assertion; FI routed |
| W16-SR-14 | W16 | Fable (validators) | validator | OUT_OF_SCOPE (routed) | V-525p.. V-542p |
| W16-SR-15 | W16 | W08 | other | OUT_OF_SCOPE (routed) | W08 boundary statement; device token |
| W16-SR-16 | W16 | W05 | union | ALREADY_SATISFIED | W05 answered (FoodProduct retired, FoodItem via IngredientMaterial); MR-01/MR-02 prune at assembly |
| W16-SR-17 | W16 | W04 | union | ALREADY_SATISFIED | StepSubstanceTarget includes FormulationVersion, ProductVariant, Product |
| W16-SR-18 | W16 | W00 with W20 | other | DEFERRED | W00-R-19 ruled MENTIONS_ENTITY with RetrievalEdgeProperties; W16 ProtocolResult.mentions still declares MENTIONS/StructuralEdgeProperties -> assembler textReplacement (section 5) |
| W16-SR-19 | W16 | W17 | other | ALREADY_SATISFIED | W17-SR-12 keeps them separate |
| W16-SR-20 | W16 | W10 | other | ALREADY_SATISFIED | W16 RULE_TRIGGERED_BY; TRIGGERED_BY only W10 |
| W17-SR-01 | W17 | Fable (ownership registry) | other | OUT_OF_SCOPE (routed) | registry admission of W17 elements |
| W17-SR-02 | W17 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W17-SR-03 | W17 | W00 (catalog conventions and safety_and_constraints module) | other | OUT_OF_SCOPE (routed) | predicates / FIs; PredicateClass SAFETY not added by W00 |
| W17-SR-04 | W17 | W02, W04, W05, W06 (writers of hasSafetySignals) and Fable | other | DEFERRED | class wording in existing hasSafetySignals descriptions (W02 via injection uses 'structural'; W04/W05/W06 descriptions are fragment text) -> Fable |
| W17-SR-05 | W17 | W00 | union | ALREADY_SATISFIED | W00 AssertionSubjectTarget without SafetySignal; SupportedRecordTarget with SafetySignal |
| W17-SR-06 | W17 | W10 (W00 resolves an archetype-subtype dispute) | other | OUT_OF_SCOPE (routed) | W10 confirmations |
| W17-SR-07 | W17 | W23 | other | OUT_OF_SCOPE (routed) | W23 private-store contract |
| W17-SR-08 | W17 | W09 | field | INJECTED + DEFERRED | (b) INJECTED Study.reportsSafetySignals (REPORTS_SAFETY_SIGNAL OUT, DerivedEdgeProperties, read-only); (a) CODED_AS_EFFECT DEFERRED (W09 decides, optional); (c) agreed |
| W17-SR-09 | W17 | Fable (merged validation) with W00 | validator | OUT_OF_SCOPE (routed) | V-W17-* and V-231 scope |
| W17-SR-10 | W17 | W03 | field | INJECTED | Condition.relatedSafetySignals (RELATES_TO_CONDITION IN, StructuralEdgeProperties) |
| W17-SR-11 | W17 | W20 | enum | ALREADY_SATISFIED | W20 DocumentType.SAFETY_COMMUNICATION |
| W17-SR-12 | W17 | W16 | other | OUT_OF_SCOPE (routed) | W16 boundary |
| W17-SR-13 | W17 | W16, W18, W10/W20/W21, W03, W22 (owners of ProtocolResult... | union | ALREADY_SATISFIED | members kept by union owners |
| W18-SR-01 | W18 | W00 / Fable (conventions.uidTypeTokens) | other | OUT_OF_SCOPE (routed) | uid tokens |
| W18-SR-02 | W18 | W00 / Fable (catalog events_and_narrative module) | other | OUT_OF_SCOPE (routed) | catalog module promotion |
| W18-SR-03 | W18 | Fable (registry) | other | OUT_OF_SCOPE (routed) | registry admission |
| W18-SR-04 | W18 | W00 | enum | OUT_OF_SCOPE (routed) | kernel statedTense FUTURE / ActivityKind.CURATION (not in W00 fragment) |
| W18-SR-05 | W18 | W01 | field | INJECTED | Organization.hostsEvents, hostsConferences (HOSTS_EVENT OUT, AssertedEdgeProperties), exhibitsAt (EXHIBITS_AT OUT), involvedInEvents (INVOLVES IN); Person.speaksAt (SPEAKS_AT OUT), attends (ATTENDS OUT), involvedInEvents (INVOLVES IN); EventRoleEdgeProperties |
| W18-SR-06 | W18 | W21 | field | INJECTED + ALREADY_SATISFIED | (a) Episode.recordingOf (RECORDING_OF OUT, RecordingEdgeProperties); (b) sponsorsContent fields use SponsorableTarget; (c) W21 chose ACCOMPANIES_TALK, PRESENTED_AT is W18's (no Presentation type) |
| W18-SR-07 | W18 | W20 | field | INJECTED + ALREADY_SATISFIED | Document.presentedAt (PRESENTED_AT OUT, AssertedEdgeProperties); REPORTED_IN with DerivedSupportProperties and Event.supportedByChunks already in W18 fragment |
| W18-SR-08 | W18 | W21 | other | DEFERRED | requester proposes keep Conference target for 0.3 |
| W18-SR-09 | W18 | W13 | other | OUT_OF_SCOPE (routed) | W13 basis predicate / EU record |
| W18-SR-10 | W18 | W00 | validator | OUT_OF_SCOPE (routed) | W18-V03 |
| W18-SR-11 | W18 | W00 | other | OUT_OF_SCOPE (routed) | ANNOUNCED_IN domain |
| W18-SR-12 | W18 | W17, Fable | other | ALREADY_SATISFIED | W17 fragment defines SafetySignal and AdverseEffect |
| W19-SR-01 | W19 | W00 | enum | ALREADY_SATISFIED | W00 SourceKind (+8 values incl. OTHER) |
| W19-SR-02 | W19 | W00 | property | ALREADY_SATISFIED | W00 Source.renditionCoverage: RenditionCoverage |
| W19-SR-03 | W19 | W00 | enum | ALREADY_SATISFIED | W00 ActivityKind.DISCOVERY; SourceDiscoveryRecord labels |
| W19-SR-04 | W19 | W00 | enum | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | W19 AuthorityScope enum; predicateAuthorityScopes convention routed |
| W19-SR-05 | W19 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W19-SR-06 | W19 | W21 | union | ALREADY_SATISFIED | W21 OccurrenceContainerTarget includes Publication |
| W19-SR-07 | W19 | W21 | field | ALREADY_SATISFIED | W21 ACCOMPANIES_TALK (Episode.accompanyingDocuments) |
| W19-SR-08 | W19 | W21 | other | DEFERRED | multi-author asserter rule (decision report C deferred W21-SR-24) |
| W19-SR-09 | W19 | W00 | validator | OUT_OF_SCOPE (routed) | V-409/V-512 |
| W19-SR-10 | W19 | W00 | validator | OUT_OF_SCOPE (routed) | V-235 rewrite |
| W19-SR-11 | W19 | W09 | other | ALREADY_SATISFIED | W09 Publication identity |
| W19-SR-12 | W19 | W20 | other | ALREADY_SATISFIED | W20 accepted |
| W19-SR-13 | W19 | W00 | validator | OUT_OF_SCOPE (routed) | QS-7 |
| W19-SR-14 | W19 | W23 | other | OUT_OF_SCOPE (routed) | W23 projection closure |
| W19-SR-15 | W19 | W00 | other | OUT_OF_SCOPE (routed) | ingestion rule |
| W19-SR-16 | W19 | W09 | other | OUT_OF_SCOPE (routed) | W09 ingestion qualification |
| W20-SR-01 | W20 | W00 | other | ALREADY_SATISFIED | W00-R-23 ruleOnly types |
| W20-SR-02 | W20 | W00 | other | OUT_OF_SCOPE (routed) | uid token |
| W20-SR-03 | W20 | Fable (registry) | union | ALREADY_SATISFIED | W20 DocumentAuthorTarget |
| W20-SR-04 | W20 | Fable (registry) with W00 | other | ALREADY_SATISFIED | registry admission (decision report C) |
| W20-SR-05 | W20 | W00 | other | ALREADY_SATISFIED | W00-R-18 WAS_GENERATED_BY domain |
| W20-SR-06 | W20 | W00 | other | OUT_OF_SCOPE (routed) | kernel reading rule |
| W20-SR-07 | W20 | W00 | other | OUT_OF_SCOPE (routed) | operations index |
| W20-SR-08 | W20 | W00 | property | OUT_OF_SCOPE (routed) | W00 Source read alias (title) and canonicalUri rule |
| W20-SR-09 | W20 | W00 | other | OUT_OF_SCOPE (routed) | uid opaque segment rule |
| W20-SR-10 | W20 | W00 with W19 | enum | ALREADY_SATISFIED | W00 SourceKind.REINSTATEMENT_NOTICE |
| W20-SR-11 | W20 | W00 with W01, W04 | other | DEFERRED | W00-R-16 ruled; W04 rename pending in assembly (section 5) |
| W20-SR-12 | W20 | W18 with Fable | other | ALREADY_SATISFIED | W18 renamed its edge EVENT_ABOUT; ABOUT is W20's derived retrieval type |
| W20-SR-13 | W20 | W00 | other | DEFERRED | W00-R-19 ruled MENTIONS_ENTITY; W20 Chunk.mentions, W21 Episode.mentions, W16 ProtocolResult.mentions still declare MENTIONS -> assembler textReplacement (section 5) |
| W20-SR-14 | W20 | W21 | field | ALREADY_SATISFIED | W21 Claim.supportedByChunks, ClaimOccurrence.supportedByChunks |
| W20-SR-15 | W20 | W21 | field | ALREADY_SATISFIED | W21 retired Episode.hasTranscriptVersions |
| W20-SR-16 | W20 | W16 | field | DEFERRED | W16 retired ProtocolResult.supportedBy without chunk/document shortcuts (W16-D17, INV-404); adding them is W16's choice |
| W20-SR-17 | W20 | W01, W02, W03, W04, W05, W06, W07, W09, W11, W17, W18, W22 | field | ALREADY_SATISFIED + DEFERRED | Present: W04 ProductSnapshot, W05 Lifestyle, W06 Treatment/Procedure, W07 Biomarker/Metric.supportedBy, W17 AdverseEffect/SafetySignal, W18 Event. DEFERRED: W01, W02, W03, W09, W11, W22 retired their chunk-support fields in their migration maps (provenance via Assertion -> SUPPORTED_BY -> SourceLocator); injecting would reverse owner decisions |
| W20-SR-18 | W20 | W00 with Fable (validation) | validator | OUT_OF_SCOPE (routed) | W20-V01..V10 |
| W20-SR-19 | W20 | W00 | other | OUT_OF_SCOPE (routed) | offset unit convention |
| W20-SR-20 | W20 | W00 | other | OUT_OF_SCOPE (routed) | matching normalization |
| W20-SR-21 | W20 | W19 | other | OUT_OF_SCOPE (routed) | W19 Source identity rule |
| W20-SR-22 | W20 | Fable (query-shapes) | other | OUT_OF_SCOPE (routed) | QS-8 patch |
| W20-SR-23 | W20 | Fable with W00 (examples) | other | OUT_OF_SCOPE (routed) | fixture repair (decision report D) |
| W20-SR-24 | W20 | Fable (contract B1) | other | ALREADY_SATISFIED | MR-11 @deprecated |
| W21-SR-01 | W21 | W00 | other | OUT_OF_SCOPE (routed) | uid token |
| W21-SR-02 | W21 | Fable (enum admission) | enum | DEFERRED | EpisodeType / EpisodeSegmentType enums not defined (strings in W21 fragment); not in decision report C |
| W21-SR-03 | W21 | Fable (registry) / W00 (relationship class catalog) | other | ALREADY_SATISFIED | DELIMITED_BY admitted (decision report C, W00-R-29) |
| W21-SR-04 | W21 | Fable (registry) | other | ALREADY_SATISFIED | IN_RENDITION admitted (decision report C) |
| W21-SR-05 | W21 | Fable (registry); W19 informed | other | ALREADY_SATISFIED | DISTRIBUTES_RENDITION admitted (decision report C) |
| W21-SR-06 | W21 | Fable (catalog range) with W09 | union | ALREADY_SATISFIED | OccurrenceContainerTarget includes Publication |
| W21-SR-07 | W21 | W00 (validation suite) with W01 | field | INJECTED + OUT_OF_SCOPE (routed) | Person.recommends (RECOMMENDS OUT -> RecommendableTarget, DerivedEdgeProperties, read-only; W00-R-25); V-423 -> V-W21-06 routed |
| W21-SR-08 | W21 | W01, W20, W18 | field | INJECTED + ALREADY_SATISFIED | Organization.sponsorsContent, ConsumerBrand.sponsorsContent (SPONSORS_CONTENT OUT -> SponsorableTarget, AssertedEdgeProperties); optional Document inverses injected (sponsoringOrganizations, sponsoringBrands); Conference inverses already in W18 |
| W21-SR-09 | W21 | W01 (RoleType owner) | enum | ENUM_ADDED + ALREADY_SATISFIED | RoleType += MODERATOR; HOST, CO_HOST, GUEST already present |
| W21-SR-10 | W21 | W00 with W20 | other | DEFERRED | W00-R-19 ruled MENTIONS_ENTITY; rename pending in assembly (section 5) |
| W21-SR-11 | W21 | Fable (enum ownership) | enum | ALREADY_SATISFIED | W03-SR-13 resolved |
| W21-SR-12 | W21 | Fable (registry) | validator | OUT_OF_SCOPE (routed) | V-417 amendment |
| W21-SR-13 | W21 | W19 (sourceKind proposals) / W00 (enum) / W20 (DocumentType) | enum | ALREADY_SATISFIED + DEFERRED | SourceKind PODCAST_FEED, EVENT_TRANSCRIPT, PRESENTATION_SLIDES, NEWS_ARTICLE present (W00); DocumentType TRANSCRIPT DEFERRED: W20 extended DocumentType with TRANSCRIPT_PAGE instead |
| W21-SR-14 | W21 | W00 (RelevanceBasis enum) | enum | ALREADY_SATISFIED | W00 RelevanceBasis.SAME_SERVICE_CATEGORY |
| W21-SR-15 | W21 | W00 (predicate registry) with W01, W03, W09 | other | OUT_OF_SCOPE (routed) | predicates |
| W21-SR-16 | W21 | W00 (validation suite) / Fable | validator | OUT_OF_SCOPE (routed) | V-W21-01..12, params |
| W21-SR-17 | W21 | Fable (examples) / W00 | other | OUT_OF_SCOPE (routed) | fixture upgrade |
| W21-SR-18 | W21 | Fable (union ownership) with W01 | union | UNION_ADDED | RecommendableTarget = Protocol \| ChemicalSubstance \| IngredientMaterial \| Organization \| ConsumerBrand \| Product \| ProductVariant \| Treatment \| Lifestyle \| Procedure, defined in extra-definitions.graphql (sole writer W21, decision report C) |
| W21-SR-19 | W21 | Fable (candidate) | other | DEFERRED | EXCERPTS_FROM (decision report C) |
| W21-SR-20 | W21 | W18 | field | ALREADY_SATISFIED + INJECTED | W18 Event.recordings (RECORDING_OF); Episode.recordingOf injected (W18-SR-06a) |
| W21-SR-21 | W21 | W00 | other | OUT_OF_SCOPE (routed) | QS-1a gap code |
| W21-SR-22 | W21 | Fable (registry) with W19, W20 | field | ALREADY_SATISFIED | W21 Episode.accompanyingDocuments (ACCOMPANIES_TALK) |
| W21-SR-23 | W21 | W00 (generic Assertion field; validation suite) | field | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | W00 Assertion.qualifiedBy / qualifies (QualificationProperties); V-416 -> V-W21-12 routed |
| W21-SR-24 | W21 | W01 with W09, W19 | other | DEFERRED | decision report C (asserter of multi-author publications) |
| W21-SR-25 | W21 | W00 (AssertionSubjectTarget) and W22 (MediaSubjectTarget) | union | ALREADY_SATISFIED | W00 AssertionSubjectTarget without ExperienceReport; W22 member removed by MR-02 pruning at assembly |
| W22-SR-01 | W22 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W22-SR-02 | W22 | W00 | enum | ALREADY_SATISFIED | W00 UseKind.DISPLAY_MEDIA |
| W22-SR-03 | W22 | W00 | other | ALREADY_SATISFIED | W00-R-18 WAS_GENERATED_BY / USED domains |
| W22-SR-04 | W22 | W00 | enum | ALREADY_SATISFIED | W00 ActivityKind MEDIA_GENERATION, MEDIA_TRANSFORMATION, MEDIA_ASSESSMENT |
| W22-SR-05 | W22 | W00 | other | OUT_OF_SCOPE (routed) | normalization IMG-PX1 |
| W22-SR-06 | W22 | W00 | enum | ALREADY_SATISFIED | W00 SourceKind MEDIA_FILE, MEDIA_REPOSITORY_RECORD, DATA_REPOSITORY_RECORD |
| W22-SR-07 | W22 | W04 | field | ALREADY_SATISFIED + INJECTED + DEFERRED | (a)(c) agreed (LabelSnapshot specialization; LABEL_FOR authoritative); (b) INJECTED LabelDeclaration.labelRegions (REGION_HAS_DECLARATION IN, StructuralEdgeProperties); DeclarationKind has no INGREDIENT_AMOUNT and W04 has not supplied the value -> DEFERRED |
| W22-SR-08 | W22 | W00 | validator | OUT_OF_SCOPE (routed) | V-601..V-615, FIs |
| W22-SR-09 | W22 | W07 | property | DEFERRED | removal of Metric.mediaUrl/mediaType (still in W07 fragment) is a fragment edit for W07/Fable |
| W22-SR-10 | W22 | W23 | other | OUT_OF_SCOPE (routed) | W23 media-display policy |
| W22-SR-11 | W22 | W21 | field | ALREADY_SATISFIED | W21 RelationshipAssertion.visualizedBy |
| W22-SR-12 | W22 | W03 | union | ALREADY_SATISFIED | Association retired (MR-02 prunes it); W03 types exist |
| W22-SR-13 | W22 | W00 | union | ALREADY_SATISFIED | W00 AssertionSubjectTarget without MediaSource, with MediaRightsRecord |
| W23-SR-01 | W23 | W00 | other | OUT_OF_SCOPE (routed) | uid tokens |
| W23-SR-02 | W23 | W00 | other | ALREADY_SATISFIED | W00-R-18 WAS_GENERATED_BY adds AnswerRecord |
| W23-SR-03 | W23 | W00 | property | OUT_OF_SCOPE (routed) | uid/id on archetype interfaces (contract B3, kernel) |
| W23-SR-04 | W23 | Fable | other | ALREADY_SATISFIED | DECLARES_CRITERION admitted (decision report C) |
| W23-SR-05 | W23 | Fable | enum | ALREADY_SATISFIED | PolicyKind in W23 fragment (decision report C) |
| W23-SR-06 | W23 | W00 | other | OUT_OF_SCOPE (routed) + ALREADY_SATISFIED | redirect record routed; SupersessionKind.DUPLICATE_MERGE, EquivalenceKind.SAME_IDENTITY_MERGED present |
| W23-SR-07 | W23 | W00 | validator | OUT_OF_SCOPE (routed) | V-432 |
| W23-SR-08 | W23 | W00 | validator | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | MR-10 stored casing; V-313/V-521/QS changes routed |
| W23-SR-09 | W23 | Fable | validator | OUT_OF_SCOPE (routed) | V-W23-*; AccessTier OWNER_PRIVATE decision |
| W23-SR-10 | W23 | W00 | other | OUT_OF_SCOPE (routed) | field-level privacy classes |
| W23-SR-11 | W23 | W16 | validator | OUT_OF_SCOPE (routed) | V-533p |
| W23-SR-12 | W23 | W01 | other | OUT_OF_SCOPE (routed) | W01 confirmation (migration) |
| W23-SR-13 | W23 | W21 | other | ALREADY_SATISFIED | W21 ledger (ClaimOccurrence PERSONAL_EXPERIENCE by AnonymousActor) |
| W23-SR-14 | W23 | W07 | other | ALREADY_SATISFIED + OUT_OF_SCOPE (routed) | MR-09 resolves ResultQualifier collision; V-313 list routed |
| W23-SR-15 | W23 | W00 | enum | ALREADY_SATISFIED | W00 UseKind.DISPLAY_MEDIA |
| W23-SR-16 | W23 | Fable | other | ALREADY_SATISFIED | MR-12, MR-01 |

## 4. Injected fields

Direction and property type mirror the owner's own declaration of the same relationship type (opposite direction, same properties type); derived fields carry `DerivedEdgeProperties` and `@settable(onCreate: false, onUpdate: false)`. `verify-seam-closure.mjs` reports 0 property-type disagreements with opposite endpoints.

| Type (owner) | Field | Relationship | Dir | Target | Properties | Class | Requests |
|---|---|---|---|---|---|---|---|
| Organization (W01) | developsPlatforms | DEVELOPS_PLATFORM | OUT | TechnologyPlatform | AssertedEdgeProperties | asserted | W08-SR-07, W01-SR-20 |
| Organization (W01) | usesPlatforms | USES_PLATFORM | OUT | TechnologyPlatform | UsageEdgeProperties | asserted | W08-SR-07, W01-SR-20 |
| Organization (W01) | usesEquipment | USES_EQUIPMENT | OUT | ToolOrInstrument | UsageEdgeProperties | asserted | W08-SR-07, W01-SR-20 |
| Organization (W01) | performsProcesses | PERFORMS_PROCESS | OUT | ManufacturingProcess | AssertedEdgeProperties | asserted | W11-SR-06, W01-SR-13, W01-SR-20 |
| Organization (W01) | capabilityStates | HAS_CAPABILITY_STATE | OUT | ManufacturingCapability | AssertedEdgeProperties | asserted | W11-SR-06, W01-SR-13, W01-SR-20 |
| Organization (W01) | hostsListings | HOSTS_LISTING | OUT | MerchantListing | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Organization (W01) | listsOffers | LISTS_OFFER | OUT | Offer | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Organization (W01) | sellerOfRecordFor | SELLER_OF_RECORD_FOR | OUT | Offer | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Organization (W01) | fulfillsOffers | FULFILLS_OFFER | OUT | Offer | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Organization (W01) | affiliateForOffers | AFFILIATE_FOR_OFFER | OUT | Offer | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Organization (W01) | sellsProductVariants | SELLS_PRODUCT | OUT | ProductVariant | DerivedEdgeProperties | derived read-only | W15-SR-01(c) |
| Organization (W01) | sellsProducts | SELLS_PRODUCT | OUT | Product | DerivedEdgeProperties | derived read-only | W15-SR-01(c) |
| Organization (W01) | sponsorsContent | SPONSORS_CONTENT | OUT | SponsorableTarget | AssertedEdgeProperties | asserted | W21-SR-08, W18-SR-06(b), W01-SR-20 |
| Organization (W01) | operatesChannels | OPERATES_CHANNEL | OUT | Channel | AssertedEdgeProperties | asserted | W01-SR-20 |
| Organization (W01) | hostsEvents | HOSTS_EVENT | OUT | Event | AssertedEdgeProperties | asserted | W18-SR-05, W01-SR-20 |
| Organization (W01) | hostsConferences | HOSTS_EVENT | OUT | Conference | AssertedEdgeProperties | asserted | W18-SR-05, W01-SR-20 |
| Organization (W01) | exhibitsAt | EXHIBITS_AT | OUT | Conference | EventRoleEdgeProperties | asserted | W18-SR-05, W01-SR-20 |
| Organization (W01) | involvedInEvents | INVOLVES | IN | Event | EventRoleEdgeProperties | asserted | W18-SR-05 |
| Organization (W01) | submittedRegulatorySubmissions | SUBMITTED_BY | IN | RegulatorySubmission | AssertedEdgeProperties | asserted | W01-SR-20 |
| Organization (W01) | sponsorsStudies | SPONSORED_BY | IN | Study | DerivedEdgeProperties | derived read-only | W01-SR-17, W01-SR-20 |
| Organization (W01) | servesAsCroFor | OPERATED_BY | IN | Study | DerivedEdgeProperties | derived read-only | W01-SR-17, W01-SR-20, W09-SR-05 |
| Organization (W01) | developsTreatments | DEVELOPS_TREATMENT | OUT | Treatment | AssertedEdgeProperties | asserted | W06-SR-06 |
| Organization (W01) | offersTreatments | OFFERS_TREATMENT | OUT | Treatment | AssertedEdgeProperties | asserted | W06-SR-06 |
| Organization (W01) | offersProcedures | OFFERS_PROCEDURE | OUT | Procedure | AssertedEdgeProperties | asserted | W06-SR-06 |
| Organization (W01) | ownsTrademarks | OWNS_TRADEMARK | OUT | Trademark | AssertedEdgeProperties | asserted | W14-SR-03(c) |
| Organization (W01) | assignedPatentFamilies | ASSIGNED_PATENT | OUT | PatentFamily | AssertedEdgeProperties | asserted | W14-SR-03(c) |
| Organization (W01) | assignedPatentApplications | ASSIGNED_PATENT | OUT | PatentApplication | AssertedEdgeProperties | asserted | W14-SR-03(c) |
| Organization (W01) | assignedGrantedPatents | ASSIGNED_PATENT | OUT | GrantedPatent | AssertedEdgeProperties | asserted | W14-SR-03(c) |
| Organization (W01) | licensesPatents | LICENSES_PATENT | OUT | PatentLicense | AssertedEdgeProperties | asserted | W14-SR-03(c) |
| Organization (W01) | grantsPatentLicenses | GRANTS_PATENT_LICENSE | OUT | PatentLicense | AssertedEdgeProperties | asserted | W14-SR-03(a)(c) |
| Facility (W01) | hostsProcesses | HOSTS_PROCESS | OUT | ManufacturingProcess | AssertedEdgeProperties | asserted | W11-SR-06, W01-SR-13, W01-SR-20 |
| Facility (W01) | capabilityStates | HAS_CAPABILITY_STATE | OUT | ManufacturingCapability | AssertedEdgeProperties | asserted | W11-SR-06, W01-SR-13, W01-SR-20 |
| Facility (W01) | regulatoryStatuses | STATUS_OF | IN | RegulatoryStatus | AssertedEdgeProperties | asserted | W01-SR-20, W13-SR-10 |
| Facility (W01) | certificationScopes | COVERS | IN | CertificationScope | AssertedEdgeProperties | asserted | W01-SR-20 |
| Facility (W01) | availableListings | AVAILABLE_IN | IN | MerchantListing | ListingEdgeProperties | asserted (inverse view) | W15-SR-01(c) |
| Person (W01) | appearsIn | APPEARS_IN | OUT | Episode | AppearanceProperties | asserted | W01-SR-20 |
| Person (W01) | servesOnChannels | SERVES_ON_CHANNEL | OUT | Channel | AppearanceProperties | asserted | W01-SR-20 |
| Person (W01) | recommends | RECOMMENDS | OUT | RecommendableTarget | DerivedEdgeProperties | derived read-only | W21-SR-07, W21-SR-18, W01-SR-20 |
| Person (W01) | speaksAt | SPEAKS_AT | OUT | Event | EventRoleEdgeProperties | asserted | W18-SR-05, W01-SR-20 |
| Person (W01) | attends | ATTENDS | OUT | Conference | EventRoleEdgeProperties | asserted | W18-SR-05, W01-SR-20 |
| Person (W01) | involvedInEvents | INVOLVES | IN | Event | EventRoleEdgeProperties | asserted | W18-SR-05 |
| Person (W01) | recordsObservations | RECORDS | OUT | Observation | AssertedEdgeProperties | asserted | W16-SR-05, W01-SR-20 |
| Person (W01) | postsResults | POSTS_RESULT | OUT | ProtocolResult | AssertedEdgeProperties | asserted | W16-SR-05, W01-SR-20 |
| Person (W01) | authoredDocuments | AUTHORED_BY | IN | Document | AssertedEdgeProperties | asserted | W01-SR-20 |
| Person (W01) | affiliateForOffers | AFFILIATE_FOR_OFFER | OUT | Offer | AssertedEdgeProperties | asserted | W15-SR-01(c), W01-SR-20 |
| Person (W01) | investigatedStudies | INVESTIGATED_BY | IN | Study | DerivedEdgeProperties | derived read-only | W01-SR-20 |
| PseudonymousActor (W01) | onPlatforms | ON_PLATFORM | OUT | Platform | StructuralEdgeProperties | structural | W01-SR-20 |
| ConsumerBrand (W01) | sponsorsContent | SPONSORS_CONTENT | OUT | SponsorableTarget | AssertedEdgeProperties | asserted | W21-SR-08, W01-SR-20 |
| Product (W04) | embodiesModels | EMBODIES_MODEL | OUT | EquipmentModelTarget | AssertedEdgeProperties | asserted (candidate) | W08-SR-03, W04-SR-08 |
| Product (W04) | runsOnDevices | RUNS_ON_DEVICE | OUT | Device | AssertedEdgeProperties | asserted (candidate) | W08-SR-04 |
| Product (W04) | certifiedUnder | CERTIFIED_UNDER | OUT | CertificationListing | DerivedEdgeProperties | derived read-only | W12-SR-05 |
| Product (W04) | bundleComponents | COMPONENT_PRODUCT | IN | BundleComponent | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| Product (W04) | soldBy | SELLS_PRODUCT | IN | Organization | DerivedEdgeProperties | derived read-only (inverse view) | W15-SR-02 |
| ProductVariant (W04) | certifiedUnder | CERTIFIED_UNDER | OUT | CertificationListing | DerivedEdgeProperties | derived read-only | W12-SR-05 |
| ProductVariant (W04) | listedIn | LISTING_FOR | IN | MerchantListing | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| ProductVariant (W04) | inventoryItems | INVENTORY_INSTANCE_OF | IN | InventoryItem | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| ProductVariant (W04) | bundleComponents | COMPONENT_PRODUCT | IN | BundleComponent | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| ProductVariant (W04) | soldBy | SELLS_PRODUCT | IN | Organization | DerivedEdgeProperties | derived read-only (inverse view) | W15-SR-02 |
| ProductVariant (W04) | commerceMatches | MATCHES_COMMERCE_ITEM | IN | CommerceMatch | (none) | structural (inverse view) | W15-SR-02 |
| PackageConfiguration (W04) | listedIn | LISTING_FOR | IN | MerchantListing | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| PackageConfiguration (W04) | inventoryItems | INVENTORY_INSTANCE_OF | IN | InventoryItem | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| PackageConfiguration (W04) | bundleComponents | COMPONENT_PRODUCT | IN | BundleComponent | AssertedEdgeProperties | asserted (inverse view) | W15-SR-02 |
| PackageConfiguration (W04) | commerceMatches | MATCHES_COMMERCE_ITEM | IN | CommerceMatch | (none) | structural (inverse view) | W15-SR-02 |
| LabelDeclaration (W04) | labelRegions | REGION_HAS_DECLARATION | IN | ProductLabelRegion | StructuralEdgeProperties | structural (inverse view) | W22-SR-07(b) |
| IngredientMaterial (W02) | capabilityStates | CAPABILITY_FOR_MATERIAL | IN | ManufacturingCapability | StructuralEdgeProperties | structural (inverse view) | W11-SR-05 |
| IngredientMaterial (W02) | usedAsProcessInput | INPUTS | IN | ManufacturingStep | ProcessIoProperties | asserted (inverse view) | W11-SR-05 |
| IngredientMaterial (W02) | hasSafetySignals | HAS_SAFETY_SIGNAL | OUT | SafetySignal | SafetyEdgeProperties | structural | W02-SR-14, W17-SR-04 |
| IngredientMaterial (W02) | derivedFromTaxa | DERIVED_FROM_TAXON | OUT | BotanicalTaxon | AssertedEdgeProperties | asserted | W05-SR-03 |
| ChemicalSubstance (W02) | usedAsProcessInput | INPUTS | IN | ManufacturingStep | ProcessIoProperties | asserted (inverse view) | W11-SR-05 |
| ChemicalSubstance (W02) | producedAsProcessOutput | OUTPUTS | IN | ManufacturingStep | ProcessIoProperties | asserted (inverse view) | W11-SR-05 |
| ChemicalSubstance (W02) | hasSafetySignals | HAS_SAFETY_SIGNAL | OUT | SafetySignal | SafetyEdgeProperties | structural | W02-SR-14, W17-SR-04 |
| FoodItem (W05) | derivedFromTaxa | DERIVED_FROM_TAXON | OUT | BotanicalTaxon | AssertedEdgeProperties | asserted | W05-SR-03 |
| Condition (W03) | treatedBy | TARGETS_CONDITION | IN | Treatment | TreatmentTargetProperties | asserted (inverse view) | W06-SR-11, W03-SR-12(d) |
| Condition (W03) | investigatedByStudies | INVESTIGATES | IN | Study | AssertedEdgeProperties | asserted (inverse view) | W03-SR-12(d) |
| Condition (W03) | relatedSafetySignals | RELATES_TO_CONDITION | IN | SafetySignal | StructuralEdgeProperties | structural (inverse view) | W03-SR-12(d), W17-SR-10 |
| Condition (W03) | indicatedByBiomarkers | INDICATES | IN | Biomarker | AssociationProjectionProperties | derived read-only (inverse view) | W03-SR-12(d), W07-SR-07 |
| Species (W03) | studiedIn | STUDIED_IN | IN | Study | AssertedEdgeProperties | asserted (inverse view) | W03-SR-12(d) (D-W03-13) |
| PanelDefinition (W07) | implementedByListings | IMPLEMENTS_PANEL | IN | MerchantListing | AssertedEdgeProperties | asserted (inverse view) | W15-SR-04 |
| AssayVersion (W07) | runsOnDevices | RUNS_ON_INSTRUMENT | OUT | Device | StructuralEdgeProperties | structural | W08-SR-01 |
| AssayVersion (W07) | usedByDevices | PERFORMED_WITH_ASSAY_VERSION | IN | Device | AssertedEdgeProperties | asserted (inverse view) | W08-SR-01 |
| AssayVersion (W07) | runsFirmwareVersion | RUNS_FIRMWARE_VERSION | OUT | FirmwareVersion | StructuralEdgeProperties | structural (candidate) | W08-SR-05 |
| Study (W09) | reportsSafetySignals | REPORTS_SAFETY_SIGNAL | OUT | SafetySignal | DerivedEdgeProperties | derived read-only | W17-SR-08(b), W09-SR-10 |
| SpecificationVersion (W11) | criteria | CRITERION_OF_SPECIFICATION | IN | SpecificationCriterion | StructuralEdgeProperties | structural (inverse view) | W12-SR-10, W11-SR-03 |
| ProductLot (W12) | units | UNIT_FROM_LOT | IN | IndividualUnit | AssertedEdgeProperties | asserted (inverse view) | W15-SR-03 |
| ProductLot (W12) | commerceMatches | MATCHES_COMMERCE_ITEM | IN | CommerceMatch | (none) | structural (inverse view) | W15-SR-03 |
| PriceObservation (W15) | supportedBy | SUPPORTED_BY | OUT | SourceLocator | (none) | structural | W15-SR-09(b) (ruling W00-R-22) |
| AffiliateLink (W15) | supportedBy | SUPPORTED_BY | OUT | SourceLocator | (none) | structural | W15-SR-09(b) (ruling W00-R-22) |
| Document (W20) | presentedAt | PRESENTED_AT | OUT | Event | AssertedEdgeProperties | asserted | W18-SR-07 |
| Document (W20) | sponsoringOrganizations | SPONSORS_CONTENT | IN | Organization | AssertedEdgeProperties | asserted (inverse view) | W21-SR-08 |
| Document (W20) | sponsoringBrands | SPONSORS_CONTENT | IN | ConsumerBrand | AssertedEdgeProperties | asserted (inverse view) | W21-SR-08 |
| Episode (W21) | recordingOf | RECORDING_OF | OUT | Event | RecordingEdgeProperties | asserted | W18-SR-06(a), W21-SR-20 |
| Claim (W21) | assertionInstances | INSTANCE_OF | IN | Assertion | DerivedEdgeProperties | derived (inverse view) | W00-SR-15 |
| ClaimEvidenceAssessment (W21) | basedOnSyntheses | CLAIM_EVIDENCE_BASED_ON | OUT | EvidenceSynthesis | (none) | structural | W10-SR-02 |

Scalar properties:

| Type (owner) | Property | Type | Request |
|---|---|---|---|
| QuantitativeContentProperties (W02) | portionBasis | `String` | W05-SR-04 |
| QuantitativeContentProperties (W02) | valueDerivation | `String` | W05-SR-04 |
| QuantitativeContentProperties (W02) | sourceDerivationCode | `String` | W05-SR-04 |
| QuantitativeContentProperties (W02) | dataPoints | `Int` | W05-SR-04 |
| QuantitativeContentProperties (W02) | minValue | `Float` | W05-SR-04 |
| QuantitativeContentProperties (W02) | maxValue | `Float` | W05-SR-04 |
| ContraindicationAssertion (W17) | massBasis | `MassBasis @settable(onCreate: false, onUpdate: false)` | W00-SR-01 (ruling W00-R-12) |
| ContraindicationAssertion (W17) | amountReferent | `AmountReferent @settable(onCreate: false, onUpdate: false)` | W00-SR-01 (ruling W00-R-12) |
| InteractionAssertion (W17) | massBasis | `MassBasis @settable(onCreate: false, onUpdate: false)` | W00-SR-01 (ruling W00-R-12) |
| InteractionAssertion (W17) | amountReferent | `AmountReferent @settable(onCreate: false, onUpdate: false)` | W00-SR-01 (ruling W00-R-12) |

Relationship types declared for the first time by an injected field: SELLS_PRODUCT, RECOMMENDS (both registered: SELLS_PRODUCT to W15 in the registry, RECOMMENDS to W21 with class ruled by W00-R-25). Every other injected field reuses a relationship type an owner already declares, with the same meaning.

## 5. Rename rulings not yet applied by the assembler (for Fable)

These are rulings, not slots: MR-04..MR-08 and W00-R-16/17/19/20 rename relationship types that fragments still declare under the old name. No injected field uses an old name. The `textReplacements` below (each `from` string occurs the number of times shown in the assembled file) were applied to a copy of the assembled schema and the result builds (BUILD OK, section 8); Fable can paste them into `assembly-rulings.json` `textReplacements`.

| Ruling | Requests | Occurrences | from -> to |
|---|---|---|---|
| MR-04 / W00-R-16 | W00-SR-08, W01-SR-03, W04-SR-06, W20-SR-11 | 1 | `snapshots: [ProductSnapshot!]! @relationship(type: "HAS_SNAPSHOT", direction: OUT) @settable(onCreate: false, onUpdate: false)` -> `snapshots: [ProductSnapshot!]! @relationship(type: "HAS_STATE", direction: OUT, properties: "StateEpisodeProperties") @settable(onCreate: false, onUpdate: false)` |
| MR-04 / W00-R-16 | W00-SR-08, W01-SR-03, W04-SR-06, W20-SR-11 | 1 | `product: [Product!]! @relationship(type: "HAS_SNAPSHOT", direction: IN) @settable(onCreate: false, onUpdate: false)` -> `product: [Product!]! @relationship(type: "HAS_STATE", direction: IN, properties: "StateEpisodeProperties") @settable(onCreate: false, onUpdate: false)` |
| MR-05 / W00-R-17 | W09-SR-13 | 1 | `evaluates: [LegacyEvaluatedIntervention!]! @relationship(type: "EVALUATES"` -> `evaluates: [LegacyEvaluatedIntervention!]! @relationship(type: "LEGACY_EVALUATES"` |
| MR-08 / W00-R-20 | W00-SR-07 | 3 | `tradeItemIdentifiers: [TradeItemIdentifier!]! @relationship(type: "IDENTIFIED_BY"` -> `tradeItemIdentifiers: [TradeItemIdentifier!]! @relationship(type: "HAS_IDENTIFIER"` |
| MR-06 / W00-R-19 | W20-SR-13, W21-SR-10 | 1 | `mentions: [AssertionSubjectTarget!]! @relationship(type: "MENTIONS", direction: OUT, properties: "RetrievalEdgeProperties")` -> `mentions: [AssertionSubjectTarget!]! @relationship(type: "MENTIONS_ENTITY", direction: OUT, properties: "RetrievalEdgeProperties")` |
| MR-06 / W00-R-19 | W21-SR-10, W20-SR-13 | 1 | `mentions: [EpisodeMentionableTarget!]! @relationship(type: "MENTIONS", direction: OUT)` -> `mentions: [EpisodeMentionableTarget!]! @relationship(type: "MENTIONS_ENTITY", direction: OUT, properties: "RetrievalEdgeProperties")` |
| MR-06 / W00-R-19 | W16-SR-18, W20-SR-13 | 1 | `mentions: [ProtocolResultMentionTarget!]! @relationship(type: "MENTIONS", direction: OUT, properties: "StructuralEdgeProperties")` -> `mentions: [ProtocolResultMentionTarget!]! @relationship(type: "MENTIONS_ENTITY", direction: OUT, properties: "RetrievalEdgeProperties")` |

```json
[
 {
  "from": "snapshots: [ProductSnapshot!]! @relationship(type: \"HAS_SNAPSHOT\", direction: OUT) @settable(onCreate: false, onUpdate: false)",
  "to": "snapshots: [ProductSnapshot!]! @relationship(type: \"HAS_STATE\", direction: OUT, properties: \"StateEpisodeProperties\") @settable(onCreate: false, onUpdate: false)"
 },
 {
  "from": "product: [Product!]! @relationship(type: \"HAS_SNAPSHOT\", direction: IN) @settable(onCreate: false, onUpdate: false)",
  "to": "product: [Product!]! @relationship(type: \"HAS_STATE\", direction: IN, properties: \"StateEpisodeProperties\") @settable(onCreate: false, onUpdate: false)"
 },
 {
  "from": "evaluates: [LegacyEvaluatedIntervention!]! @relationship(type: \"EVALUATES\"",
  "to": "evaluates: [LegacyEvaluatedIntervention!]! @relationship(type: \"LEGACY_EVALUATES\""
 },
 {
  "from": "tradeItemIdentifiers: [TradeItemIdentifier!]! @relationship(type: \"IDENTIFIED_BY\"",
  "to": "tradeItemIdentifiers: [TradeItemIdentifier!]! @relationship(type: \"HAS_IDENTIFIER\""
 },
 {
  "from": "mentions: [AssertionSubjectTarget!]! @relationship(type: \"MENTIONS\", direction: OUT, properties: \"RetrievalEdgeProperties\")",
  "to": "mentions: [AssertionSubjectTarget!]! @relationship(type: \"MENTIONS_ENTITY\", direction: OUT, properties: \"RetrievalEdgeProperties\")"
 },
 {
  "from": "mentions: [EpisodeMentionableTarget!]! @relationship(type: \"MENTIONS\", direction: OUT)",
  "to": "mentions: [EpisodeMentionableTarget!]! @relationship(type: \"MENTIONS_ENTITY\", direction: OUT, properties: \"RetrievalEdgeProperties\")"
 },
 {
  "from": "mentions: [ProtocolResultMentionTarget!]! @relationship(type: \"MENTIONS\", direction: OUT, properties: \"StructuralEdgeProperties\")",
  "to": "mentions: [ProtocolResultMentionTarget!]! @relationship(type: \"MENTIONS_ENTITY\", direction: OUT, properties: \"RetrievalEdgeProperties\")"
 }
]
```

## 6. Union, enum and extra-definition additions

| Union (owner) | Added | Request |
|---|---|---|
| TreatmentComponentTarget (W06) | ProductVariant | W04-SR-10; W05-SR-14 |
| StepInstrumentTarget (W16) | Procedure | W06-SR-04 |
| ApplicabilityUseTarget (W10) | ProtocolStep, ProtocolEdition | W16-SR-13 |

Union requests that needed no addition are ALREADY_SATISFIED in section 3 (owners implemented them: W02-SR-12/19/20/21/22/24/25, W05-SR-12/13/17, W06-SR-09, W07-SR-16/17, W09-SR-03, W12-SR-02, W13-SR-11/12/18, W15-SR-07, W17-SR-05, W19-SR-06, W21-SR-06/25, W22-SR-13). MR-01 still prunes specializations at assembly (this run: MaterialMixture from RegulatorySubjectTarget, FoodItem from StepSubstanceTarget and MediaSubjectTarget, ClaimOccurrence/RelationshipAssertion from MediaVisualizableRelationshipTarget, and others listed by the assembler).

| Enum (owner) | Added | Request | Basis |
|---|---|---|---|
| OrganizationType (W01) | CORPORATE_GROUP | W01-SR-09 | Fable decision report C (accepted) |
| RoleType (W01) | MODERATOR | W21-SR-09 | Fable decision report C (HOST, CO_HOST, GUEST already in W01 RoleType) |
| CadenceUnit (W16) | YEAR, MINUTE | W16-SR-07 | Fable decision report C |
| ConstraintRole (W16) | REPEAT_UNTIL | W16-SR-08 | Fable decision report C |
| ReferenceIntervalDerivation (W07) | ADOPTED_FROM_GUIDELINE | W07-SR-06 | Fable decision report C |
| RegulatoryResponseKind (W13) | NDI_FILING_ACKNOWLEDGED | W13-SR-06 | Fable decision report C |
| ResultQualifier (W07) | BELOW_REPORTING_LIMIT, QUALITATIVE_ABSENT, QUALITATIVE_PRESENT | W12-SR-12 | MR-09 (decision report B) |
| MaterialKind (W02) | FOOD | W05-SR-02 | stated failing case (fixture 01/03: food node is both intervention material and component material); W02 did not answer |
| PathwayKind (W13) | NOVEL_FOOD_AUTHORISATION | W13-SR-03 | stated failing case (EU 2020/16 NR chloride; V-336 rows); the AUTHORIZATION status-kind question stays deferred (decision report C) |
| RegulatoryResponseKind (W13) | NOVEL_FOOD_AUTHORISED | W13-SR-03 | stated failing case (EU 2020/16 NR chloride; V-336 rows); the AUTHORIZATION status-kind question stays deferred (decision report C) |
| RegulatoryStatusKind (W13) | DESIGNATION_ENDED_UNSPECIFIED | W06-SR-05 | stated failing case (OOPD 465514, baseline V-333 row); alternative 'null statusKind + scopeText' convention for Fable |

Enum value requests already implemented by their owners: ProcessKind (W11-SR-01), OfferKind/ObservedAvailability (W15-SR-10), RoleType HOST/CO_HOST/GUEST (W21-SR-09), and every kernel value W00 ruled (SourceKind +17, ActivityKind +5, UseKind DISPLAY_MEDIA, EquivalenceKind SAME_IDENTITY_MERGED, RelevanceBasis SAME_SERVICE_CATEGORY: W00-R-08..R-11).

Extra definition: `union RecommendableTarget = Protocol | ChemicalSubstance | IngredientMaterial | Organization | ConsumerBrand | Product | ProductVariant | Treatment | Lifestyle | Procedure` (W21 sole writer; no member is a specialization of another member, so MR-01 removes nothing).

## 7. Deferred items and observations for Fable

Deferred because an owner decided otherwise or the element is a removal/retype rather than an addition:

- W03-SR-03 / W02-SR-08 HAS_ANALYTE: no fragment declares it and the registry does not admit it; W07 has not answered. If Fable admits it as a W07 CANDIDATE, the field text is ready: `"""class: structural (candidate); cardinality: zero_or_one; catalog: HAS_ANALYTE (registry: W07); request: W03-SR-03, W02-SR-08.""" analyteSubstances: [ChemicalSubstance!]! @relationship(type: "HAS_ANALYTE", direction: OUT, properties: "StructuralEdgeProperties")` and `analyteMolecularEntities: [MolecularEntity!]!` with the same directive, both on Biomarker.
- W08-SR-01: retype `AssayVersion.runsOnInstrument` from `[ToolOrInstrument!]!` to `[EquipmentModelTarget!]!` (a fieldTypeFix). Until then the injected `AssayVersion.runsOnDevices` (same RUNS_ON_INSTRUMENT type, Device target) exposes device-run assay versions; after the retype it becomes redundant and can be dropped from the injections.
- W04-SR-05: W22 keeps ProductLabelRegion.aboutProduct -> Product (rule LABEL-REGION-PRODUCT-1, zero_or_one); W04 asked for ProductVariant|PackageConfiguration. Owner conflict.
- W04-SR-07: W01 keeps MANUFACTURES_PRODUCT -> Product; W04 asked ProductVariant|ProductLot endpoints.
- W01-SR-17 / W01-SR-20: FUNDS_STUDY, HOSTS_STUDY_SITE, PROVIDES_INVESTIGATIONAL_PRODUCT stay assertion-only predicates (W09); the injected Organization.sponsorsStudies / servesAsCroFor and Person.investigatedStudies are read-only inverse views of W09's derived SPONSORED_BY / OPERATED_BY / INVESTIGATED_BY.
- W01-SR-20 authorsReports / reportsExperiences: AUTHORS and REPORTS are retired with ExperienceReport (W21); ConsumerBrand.marketedUnderMarks would widen MARKETED_UNDER_MARK beyond branded materials (W14 defers product/brand marks).
- W09-SR-09(b): W06 retired Treatment.evaluatedInStudies; legacy edges remain readable from Study.evaluates.
- W20-SR-17: W01, W02, W03, W09, W11 and W22 retired chunk-support fields; W20-SR-16: W16 retired ProtocolResult.supportedBy without shortcuts.
- Removals requested of owners (not additions): Exposure out of StepInstrumentTarget (W05-SR-08), Biomarker.inPathways / expressedInOrgans (W03-SR-06), Metric.mediaUrl / mediaType (W22-SR-09), LocationType GMP_FACILITY / PILOT_PLANT (W11-SR-07, W12-SR-08), Sensor in the MeasurementEdgeProperties description (W08-SR-02), 'asserted' wording in existing hasSafetySignals descriptions (W17-SR-04).
- New enums not defined by any fragment and not admitted in decision report C: DosageForm / AdministrationRoute (W09-SR-06, W16-SR-09), EpisodeType / EpisodeSegmentType (W21-SR-02), CommerceMatchKind / CommerceMatchOutcome (W15-SR-10), PortionBasis / ValueDerivation (W05-SR-04: injected as controlled Strings).
- Enum values added on a stated failing case without an explicit Fable admission (Fable may drop them from enum-additions.json): MaterialKind.FOOD (W05-SR-02), PathwayKind.NOVEL_FOOD_AUTHORISATION and RegulatoryResponseKind.NOVEL_FOOD_AUTHORISED (W13-SR-03; the AUTHORIZATION status kind stays deferred), RegulatoryStatusKind.DESIGNATION_ENDED_UNSPECIFIED (W06-SR-05b; alternative: null statusKind + scopeText).

Observations (no action taken, not seam slots):

- One relationship type, two property shapes: AFFECTS_MECHANISM and MODULATES use DerivedEdgeProperties on the W02 side and AssociationProjectionProperties on the W03 side (W03-SR-05 asked W02 for AssociationProjectionProperties); SUPPORTED_BY is property-less in W00/W09/W10/W15/W17/W18/W21 but StructuralEdgeProperties in W12 (MeasuredResult, PassFailInterpretation, LotTestSummary, CertificateOfAnalysis). @neo4j/graphql builds, but a stored edge has one property set; Fable should pick one per type.
- `Claim.assertionInstances` (INSTANCE_OF IN, Assertion) also returns ClaimOccurrence and RelationshipAssertion nodes, which carry the Assertion label; `occurrences` and `relationshipAssertions` remain the typed views. Corroboration counts should count distinct uids.
- SupportedRecordTarget (W00-R-22) lists ClaimEvidenceAssessment, RetellingFidelityAssessment, ComparabilityAssessment, NarrativeArc, MediaSuitabilityAssessment and SourceAuthorityAssessment, whose owners declare no `supportedBy` field; no request asks for one, so none was injected (the edges are readable from SourceLocator.supports).
- MR-06 default name was MENTIONS_SUBJECT; W00-R-19 ruled MENTIONS_ENTITY with RetrievalEdgeProperties. Section 5 uses W00's name.

## 8. Test record and final counts

Harness: `/tmp/claude-0/-home-user-biotech-meta/c83435a6-8371-518c-961a-6504ccbc2c3e/scratchpad/harness` (its node_modules: @neo4j/graphql 7.6.3, graphql 16.14.2), Node 22, `--max-old-space-size=8192`. Fragments as on disk at 2026-10-04T02:27Z (W00 after its reconciliation pass; W10, W15, W17, W18 re-read).

| Step | Command | Result |
|---|---|---|
| merge | `node merge-fragments.mjs workers /tmp/x.graphql` | definitions: 471; duplicates: 0; undefined refs: 3; extend blocks: 0; forbidden directives: 0; 10 union overlaps reported (pruned at assembly under MR-01); undefined: UNDEF FoodProduct <- W16,W22, UNDEF ExperienceReport <- W22, UNDEF Association <- W22 |
| assemble | `node assemble-final.mjs workers /tmp/final-test.graphql validation/harness/assembly-rulings.json validation/harness/field-injections.json` | assembled 14971 lines; union edits 4; 14 union members pruned (MR-01/MR-02); field injections applied with no 'already present' skips and no 'type not found' |
| verify | `node verify-seam-closure.mjs /tmp/final-test.graphql field-injections.json union-additions.json enum-additions.json` | verify: 103 injected fields checked; errors 0; warnings 0; definitions 472 |
| build | `node build-errors.mjs /tmp/final-test.graphql` | BUILD OK (34 s) |
| build with section 5 renames | copy of the assembled file with the seven textReplacements | BUILD OK (34 s) |

Iteration note: the first build after injection failed with 4 errors, all `Interface field AssertionArchetype.massBasis/amountReferent expected but ContraindicationAssertion/InteractionAssertion does not provide it` (W00-R-12 added the fields to the interface; W00 states W17 must add them). The two nullable fields were injected on both W17 types (W00-SR-01 rows), after which the build passed.

| Count | Value |
|---|---|
| Worker fragment definitions (merge-fragments) | 471 |
| Definitions in the assembled schema (fragments + extra-definitions.graphql) | 472 |
| Relationship types declared before / after injection | 387 / 389 |
| Injected relationship fields | 93 |
| Injected scalar properties | 10 |
| Types receiving injections | 28 |
| Union additions (entries / members) | 3 / 4 |
| Enum additions (entries / values) | 11 / 14 |
| Extra definitions | 1 (RecommendableTarget) |
| Pending rename textReplacements proposed (section 5) | 7 |

