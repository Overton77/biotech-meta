# W03 Biology and mechanisms: domain recommendation

Worker W03 (Opus 5.5), run `run-2026-10-04-fable51-01`. Canonical catalog module: `mechanisms` (catalog 0.2.0, digest `8fb50ff0…84f0`, maturity candidate). Live schema digest `86b5e0b5…f112`. Authority read: catalog `mechanisms` module and INV-210..213, architecture.md section 7 (mechanisms paragraph), round 0003 (M1–M7), competency-questions.md CQ-MX-01..06, CQ-ST-03, CQ-AX-20, live-schema-alignment.md rounds 0002/0003 rows, property-cards.md mechanism cards, validation.cypher V-112 and V-230..V-239, examples/study-vs-product-mismatch.cypher section 6, live lines 274-298, 1147-1375, 2748-2760.

## 1. Boundary

The domain answers one question family: **what biological thing is being talked about, and how much of a mechanism story was actually measured, in which species, compartment and exposure** (CQ-MX-01..06), and supplies the biological referents other modules point at (CQ-ST-03 outcome concept, condition, compartment, species). It never decides evidence applicability to a product (W10, INV-212), never holds endpoint roles or surrogate status (W10, INV-205), never holds measurands, tests or assays (W07), and never holds study design or arms (W09).

| Subdomain | Elements | Archetype | Identity basis |
|---|---|---|---|
| Reference concepts | `Mechanism`, `Pathway`, `MolecularEntity`, `Outcome`, `Condition`, `RiskFactor` | Entity | BellLabs uid; external authority ids as `Identifier` records (W00) with materialized lookup keys only where one id names one concept |
| Biological frames | `Species`, `AnatomicalContext` (with `Organ` as a specialization label) | Entity | NCBI taxonomy id; UBERON/CL/Cellosaurus ids |
| Measurement event | `MechanismEvidenceContext` | Occurrence | one reported exposure group measured in one compartment |
| Statements | mechanism-class `Assertion`s (W00 type; predicates owned by the module) | Assertion | one subject, one object, `basisKind`, `polarity`, at most one context |
| Shortcuts | `AFFECTS_MECHANISM`, `MODULATES`, `APPLIES_TO_SPECIES`, `INFLUENCES_OUTCOME`, `ACTS_IN`, `INCREASES_RISK_FOR`, `MEDIATES_RISK_THROUGH`, `ASSOCIATED_WITH_CONDITION`, `ASSOCIATED_WITH_OUTCOME` | derived relationships | regenerable from assertions (rule `mx-proj/v1` or one-to-one) |
| Curated reference structure | `INVOLVES_PATHWAY`, `HAS_MECHANISM`, `PARTICIPATES_IN`, `CONTRIBUTES_TO`, `ENCODES`, `REFLECTS_MECHANISM`, Condition `AFFECTS_ORGAN` | structural relationships | carry the authority record revision they were read from |

Identity versus state versus artifact versus occurrence: every reference concept is an **Entity** whose meaning does not change with evidence; evidence lives on **Assertions**; the exposure-and-measurement event is an **Occurrence**; authority records (Reactome JSON, OLS term, ICD-10-CM code set) are **SourceSnapshots**, and their revision is a property of the snapshot and of the curated link, not of the concept identity. No VersionedState is needed in this domain (round 0003 C3-02 rejected it for the context; the pathway revision case below is handled without one).

## 2. Findings that shape the model (from records retrieved in this run)

1. **Same analyte, different measurand (compartment and species).** Dellinger 2017 (PMID 29184669) measured NAD+ in human *whole blood* after daily NRPT for 8 weeks; Trammell 2016 (PMID 27721479) measured NAD+ in mouse *liver* after one 185 mg/kg gavage of NR Cl in 12-week-old male C57Bl/6J mice ("NR elevated hepatic NAD by more than fourfold with a peak at 6 h post gavage") and, in the same paper, NAAD rose in the *heart* "without increasing steady-state NAD". Three measurands of one analyte, two species, two exposure bases (`ABSOLUTE_PER_DAY` via arm vs `SINGLE_DOSE` mg/kg). The catalog's compartment-specific measurand (M1) is necessary, and a link from each measurand to its analyte is missing (seam W03-SR-03 to W07).
2. **Level is not flux; proxy is not flux.** Liu 2018 (PMID 29685734) states "A limitation in understanding NAD metabolism has been reliance on concentration measurements" and measured isotope incorporation: "the 200 mg/kg dose resulted in M+2 NAD in liver but not muscle or kidney after oral administration". Trammell's "NAAD sensitively reports on increased NAD metabolism" is an inference from a marker. These are the measured-flux / inferred-from-proxy / level-only distinctions the forbidden implication PROXY_MARKER_CHANGED → PROCESS_FLUX_CHANGED protects.
3. **Sources state dose scalings.** Trammell: "the conversion between human adult dose and mouse dose is a factor of 12.3 … mice should be administered 185 mg kg"; Liu: "50 mg/kg, which is equivalent to 290 mg in a 70 kg human on a body surface area basis". A source-stated scaling is still a calculation: the context stores the administered exposure; the HED is a derived value with `hedMethod` (INV-213).
4. **Pathway records change revision without changing identity.** Reactome `R-HSA-196807` (Nicotinate metabolism) returned `stIdVersion` `R-HSA-196807.8`, release 97, `lastUpdatedDate` 2021-09-15, while its own `doi` is `10.3180/R-HSA-196807.7`. The versioned id cannot be identity; the unversioned stable id is. The mouse record `R-MMU-196807.1` is `isInferred: true` (computational orthology), released 2026-06-17.
5. **Classification codes are not identity keys.** ICD-10-CM `E88.81` was a valid billable code in FY2022 and is a header in FY2027 (children E88.810 to E88.819; E88.819 "Insulin resistance, unspecified" first tracked FY2024). Sarcopenia has ICD-10-CM `M62.84` and no MONDO term in OLS (MONDO release 2026-09-01). "Insulin resistance" resolves in MONDO only to the imported phenotype `HP:0000855`; `MONDO:0012520` (insulin-resistance syndrome type A) lists OMIM, Orphanet and ICD-11 foundation cross-references but no ICD-10-CM code.
6. **NAD+ is one chemical identity** (PubChem CID 5892 title "Nadide", InChIKey `BAWFJGJZGIEFAR-NNYOXOHSSA-N`), whether a paper calls it an endogenous metabolite or a supplement calls it an ingredient. Genes and proteins are species specific in their authorities (HGNC:14929 human SIRT1; HGNC lists MGI:2135607 for mouse Sirt1).

