# W12 Quality testing and certification: domain recommendation

Run `run-2026-10-04-fable51-01`, worker W12 (Opus 5.5). Canonical module: `quality` (catalog 0.2.0, digest `8fb50ff0…84f0`, provisional). Sole writer for the 13 node types, the union `CertificationCoverageTarget`, the quality relationship types and the enums in `sdl-fragment.graphql`. Specification payload is W11's `SpecificationVersion` (D-009, CL-010); laboratory identity is a specialization of W01's `Organization`.

## 1. Boundary and subdomains

The quality domain answers one family of questions: *what was tested, on which physical lot, by whom, how, with what outcome, against which limit, reported in which document, and what a certifier's listing actually covers*. It has five subdomains.

| Subdomain | Types (W12) | Question it serves | Hard boundary |
|---|---|---|---|
| Lot identity | `ProductLot` | Which batch is this unit from; lot code, manufacture and expiry dates | Not a package, inventory item, unit or certification. Expired is computed at query time; recall and counterfeit are W13/W15 (section 6). |
| Analytical chain | `TestSample`, `TestExecution`, `TestMethod`, `TestingLaboratory`, `MeasuredResult` | What was measured, by which method and lab, with what value, uncertainty and limits | Not a diagnostics `AssayVersion` or clinical result (W07); not an instrument (W08); not a label declaration (W04, INV-006, V-011). |
| Specification and conformity | `SpecificationCriterion`, `PassFailInterpretation` | Against which limit (release, shelf-life, in-house, pharmacopeial) a lot or result was judged, under which decision rule | The specification version itself is W11's; a label claim is never a criterion. A verdict is never a value. |
| Test documents | `CertificateOfAnalysis`, `LotTestSummary` | Is this document a COA or a summary, and what does it certify | A COA is not a certification and not evidence of independence; a summary is never promoted to a COA. |
| Certification | `CertificationProgram`, `CertificationListing`, `CertificationScope`, `CertificationCoverageTarget`, derived `CERTIFIED_UNDER` | What a certifier's listing covers (facility, product, variant, lot, trade item, laboratory) as observed when | Not a regulatory status (INV-010, W13); facility certification never covers products or lots; certifier identity is W01. |

Out of scope (owner): `Facility`, `Organization`, role predicates (`AFFILIATED_WITH`, `OPERATES_CERTIFICATION_PROGRAM`, `CLAIMS_CGMP_COMPLIANCE`, `OWNS_SPECIFICATION`) W01; `SpecificationVersion`, `ManufacturingSpecification`, processes W11; label snapshots, declarations and `QuantityDeclaration` W04; registration, inspections and recall actions W13; inventory, units, counterfeit sellers W15; recall and safety events W18/W17; the private record of which lot a person bought W23 (external contract; only the lot uid crosses into a shared query).

## 2. Baseline names and dispositions

The live schema (`current_biotech_schema.graphql`) has no quality type. Every catalog element is written in full for the first time; live fields that carry quality meaning are seams owned elsewhere. Complete old-to-new list: `migration-map.yaml`.

### Catalog nodes (module `quality`)

