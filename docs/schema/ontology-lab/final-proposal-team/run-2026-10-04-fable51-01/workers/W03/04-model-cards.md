# W03 model cards

Conventions: every node carries the B2 skeleton (`id`, `uid`, `name` nullable, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass` default PUBLIC, `maturity`, `schemaVersion`) and its archetype fields; these are not repeated per card. Kinds: A asserted, O observed (as reported), C calculated, I inferred, D derived (regenerable), OP operational, DI display (not truth-bearing). Privacy: all W03 elements are PUBLIC; no W03 element may hold private-personal data (INV-506). Maturity: catalog `mechanisms` module is candidate; cards state the proposed maturity.

## Nodes

### MechanismEvidenceContext (Occurrence; uid token `mech-context`; maturity PROVISIONAL)
Meaning: one reported exposure group measured in one compartment; the context of a DIRECT_MEASUREMENT mechanism assertion (round 0003 M3). Not a Study, not a VersionedState, not a person's measurement.
Labels: `MechanismEvidenceContext`, `Occurrence`. `occurrenceType` = `'MechanismEvidenceContext'`; `startedAt`/`endedAt` = study conduct dates only when the source states them (null = unknown).

| Property | Type | Null meaning | Units / values | Kind | Temporal |
|---|---|---|---|---|---|
| setting | MechanismSetting! | invalid if null (V-231) | enum | O | immutable |
| modelDescriptor | String | not reported | verbatim | O | immutable |
| sexScope | String (candidate enum SexScope) | not reported; UNKNOWN = reported unknown or not extracted | MALE, FEMALE, BOTH, UNKNOWN | O | immutable |
| ageDescriptor | String | not reported | verbatim | O | immutable |
| sampleSize | Int | not reported | animals / participants in this group | O | immutable |
| exposureAmount | Float | unknown (then exposureStatus) or read from arm | — ; never 0 for unknown (V-232) | O | immutable |
| exposureUnit | String | required with amount | UCUM: mg/d, mg/kg/d, mg/kg, umol/L | O | immutable |
| exposureBasis | ExposureBasis | required with amount | enum | O | immutable |
| route | String (candidate enum ExposureRoute) | not reported / read from arm | ORAL, GAVAGE, DIET, IP, IV, IN_MEDIUM, TOPICAL | O | immutable |
| exposureDurationIso | String | not reported | ISO 8601 (P21D) | O | immutable |
| exposureStatus | String (candidate enum ExposureStatus) | exposure present or arm-linked | NOT_EXTRACTED, NOT_REPORTED, NOT_APPLICABLE | OP | replaced only through a new context + superseding assertion |
| hedValue, hedUnitCode, hedMethod | Float, String, String | not computed | mg/kg; method id required with value (V-236) | C / D | regenerable |

Edges (all structural, out of the context): `IN_SPECIES` → Species (zero_or_one; required except IN_VITRO_CELL_FREE, IN_SILICO), `MEASURED_IN` → AnatomicalContext (zero_or_one), `EXPOSED_TO` → IngredientMaterial | ChemicalForm | ChemicalSubstance (zero_or_one across the three; most specific level supported), `IN_STUDY_ARM` → StudyArm (zero_or_one; exposure fields then null, V-238). Incoming `OBSERVED_IN_CONTEXT` from Assertion (zero_or_one per assertion; exactly one for DIRECT_MEASUREMENT, none otherwise, V-231).
Identity: uid only; two groups of one paper measured in two compartments are two contexts. Correction rule: a context is immutable; a better extraction creates a new context and a new assertion that `SUPERSEDES {EXTRACTION_FIX}` the old one (fixture: Trammell v1 → v2). Sources: round 0003, property cards. CQ: MX-01..04, 06.

### Mechanism (Entity; token `mechanism`; PROVISIONAL)
Meaning: species-neutral biological process concept. Properties: `entityType`, `mechanismClass` (DI; catalog `mechanismKind`), `regulatoryMode` (DI), `biologicalLayer` (DI), `keyEntitiesSummary` (DI), search fields (OP, INV-107). Edges: `INVOLVES_PATHWAY` → Pathway (structural curated, many, MechanismLinkProperties); derived read-only `ACTS_IN` → AnatomicalContext, `APPLIES_TO_SPECIES` → Species, `INFLUENCES_OUTCOME` → Outcome; inverse views of `AFFECTS_MECHANISM` (from ChemicalSubstance, ChemicalForm, IngredientMaterial; Lifestyle by W05), `CONTRIBUTES_TO` (from MolecularEntity), `HAS_MECHANISM` (from Condition), `MEDIATES_RISK_THROUGH` (from RiskFactor). Identity: uid; name never identity; optional Identifier (GO biological process) when a curator binds one. Fulltext `MechanismSearch` retained (D-015).

### Pathway (Entity; token requested `pathway`, W03-SR-04; PROVISIONAL)
Meaning: a species-specific reference pathway record of an authority, identified by the unversioned stable id. Properties: `pathwayClass` (DI), `sourceDatabase` (materialized from primary Identifier scheme), `externalId` (materialized key; normalization Reactome `^R-[A-Z]{3}-[0-9]+$`, no version suffix, V-W03-09; unique per sourceDatabase), `pathwayRevision` (D: revision observed at latest capture), `pathwayRelease` (D), `revisionObservedAt` (D, DateTime), `speciesTaxonId` (O from record; null for species-neutral), `orthologyInferred` (O, Boolean: authority flags computational inference). Edges: `HAS_IDENTIFIER` → Identifier (asserted, IdentifierLinkProperties); inverse views of `INVOLVES_PATHWAY` (from Mechanism, Condition) and `PARTICIPATES_IN` (from MolecularEntity). Temporal: identity stable; revision changes recorded through new SourceSnapshots; curated links keep `referenceRevision` (V-W03-10 flags drift for review). Source: S6/S7.

### MolecularEntity (Entity; token `molecular-entity`; PROVISIONAL)
Meaning: genome-encoded actor. `entityKind` (controlled string; candidate enum MolecularEntityKind: GENE, TRANSCRIPT, PROTEIN, PROTEIN_COMPLEX, PROTEIN_FAMILY, NONCODING_RNA; V-W03-05), `geneSymbol` (DI), `hgncId`, `uniprotId`, `ensemblId` (materialized keys; Identifier authoritative), `speciesTaxonId` (O; HGNC → 9606). Edges: `HAS_IDENTIFIER`; structural curated `ENCODES` → Biomarker, `PARTICIPATES_IN` → Pathway, `CONTRIBUTES_TO` → Mechanism (MechanismLinkProperties); derived inverse `MODULATES` from ChemicalSubstance / IngredientMaterial. CL-002 boundary: small molecules and metabolites are ChemicalSubstance (W02).

### Species (Entity; token `species`; PROVISIONAL)
`ncbiTaxonomyId` (identity key, `^[0-9]+$`, unique, V-W03-12), `scientificName` (O). Edges: inverse `APPLIES_TO_SPECIES` (derived), inverse `IN_SPECIES`. Strains and disease models stay in `modelDescriptor`.

### AnatomicalContext (Entity; token `anatomical-context`; PROVISIONAL)
`contextKind: AnatomicalContextKind`, `uberonId` (materialized key `^UBERON:[0-9]{7}$`; CL / Cellosaurus ids as Identifier records). Edges: `HAS_IDENTIFIER`; inverse `MEASURED_IN` (contexts), inverse `MEASURED_IN_MATRIX` (W07 Biomarker), inverse derived `ACTS_IN`. One identity per compartment (V-W03-06).

### Organ (Entity specialization; labels `Organ, AnatomicalContext, Entity`; token: `anatomical-context` requested, W03-SR-04; PROVISIONAL)
Same identity space as AnatomicalContext; `contextKind` always ORGAN; `organSystem` (DI). Edges: `HAS_IDENTIFIER`, inverse `MEASURED_IN`, inverse derived `ACTS_IN`, inverse curated `AFFECTS_ORGAN` (from Condition).

### Outcome (Entity; token `outcome`; PROVISIONAL)
Biological/clinical outcome concept. `outcomeClass` (DI; catalog `outcomeKind`), `outcomeDomain` (DI), `timeframeText` (DI). Edges: `OPERATIONALIZED_BY` → Metric (structural curated, StructuralEdgeProperties; name shared with W16, W03-SR-07), `REFLECTS_MECHANISM` → Mechanism (structural curated; never a premise, V-W03-03), derived `ASSOCIATED_WITH_CONDITION` → Condition (one-to-one), inverse derived `INFLUENCES_OUTCOME`. Not an OutcomeDefinition (W09), not an EndpointClassification (W10).

### Condition (Entity; token requested `condition`; PROVISIONAL)
`conditionClass` (DI), `mondoId` (key `^MONDO:[0-9]{7}$`, null = no MONDO concept recorded), `icd11Code` (read-only legacy), `orphaCode` (`^ORPHA:[0-9]+$`), `omimId` (`^[0-9]{6}$`), `isRare` (DI hint from a rare subset; not an assessment), search fields. Edges: `HAS_IDENTIFIER` (asserted; ICD-10-CM and ICD-11 codes with fiscal-year/release validity on the link; V-W03-08), curated `AFFECTS_ORGAN` → Organ, `HAS_MECHANISM` → Mechanism, `INVOLVES_PATHWAY` → Pathway; inverse derived `INCREASES_RISK_FOR`, `ASSOCIATED_WITH_CONDITION`. Fulltext `ConditionSearch` retained with its live field list (D-015).

### RiskFactor (Entity; token requested `risk-factor`; PROVISIONAL)
`riskClass`, `modifiable`, `exposureCategory` (DI). Derived edges `INCREASES_RISK_FOR` → Condition, `MEDIATES_RISK_THROUGH` → Mechanism (one-to-one), `APPLIES_TO_SPECIES` → Species (mx-proj/v1). No fixture case in this run (stated gap).

## Relationships

| Type | Domain → range | Class | Cardinality | Properties | Rule / note |
|---|---|---|---|---|---|
| OBSERVED_IN_CONTEXT | Assertion → MechanismEvidenceContext | structural | zero_or_one per assertion | none | exactly one for DIRECT_MEASUREMENT (V-231); field on Assertion requested from W00 (W03-SR-02) |
| IN_SPECIES | MEC → Species | structural | zero_or_one | none | |
| MEASURED_IN | MEC → AnatomicalContext | structural | zero_or_one | none | name collides with live Metric→Organ `MEASURED_IN` (retire, W03-SR-06) |
| EXPOSED_TO | MEC → IngredientMaterial \| ChemicalForm \| ChemicalSubstance | structural | zero_or_one | none | |
| IN_STUDY_ARM | MEC → StudyArm | structural | zero_or_one | none | |
| MEASURED_IN_MATRIX | Biomarker → AnatomicalContext | structural | zero_or_one (catalog proposes exactly_one) | none | meaning owned by W03; field on W07's Biomarker |
| AFFECTS_MECHANISM | ChemicalSubstance \| ChemicalForm \| IngredientMaterial \| Lifestyle → Mechanism | derived | many | AssociationProjectionProperties | mx-proj/v1; outgoing fields on W02/W05 types (W03-SR-05, W05-SR-05) |
| MODULATES | ChemicalSubstance \| IngredientMaterial → MolecularEntity | derived | many | AssociationProjectionProperties | mx-proj/v1 (INCREASES_ACTIVITY_OF, DECREASES_ACTIVITY_OF, BINDS) |
| APPLIES_TO_SPECIES | Mechanism \| RiskFactor → Species | derived | many | AssociationProjectionProperties | mx-proj/v1; species of POSITIVE measured contexts only (V-234r) |
| INFLUENCES_OUTCOME | Mechanism → Outcome | derived | many | AssociationProjectionProperties | mx-proj/v1, subject Mechanism, object Outcome |
| ACTS_IN | Mechanism → AnatomicalContext | derived | many | AssociationProjectionProperties | mx-proj/v1; replaces live ACTS_IN (Organ) and ACTS_IN_CONTEXT |
| INCREASES_RISK_FOR | RiskFactor → Condition | derived | many | AssociationProjectionProperties | one-to-one, predicate INCREASES_RISK_FOR (V-W03-07) |
| MEDIATES_RISK_THROUGH | RiskFactor → Mechanism | derived | many | AssociationProjectionProperties | one-to-one |
| ASSOCIATED_WITH_CONDITION | Outcome \| Lifestyle \| AdverseEffect → Condition | derived | many | AssociationProjectionProperties | one-to-one; outgoing fields on W05/W17 types |
| ASSOCIATED_WITH_OUTCOME | Lifestyle → Outcome | derived | many | AssociationProjectionProperties | one-to-one (W05) |
| INVOLVES_PATHWAY | Mechanism \| Condition → Pathway | structural (curated) | many | MechanismLinkProperties | replaces Pathway `HAS_MECHANISM` |
| HAS_MECHANISM | Condition → Mechanism | structural (curated) | many | MechanismLinkProperties | Pathway and Organ uses retired |
| PARTICIPATES_IN | MolecularEntity (\| ChemicalSubstance requested) → Pathway | structural (curated) | many | MechanismLinkProperties | |
| CONTRIBUTES_TO | MolecularEntity → Mechanism | structural (curated) | many | MechanismLinkProperties | |
| ENCODES | MolecularEntity → Biomarker | structural (curated) | many | MechanismLinkProperties | W07 inverse field already uses this type |
| REFLECTS_MECHANISM | Outcome \| Biomarker \| Metric → Mechanism | structural (curated) | many | MechanismLinkProperties | readout-of; never premise (V-W03-03) |
| AFFECTS_ORGAN (Condition) | Condition → Organ | structural (curated) | many | MechanismLinkProperties | shared name with W17 (W03-SR-08) |
| OPERATIONALIZED_BY (Outcome) | Outcome → Metric | structural | many | StructuralEdgeProperties | shared name with W16 (W03-SR-07) |
| HAS_IDENTIFIER | my types → Identifier | asserted (W00) | many | IdentifierLinkProperties | W00 type |
| HAS_ANALYTE (candidate, W07) | Biomarker → ChemicalSubstance \| MolecularEntity | structural | zero_or_one | none | CANDIDATE, CQ-MX-C04 (W03-SR-03); used in fixtures only |

## Relationship-property types

**MechanismLinkProperties** (structural curated reference; successor of MechanismLinkMetadata): `orderIndex: Int`, `notes: String`, `mongoResearchRunId: String` (frozen StructuralEdgeProperties fields), `regulatorySign: RegulatorySign`, `enzymeRole`, `stoichiometryNote`, `upstreamDownstream` (DI), `referenceSnapshotUid` (uid of the authority SourceSnapshot), `referenceRecordId` (unversioned authority id), `referenceRevision` (revision read, e.g. "8"), `referenceRelease` (e.g. "97"). Temporal: immutable; a re-curation from a newer revision is a new edge, the old edge is deleted only by the curation job with the snapshot kept.

**AssociationProjectionProperties** (derived; successor of AssociationMetadata on derived edges): frozen DerivedEdgeProperties fields (`projectionOfAssertionUid`, `derivationRule`, `derivedFromAssertionUids`, `derivedFromAssessmentUids`, `derivedAt`, `mongoResearchRunId`) + `projectedPolarity: Polarity` (always POSITIVE in mx-proj/v1), `projectedPredicate`, `speciesUids`, `settings: [MechanismSetting!]`, `anatomicalContextUids` (D) + `associationShape`, `specificity`, `effectSummary` (DI, live). Citation modes: rule (`derivationRule = 'mx-proj/v1'` + non-empty `derivedFromAssertionUids`) for AFFECTS_MECHANISM, MODULATES, APPLIES_TO_SPECIES, INFLUENCES_OUTCOME, ACTS_IN; one-to-one (`projectionOfAssertionUid`, same predicate) for risk and association edges; never `assertionUid` (D-011). Regeneration deletes and rebuilds; history stays on assertions.

### Derivation rule `mx-proj/v1` (for registration in the catalog)
Input assertion `a` qualifies iff `predicateClass = MECHANISM`, `basisKind = DIRECT_MEASUREMENT`, `status = ACCEPTED`, `polarity = POSITIVE`, `recordedTo IS NULL`, and exactly one `OBSERVED_IN_CONTEXT`. Then:
1. `AFFECTS_MECHANISM(subject → object)` when object is Mechanism, predicate ∈ {INDUCES_PROCESS, INHIBITS_PROCESS, IMPROVES, IMPAIRS, EXTENDS}, subject ∈ {IngredientMaterial, ChemicalForm, ChemicalSubstance, Lifestyle}; one edge per (subject, object, predicate).
2. `MODULATES(subject → object)` when object is MolecularEntity, predicate ∈ {INCREASES_ACTIVITY_OF, DECREASES_ACTIVITY_OF, BINDS}, subject ∈ {IngredientMaterial, ChemicalSubstance}.
3. `APPLIES_TO_SPECIES(m → sp)` for Mechanism m as subject or object and sp the context species; one edge per (m, sp).
4. `ACTS_IN(m → site)` for the context compartment.
5. `INFLUENCES_OUTCOME(m → o)` when subject is Mechanism and object Outcome.
Assertions whose object is a Biomarker or Metric (level changes, proxies) never produce process-level edges (V-W03-03). Edge properties carry the union of contexts' species, settings and sites. Idempotent (run twice: identical edge counts, section 3 of 06).

## Enums (sole owner W03)

| Enum | Values | Source | Note |
|---|---|---|---|
| MechanismSetting | IN_VITRO_CELL_FREE, IN_VITRO_CELL, EX_VIVO, IN_VIVO_NONMAMMAL, IN_VIVO_MAMMAL, HUMAN_INTERVENTIONAL, HUMAN_OBSERVATIONAL, IN_SILICO | catalog conventions | frozen |
| ExposureBasis | PER_KG_BODY_WEIGHT_PER_DAY, ABSOLUTE_PER_DAY, SINGLE_DOSE, MEDIUM_CONCENTRATION, DIET_CONCENTRATION | catalog conventions | frozen; note SINGLE_DOSE is per-kg or absolute only by `exposureUnit` (mg/kg vs mg) |
| AnatomicalContextKind | TISSUE, CELL_TYPE, CELL_LINE, SPECIMEN_MATRIX, ORGAN, SUBCELLULAR | live-schema-alignment refinement | new enum (refines live free text) |
| RegulatorySign | ACTIVATES, INHIBITS, NEUTRAL, UNKNOWN | live-schema-alignment refinement | new enum |
| SexScope, ExposureRoute, ExposureStatus, MolecularEntityKind | see cards | property cards / CL-002 | CANDIDATE; kept as controlled strings + V-W03-05/11 until registered (W03-SR-12) |

## Candidate elements kept out of the fragment

`HAS_ANALYTE` (W07 type; CQ-MX-C04); species edges for MolecularEntity/Pathway (property `speciesTaxonId` suffices); `MechanismChain` node (round 0003 C3-05, deferred); assessment of "same mechanism across species" (would be W10).