## 3. Disposition of every element in scope

Legend: keep | refine | merge | split | seam | derive | retire | defer. Field-level detail is in `migration-map.yaml`.

| Element (live line / catalog) | Disposition | Final form |
|---|---|---|
| `Mechanism` (1147) | keep, refine | Entity, labels `Mechanism, Entity`; species, compartment and outcome shortcuts become derived read-only fields; `supportedBy` retired |
| `Mechanism.mechanismClass`, `regulatoryMode`, `biologicalLayer`, `keyEntitiesSummary` | keep (display) | live names kept; catalog `mechanismKind` maps to `mechanismClass` (no alias introduced) |
| `Mechanism.involvesPathways` / `INVOLVES_PATHWAY` | keep | structural curated, `MechanismLinkProperties` with authority revision |
| `Mechanism.actsInOrgans` (`ACTS_IN`), `actsInContexts` (`ACTS_IN_CONTEXT`) | merge, derive | one derived `ACTS_IN` to `AnatomicalContext` (Organ included) |
| `Mechanism.appliesToSpecies`, `influencesOutcomes` | derive | `mx-proj/v1` |
| `Pathway` (1171) | keep, refine | unversioned `externalId`; `pathwayRevision` is a derived cache; adds `pathwayRelease`, `revisionObservedAt`, `speciesTaxonId`, `orthologyInferred`, `identifiers` |
| `Pathway.hasMechanisms` (`HAS_MECHANISM`) | merge | inverse view of `INVOLVES_PATHWAY` (one edge, one direction) |
| `Pathway.actsInOrgans` | retire | no CQ; pathway authorities do not scope pathways to organs |
| `Organ` (1186) | refine (specialize) | labels `Organ, AnatomicalContext, Entity`, `contextKind ORGAN`; one identity per organ |
| `Organ.measuredByMetrics`, `hasMechanisms` | retire / derive | compartment is `MEASURED_IN_MATRIX`; mechanism location is derived `ACTS_IN` |
| `Condition` (1199) | keep, refine | ontology ids materialized (`mondoId`, `orphaCode`, `omimId`); ICD codes only as `Identifier` + validity; `icd11Code` read-only legacy; catalog `icd10Code` not carried |
| `Condition.affectsOrgans`, `hasMechanisms`, `involvesPathways` | keep | structural curated (`MechanismLinkProperties`); `AFFECTS_ORGAN` name shared with W17 (seam) |
| `Condition.appliesToSpecies` | retire | a condition concept's species is part of its identity (MONDO human vs veterinary terms) |
| `Condition.indicatedByBiomarkers`, `investigatedByStudies`, `treatedBy`, `workedOnBy`, `relatedSafetySignals` | move | owned by W07, W09, W06, W01, W17 (outgoing fields); inverse fields omitted from this fragment (seam W03-SR-12) |
| `Outcome` (1228) | keep | concept only; `outcomeClass` (catalog `outcomeKind`), `outcomeDomain`, `timeframeText` display |
| `Outcome.operationalizedBy`, `reflectsMechanisms` | keep | structural curated |
| `Outcome.associatedWithConditions` | derive | one-to-one projection |
| `MolecularEntity` (1322) | keep, refine | genome-encoded actors only (CL-002); `speciesTaxonId`; `identifiers` |
| `MolecularEntity.encodesBiomarkers`, `participatesInPathways`, `contributesToMechanisms` | keep | structural curated |
| `AnatomicalContext` (1338) | refine | `contextKind: AnatomicalContextKind`; `uberonId`; `identifiers` |
| `Species` (1348) | keep | `ncbiTaxonomyId` materialized identity key |
| `RiskFactor` (1359) | keep | concept; three edges derived (one-to-one and `mx-proj/v1`) |
| `Association` (2748) | retire (split by origin) | source-extracted rows become `Assertion`s (LEFT → subject, RIGHT → object, `associationType` → registered predicate); BellLabs syntheses become `EvidenceSynthesis`/`EvidenceAssessment` (W10). No `Association` type in the final schema |
| `AssociationParticipant` union, `AssociationPolarity` enum | retire | ranges come from `AssertionSubjectTarget` (W00); polarity is kernel `Polarity` (NEUTRAL maps to NEGATIVE with a MIGRATION adjudication when it meant "no association measured", otherwise UNKNOWN) |
| `AssociationMetadata` (274) | split | truth-bearing fields move to Assertion/MEC/assessments; display fields stay on `AssociationProjectionProperties` |
| `MechanismLinkMetadata` (291) | refine | `MechanismLinkProperties` (`regulatorySign: RegulatorySign` + reference revision fields) |
| catalog `MechanismEvidenceContext` | keep | Occurrence; adds derived `hedUnitCode`; controlled strings with candidate enums |
| catalog `OBSERVED_IN_CONTEXT`, `IN_SPECIES`, `MEASURED_IN`, `EXPOSED_TO`, `IN_STUDY_ARM`, `MEASURED_IN_MATRIX` | keep | structural; `OBSERVED_IN_CONTEXT` outgoing field requested on W00 Assertion types |
| catalog `AFFECTS_MECHANISM`, `MODULATES`, `APPLIES_TO_SPECIES`, `INFLUENCES_OUTCOME` | keep (derived) | cite `derivationRule: mx-proj/v1` + `derivedFromAssertionUids` (decision D-W03-01) |
| live `INCREASES_RISK_FOR`, `MEDIATES_RISK_THROUGH`, `ASSOCIATED_WITH_CONDITION`, `ASSOCIATED_WITH_OUTCOME` | derive | one-to-one `projectionOfAssertionUid`, predicate equals edge type |
| enums `MechanismSetting`, `ExposureBasis` | keep | catalog values |
| enums `AnatomicalContextKind`, `RegulatorySign` | refine (new enums from free text) | values from live-schema-alignment.md |

