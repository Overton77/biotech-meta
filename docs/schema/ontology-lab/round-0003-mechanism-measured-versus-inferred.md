# Round 0003: Mechanism Steps, Measured versus Inferred

Status: `OPEN` (Lane 2 recommendation: `ACCEPTED` for rules M1 to M7; kernel-change request KCR-3a needs coordinator approval)

## Header

- Round ID: 0003
- Date: 2026-10-03
- Builder: Lane 2
- Challenger: Lane 2 internal challenger; open to the review lane
- Owning module: new `mechanisms` module (candidate), depending on `kernel`, `provenance`, `substances_and_materials`, `studies_and_evidence`
- Candidate schema version: 0.2.0-candidate
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status: `OPEN`

## Intent and competency questions

- Decision or workflow being supported: answering "how is this supposed to work, and how much of that was actually shown, where, and at what exposure?" without letting a mouse result, a blood biomarker, or an author's hypothesis stand in for a measured human tissue effect; and answering "does the product I can buy deliver the exposure under which the effect was seen?".
- In scope: step-level epistemic status (measured, inferred, cited, hypothesized); species, model, tissue or cell system, compartment, setting, exposure (amount, unit, basis, route, duration), and material form per measured step; the bridge from an ingredient-level mechanism to a formulation's delivered exposure; how live mechanism edges (`AFFECTS_MECHANISM`, `MODULATES`, `APPLIES_TO_SPECIES`, `INFLUENCES_OUTCOME`, `ACTS_IN`) relate to source assertions.
- Out of scope: curated pathway topology (Reactome-style `INVOLVES_PATHWAY`, `PARTICIPATES_IN`), which stays reference knowledge; pharmacokinetic modeling; assay comparability (round 0004).
- Competency question IDs: `CQ-MX-01` to `CQ-MX-06`; `CQ-EV-04` (EXPOSURE dimension); `CQ-EV-05` (retraction propagation).

## Case packet

