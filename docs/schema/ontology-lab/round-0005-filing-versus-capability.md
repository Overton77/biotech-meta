# Round 0005: Filing Versus Capability

## Header

- Round ID: 0005
- Date: 2026-10-03
- Builder: Lane 3 (diagnostics, devices, manufacturing, regulatory status, commerce)
- Challenger: Lane 3 internal challenger; cross-lane challenge requested from Lane 4 (speaker and source attribution) and Lane 1 (query shapes)
- Owning modules: `regulatory_and_ip` (catalog, provisional), `commerce` (provisional), `formulation_and_ingredients` (manufacturing subset), `quality` (certification scope); new small module `manufacturing_readiness` proposed as `candidate`
- Candidate schema version: 0.2.0-candidate (coordinator assigns)
- Source schema digest: `current_biotech_schema.graphql` sha256 `86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112`; `catalog/schema.yaml` sha256 `4c3203f57706c43fe508549211ed6f11910e2150947814c047122eb34f29825f`
- Decision status (recommendation): `OPEN`, recommend `ACCEPTED` for the regulatory split and commerce role split, `REVISED` for the live `RegulatoryStatus` (kept as the name, narrowed in meaning)

## Intent and competency questions

- Decision or workflow being supported: when BellLabs says "this ingredient has an FDA response", "this company manufactures", "this product is certified", or "this is available at this price", the answer must separate what a filing or an agency record disclosed, what a company promoted, what a third party certified within a scope, and what BellLabs concluded, each with time and source.
- In scope: regulatory submission, response, and resulting status for NDI notifications, GRAS notices, 510(k), De Novo, PMA, LDT policy, orphan designation, drug approval, facility and establishment registration; cGMP claims versus certification versus inspection; capability stages operating, piloting, planned; listing versus selling versus fulfilling versus affiliate; price and availability observation; the declared-amount referent (full compound versus active moiety versus extract marker).
- Out of scope: patent semantics (unchanged), clinical efficacy assessment (Lane 2), speaker-level attribution inside documents (Lane 4), a person's purchases (Lane 5).
- Competency question IDs: `CQ-MF-01` to `CQ-MF-06`, `CQ-CM-01` to `CQ-CM-05`, `CQ-PF-01` to `CQ-PF-04` (new); reuses `CQ-EV-01`, `CQ-EV-02`, `CQ-ID-03`, `CQ-TM-03`, `CQ-RC-02`.

## Case packet