| Catalog element | Archetype | Disposition | Change and reason |
|---|---|---|---|
| `ProductLot` {lotCode, manufactureDate, expiryDate} | Entity | **refine** | + per-date `…Precision` (Elysium prints "Exp. 12/2027"), `dateTextVerbatim`. Identity = (issuer, variant, lot code), never the code alone (R110-01 vs R1110-01). |
| `TestSample` {sampleCode, sampledAt, samplingMethod} | Entity | **keep** (+ `sampledAtPrecision`) | Needed so a surveillance purchase of a unit with unknown lot is recordable without attaching to any lot. |
| `TestExecution` {executedAt, status} | Occurrence | **refine** | + `executedAtPrecision`, `testNameVerbatim`, `testPurpose`, `accreditationScopeStatus`, `subcontracted`, `performerStatementVerbatim`; `status` becomes enum. Real COA rows are subcontracted to unnamed labs or outside the accreditation scope. |
| `TestMethod` {name, methodIdentifier, methodVersion} | Entity | **refine** (+ `techniqueVerbatim`) | A technique name ("HPLC") is a weak identity; compendial ids ("USP <2022>") are strong. |
| `TestingLaboratory` {name, accreditation} | Entity, parent `Organization` | **keep, narrowed** | `accreditation` = the lab's verbatim self-statement only; verified accreditation is a `CertificationListing` covering the lab. Labels `["TestingLaboratory","Organization","Entity"]`, token `org`. |
| `MeasuredResult` {analyte, value, unitCode, uncertainty, limitOfDetection, qualifier} | InformationArtifact | **refine** | + `analyteUid`, `valueTextVerbatim`, `uncertaintyKind`, `coverageFactor`, `limitOfQuantitation`, `reportingLimit(Text)`, `sampleQuantity(UnitCode)`, `quantityBasis`, `massBasis`, `amountReferent`; `qualifier` becomes the closed `ResultQualifier` enum (INV-007). |
| `SpecificationCriterion` {analyte, comparator, threshold, unitCode} | VersionedState | **refine** | + `upperThreshold`, `targetValue`, `criterionText`, `criterionPurpose`, `criterionBasis`, sample quantity, basis triple. Closes OPEN-QUESTIONS P2 quality 2 (section 4). |
| `PassFailInterpretation` {verdict, rationale} | EvidenceAssessment | **refine** | + `verdictBasis` (SOURCE_STATED vs EVALUATED_FROM_RESULT), `verdictTextVerbatim`, `resultValueReported`, `decisionRule`, `basisAssertionUid`. Lets "conforms" be recorded without inventing a value. |
| `LotTestSummary` {title, observedAt} | InformationArtifact | **refine** (+ `lotCodeVerbatim`, `attributionStatementVerbatim`) | Elysium lot page is the reference case. |
| `CertificateOfAnalysis` {certificateNumber, signedAt, signer} | InformationArtifact | **refine** | + `revisionNumber`, `reportDate(Precision)`, `documentTitleVerbatim`, `signatureEvidence` (enum). One node per report revision. Classification rule in section 3. |
| `CertificationProgram` {name, standard} | Entity | **refine** (+ `certifiedObjectKind`) | Separates FACILITY (455-2), PRODUCT (173), LOT (306), INGREDIENT (173DI) and LABORATORY (17025) programmes; V-W12-06. |
| `CertificationListing` {listingId, status, effectiveFrom, effectiveTo} | VersionedState | **refine** (+ `listingCurrentAsOf`, `listedOrganizationText`; status enum) | NSF pages state "current as of …"; absence in a later capture is not withdrawal. |
| `CertificationScope` {scopeText} | VersionedState | **refine** (+ `coveredIdentifierValues`, `facilityQualifierText`, form, serving, country) | Printed values are preserved even when unresolved; a facility grouping is a qualifier, never a covered Facility. |

### Catalog relationships

| Relationship | Class | Disposition |
|---|---|---|
| `LOT_OF` ProductLot→ProductVariant | asserted | keep; cardinality exactly_one |
| `MANUFACTURED_UNDER` ProductLot→FormulationVersion\|SpecificationVersion | asserted | keep (two GraphQL fields) |
| `SAMPLE_FROM` TestSample→ProductLot\|IndividualUnit\|IngredientMaterial | asserted | keep; exactly one target (V-W12-08) |
| `TESTED_SAMPLE` | structural | keep; exactly_one |
| `USED_METHOD`, `PERFORMED_BY_LAB` | asserted | keep; zero_or_one (absent = not stated) |
| `PRODUCED_RESULT` | structural | keep; each result exactly one producer (V-W12-03) |
| `EVALUATED_AGAINST` MeasuredResult→SpecificationCriterion | asserted | keep (the criterion printed beside the result) |
| `INTERPRETS_RESULT` | structural | keep; zero for a not-reported source verdict, exactly one when evaluated |
| `SUMMARIZES_TESTING`, `CERTIFIES_RESULTS_FOR` | asserted | keep (two fields each) |
| `PROGRAM_HAS_LISTING` | structural | keep |
| `HAS_CERTIFICATION_SCOPE` | structural, **bitemporal attachment** | refine: `StateEpisodeProperties` so scope changes are recorded episodes |
| `COVERS` CertificationScope→CertificationCoverageTarget | asserted | refine: range + `TestingLaboratory` |
| `CERTIFIED_UNDER` Product\|ProductVariant\|ProductLot→CertificationListing | derived (`w12-certified-under/v1`) | keep; only from direct COVERS (V-332, V-W12-07); Product/Variant fields requested from W04 |

### Proposed additions (each with a failing case in `fixtures/`)

| Element | Failing case without it |
|---|---|
| `APPLIES_CRITERION` PassFailInterpretation→SpecificationCriterion (structural) | Elysium "Conforms to internal specs" per row: with no result to hang `EVALUATED_AGAINST` on, the verdict loses its criterion. |
| `INTERPRETS_TESTING_OF` PassFailInterpretation→ProductLot\|TestExecution (structural) | Same rows: the verdict has no subject; the lead "Pass" on the real COA needs its execution. |
| `CRITERION_OF_SPECIFICATION` SpecificationCriterion→SpecificationVersion (structural) | Architecture section 8 draws `SpecificationCriterion -> SpecificationVersion` but the catalog names no relationship (CL-010). |
| `COA_ISSUED_BY` CertificateOfAnalysis→TestingLaboratory\|Organization (asserted) | Real COA: the issuer (ChromaDex Analytics) is not the performer of the subcontracted rows; issuer cannot be read from `PERFORMED_BY_LAB`. |
| `CertificationCoverageTarget` + `TestingLaboratory` | Lab accreditation (ISO/IEC 17025) is a listing that covers a laboratory; needed for the CQ-AX-19 competence context. |
| 13 enums (`ResultQualifier` … `CertifiedObjectKind`) | The catalog defines no quality enum; each value is used by a fixture (04-model-cards.md). |
| Predicate `CONFORMS_TO_SPECIFICATION` (assertion only, no edge) | The sourced pass/fail assertion of architecture section 8 needs a registered predicate (W12-SR-04). |