All PubMed records retrieved through the PubMed MCP tool on 2026-10-03. Doses for the mouse studies below were not extracted in this session and are marked unverified.

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| PMID 29184669 (Basis/NRPT trial paper) | publication | Results "NRPT increases NAD+": whole-blood NAD+ by LC-MS/MS, +40% (1X) and +90% (2X) at day 30; Introduction: "pterostilbene providing additional activation of SIRT1" and "predicted to synergistically support metabolic health"; Discussion: "If NRPT 1X upregulates SIRT1 as expected"; Introduction cites mouse studies (NR lifespan, stem cells, high-fat diet) | 2017-11-24 | measured: human whole-blood NAD+ at 250/500 mg NR + 50/100 mg PT daily for 8 weeks; everything about SIRT1 and tissues is hypothesis or citation |
| PMID 31278280 (Conze, NIAGEN) | publication | abstract: whole-blood NAD+ +22%, +51%, +142% at 100, 300, 1000 mg NR for 8 weeks, within 2 weeks | 2019-07-05 | measured: human whole-blood NAD+ dose response for one branded crystal form |
| PMID 31412242, doi:10.1016/j.celrep.2019.07.043 (Elhassan, Cell Rep 2019) | publication | abstract: 12 aged men, 1 g NR/day, 21 days, crossover; "NR elevated the muscle NAD+ metabolome, evident by increased nicotinic acid adenine dinucleotide and nicotinamide clearance products"; "without altering mitochondrial bioenergetics". Full text (PMC6702140): mitochondrial respiration, citrate synthase activity, mtDNA copy number unchanged; "did not detect NR-mediated changes to muscle protein acetylation" | 2019-08-13 | measured in human skeletal muscle: NAD+ metabolome up; sirtuin-proxy (pan-acetylation) and respiration unchanged. Whether muscle NAD+ itself rose was not verified in this session |
| PMID 29992272, doi:10.1093/ajcn/nqy132 (Dollerup, AJCN 2018) | publication | 40 obese insulin-resistant men, NR 1000 mg twice daily, 12 weeks; insulin sensitivity, glucose metabolism, energy expenditure unchanged; registered NCT02303483 (registry record not opened in session) | 2018-08-01 | measured human null for whole-body metabolic outcomes at 2 g/day |
| PMID 27127236, doi:10.1126/science.aaf2693 (Zhang, Science 2016) | publication | NR treatment in aged mice: mitochondrial unfolded protein response, MuSC rejuvenation; increased mouse life span | 2016-04-28 | measured in mice; dose and route not extracted (unverified) |
| PMID 27400265, doi:10.1038/nm.4132 (Ryu, Nat Med 2016) | publication | urolithin A induces mitophagy in vitro and in vivo; extends C. elegans lifespan; improves exercise capacity in two mouse models and young rats | 2016-07-11 | measured in worms, mice, rats, cells; doses not extracted (unverified) |
| PMID 32694802, doi:10.1038/s42255-019-0073-4 (Andreux, Nat Metab 2019) | publication | first-in-human; UA "bioavailable in plasma at all doses tested"; 500 and 1000 mg for 4 weeks modulated plasma acylcarnitines and skeletal muscle mitochondrial gene expression | 2019-06-14 | measured: human plasma exposure and muscle gene expression; mitophagy flux not measured |
| PMID 35584623 (Singh, ATLAS) | publication | "expression of proteins linked to mitophagy and mitochondrial metabolism in skeletal muscle ... significant increase"; softgel delivery, 500 and 1000 mg | 2022-05-17 | measured: protein markers (proxy), not flux |
| timeline.com/products/mitopure-softgels-vegan and timeline.com home | manufacturer page | "Directly activates mitophagy"; "Mitochondrial renewal increases by +39% after 16 weeks over placebo" citing Cell Reports Medicine | observed 2026-10-03 | company claim; renders a proxy measurement as "renewal" |
| PMID 18789672, doi:10.1016/j.jnutbio.2008.05.003 (Dudley, Das et al., J Nutr Biochem 2009;20:443-52) | publication, PubMed type "Retracted Publication" | rats gavaged 14 days with resveratrol 2.5, 5, 25, 50 mg/kg; low doses cardioprotective with Akt/Bcl-2 up; high doses the reverse | 2008-09-11 (epub) | what the retracted paper reported; nothing as accepted fact. Retraction notice identifier not retrieved (unverified) |
| FDA guidance "Estimating the Maximum Safe Starting Dose in Initial Clinical Trials for Therapeutics in Adult Healthy Volunteers" (July 2005), fda.gov/media/72309/download | regulatory guidance | Section V "Human Equivalent Dose Calculation", body-surface-area conversion | 2005-07 | a named method for animal-to-human dose scaling in drug safety; not a bioavailability equivalence for supplements |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "NAD+ in whole blood" | Biomarker (analyte in matrix) | `hu:biomarker:nad-plus-whole-blood` | none | PROPOSED | the measurand is analyte plus matrix; live `Biomarker.specimenMatrix` already carries this |
| "muscle NAD+ metabolome" | Biomarker set; NAAD and MeNAM as separate biomarkers | `hu:biomarker:naad-skeletal-muscle` | none | PROPOSED | the paper's positive finding is on NAAD and clearance products, not a single "muscle NAD+" value |
| "SIRT1 activation" | MolecularEntity activity | `hu:molecular-entity:sirt1` with predicate `INCREASES_ACTIVITY_OF` | HGNC not verified | PROPOSED | a step, not a biomarker; human proxy is pan-acetylation |
| "mitophagy", "mitochondrial renewal" | Mechanism concept | live `Mechanism` | none | PROPOSED | "renewal" on the product page is not a measured quantity |
| "NR", "NIAGEN", "NRPT", "UA", "Mitopure" | material vs substance | see round 0002 | | | the tested material is part of the context, not of the step identity |

## Builder proposal

### The NR chain as BellLabs would answer CQ-MX-01 and CQ-MX-02 today