| Source snapshot | Source kind | Exact locator | Published/observed time | Authority scope |
|---|---|---|---|---|
| FDA NDI notification process (SRC-FDA-NDI-PROCESS, existing) | regulatory guidance page | fda.gov NDI Notification Process page | content current as of 06/11/2025; observed 2026-10-03 | meaning of an NDI notification |
| FDA NDIN procedures and timeframes guidance (SRC-FDA-NDIN-PROCEDURES) | regulatory guidance PDF | fda.gov/media/176512/download, list of response letter types; "receiving an acknowledgement letter without objection means that FDA's review of the NDIN did not find any reason to object ... However, such a letter does not constitute an ..." (snippet truncated in capture); 75-day marketing wait after filing date; supplemental substantive information resets the filing date | observed 2026-10-03 via search snippet | response categories and filing-date semantics |
| FDA GRAS overview (SRC-FDA-GRAS-OVERVIEW) | regulatory page | fda.gov/food/food-ingredients-packaging/generally-recognized-safe-gras; notice of a proposed rule dated August 10, 2026, docket FDA-2025-N-3262 | content current as of 08/10/2026 | GRAS meaning; that the regime is under proposed change |
| FDA GRAS notice inventory (SRC-FDA-GRAS-INVENTORY) | regulatory database | hfpappexternal.fda.gov GRAS Notices inventory; response types "FDA has no questions", "Notice does not provide a basis for a GRAS determination", "At the notifier's request, FDA ceased to evaluate this notice"; resubmissions link to prior entries | observed 2026-10-03 | per-notice response type and closure date |
| FDA response letter GRN 000635 (SRC-FDA-GRN-000635) | agency response letter | fda.gov/food/gras-notice-inventory/agency-response-letter-gras-notice-no-grn-000635: "the agency has no questions at this time regarding ChromaDex's conclusion that NR is GRAS under the intended conditions of use. The agency has not, however, made its own determination regarding the GRAS status"; intended use "as a source of vitamin B3 in vitamin waters, protein shakes, nutrition bars, gum, chews, and powdered beverages at a maximum level of 0.0057% by weight as consumed" | observed 2026-10-03 | the response, its conditions of use, and its disclaimer |
| Company regulatory page (SRC-TRUNIAGEN-REGULATORY) | official company page | pages.truniagen.com/regulatory: "FDA GRAS no objection for Niagen ... on August 05, 2016, Dose: 180 mg/day, GRN 635"; "FDA NDIN no objection ... November 03, 2015, Dose: 180 mg/day, NDI 882"; "March 07, 2018, Dose: 300 mg/day, NDI 1062" | observed 2026-10-03 via search snippet | what the company says about its responses |
| Niagen Bioscience FY2025 Form 10-K (SRC-SEC-NAGE-10K-FY2025) | SEC filing | sec.gov/Archives/edgar/data/1386570/000138657026000013/cdxc-20251231.htm; Item 1A risk factor "We rely on a single supplier, W.R. Grace, for NRC"; "Grace holds patents related to the crystalline form of NR chloride that provide Grace with exclusive manufacturing rights for certain forms of NRCL"; "We rely on contract manufacturers to manufacture pharmaceutical-grade Niagen and 503B outsourcing facilities to compound"; "Pharmaceutical-grade Niagen is authorized by the FDA for compounding by 503B outsourcing facilities"; risk factor that the substance must remain on FDA's interim Category 1 list under enforcement discretion | fiscal year ended 2025-12-31; observed 2026-10-03 | what the company disclosed in a securities filing |
| Niagen Bioscience home page (SRC-NIAGEN-HOME) | company marketing page | niagenbioscience.com: "Every ingredient we make is clinically researched and held to the highest standards" | observed 2026-10-03 via search snippet | what the company promotes |
| ASN business directory entry (SRC-ASN-NIAGEN-DIRECTORY) | company-supplied directory listing | nutrition.org/business-directory/chromadex-corp: "All manufacturing facilities are visited and inspected frequently by our internal inspectors and third-party certifiers including NSF ..."; "Niagen Bioscience laboratories are ISO/IEC 17025:2017 accredited" | observed 2026-10-03 via search snippet | company statements placed on a third-party site; not an ASN statement |
| FDA 503B bulk drug substances page (SRC-FDA-503B-BULKS) | regulatory page | fda.gov/drugs/human-drug-compounding/bulk-drug-substances-used-compounding-under-section-503b-fdc-act: "Bulk drug substances that appear in category 1 may continue to be within the scope of the interim enforcement policy ... until the agency decides on inclusion" | observed 2026-10-03 | the category 1 policy is enforcement discretion, not a listing or approval |
| eCFR 21 CFR 807.39 and 807.97 (SRC-ECFR-21-807) | regulation | ecfr.gov 21 CFR Part 807: 807.39 "Registration of a device establishment or assignment of a registration number does not in any way denote approval of the establishment or its products"; 807.97 the same for premarket notification | observed 2026-10-03 | registration and 510(k) clearance are not approval |
| FDA "Is It Really FDA Approved?" (SRC-FDA-IS-IT-APPROVED) | consumer guidance | fda.gov/consumers/consumer-updates/it-really-fda-approved: "Mere registration of an establishment or listing of a drug or device does not denote approval"; "510(k) clearance ... substantially equivalent to a legally marketed predicate"; FDA does not approve dietary supplement labels | observed 2026-10-03 | vocabulary: approval, clearance, registration, notification |
| FDA Zona Health warning letter (SRC-FDA-WL-ZONA-2019) | warning letter | fda.gov warning letter 584676, 12/06/2019: website representations of approval based on registration and premarket notification are misbranding under 807.39 and 807.97 | issued 2019-12-06 | a real case where registration was promoted as approval |
| FDA Q&A on dietary supplements (SRC-FDA-DS-QA) | regulatory Q&A | fda.gov/food/information-consumers-using-dietary-supplements/questions-and-answers-dietary-supplements: facilities that manufacture, process, pack, or hold dietary supplements must register; firms must follow CGMP; "FDA generally does not approve dietary supplement claims or other labeling before use" | observed 2026-10-03 | registration duty is separate from CGMP duty |
| FDA De Novo page (SRC-FDA-DENOVO) | regulatory page | fda.gov De Novo Classification Request: if declined "the device remains in class III"; FDA publishes decision summaries | observed 2026-10-03 | De Novo grant versus decline |
| FDA DEN200080 record (SRC-FDA-DEN200080) | regulatory record | accessdata.fda.gov De Novo DEN200080 (see Round 0004) | decision 2021-09-21 | a granted De Novo with no PCCP |
| FDA LDT page and Federal Register 2025-18239 (SRC-FDA-LDT, SRC-FR-2025-18239) | regulatory page and final rule | fda.gov LDT page: rule issued May 6, 2024, vacated March 31, 2025 by E.D. Tex. (Am. Clinical Lab'y Ass'n v. FDA, No. 4:24-CV-479-SDJ), reverted by final rule effective September 19, 2025 | observed 2026-10-03 | the governing regime for LDTs changed twice in 17 months |
| FTC Health Products Compliance Guidance (SRC-FTC-HEALTH-PRODUCTS-2022) | enforcement guidance | ftc.gov/business-guidance/resources/health-products-compliance-guidance: "competent and reliable scientific evidence"; testimonials "don't constitute substantiation" | observed 2026-10-03 | substantiation standard for health claims in advertising |
| NSF ingredient certification article (SRC-NSF-173DI) and NSF/ANSI 455-2 article (SRC-NSF-455-2) | certifier explainer | nsf.org knowledge library: "NSF is known for certifying facilities to the NSF/ANSI 455 Good Manufacturing Practices (GMP) standard, and for certifying products to NSF/ANSI 173 Contents Certified and NSF 306 Certified for Sport"; 173DI without GMP "limits a company to certifying only ingredients" | observed 2026-10-03 | facility GMP certification versus product certification versus ingredient certification |
| NSF 306 listing for Elysium Health (SRC-NSF-ELYSIUM, existing) | certification listing | info.nsf.org listing, "current as of Saturday, October 3, 2026"; trade designation "Basis" appears in several rows with distinct "Product ID" values (for example 231202; 24150 24150A ...; R212-01 M070-01 P043-01) | observed 2026-10-03 | scope is per listed Product ID, not per product name |
| Amazon listing ASIN B0FS82B35K (SRC-AMAZON-B0FS82B35K) | marketplace listing | amazon.com/TRU-NIAGEN-Astaxanthin-Hyaluronic-Supplements/dp/B0FS82B35K: "One-time purchase $49.00 ... Ships from: Amazon Sold by: TRU NIAGEN" | observed 2026-10-03 via search snippet, not a captured snapshot | marketplace operator, seller of record, fulfiller as displayed |
| Amazon Tru Niagen brand store (SRC-AMAZON-TRUNIAGEN-STORE) | marketplace brand page | amazon.com/stores/TruNiagen/page/32AC1A83-7E42-4575-9911-6BF694DD03C7: "Nicotinamide Riboside 300mg, 30 Daily Servings. You pay $41.65 with coupon" | observed 2026-10-03 via search snippet | displayed coupon-adjusted price |
| eCFR 21 CFR 101.36 (SRC-ECFR-21-101-36) | regulation | 101.36(b)(2)(ii): amounts "shall represent the weight of the dietary ingredient rather than the weight of the source of the dietary ingredient (e.g., the weight of calcium rather than that of calcium carbonate)"; 101.36(b)(3)(ii): for other dietary ingredients "the weight of the other dietary ingredient listed and not the weight of any component, or the source"; proprietary blend paragraph: amount is "the total weight of all other dietary ingredients contained in the proprietary blend" | observed 2026-10-03 | which entity a US Supplement Facts amount refers to |