## 3. COA versus test summary (OPEN-QUESTIONS P2 quality 1): proposed closure

Evidence: one real COA (Tru Niagen sample COA, lot T25189001, report CDXA-RSS-11207-00, issued by ChromaDex Analytics, an affiliate of the brand owner), one real lot summary (Elysium Basis lot P098-01 page), and WHO TRS 957 Annex 1 §19.1, which lists the usual COA contents (lab name, batch number, specification reference, results with limits, conclusion, completion date, signature).

Rule (validator V-W12-01): an artifact is a `CertificateOfAnalysis` only if it has (a) exactly one issuer (`COA_ISSUED_BY`), (b) a named lot (directly or through certified executions' samples), (c) at least one certified `TestExecution`, each with `USED_METHOD` and a judged outcome (a `MeasuredResult` `EVALUATED_AGAINST` a criterion or a `PassFailInterpretation` `APPLIES_CRITERION`), (d) a report number or report date, and (e) a recorded `signatureEvidence` state. Otherwise it is a `LotTestSummary` (or plain assertions). Not required: the title (the title is kept verbatim but is never sufficient), a signature visible in the capture (the real COA's text extraction shows none; WHO says "usually contains"; `NOT_CAPTURED` is never read as unsigned), or every row having a value (the real COA reports one value and ten "Pass" rows). Independence is a separate question answered from W01 affiliation, not from document kind.

| Element | Tru Niagen COA (real) | Elysium lot page (real) | Lab Z COA (synthetic) |
|---|---|---|---|
| Lot named | T25189001 | P098-01 | P098-01 |
| Issuer | ChromaDex Analytics, Inc. (affiliate of Niagen Bioscience) | none ("third-party testing lab") | Lab Z |
| Methods per row | yes (HPLC, USP 2091, USP 61/2021/2022, ICP-MS, NSF 306, Visual) | no | yes |
| Values | 1 of 11 rows (555 mg/capsule); the others "Pass" | none ("Conforms to internal specs") | yes, with expanded uncertainty |
| Report number / date | CDXA-RSS-11207-00 / 03Sep2025 | none | LZ-2026-0412-00 / 2026-04-20 |
| Signature | NOT_CAPTURED (text extraction) | n/a | SIGNATURE_PRESENT |
| Classification | COA | LotTestSummary | COA |

## 4. Target, release, shelf-life and uncertainty (OPEN-QUESTIONS P2 quality 2): proposed closure

ICH Q6A §2.2 (captured): release and shelf-life acceptance criteria may differ (tighter release, mainly for assay and degradants); in the US and Japan regulatory criteria are the same throughout shelf-life and tighter release limits are in-house; the EU requires distinct release and shelf-life specifications where different. 21 CFR 111.70(e) requires dietary-supplement specifications for identity, purity, strength, composition and contaminant limits of the finished batch. WHO TRS 957 §18.9: compendial limits already account for measurement uncertainty and compliance testing does not require stating expanded uncertainty.

Model: one `SpecificationCriterion` per limit and period, `criterionPurpose` ∈ {RELEASE, SHELF_LIFE, RELEASE_AND_SHELF_LIFE, NOT_STATED}, `criterionBasis` ∈ {INTERNAL, PHARMACOPEIAL, REGULATORY, CERTIFICATION_PROGRAM, NOT_STATED}, optional `targetValue` (a stated nominal, for example "828 mg/capsule ±10%"). A label claim is never a criterion (W04 `QuantityDeclaration`; INV-006). Measurement uncertainty lives on `MeasuredResult` (`uncertainty`, `uncertaintyKind`, `coverageFactor`; null = not reported, never zero). How uncertainty is applied to a verdict lives on `PassFailInterpretation.decisionRule` with a `methodVersion` (fixture: the same 258 ± 9 mg result is CONFORMS under simple acceptance and INDETERMINATE under an expanded-uncertainty guard band; both stand). A stability result judged against a release-only limit is rejected (V-W12-11).

## 5. NSF listing semantics (CQ-PF-03): finding that corrects round 0005

