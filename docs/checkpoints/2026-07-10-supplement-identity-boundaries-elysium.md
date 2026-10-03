# Supplement Identity Boundaries: Elysium Health Deep Dive

Date: 2026-07-10

Status: Working modeling checkpoint

This checkpoint uses Elysium Health and several products as stress tests for the Human Upgrade temporal knowledge graph. It distinguishes company assertions from labels, trials, publications, legal records, certification records, and Human Upgrade adjudication. It is not a product recommendation.

## Highest-Order Graph Structure

The semantic graph should distinguish six archetypes before choosing database tables, node labels, or relationship storage.

1. **Stable Identity** persists while descriptions and states change. Examples include Elysium Health, the BASIS trademark, the Basis Product, nicotinamide riboside chloride, NR-E, and the VITACOG Study.
2. **Versioned State** describes an identity for a bounded time or scope. Examples include a Formulation Version, Label Version, Specification Version, and organization-role period.
3. **Occurrence** is an event or process: manufacturing a lot, administering an intervention, testing a sample, purchasing a product, or taking a dose.
4. **Information Artifact** represents something without being that thing: a Label Snapshot, Trial Registration Version, Publication, patent document, Certificate of Analysis, or webpage capture.
5. **Assertion** is a proposition attributable to a claimant and source. It can be supported, contradicted, unresolved, superseded, or adjudicated without deleting the original.
6. **Evidence** is an observation, measurement, result, artifact, or reasoning chain used to evaluate an Assertion. A citation points to evidence; it is not the conclusion.

## Elysium Is an Organization With Many Roles

The company-facing name hides several identities and relationships:

- Elysium Health, Inc. is a Legal Organization.
- Elysium Health is a Brand.
- BASIS is a Product Mark associated with Elysium.
- Current labels name Elysium as distributor, which does not identify the physical manufacturer.
- Elysium describes NR-E as proprietary and owns patents related to NR synthesis and crystalline forms.
- Elysium funded and supplied interventions for studies, employs authors, owns patents, licenses other patents, operates a storefront, and participates in institutional partnerships.

These require typed and time-bounded roles rather than one `organizationId`. The advisory-board page explicitly says members advise the company and do not endorse specific products, so `ADVISES_ORGANIZATION` must not imply `ENDORSES_PRODUCT`.