## What the sources can and cannot establish

| Source | Can establish | Cannot establish | Schema consequence |
|---|---|---|---|
| GRN 000635 letter | FDA has no questions about the notifier's GRAS conclusion for stated food uses at 0.0057 % by weight; FDA did not make its own determination. | Approval; safety at a dietary supplement dose; GRAS for uses outside the notice. | `RegulatoryResponse{responseKind: GRAS_NO_QUESTIONS}` with `conditionsOfUseText` verbatim; no `RegulatoryStatus{statusKind: APPROVAL}` may cite it (V-320). |
| Company regulatory page | The company's characterization, including "Dose: 180 mg/day" next to GRN 635. | That the FDA letter states 180 mg/day (the letter speaks in percent by weight in food categories). | A separate `Assertion` ASSERTED_BY the company, predicate `CHARACTERIZES_REGULATORY_RESPONSE`; BellLabs `Adjudication` compares it with the letter. Conversion of 0.0057 % to mg/day is not performed by the schema. |
| NDIN guidance | Response types: acknowledgement without objection, incomplete, objection, other regulatory issue; 75-day wait; filing date resets on substantive supplement. | Product safety for a product not described in the notification. | `RegulatorySubmission.filingDate` is a versioned fact (new recorded episode on reset); `responseKind` is a closed per-pathway enum. |
| 10-K FY2025 | What the company disclosed: single supplier for NRC; contract manufacturers; 503B outsourcing facilities; reliance on interim Category 1. | That the company operates any NRC manufacturing; that FDA "authorized" anything beyond the interim enforcement policy. | Filing statements are `Assertion`s with `ASSERTED_BY` the issuer and the filing as source; the 10-K's "authorized by the FDA" is itself a company characterization and is adjudicated against SRC-FDA-503B-BULKS. |
| Home page and ASN directory | What the company promotes: "Every ingredient we make", facilities inspected by certifiers, lab accreditation. | Capability stage, facility identity, inspection outcome, accreditation scope. | Promoted capability is an `Assertion` whose source kind is marketing; it cannot by itself attach an `OPERATING` capability state (V-324). |
| 21 CFR 807.39, 807.97; FDA consumer page; Zona letter | Registration and 510(k) clearance do not denote approval; promoting them as approval is misbranding. | Anything about a specific product's safety. | Forbidden implications `[ESTABLISHMENT_REGISTERED, FDA_APPROVED]`, `[CLEARED_510K, FDA_APPROVED]`; registration is a `RegulatoryStatus` of a `Facility`, never of a `Product` (V-323). |
| FDA DS Q&A | Facility registration duty and CGMP duty are separate obligations. | That a registered facility complies with CGMP. | Forbidden implication `[ESTABLISHMENT_REGISTERED, CGMP_COMPLIANT]`; a cGMP "claim" is an Assertion, a certification is a `CertificationListing`, an inspection is an `Occurrence` (expansion). |
| NSF explainers and listing | Facility GMP certification (455-2), product contents certification (173), sport certification (306), ingredient certification (173DI) are different programs; a 306 listing enumerates Product IDs. | That every lot sold under a trade name is in scope. | `CertificationScope.COVERS` range adds `Facility` and `TradeItemIdentifier`; a facility GMP certificate never projects to a product certification (V-332). |
| LDT page and FR notice | The regime changed: rule effective 2024, vacated 2025-03-31, text reverted 2025-09-19. | Status of any specific LDT. | Statuses carry `legalBasisCitation` and valid time; a status derived from a vacated rule ends at vacatur, it is not deleted (V-334). |
| FTC guidance | Health claims require competent and reliable scientific evidence; testimonials are not substantiation. | Whether a specific claim is substantiated. | "FDA approved" or "clinically proven" in marketing is a promoted assertion; substantiation is an `EvidenceAssessment`, not a node attribute. |
| Amazon listing | As displayed on observation: seller of record "TRU NIAGEN", ships from "Amazon", price $49.00 one-time. | That Amazon sells the product; that the price persists; that the product page identity equals one product variant. | `MerchantListing` (live `Listing`) hosted by a marketplace (`HOSTS_LISTING`); `Offer` has a seller of record (`SELLER_OF_RECORD_FOR`) and a fulfiller (`FULFILLS_OFFER`) as separate asserted roles; `PriceObservation` with `priceKind`. |
| 21 CFR 101.36 | For vitamins and minerals the declared amount is the nutrient (calcium, not calcium carbonate); for other dietary ingredients it is the ingredient as listed, not a component or source; for a proprietary blend it is the blend total. | Active-moiety mass, nutrient equivalents, or marker content when the label does not state them. | `QuantityDeclaration.amountReferent` (closed enum); active-moiety and nutrient-equivalent amounts are calculated assertions with a cited rule, never declarations (V-330). |