Captured 2026-10-04: info.nsf.org (Elysium, Standard 306, "current as of Saturday, October 3, 2026 at 12:15 a.m. Eastern Time") lists Basis rows by facility grouping (`# 1 USA`, `Salisbury, MD`, `Chester, NY`, `Windsor, Ontario, Canada`) with a "Product ID" column. The nsfsport.com listing detail for the same rows (id 1786167, 1463170) labels the same values **"Lot #"**, and Elysium's own lot page lists the same codes as lots (P098-01, 70579, 70918, 70064, R173-01 …). NSF's get-certified page says "Lots tested will be listed online". So the 306 listing's scope is **lot-level**: `CertificationScope COVERS ProductLot`. Round 0005 read these values as product IDs (`TradeItemIdentifier`); `TradeItemIdentifier` stays in the union for programmes that certify by UPC/GTIN, but the NSF 306 case is lots. Consequences: (1) "Basis is NSF Certified for Sport" (the brand page) never derives `CERTIFIED_UNDER` to the product or variant (V-332, negative N03); (2) a lot not printed in the scope (R110-01 on Elysium's page vs "R1110-01" printed by NSF; 70969 printed by NSF but absent from Elysium's page) is resolved by a `ResolutionHypothesis`, never by string similarity; (3) the facility grouping is `facilityQualifierText`, never a covered `Facility` (V-W12-06); (4) the two NSF renditions disagree on Windsor serving size ("1 capsule" vs "2 capsules"): scope text is kept per source.

## 6. Recalled, expired, counterfeit and gray-market inventory (OPEN-QUESTIONS P2 quality 5): boundary

W12 owns lot identity and lot facts (codes, dates, tests, certification coverage). It does not own: inventory and unit states, seller authorization or counterfeit suspicion (W15: `InventoryItem`, `IndividualUnit`, `UNIT_FROM_LOT`, offer and seller roles); recall actions and agency notices (W13 regulatory records; W18 `RECALL_EVENT`). Rules W12 imposes on that seam: "expired" is computed from `ProductLot.expiryDate` and its precision at query time and never stored; a counterfeit unit bearing a real lot code is a unit whose `UNIT_FROM_LOT` assertion is contradicted or absent, never a property of the lot (the Niagen survey names "outdated and out-of-market lot numbers" on counterfeits); a recall is linked to the lots it names through a W13/W18 record, not by flagging the lot. Seam request W12-SR-06.

## 7. Identity, state, artifact, occurrence

| Archetype | W12 types | Why |
|---|---|---|
| Entity | ProductLot, TestSample, TestMethod, TestingLaboratory, CertificationProgram | Enduring identities referenced by many records |
| Occurrence | TestExecution | Happened once (possibly at unknown time) |
| InformationArtifact | MeasuredResult, LotTestSummary, CertificateOfAnalysis | What a source reported; immutable; corrected by a new artifact on a revised snapshot |
| VersionedState | SpecificationCriterion, CertificationListing, CertificationScope | Time-bounded payloads that change by replacement |
| EvidenceAssessment | PassFailInterpretation | A verdict with method and decision rule; superseded, never edited |

## 8. Alternatives considered (rejected)

1. **COA as a `SourceSnapshot` specialization** (the `LabelSnapshot` pattern). Rejected: the same report fetched twice is two snapshots but one certificate; revision 01 must be a new artifact, not a new capture of revision 00.
2. **"Pass" as a `MeasuredResult` with qualifier PASS.** Rejected: it creates a value-shaped record from a verdict, exactly the failure architecture section 8 forbids; V-W12-05/V-W12-12 would be unenforceable.
3. **Pass/fail only as an `Assertion`.** Rejected as the only record: verdicts need per-criterion typed queries, decision rules and supersession; the assertion is kept as the provenance of a SOURCE_STATED interpretation.
4. **Release and shelf-life limits as two properties of one criterion.** Rejected: a criterion has one comparator and limit; real specifications list them as separate lines with different purposes.
5. **Scope as a list property on the listing.** Rejected: scopes change over time (synthetic late capture adds P120-01) and coverage needs typed, assertion-backed edges.
6. **Independence flag on `TestingLaboratory`.** Rejected: independence is relative to a brand owner and time; it is read from W01 affiliation assertions.
7. **Inheriting lot certification to the product or variant.** Rejected (round 0005 C6; V-332).

## 9. Smallest recommended model

The 13 catalog nodes (no new node type), the catalog relationships plus four structural/asserted edges named in section 2, one union with one new member, 13 small closed enums, and no change to the kernel. Two kernel-adjacent requests go to W00: admit `MeasuredResult`, `LotTestSummary`, `CertificateOfAnalysis` to the `SUPPORTED_BY` domain (W12-SR-02) and register `CONFORMS_TO_SPECIFICATION` (W12-SR-04). Everything else (inspection occurrences, `LOT_PRODUCED_AT` facility edge, `IngredientMaterial`/`AssayVersion` coverage, a label-conformity assessment) stays CANDIDATE.