| Step (subject, predicate, object) | Human | Animal | In vitro | Status in the Basis paper |
|---|---|---|---|---|
| NR intake `INCREASES_LEVEL_OF` NAD+ whole blood | MEASURED positive (Basis 250/500 mg + PT, 8 wk, age 60 to 80; Conze 100 to 1000 mg, 8 wk) | cited | n/a | MEASURED |
| NR intake `INCREASES_LEVEL_OF` NAAD skeletal muscle | MEASURED positive (Elhassan 1 g/d, 21 d, aged men) | cited | n/a | not addressed |
| NAD+ (muscle) `INCREASES_ACTIVITY_OF` SIRT1 | MEASURED null for proxy (pan-acetylation unchanged, Elhassan) | cited | biochemistry (cited) | HYPOTHESIS ("If NRPT 1X upregulates SIRT1 as expected") |
| Pterostilbene `INCREASES_ACTIVITY_OF` SIRT1 | not measured | cited | cited | HYPOTHESIS |
| NR intake `IMPROVES` muscle mitochondrial function | MEASURED null (respiration, CS, mtDNA unchanged, Elhassan) | MEASURED positive (Zhang 2016, dose unverified) | | CITED_FROM_PRIOR_WORK |
| NR intake `IMPROVES` insulin sensitivity | MEASURED null (Dollerup 2 g/d, 12 wk, obese men) | MEASURED positive (cited in Dollerup background) | | CITED_FROM_PRIOR_WORK |
| NR intake `EXTENDS` lifespan | not measured | MEASURED positive (Zhang 2016) | | CITED_FROM_PRIOR_WORK |

The table is not a new data structure. It is the answer shape that the model must produce from step assertions, their `basisKind`, and their contexts.

### Rules

**M1. Step identity is (subject, predicate, object), where level-change objects are compartment-specific measurands.** A step that changes the level of something targets a `Biomarker` (analyte in matrix: "NAD+ whole blood", "NAAD skeletal muscle"), not the bare `MolecularEntity`. A step about molecular interaction (activation, binding) targets a `MolecularEntity` with the compartment in the context. Chains are traversals over shared nodes: step n's object is step n+1's subject. Failing case it prevents: with a bare "NAD+" object, the Basis whole-blood result joins the "NAD+ activates SIRT1 in muscle" step, producing an unmeasured path from a blood draw to muscle sirtuin activity. FI-301 forbids the cross-compartment inference.

**M2. Every mechanism-predicate `Assertion` carries `basisKind`** in {`DIRECT_MEASUREMENT`, `INFERRED_FROM_MEASUREMENT`, `CITED_FROM_PRIOR_WORK`, `HYPOTHESIS`}. This is kernel-change request **KCR-3a**: an optional enum on `Assertion`, required by validation (V-230) for predicates of class `mechanism`. Failing case without it: the Basis paper's "pterostilbene providing additional activation of SIRT1" and its "NRPT significantly increases NAD+" are both `Assertion`s with subject, predicate, object, and a locator in the same paper. Without `basisKind`, a retrieval for "evidence that NRPT activates SIRT1" returns a source-supported, `ACCEPTED`-looking assertion. `polarity: NEGATIVE` with `DIRECT_MEASUREMENT` means "no change detected in this context", never `absent` (INV-007 distinct states).