## Identification and clustering

| Mention | Candidate kind | Candidate identity | External identifiers | Resolution status | Rationale |
|---|---|---|---|---|---|
| "GRN 635" / "GRN 000635" | RegulatorySubmission (GRAS notice) | `hu:reg-submission:us-fda-grn-000635` | Identifier scheme `FDA_GRN`, value `000635` (normalized zero-padded 6 digits) | resolved | FDA inventory number |
| "GRAS no objection" | RegulatoryResponse | `hu:reg-response:us-fda-grn-000635-response` | none beyond submission | resolved | company wording differs from FDA wording ("no questions"); company wording is an Assertion |
| "NDI 882" | RegulatorySubmission (NDI notification) | `hu:reg-submission:us-fda-ndi-882` | scheme `FDA_NDI`, value `882` | company-reported; FDA letter not fetched | unverified at the agency record |
| "Niagen Bioscience" / "ChromaDex" | Organization (LegalEntity) | `hu:org:niagen-bioscience-inc` | SEC CIK 1386570 | resolved | 10-K path carries the CIK; name change is an alias, not a new identity |
| "W.R. Grace" | Organization (LegalEntity) | `hu:org:w-r-grace-and-co-conn` | none fetched | resolved by filing text | |
| "TRU NIAGEN" (Amazon "Sold by") | Organization or ConsumerBrand acting as seller account | `hu:org:seller-account-amazon-tru-niagen` | Amazon seller id not captured | unresolved to legal entity | a seller display name is not a legal entity; `ResolutionHypothesis` to Niagen Bioscience |
| "Basis" (NSF listing rows) | ProductVariant / ProductLot scope | several Product IDs | NSF Product ID values | resolved per row | one trade name, many scoped IDs |

## Builder proposal

### A. Regulatory: submission, response, status