Sources: [team](https://www.elysiumhealth.com/pages/team), [advisory board](https://www.elysiumhealth.com/pages/advisory-board), [mission](https://www.elysiumhealth.com/pages/mission).

## Basis: One Product Name, Multiple Material Histories

### Historical supply and trial formulation

Court records state that Elysium launched Basis in February 2015 and obtained NR and pterostilbene from ChromaDex until approximately August 2016. The branded materials were NIAGEN and pTeroPure. The first Basis trial recruited from January through July 2016; the court record describes it as using ChromaDex's Niagen.

The randomized trial administered:

- 250 mg NR plus 50 mg pterostilbene daily in the 1x arm;
- 500 mg NR plus 100 mg pterostilbene daily in the 2x arm;
- four capsules per day under its blinding design;
- microcrystalline cellulose, silicon dioxide, magnesium stearate, and gelatin as non-dietary ingredients.

The trial reported an approximately 40% whole-blood NAD+ increase in the 1x arm and approximately 90% at day 30 in the 2x arm. It also reported LDL changes requiring cautious interpretation. Elysium funded the trial; multiple authors were employees and shareholders; a CRO conducted data collection.

Sources: [litigation record](https://law.justia.com/cases/federal/district-courts/new-york/nysdce/1%3A2017cv07394/481243/302/), [2017 NRPT trial](https://www.nature.com/articles/s41514-017-0016-9).

### Current declaration

The current US label declares:

- `Elysium NR (Nicotinamide Riboside Chloride)` — 250 mg;
- `PT (Pterostilbene)` — 50 mg;
- microcrystalline cellulose, hypromellose, vegetable magnesium stearate, and silica.

The current page calls its NR material proprietary `NR-E`. The current formulation therefore differs visibly from the 2016 intervention in capsule/excipient composition and branded source-material identity. Matching active chemical names and nominal doses do not demonstrate exact current-product equivalence.

Sources: [current label](https://www.elysiumhealth.com/pages/basis-supplement-facts), [current product page](https://www.elysiumhealth.com/products/basis).

### NR-E identity and process

The NR-E toxicology publication describes synthetic, nature-identical nicotinamide riboside chloride, CAS 23111-00-4, made through a proprietary process. The tested crystalline material was reported at greater than 97% purity and evaluated in a 90-day GLP rat study. This characterizes that test material and animal toxicology; it is not a head-to-head human trial proving current Basis safer or more effective than every other NAD+ supplement.

Sources: [NR-E toxicology](https://journals.sagepub.com/doi/10.1177/1091581820927406), [synthesis patent](https://patents.justia.com/patent/11629163), [crystalline-form patent](https://patents.justia.com/patent/12043616).

### Evidence applicability

The graph needs a path like:

```text
2016 Trial Arm
-> administered Historical Basis Study Intervention
-> contained NIAGEN NR material and historical PT material
-> realized NR chloride and pterostilbene substances

Current Basis Formulation
-> contains NR-E material and current PT material
-> realizes the same or related substances at nominally matching doses

Evidence Applicability
-> historical intervention match: high
-> exact current material match: not demonstrated
-> active-substance match: likely/high, subject to verification
-> nominal dose match: high for 1x
-> delivery/excipient match: no
-> population match: limited to adults resembling ages 60–80
-> demonstrated outcome: whole-blood NAD+, not longevity
```

Applicability is multidimensional, not a binary edge.

### Outcomes must not collapse

Higher whole-blood NAD+, tissue exposure, mechanism activation, biomarker improvement, symptom improvement, disease-risk reduction, and longer healthspan are different outcomes.

The six-month NAFLD trial found no significant improvement in its primary endpoint of hepatic fat fraction versus placebo. Some prespecified secondary markers improved at the recommended dose, without a dose-response pattern at the double dose. The null primary outcome must remain beside favorable secondary findings. [NAFLD trial](https://pubmed.ncbi.nlm.nih.gov/36082508/)

The COPD trial tested 2 grams/day of NR-E without pterostilbene, not marketed Basis at 250 mg NR-E plus 50 mg PT. It is ingredient-material evidence at a different dose and in a disease population, not direct current-Basis evidence. [COPD trial](https://www.nature.com/articles/s43587-024-00758-1)

## Matter: Licensed Evidence Is Not Product Evidence

VITACOG administered folic acid 0.8 mg/day, vitamin B12 0.5 mg/day, and vitamin B6 20 mg/day for two years to people aged 70+ with mild cognitive impairment. It reported slower whole-brain atrophy. Later analysis found strong effect modification by baseline homocysteine and suggested benefit was concentrated among participants with adequate omega-3 status.

Matter declares the same nominal B-vitamin doses but also contains an omega-3 lysine complex and bilberry extract. Matter launched after VITACOG and was not its finished intervention. Oxford patents have been licensed to Elysium.

Therefore:

- `LICENSES_PATENT` is not `OWNS_STUDY`;
- `CONTAINS_STUDIED_DOSES` is not `WAS_STUDIED_AS_FINISHED_PRODUCT`;
- `PATENT_CLAIMS_USE` is not `PROVES_EFFICACY`;
- evidence in people 70+ with mild cognitive impairment is not automatically evidence in all healthy adults;
- subgroup and effect-modifier results belong in Evidence Applicability.

Sources: [VITACOG registry](https://www.isrctn.com/ISRCTN94410159), [original report](https://journals.plos.org/plosone/article/file?id=10.1371%2Fjournal.pone.0012244&type=printable), [regional analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC3677457/), [Matter](https://www.elysiumhealth.com/products/matter), [Matter label](https://www.elysiumhealth.com/pages/matter-supplement-facts).

## Mosaic and Format: Mixtures and Regimens

Mosaic's Phytonutrient Carotenoid Complex contains botanical extracts providing multiple constituents. The complex is a material mixture, not a synonym for lycopene, tomato, rosemary, or one constituent. `PROVIDES_CONSTITUENT` must not become quantitative `CONTAINS` unless the amount is declared or measured. Sources: [Mosaic science](https://www.elysiumhealth.com/pages/science-behind-mosaic), [Mosaic lot information](https://www.elysiumhealth.com/pages/mosaic-lot-info).

Format combines a daily supplement with a separately scheduled senolytic component. Its label contains nested named complexes and different dosing schedules. This distinguishes Product, Kit, Regimen Component, Formulation, Serving, Administration Schedule, and Protocol. A bundle containing the same named Senolytic Complex as a standalone product does not prove identical formulation versions or lots. [Format label](https://www.elysiumhealth.com/pages/format-supplement-facts)

## Quality Boundaries

Elysium publishes lot-specific pages, but they generally report `Conforms to internal specs` rather than measured analyte values, laboratory identity, methods, uncertainty, or a signed report.

The graph must distinguish Product Lot, Specification Version, Test Sample, Test Execution, Test Method, Laboratory, Measured Result, Pass/Fail Interpretation, Test Summary, Certificate of Analysis, Certification Program, Certification Listing, Certification Scope, and covered lots.

NSF separately lists finished-product and lot identifiers. The word `certified` must always retain its program and scope.

Sources: [Basis lot information](https://www.elysiumhealth.com/pages/basis-lot-info), [NSF listing](https://info.nsf.org/Certified/BannedSub/Listings.asp?Company=C0364723&Standard=306), [program scope](https://www.nsf.org/consumer-resources/articles/certified-for-sport-program).

## Regulatory and IP Boundaries

The model must distinguish Trademark, branded material, Patent Family, Patent Application, Granted Patent, Patent Claim, assignee, inventor, license, field of use, exclusivity, legal status, proprietary process, NDI notification, GRAS notice, orphan designation, and drug approval.

FDA lists an orphan designation for NR plus pterostilbene for ALS with Elysium as sponsor, but explicitly says it is not FDA approved for the orphan indication. `HAS_ORPHAN_DESIGNATION` must not imply `IS_APPROVED`. [FDA record](https://www.accessdata.fda.gov/scripts/opdlisting/oopd/detailedIndex.cfm?cfgridkey=628218)

FDA also states that an NDI filing is a safety notification and agency silence is not a safety finding or approval. [FDA NDI process](https://www.fda.gov/food/dietary-supplements/new-dietary-ingredient-ndi-notification-process)

## Official Sources Can Conflict

During this research, Elysium's science index associated the NAFL study with an identifier used by an acute-kidney-injury study, while the NAFL publication reports `NCT03513523`.

Ingestion must preserve the verbatim identifier assertion, resolve it against the authoritative registry, detect incompatible metadata, mark the link conflicted or rejected, and retain the correction rather than silently rewriting the source.

## Identity-Boundary Inventory

### Organization and IP

- legal entity vs brand vs parent/subsidiary;
- owner vs operator vs marketer vs distributor vs labeler;
- manufacturer vs contract manufacturer vs site;
- ingredient supplier vs specification owner;
- trademark owner vs patent assignee vs licensee;
- sponsor vs funder vs collaborator vs CRO vs study site;
- author affiliation vs employment vs advisory role;
- testing laboratory vs certifier;
- Patent Family vs application vs grant vs claim vs license;
- orphan designation vs approval.

### Product and commerce

- Product vs Product Variant;
- variant vs package configuration;
- package vs SKU, GTIN, UPC, or merchant-platform ID;
- Product Variant vs Offer;
- Offer vs price observation;
- one-time Offer vs Subscription Plan;
- Product vs Bundle or Kit;
- bundle component vs standalone product;
- inventory item vs lot vs individual unit;
- recommended product vs retailer match vs purchased item.

### Formulation and ingredient

- Product vs Formulation Version;
- formulation design vs manufacturing specification;
- specification vs actual batch composition;
- Label Snapshot vs declaration vs measured composition;
- dietary ingredient vs non-dietary ingredient;
- Ingredient Component vs Ingredient Material;
- material mass vs nutrient or active-moiety amount;
- per-unit vs per-serving vs per-day quantity;
- target amount vs minimum spec vs measured result;
- dosage form vs shell vs delivery technology;
- nutrient vs source ingredient;
- chemical substance vs salt, hydrate, stereoisomer, polymorph, grade, and impurity profile;
- generic substance vs Branded Ingredient Material vs trademark;
- material specification vs supplier lot;
- botanical taxon vs part vs preparation vs extract;
- extract ratio vs standardized constituent;
- species vs strain vs commercial culture;
- mixture vs constituent;
- proprietary blend vs nested component;
- present constituent vs quantitatively standardized constituent;
- process vs resulting material.

### Research and claims

- Study vs Trial Registration and Registration Version;
- Study vs Protocol Version;
- Study Arm vs Study Intervention;
- intervention vs marketed Product;
- investigational batch vs commercial lot;
- assigned dose vs actual exposure vs adherence;
- eligibility population vs enrolled vs analyzed cohort;
- biomarker vs surrogate endpoint vs clinical outcome;
- primary vs secondary vs exploratory vs post-hoc result;
- result vs interpretation;
- null result vs absent result;
- sponsorship vs data collection vs analysis vs authorship;
- Publication vs Study;
- ingredient evidence vs formulation evidence vs finished-product evidence;
- mechanism vs demonstrated human effect;
- statistical significance vs clinical importance;
- source-verbatim statement vs normalized Assertion;
- marketing claim vs label claim vs study finding;
- source Assertion vs Human Upgrade adjudication;
- unknown vs absent vs unmeasured vs below detection vs false;
- no evidence of effect vs evidence of no effect;
- authority for identity vs authority for efficacy.

### Time and user state

- stable identity vs Versioned State vs Snapshot;
- valid time vs recorded time vs publication time vs observation time;
- reformulation vs relabeling;
- ownership change vs identity change;
- user-stated fact vs imported measurement vs inferred signal;
- goal vs preference vs safety constraint;
- recommendation vs Decision Cart item vs commercial cart line;
- planned protocol vs actual administration;
- purchase vs possession vs adherence;
- subjective observation vs device or laboratory measurement;
- adverse-event report vs established causal reaction;
- evidence snapshot reviewed by a user vs live graph state.

## Relationship Policy

A direct relationship is appropriate when it is stable, uncontroversial, and regenerable. A relationship requires first-class assertion identity when it needs source attribution, disagreement, confidence, temporal bounds, jurisdiction, dose or population qualifiers, applicability, review state, or an independent lifecycle.

Derived edges such as `Product CONTAINS Ingredient` may aid traversal, but authoritative composition must flow through Product Variant, Formulation Version, and Ingredient Component.

## Application Capabilities Enabled

1. **Product Identity Timeline** — formulation, supplier, label, ownership, certification, lot, and price history.
2. **Study-Match Lens** — exact product, historical formulation, same branded material, same substance, same dose/different formulation, related ingredient, mechanism only, or unresolved.
3. **Claim Decomposition** — population, intervention, comparator, outcome, duration, result, funding, conflicts, and applicability behind “clinically proven.”
4. **Lot Passport** — declared specifications, measured values, reports, certificates, certifications, and gaps.
5. **Evidence-Inheritance Warnings** — explain why evidence transfers or fails to transfer.
6. **Personalized Applicability** — compare the user with population, biomarker, medication, dose, duration, and outcome context.
7. **Commerce Integrity** — keep recommendation rank independent from affiliate relationships, subscriptions, substitutions, and availability.

## Next Modeling Decisions

1. Define lifecycle rules for Product, Product Variant, Formulation Version, and Ingredient Material.
2. Define Ingredient Component for nested blends, source materials, nutrients, and standardized constituents.
3. Define the Assertion envelope and which relationships must be reified.
4. Define multidimensional Evidence Applicability.
5. Decide what creates a new Product Variant versus a new Formulation Version.
6. Define equivalence vocabulary: identical, realizes, sourced-from, branded-as, formulation-equivalent, analytically-equivalent, clinically-bridged, and merely related.