## 4. Alternatives considered

| Question | Alternative | Rejected because |
|---|---|---|
| How derived mechanism edges cite evidence | (a) `projectionOfAssertionUid` as in V-233/V-234 | the input predicate (`INDUCES_PROCESS`, `IMPROVES`) differs from the edge type, so V-112 reports `CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE` (run: negative N12); one edge also aggregates several assertions |
| | (b) register `AFFECTS_MECHANISM` etc. as assertion predicates | duplicates the step predicate vocabulary; a source never states "affects mechanism" with a context |
| | **(c) `derivationRule mx-proj/v1` + `derivedFromAssertionUids` (chosen)** | V-112-clean; requires V-233/V-234 to read rule-mode citations (seam W03-SR-01) |
| Organ vs AnatomicalContext | two separate types | "liver" would exist twice (V-W03-06 negative N9); `AnatomicalContextKind` already has ORGAN |
| Pathway revision | (a) versioned id as identity; (b) `VersionedState` per revision | (a) splits one pathway into a node per curation edit and disagrees with its own DOI; (b) no CQ needs pathway content history, only "which revision was a link read from" (CQ-MX-C02), carried on the link and the snapshot |
| Condition codes | materialized `icd10Code` (catalog) | E88.81 changes meaning across fiscal years; many-to-one; needs validity (V-W03-08) |
| NAD+ placement | MolecularEntity of kind METABOLITE and ChemicalSubstance | two identities for one structure (V-W03-05 negative N8) |
| Species on molecular entities and pathways | a structural edge to `Species` | a property `speciesTaxonId` joins to `Species.ncbiTaxonomyId` without a new relationship type; promote to an edge only if a traversal CQ needs it |
| Shortcut polarity | project NEGATIVE measurements with a polarity property | a consumer that ignores the property reads "applies to human"; nulls stay assertions, answered by CQ-MX-03 |
| Proxy readouts | a `readoutKind` enum on `REFLECTS_MECHANISM` | the distinction is already the assertion's object type (Biomarker vs Mechanism); V-W03-03 enforces it without a new enum |

## 5. Smallest recommended model

Ten node types (all live or catalog; none new), four enums (two catalog, two refinements already named by the alignment table), two relationship-property types (successors required by contract B4), the catalog's structural context edges, the live derived edges re-founded on one rule (`mx-proj/v1`) and one one-to-one mode, and twelve candidate validators. New properties are limited to: `Pathway.pathwayRelease`, `revisionObservedAt`, `speciesTaxonId`, `orthologyInferred`; `MolecularEntity.speciesTaxonId`; `AnatomicalContext.uberonId` (catalog); `MechanismEvidenceContext.hedUnitCode`; `identifiers` fields to W00's `Identifier`; projection qualifiers on `AssociationProjectionProperties`; reference-revision fields on `MechanismLinkProperties`. One candidate edge (`HAS_ANALYTE`, W07's type) is requested, not defined here.