```text
RegulatoryPathway (Entity, live, kept)              NDI_NOTIFICATION, GRAS_NOTICE, PREMARKET_NOTIFICATION_510K, DE_NOVO,
                                                     PMA, NDA, BLA, ORPHAN_DESIGNATION, FOOD_FACILITY_REGISTRATION,
                                                     DEVICE_ESTABLISHMENT_REGISTRATION, COMPOUNDING_503B_BULKS_POLICY, LDT_POLICY
  -[:HAS_REGULATORY_STEP]-> RegulatoryStep (live, kept: template step, not an event)
RegulatoryAgency (live, kept; catalog: Organization label RegulatoryAgency)
RegulatorySubmission (InformationArtifact, catalog, kept)
  -[:UNDER_PATHWAY]-> RegulatoryPathway
  -[:SUBMITTED_BY]-> Organization                       (asserted)
  -[:SUBMISSION_ABOUT]-> IngredientMaterial | Product | ProductVariant | AlgorithmVersion | Facility  (asserted)
  -[:IDENTIFIED_BY]-> Identifier
  -[:SUPERSEDES_SUBMISSION]-> RegulatorySubmission      (resubmission chain, GRAS inventory)
RegulatoryResponse (InformationArtifact, catalog, kept; responseKind closed per pathway)
  <-[:SUBMISSION_HAS_RESPONSE]- RegulatorySubmission
  -[:ISSUED_BY]-> RegulatoryAgency
RegulatoryStatus (VersionedState; live name kept, meaning narrowed)
  statusKind: APPROVAL | CLEARANCE | DE_NOVO_AUTHORIZATION | DESIGNATION | ESTABLISHMENT_REGISTRATION
              | NOTIFICATION_ON_FILE | ENFORCEMENT_DISCRETION | WITHDRAWN | REVOKED
  -[:STATUS_OF]-> Product | ProductVariant | IngredientMaterial | AlgorithmVersion | Facility
  -[:RESULTS_FROM_RESPONSE]-> RegulatoryResponse        (structural when the status is the response's direct effect)
  -[:UNDER_LEGAL_BASIS]-> RegulatoryPathway
  catalog OrphanDesignation and DrugApproval become specialization labels: (:VersionedState:RegulatoryStatus:DrugApproval)
```

`NOTIFICATION_ON_FILE` is deliberately not an approval kind: an NDI acknowledgement without objection or a GRAS "no questions" letter puts the notification on file with a response; it changes nothing about approval. The set `{APPROVAL}` is the only kind that may project to live `Product.status = APPROVED`.

### B. Manufacturing capability and readiness

```text
ManufacturingCapability (VersionedState, NEW)
  properties: stage (OPERATING | PILOTING | PLANNED | SUSPENDED | DISCONTINUED), capacityValue, capacityUnitCode,
              capacityBasis (NAMEPLATE | UTILIZED | NOT_REPORTED), targetOperationalDate (PLANNED only)
  -[:CAPABILITY_FOR_PROCESS]-> ManufacturingProcess (live + catalog, merged)
  -[:CAPABILITY_FOR_MATERIAL]-> IngredientMaterial  (optional)
(Organization | Facility)-[:HAS_CAPABILITY_STATE {validFrom, validTo, recordedFrom, recordedTo, assertionUid}]->(ManufacturingCapability)
```

"Promoted" is not a fifth stage. It is the communicative context of the asserting source. A company can promote a capability that is operating, planned, or nonexistent. The model therefore records stage on the state and context on the source: `Source.sourceKind` in {`SECURITIES_FILING`, `REGULATORY_RECORD`, `PRESS_RELEASE`, `MARKETING_PAGE`, `THIRD_PARTY_DIRECTORY`, `CERTIFICATION_LISTING`, `AUDIT_REPORT`}. A `HAS_CAPABILITY_STATE` edge with stage `OPERATING` requires either an assertion from a non-marketing source or an `Adjudication` with verdict `SUPPORTED` (V-324).

### C. Assertion versus adjudication ("company statement versus our inference")

| Proposition | Representation |
|---|---|
| "We rely on a single supplier, W.R. Grace, for NRC" (10-K) | `Assertion{predicate: SUPPLIES_INGREDIENT_MATERIAL, status: ACCEPTED}` subject Grace, object NRC material, `ASSERTED_BY` Niagen Bioscience, `SUPPORTED_BY` 10-K locator |
| "Every ingredient we make ..." (home page) | `Assertion{predicate: HAS_CAPABILITY_STATE, status: EXTRACTED}` subject Niagen Bioscience, object a `ManufacturingCapability{stage: OPERATING}` node that stays unattached, `ASSERTED_BY` Niagen Bioscience, `SUPPORTED_BY` home-page locator |
| BellLabs: the filing does not disclose company-operated NRC manufacturing; the promotion does not establish an operating capability | `Adjudication{verdict: INSUFFICIENT}` `EVALUATES` the home-page assertion, `SUPPORTED_BY` the 10-K locator. Not `CONTRADICTED`: the 10-K grants Grace exclusivity only "for certain forms of NRCL". |
| "Pharmaceutical-grade Niagen is authorized by the FDA for compounding by 503B outsourcing facilities" (10-K) | `Assertion{predicate: CHARACTERIZES_REGULATORY_STATUS}`; BellLabs `Adjudication{verdict: PARTIALLY_SUPPORTED}` citing SRC-FDA-503B-BULKS: the agency position for Category 1 substances is interim enforcement discretion. Whether NRC is in Category 1 is unverified in this round. |
| BellLabs status record | `RegulatoryStatus{statusKind: ENFORCEMENT_DISCRETION}` only if a BellLabs reviewer confirms the Category 1 entry; until then no status node is created. |