**M3. A `DIRECT_MEASUREMENT` assertion has exactly one `MechanismEvidenceContext`** via `OBSERVED_IN_CONTEXT` (structural). `MechanismEvidenceContext` is archetype `Occurrence` (the reported exposure-and-measurement event), with:
- `setting` (`IN_VITRO_CELL_FREE`, `IN_VITRO_CELL`, `EX_VIVO`, `IN_VIVO_NONMAMMAL`, `IN_VIVO_MAMMAL`, `HUMAN_INTERVENTIONAL`, `HUMAN_OBSERVATIONAL`, `IN_SILICO`);
- `IN_SPECIES -> Species` (required except cell-free and in silico), `modelDescriptor` (verbatim strain, genotype, disease model, cell line), `sexScope`, `ageDescriptor`, `sampleSize`;
- `MEASURED_IN -> AnatomicalContext` (tissue, cell type, matrix);
- `EXPOSED_TO -> IngredientMaterial | ChemicalForm | ChemicalSubstance` (the tested material at the most specific level the source supports);
- `exposureAmount`, `exposureUnit` (UCUM: `mg/kg/d`, `mg/d`, `umol/L`), `exposureBasis` (`PER_KG_BODY_WEIGHT_PER_DAY`, `ABSOLUTE_PER_DAY`, `SINGLE_DOSE`, `MEDIUM_CONCENTRATION`, `DIET_CONCENTRATION`), `route`, `exposureDurationIso`;
- `IN_STUDY_ARM -> StudyArm` when the context is a human study already modeled; then dose, route, schedule, and population are read from the arm, and the context's own exposure fields stay null (V-238 rejects duplication).
Human-equivalent dose is never stored as asserted. If computed, it is a derived value with `hedMethod` (e.g. `FDA-2005-BSA`) and `hedValue`, regenerable.

**M4. Ingredient-level mechanism does not imply product exposure.** An `EvidenceApplicability` whose evidence target is a mechanism `Assertion` must carry an `EXPOSURE` dimension. Its verdict may be `MATCH` or `PARTIAL` only when `BASED_ON_EVIDENCE` links a human `StudyResult` that measured exposure (plasma level or tissue measurand) for the target's material and chemical form at a dose within the method's band; otherwise `UNKNOWN`. Value fields: `evidenceValue` (context exposure), `targetValue` (product daily amount), `unitCode`, `evidenceQuantityBasis`, `targetQuantityBasis`, `ratio` (only when bases match, e.g. both absolute mg/day in humans). Failing case: Ryu 2016 shows mitophagy induction by urolithin A in worms and rodents; Timeline sells 500 mg/day vegan softgels; Andreux 2019 measured plasma bioavailability for the trial material, and ATLAS used softgels. Whether the current vegan softgel delivers the ATLAS exposure depends on whether the trial softgel and the current softgel share material specification and matrix, which no source in the packet establishes. The dimension is `PARTIAL` with that missing fact listed, not `MATCH`.

**M5. Live mechanism edges are derived projections.** `CompoundForm -AFFECTS_MECHANISM->`, `Compound -MODULATES->`, `Mechanism -APPLIES_TO_SPECIES->`, `Mechanism -INFLUENCES_OUTCOME->`, `Mechanism -ACTS_IN->` may be materialized only from `ACCEPTED` assertions with `basisKind: DIRECT_MEASUREMENT`, carry `projectionOfAssertionUid`, and `APPLIES_TO_SPECIES` targets only species that appear in a projected assertion's context (V-233, V-234). Curated pathway edges with `MechanismLinkMetadata` remain reference structure (keep), with `regulatorySign` refined to an enum.

**M6. Retraction propagates as review, not deletion.** An `ACCEPTED` mechanism assertion whose every supporting locator belongs to a retracted publication is surfaced by V-235 for adjudication; the assertion is kept with its history (Lane 5 owns the correction event model). The Das case also shows why dose must be in the context: the same paper reports opposite signs at 2.5 to 5 mg/kg and 25 to 50 mg/kg in rats, so a step without exposure would carry contradictory polarities from one source.

**M7. Forbidden implications** (catalog-patch FI-301 to FI-305): a level change in one compartment does not imply the same change in another; a step measured in one species does not apply in another; an ingredient-level mechanism does not imply that a formulation delivers that exposure; a hypothesized or cited step is not a measured step; a proxy measurement (protein marker, gene expression) of a process is not a measurement of the process flux.

### Placement choices