No new kernel type is needed for "our inference": BellLabs conclusions are `Adjudication`s; BellLabs-generated propositions that no source states are `Assertion`s `ASSERTED_BY` an `Agent` with `extractionMethod: INFERENCE`, which the kernel already allows. One kernel-change request is filed below for calculated quantities.

### D. Commerce: listing, selling, fulfilling, affiliate, price

```text
MerchantListing (catalog; live projection name Listing)    the page or catalog entry (Amazon detail page, merchant PDP)
  -[:LISTING_FOR]-> ProductVariant | PackageConfiguration  (catalog, asserted)
  -[:HAS_OFFER]-> Offer                                    (catalog, structural)
Offer (VersionedState, catalog)                            one seller's proposition on that listing
  -[:HAS_PRICE_OBSERVATION]-> PriceObservation             (catalog, structural)
Organization -[:HOSTS_LISTING]-> MerchantListing           marketplace operator; asserted, NEW
Organization -[:SELLER_OF_RECORD_FOR]-> Offer              offer-scoped, observed; asserted, NEW
Organization -[:FULFILLS_OFFER]-> Offer                    catalog predicate, now also a typed asserted edge
Organization -[:LISTS_OFFER]-> Offer                       catalog predicate (the party that placed the offer on the listing)
PriceObservation (Occurrence, catalog)                     amount, currency, observedAt, priceKind, availabilityObserved
AffiliateLink (InformationArtifact, NEW small)             a tracked link in an episode or article
  -[:LINKS_TO]-> MerchantListing | Offer
Person | Organization -[:AFFILIATE_FOR_OFFER]-> Offer      catalog predicate
```

Live `Listing.priceAmount`, `currency`, `availabilityStatus`, `capturedAt` become a current projection of the latest `PriceObservation`; `ListingSnapshot` maps to the `SourceSnapshot` of the listing page.

### E. Declared amount referent (closes OPEN-QUESTIONS ingredient identity 3 for US Supplement Facts)

`QuantityDeclaration.amountReferent` (and the same on `IngredientComponent` when it is populated from a label):

| Value | Meaning | Source rule |
|---|---|---|
| `NUTRIENT_AS_NUTRIENT` | amount is the nutrient, not its source compound (calcium, not calcium carbonate) | 21 CFR 101.36(b)(2)(ii) |
| `LISTED_INGREDIENT_AS_LISTED` | amount is the whole ingredient as named on the line (for example "Nicotinamide Riboside Chloride 250 mg" refers to the chloride salt) | 21 CFR 101.36(b)(3)(ii) |
| `PROPRIETARY_BLEND_TOTAL` | amount is the blend total; nested amounts unknown | 21 CFR 101.36 proprietary blend paragraph |
| `EXTRACT_TOTAL` | amount is the extract mass | label text; botanical detail is OPEN-QUESTIONS P1-4 |
| `MARKER_CONSTITUENT` | amount or percent of a marker in an extract ("standardized to") | label text; does not establish total constituent content |
| `NOT_STATED` | label gives no amount | |

`ACTIVE_MOIETY` and `NUTRIENT_EQUIVALENT` are not label referents. They are calculated `Assertion`s (predicate `QUANTITATIVELY_CONTAINS` with `kind: CALCULATED`, `derivationRule`, inputs) and never attach to a `LabelDeclaration` (V-330). Example: "250 mg nicotinamide riboside chloride" is `LISTED_INGREDIENT_AS_LISTED`; the NR cation mass of about 219.5 mg is a calculation from molecular weights (NR cation about 255.25 g/mol, NR chloride about 290.70 g/mol; both values unverified in this round because PubChem was not reachable) and must cite its weight source when committed.

## Challenger objections

| ID | Lens | Counterexample or failure | Severity | Proposed discriminating test | Resolution |
|---|---|---|---|---|---|
| C1 | Epistemic | "GRN 635 means NR is FDA-approved." FDA letter: no questions; "has not ... made its own determination". | high | `RegulatoryResponse{GRAS_NO_QUESTIONS}`; query for approval returns nothing. | Accepted. V-320. |
| C2 | Linguistic | The company calls GRN 635 a "No Objection Letter" with "Dose: 180 mg/day"; the FDA letter says "no questions" at 0.0057 % by weight in listed foods. | high | Two propositions with different conditions. | Accepted. Company characterization is a separate Assertion; `RegulatoryResponse.conditionsOfUseText` stores FDA wording verbatim. |
| C3 | Ontological | "Live `RegulatoryStatus` already has `applicationNumber` and `decisionDate`; why split?" A notification, its response, and the resulting status have different dates, issuers, and lifecycles; an NDI filing date resets when supplemented. | high | NDI with supplement: filing date changes, response date unchanged. | Accepted. Split into Submission, Response, Status. Live `RegulatoryStatus` name kept for the status. |
| C4 | Ontological | "FDA-registered facility" on a product page. 21 CFR 807.39; FDA consumer page; Zona letter. | high | Facility registration status with `STATUS_OF -> Product`. | Accepted. Registration attaches to `Facility` only (V-323) and never projects to approval (V-321). |
| C5 | Epistemic | "cGMP compliant" on a label. FDA DS Q&A separates registration and CGMP; NSF 455-2 certifies facilities; inspections are agency occurrences. | medium | Three sources: company claim, NSF 455-2 listing, FDA inspection. | Accepted: three representations (Assertion; CertificationListing scoped to Facility; Inspection occurrence deferred to expansion). |
| C6 | Ontological | "NSF certified" for a product whose listed Product IDs do not include the purchased lot. | high | Listing scope with Product IDs; lot not in scope. | Accepted. `CertificationScope.COVERS` may target `TradeItemIdentifier` and `ProductLot`; product-name-level coverage is a projection only when the scope says so. |
| C7 | Ontological | "Promoted is a capability stage." | medium | A filing says "operating", a marketing page promotes the same. | Rejected as a stage. Promotion is source context. Same capability, two assertions. |
| C8 | Temporal | "Planned capacity disclosed in 2024 and operating in 2026: update the node." | high | Two filings two years apart. | Accepted: two `HAS_CAPABILITY_STATE` episodes with different stages and valid times; earlier planned state is not overwritten. `targetOperationalDate` is a forward-looking assertion with no valid time of its own. |
| C9 | Ontological | "Listing on Amazon means Amazon sells it." Observed: "Sold by: TRU NIAGEN", "Ships from: Amazon". | high | Same listing, marketplace host, seller of record, fulfiller. | Accepted. `HOSTS_LISTING`, `SELLER_OF_RECORD_FOR`, `FULFILLS_OFFER` are separate; existing forbidden `[LISTS_OFFER, SELLS_PRODUCT]` extended with `[FULFILLS_OFFER, SELLS_PRODUCT]` and `[HOSTS_LISTING, SELLS_PRODUCT]` (V-326). |
| C10 | Linguistic | Amazon title "Nicotinamide Riboside 300mg" versus a label line that may read "Niagen (nicotinamide riboside chloride) 300 mg" (label not captured: unverified). | medium | Listing title amount versus label declaration. | Accepted. A listing title is a merchant assertion on the listing, not a `LabelDeclaration`; `amountReferent` is set only from a label snapshot. |
| C11 | Temporal | "One-time purchase $49.00" and "You pay $41.65 with coupon" observed on the same day. | medium | Two price observations. | Accepted. `priceKind` in {`ONE_TIME`, `SUBSCRIPTION`, `COUPON_ADJUSTED`, `LIST`, `PER_UNIT`}; not averaged. |
| C12 | Temporal | LDT status asserted in 2024 under the rule; rule vacated 2025-03-31. | medium | Status with `UNDER_LEGAL_BASIS` to the 2024 rule. | Accepted: `validTo` set to the vacatur date with `legalBasisCitation`; history kept (V-334). |
| C13 | Epistemic | "De Novo granted" read as "PMA approved." | medium | DEN200080 versus a PMA record. | Accepted. `statusKind: DE_NOVO_AUTHORIZATION` is not `APPROVAL`; forbidden `[DE_NOVO_AUTHORIZATION, PMA_APPROVAL]`. |

## Linguistic analysis

- Source wording: "has no questions at this time"; "has not, however, made its own determination"; "acknowledgement letter without objection ... does not constitute an ..."; "Every ingredient we make"; "authorized by the FDA for compounding"; "Sold by: TRU NIAGEN"; "Ships from: Amazon".
- Normalized propositions: see section C.
- Negation: "does not in any way denote approval" (807.39) yields a forbidden implication, not a negative fact about any product.
- Modality/hedging: "may continue to be within the scope of the interim enforcement policy" is conditional and revocable; status kind `ENFORCEMENT_DISCRETION`, never `APPROVAL`.
- Quantification: "Every ingredient" quantifies over an unstated set; it is not an inventory.
- Scope ambiguity: "make" may mean manufacture, commission, or brand; the adjudication records the ambiguity.
- Presuppositions not licensed as facts: "authorized" presupposes an authorization act; the agency source describes a policy.

## Confidence vector

| Dimension | Value/status | Method version | Evidence | Calibration set |
|---|---|---|---|---|
| Extraction | verbatim spans copied from captured snippets and extracts | manual-lane3-2026-10-03 | case packet | none |
| Resolution | issuers and submissions resolved by identifiers; seller display name unresolved | n/a | ResolutionHypothesis | none |
| Source reliability | agency records authoritative for their own actions; filings for disclosures; marketing for what is promoted | n/a | source registry | n/a |
| Evidence strength | not applicable | n/a | n/a | n/a |
| Applicability | not applicable | n/a | n/a | n/a |
| Adjudication | INSUFFICIENT (capability), PARTIALLY_SUPPORTED (503B characterization) | lane3-adjudication-2026-10-03 | fixture | none |
| Decision | none | n/a | n/a | n/a |