- `basisKind`: assertion property (kernel), because it qualifies the proposition as the source made it and changes with nothing else.
- Context: `Occurrence` node, because it is shared by several step assertions from one experiment (Elhassan reports NAAD, MeNAM, respiration, citrate synthase, mtDNA, acetylation, and cytokines in one exposure), references three other identities (species, tissue, material), and may be cited by later syntheses.
- Measurand: referenced entity (`Biomarker`, owned by diagnostics), because the same analyte-matrix pair recurs across studies and must be joinable.
- Exposure bridge: evidence assessment dimension, because it is BellLabs' judgement comparing two contexts.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| C3-01 | Operational | Alternative A, qualifiers on `Assertion` (species, tissue, dose, setting as properties): smaller | high | Elhassan: seven step assertions share one exposure (1 g/d, 21 d, aged men, skeletal muscle biopsy). Qualifiers would be copied seven times; and for a human RCT they duplicate `StudyArm` dose and population, so two sources of dose truth can drift. Species and tissue as strings cannot be traversed for "all steps measured in human skeletal muscle" | Rejected A. Context node with `IN_STUDY_ARM` reuse |
| C3-02 | Ontological | Alternative B, `MechanismEvidenceContext` as `VersionedState` (coordinator's suggestion) | medium | A `VersionedState` is a state of an enduring identity attached by `HAS_STATE` with valid-time intervals. An experiment has no enduring identity whose state changes; giving it `validFrom/validTo` invites "current context" queries that mean nothing. A correction to a reported dose is a new recorded episode of the assertion (Lane 5), not a new state | Rejected B; archetype `Occurrence` |
| C3-03 | Operational | Alternative C, model every preclinical experiment as a `Study` with arms | high | Basis paper "pterostilbene ... activation of SIRT1" is `HYPOTHESIS` with no experiment, so there is no Study to attach to. A six-concentration cell assay becomes six arms with null registry fields, and "how many studies tested NR?" counts mouse cohorts and human trials together, which feeds `EvidenceApplicability` with non-human "studies" | Rejected C; human trials keep `Study`, contexts link to arms |
| C3-04 | Epistemic | Alternative D, keep species on the mechanism concept (`Mechanism -APPLIES_TO_SPECIES-> Species`) | high | "NR improves muscle mitochondrial function": mouse positive (Zhang), human null (Elhassan). One concept edge cannot carry both | Rejected D; edge becomes a derived projection per species |
| C3-05 | Operational | Alternative E, a `MechanismChain` node with ordered `HAS_STEP` | low | Needed only when a source asserts an ordered chain with a gap that has no shared node (e.g. a diagram jumping from "NAD+" to "longevity") | Deferred as Expansion (CQ-MX-06 note); traversal over shared measurands suffices for CQ-MX-01 to 05 |
| C3-06 | Linguistic | "Bioavailable in plasma at all doses tested" will be read as "reaches muscle" | medium | Andreux measured plasma; muscle effect is gene expression | Plasma measurand and muscle measurand are separate biomarkers (M1) |
| C3-07 | Temporal | A retraction arrives years after BellLabs accepted a step | medium | Das 2008 epub, retraction later (notice not retrieved) | M6; V-235; synthesis `TRIGGERED_BY {criterionCode: CORRECTION_OR_RETRACTION}` |
| C3-08 | Operational | HED conversion is standard; store it | medium | FDA 2005 guidance is a drug safety starting-dose method; it ignores formulation and bioavailability. Storing it as fact hides the method | Derived only, with `hedMethod` (V-236) |

## Linguistic analysis

- Source wording: "NRPT is predicted to synergistically support metabolic health through NR providing NAD+ to all seven sirtuins and pterostilbene providing additional activation of SIRT1" (Basis paper Introduction); "NR elevated the muscle NAD+ metabolome" (Elhassan abstract); "Urolithin A ... a known mitophagy activator" (Singh abstract); "Directly activates mitophagy" (Timeline page).
- Normalized propositions: `INCREASES_ACTIVITY_OF(pterostilbene, SIRT1)` with `basisKind: HYPOTHESIS`; `INCREASES_LEVEL_OF(NR intake, NAAD skeletal muscle)` with `DIRECT_MEASUREMENT` in context (human, aged men, 1 g/d, 21 d); `INDUCES_PROCESS(urolithin A, mitophagy)` with `CITED_FROM_PRIOR_WORK` in Singh and `DIRECT_MEASUREMENT` in Ryu (worm, rodent, cell contexts).
- Negation: "did not detect NR-mediated changes to muscle protein acetylation" -> `polarity: NEGATIVE`, `DIRECT_MEASUREMENT`; meaning "not detected", not "absent".
- Modality/hedging: "predicted", "as expected", "may" -> `HYPOTHESIS`.
- Quantification: "+39%" on the product page lacks a named measurand; recorded on the claim (Lane 4) with no step mapping until a measurand is resolved.
- Scope ambiguity: "muscle NAD+ metabolome" covers several metabolites; split per measurand.
- Presuppositions not licensed: "known mitophagy activator" presupposes human mitophagy flux was measured; it was not in the packet.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | high for abstracts; medium for Elhassan full-text details | manual read | PMC6702140 | none |
| Resolution | measurands PROPOSED | n/a | | none |
| Source reliability | papers authoritative for what they measured | source-registry 0.1 | | none |
| Evidence strength | not assessed | | | |
| Applicability | EXPOSURE dimension UNKNOWN for Basis current formulation vs mouse mechanism | applicability-v0.1 | fixture section 6 | none |
| Adjudication | PROPOSED | | | |
| Decision | n/a | | | |

## Schema projection

- Projection request ID: `proj-req-l2-0003`
- Selected modules: `mechanisms` (new), `studies_and_evidence`, `substances_and_materials`, `provenance`
- Closure additions: `Species`, `AnatomicalContext`, `Biomarker`, `MolecularEntity`, `Mechanism` (live reference types, endpoint surfaces only)
- Explicit exclusions: curated pathway topology
- Budget result / Projection ID: not generated

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | fixture section 6 (NR steps, Elhassan context, Basis arm context) | V-230 to V-238 return zero rows | statically checked | not run |
| Negative fixture | fixture NEGATIVE TEST block (projection from a HYPOTHESIS assertion) | V-233 returns a row | statically checked | not run |
| Minimal pair | whole-blood NAD+ (measured human) vs SIRT1 activation (hypothesis in Basis paper; measured-null proxy in Elhassan) | different `basisKind`, contexts | encoded | not run |
| Temporal correction | Das retraction | V-235 row | illustrative | not run |
| Identity collision | NAD+ blood vs muscle measurands | distinct Biomarker uids | encoded | not run |
| Extraction / retrieval evaluation | none | | | open |
| Migration compatibility | live mechanism edges become projections | additive | live-schema-decisions.md | review |

## Decision

- Outcome: recommend `ACCEPTED` for M1 to M7; KCR-3a (`Assertion.basisKind`) to the coordinator as a kernel change with the failing case above.
- Accepted semantic rule: a mechanism step is answerable as measured only through a `DIRECT_MEASUREMENT` assertion with a context naming species, compartment, material, and exposure; product applicability of a mechanism needs an `EXPOSURE` dimension backed by human exposure evidence for the target's material and form.
- Rejected alternatives: A (qualifiers on Assertion), B (VersionedState), C (preclinical experiments as Study), D (species on the mechanism concept); E deferred.
- Residual uncertainty: mouse doses for Zhang 2016 and Ryu 2016 not extracted; whether muscle NAD+ itself rose in Elhassan not verified; retraction notice id for PMID 18789672 not retrieved; measurand behind "+39% mitochondrial renewal" unresolved.
- Required catalog/schema changes: `lanes/lane2/catalog-patch.yaml` module `mechanisms`.
- Required ingestion changes: extractors label every mechanism proposition with `basisKind` and emit one context per exposure group; plasma and tissue measurands are never merged.
- Required retrieval/API/MCP changes: mechanism answers list steps with status per setting (the table shape above) and always state the compartment.
- Changelog and migration references: coordinator, 0.2.0.