## Schema projection

- Projection request ID: `proj-req-0005-filing-vs-capability`
- Selected modules: `kernel`, `provenance`, `temporal`, `organizations`, `regulatory_and_ip`, `manufacturing_readiness`, `commerce`, `quality` (certification only), `labels` (amount referent)
- Closure additions: `Identifier`, `Facility`, `IngredientMaterial`, `ProductVariant`
- Explicit exclusions: patents; inspections (expansion)
- Budget result: not run
- Projection ID/digest: not generated

## Qualification evidence

| Gate | Artifact | Expected | Actual | Pass |
|---|---|---|---|---|
| Positive fixture | `examples/filing-vs-capability.cypher` | zero rows from validation section | statically checked only | not run |
| Negative fixture | commented "forbidden projection" statements in the same file | uncommenting returns rows from V-320, V-321, V-323, V-324, V-326 | statically checked only | not run |
| Minimal pair | filing disclosure versus promoted capability | different source kinds, one adjudication | encoded | not run |
| Temporal correction | NDI filing date reset by supplement | two recorded-time episodes on the submission's filing-date edge | described, not encoded | n/a |
| Identity collision | "TRU NIAGEN" seller account versus legal entity | ResolutionHypothesis | encoded | not run |
| Extraction evaluation | none | n/a | n/a | n/a |
| Retrieval evaluation | none | n/a | n/a | n/a |
| Migration compatibility | live `RegulatoryStatus`, `Listing`, `ManufacturingProcess` kept; additive fields | no removal | see live-schema decisions | n/a |

## Kernel-change request (for the coordinator)

- Request: allow `Assertion` to carry `derivationRule` and a structural `DERIVED_FROM_ASSERTION` edge to its input assertions, with `kind: CALCULATED`.
- Failing case: the NR cation mass (about 219.5 mg) calculated from "Nicotinamide Riboside Chloride 250 mg" must be stored so it is neither a label declaration (INV-006) nor a measured result, and must be regenerable if the molecular weight source changes. Today INV-004 permits `derivationRule` only on derived relationships, and the kernel `Assertion` has no input lineage, so the calculation either becomes an untraceable literal or a derived edge with no history.

## Decision

- Outcome (recommended): accept the regulatory split, the capability state model, the commerce role split, and the amount referent enum.
- Accepted semantic rules:
  1. A notification, a response, and a status are distinct records; only `statusKind: APPROVAL` is approval.
  2. Establishment or facility registration is a status of a facility, never of a product, and never approval or CGMP compliance.
  3. A capability stage is a state with valid time; promotion is source context; an operating state needs non-marketing support or a supporting adjudication.
  4. Company statements are Assertions attributed to the company; BellLabs conclusions are Adjudications; a company's characterization of an agency action is adjudicated against the agency record.
  5. A listing is not a sale; seller of record and fulfiller are offer-scoped roles observed at a time.
  6. A declared amount refers to the entity named on the label line per 21 CFR 101.36; active-moiety and nutrient-equivalent amounts are calculated.
- Rejected alternatives: one `RegulatoryStatus` node with string `statusCode` (fails C1 to C4); a `promoted` capability stage (fails C7); a `listRole` string on the live `LISTS` edge as the only role record (fails C9 for time and seller identity).
- Residual uncertainty: whether NRC is in 503B Category 1 (unverified); FDA response letters for NDI 882 and 1062 not fetched (company-reported only); the botanical extract declaration rules beyond 101.36(b)(3)(ii) (OPEN-QUESTIONS P1-4); non-US label rules.
- Required catalog/schema changes: `lanes/lane3/catalog-patch.yaml`; validation V-320 to V-335.
- Required ingestion changes: filing parsers emit Assertions attributed to the issuer with locators; agency parsers emit Submission/Response with verbatim conditions; listing scrapers emit Listing snapshot, Offer roles, PriceObservation with `priceKind`.
- Required retrieval/API/MCP changes: any answer containing "approved", "cleared", "registered", "certified" must name the status kind, jurisdiction, scope, and source; capability answers must name the stage, valid time, source kind, and adjudication.
- Changelog and migration references: live `Product.status = APPROVED`, `Product.approvedYear`, `Product.regulatoryAuthorizationId`, `Treatment.orphanDrugDesignation` become derived projections that must name the `RegulatoryStatus` they project (V-322).

### Unverified items

- FDA NDI 882 and NDI 1062 response letters (company-reported dates and doses only).
- Whether nicotinamide riboside chloride appears in FDA 503B Category 1 (the 10-K implies reliance on the interim list).
- Molecular weights for NR cation and NR chloride (PubChem unreachable).
- The Tru Niagen label text; Amazon observations are search-result snippets, not archived snapshots.
- The FDA NDIN guidance sentence ending "does not constitute an ..." was truncated in capture; the remainder is not quoted.
