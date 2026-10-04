# W13 CQ coverage matrix

The example answers are the rows actually returned by `fixtures/w13-cq-queries.cypher`. They were run on embedded Neo4j 5.26.31 Community in this session (see `06-fixtures-and-queries.md`).

## 1. Existing competency questions

### CQ-MF-02 (Essential now, A)

- **Example answer (Q-MF-02a):**
  - NRC: US NOTIFICATION_ON_FILE; GRN 000635; GRAS_NO_QUESTIONS 2016-08-03; scope "intended food uses at up to 0.0057% by weight; not dietary supplements"; not approval.
  - Stelo: CLEARANCE; K234070; SUBSTANTIALLY_EQUIVALENT 2024-03-05; code SAF.
  - Paige Prostate: DE_NOVO_AUTHORIZATION; DEN200080; 2021-09-21; QPN.
  - NR + pterostilbene: DESIGNATION; "Not FDA Approved for Orphan Indication".
  - REZDIFFRA: APPROVAL; NDA 217785; APPROVED 2024-03-14.
  - Synthetic LDT: ENFORCEMENT_DISCRETION (post-vacatur regime).
  - Synthetic plant: ESTABLISHMENT_REGISTRATION.
  - Tru Niagen 300: NOT_RECORDED.
- **Distinction:** submission vs response vs status; the nine status kinds; jurisdiction; time.
- **Evidence:** agency database records and letters (Drugs@FDA, 510(k), De Novo, OOPD, GRAS inventory and letter).
- **Elements:** `RegulatorySubmission`, `RegulatoryResponse.responseKind`, `RegulatoryStatus{statusKind, jurisdiction, scopeText, productCode, pcccAuthorized}`, `STATUS_OF` (AssertedEdgeProperties), `RESULTS_FROM_RESPONSE`, `SUBMISSION_HAS_RESPONSE`, `UNDER_LEGAL_BASIS`, `ISSUED_BY`, `RegulatorySubjectTarget`.
- **Query:** Q-MF-02a (status episode current at R and valid at V); QS-7 style NOT_RECORDED.
- **Prevents:** reading "FDA approved" off a notification, clearance, designation or registration; reading "not approved" off a missing record.

### CQ-MF-03 (Essential now, A)

- **Example answer (Q-MF-03):** the company wrote "FDA GRAS no objection … August 05, 2016; Dose: 180 mg/day". FDA wrote GRAS_NO_QUESTIONS on 2016-08-03 for food uses ≤0.0057% by weight, and "has not … made its own determination". Verdict PARTIALLY_SUPPORTED. 180 mg/day appears in the letter only as the notifier's estimated UL. For NDI 1062, the company's "no objection March 07, 2018" refers to a procedural filing letter; verdict INSUFFICIENT.
- **Distinction:** agency wording vs company characterization; response kind vs company wording; dates.
- **Evidence:** the FDA letter; the company page; the regulations.gov filing letter.
- **Elements:** `RegulatoryResponse.conditionsOfUseText`, `agencyDisclaimerText`, `decisionTextVerbatim`, `issuedAt`; kernel `Assertion{CHARACTERIZES_REGULATORY_RESPONSE}` + `Adjudication{SUPPORT}` + `SUPERSEDES{RE_REVIEW}`.
- **Query:** Q-MF-03; V-335.
- **Prevents:** repeating marketing paraphrase as the agency position; silently overwriting an earlier adjudication.

### CQ-MF-06 (Foundational, Q → A for the registration, claim and inspection parts)

- **Example answer (Q-MF-06):**
  - Synthetic plant: ESTABLISHMENT_REGISTRATION; a company cGMP claim (EXTRACTED); no inspection captured.
  - Nutratech: FDA inspection 2025-09-22..2025-10-15; Form 483 issued; finding 21 CFR 111.70(e); classification NOT_CAPTURED.
  - Anti L'Age: inspection end CONFLICTING (Oct 4 vs Oct 7).
  - None of the three is "CGMP compliant".
- **Distinction:** registration, cGMP claim, certification (W12), inspection and its outcome.
- **Evidence:** registration record; marketing page; warning letters; dashboard definitions.
- **Elements:** `RegulatoryStatus{ESTABLISHMENT_REGISTRATION}` on `Facility` only; `CLAIMS_CGMP_COMPLIANCE` assertion (kernel); candidate `RegulatoryInspection` + `INSPECTED_FACILITY` + `CONDUCTED_BY`; assertions `INSPECTION_PERIOD`, `INSPECTION_FOUND_VIOLATION`, `INSPECTION_CLASSIFIED_AS` (candidate predicates).
- **Query:** Q-MF-06; V-323, V-W13-11, V-W13-12.
- **Prevents:** "FDA-registered" or "cGMP-compliant" read as approval or compliance; "no record" read as "not inspected".

### CQ-AX-23 (Foundational, A)

- **Example answer (Q-AX-23-guard):** REZDIFFRA fdaApproved = true. Stelo, Paige Prostate and NRC = false (their standings listed). Tru Niagen = false, even after the negative fixture wrote an unbacked APPROVAL status and `Product.status = 'APPROVED'`.
- **Distinction:** approval vs every other kind; jurisdiction; an approving response is required.
- **Evidence:** agency record; 21 CFR 807.39/807.97 (inherited).
- **Elements:** `statusKind`, `RESULTS_FROM_RESPONSE`, `responseKind ∈ {APPROVED, PMA_APPROVED}`, `jurisdiction`.
- **Query:** Q-AX-23-guard; V-336, V-322r.
- **Prevents:** any link to a regulatory node read as approval.

### CQ-PF-03 (Essential now, A; regulatory attachment only)

- **Example answer (Q-MF-02a):** the registration attaches to the facility. The orphan designation attaches to the designated mixture, not to Basis. Clearance and De Novo attach to the device product, not to an AlgorithmVersion that the record does not name.
- **Distinction:** attachment grain (product, variant, material, mixture, assay version, facility).
- **Evidence:** agency record subject text.
- **Elements:** `RegulatorySubjectTarget` (adds `AssayVersion`, `MaterialMixture`).
- **Query:** V-323, V-W13-01.
- **Prevents:** a facility registration shown on a product; a designation shown on a consumer product.

### CQ-PF-04 (Foundational, Q)

- **Example answer (Q-PF-04):** GRN 000635 agency conditions: "as a source of vitamin B3 in vitamin waters … at a maximum level of 0.0057% by weight as consumed". The EU entry (pending file) reads "Food Supplements … 300 mg/day for the general adult population …".
- **Distinction:** agency conditions vs submitted conditions vs company restatement. Matching to a formulation is W10's.
- **Evidence:** letters; EUR-Lex.
- **Elements:** `RegulatoryResponse.conditionsOfUseText`, `RegulatorySubmission.conditionsOfUseText`.
- **Query:** Q-PF-04; V-331.
- **Prevents:** extending food-use conditions to a 300 mg capsule.

### CQ-TM-03 (Foundational, A)

- **Example answer (Q-TM-03):** GRN 000635:
  - notice dated 2016-03-08;
  - received 2016-03-09;
  - filed 2016-03-29;
  - response issued 2016-08-03;
  - status valid from 2016-08-03;
  - recorded 2026-10-04;
  - legal basis at filing: proposed 21 CFR 170.36 (1997).

  LDT: legal effect ended 2025-03-31; codified text until 2025-09-19.
- **Distinction:** the submittedAt, receivedAt, filingDate, issuedAt, valid time, recorded time, legal-effect and codified-text clocks.
- **Evidence:** letter; Federal Register.
- **Elements:** `receivedAt` (new), `filingDate`, `issuedAt`, `codifiedTextFrom/To` (new), episode valid and recorded time.
- **Query:** Q-TM-03, Q-MF-C02.
- **Prevents:** one `decisionDate` standing for five clocks.

## 2. Candidate CQs (marked candidate; not existing ids)

| Id | Question | Rationale and failing case | Elements it justifies | Query |
|---|---|---|---|---|
| `CQ-MF-C01` (candidate, Foundational) | Which agency inspections of facility F are recorded, over which period, with which Form 483 / warning-letter findings and which per-project-area classification, and what do they not establish? | CQ-MF-06 cannot reach inspection outcomes (OQ-L3-06). Failing case: CMS #698661 states two end dates for one inspection. As assertions only, nothing groups them into one event. As a status (`statusKind: 'INSPECTED_OAI'`), V-333, V-333r, V-W13-01, V-W13-02, V-W13-07 and V-W13-09 all fire (executed). | `RegulatoryInspection`, `INSPECTED_FACILITY`, `CONDUCTED_BY` (all CANDIDATE) | Q-MF-06 |
| `CQ-MF-C02` (candidate, Foundational) | Which legal basis governed program P at valid time V, as known at recorded time R, and which statuses depended on it? | OQ-L3-07. Failing cases: the LDT late vacatur and the GRAS 1997 proposal vs 2016 final rule (§4 of the recommendation). | `RegulatoryPathwayVersion`, `HAS_PATHWAY_VERSION`, `UNDER_LEGAL_BASIS_VERSION`, derived pathway fields | Q-MF-C02, Q-MF-C02b |
| `CQ-MF-C03` (candidate, Essential now) | What is the standing of subject X in each jurisdiction, with NOT_RECORDED kept distinct per jurisdiction? | NRC is US NOTIFICATION_ON_FILE, EU authorised novel food, GB-GBN authorised (England, Scotland, Wales). Northern Ireland is NOT_RECORDED. A single "UK" code is wrong. | `jurisdiction` convention (W13-SR-01), V-W13-10 | Q-MF-C03 |

## 3. Forbidden implications (12) → guard

| Catalog pair | Guard | Negative fixture |
|---|---|---|
| [HAS_ORPHAN_DESIGNATION, IS_APPROVED] | V-320a (ORPHAN_DESIGNATION_GRANTED → APPROVAL), V-336, V-321, V-W13-12 | N-04 (fires V-320a, V-336) |
| [NDI_NOTIFICATION_RECEIVED, FDA_APPROVED] | V-320a, V-320b (NDI_NOTIFICATION), V-W13-12; proposed NDI_FILING_ACKNOWLEDGED added to the V-320a list (W13-SR-06) | pending-values file (filing acknowledgment, INSUFFICIENT adjudication) |
| [PATENT_CLAIMS, PROVES_EFFICACY] | W14 (same module, not this package) | — (W13-SR-17) |
| [ESTABLISHMENT_REGISTERED, FDA_APPROVED] | V-320a (REGISTRATION_*), V-320b, V-323 | N-02 (V-323, V-333r) |
| [ESTABLISHMENT_REGISTERED, CGMP_COMPLIANT] | V-W13-12 | N-13 (neg-cgmp-from-registration) |
| [DEVICE_LISTED, FDA_CLEARED] | V-W13-12 pair (no listing status kind exists; listing is a Source fact) | — (no listing record; guard only) |
| [CLEARED_510K, FDA_APPROVED] | V-320a (SUBSTANTIALLY_EQUIVALENT), V-320b, V-336 | N-05 |
| [DE_NOVO_AUTHORIZATION, PMA_APPROVAL] | V-320a (DE_NOVO_GRANTED), V-W13-12 | N-06 |
| [GRAS_NO_QUESTIONS, FDA_APPROVED] | V-320a, V-320b, V-336 | N-03 |
| [GRAS_NO_QUESTIONS, FDA_GRAS_DETERMINATION] | V-W13-12; `agencyDisclaimerText` | N-13 (neg-gras-determination) |
| [ENFORCEMENT_DISCRETION, AUTHORIZATION] | V-320b (LDT_POLICY, COMPOUNDING_503B_BULKS_POLICY), V-W13-12 | N-13 (neg-ldt-authorized) |
| [CLAIMS_CGMP_COMPLIANCE, CGMP_COMPLIANT] | V-W13-12 | N-13 (neg-cgmp-from-claim) |

## 4. Every SDL element → CQ, invariant or ingestion failure

| SDL element | Mapping |
|---|---|
| `RegulatoryStatusKind` | CQ-MF-02, CQ-AX-23, INV-304, V-333r |
| `RegulatoryResponseKind` | CQ-MF-02/03, V-320a, V-336, V-W13-03 |
| `PathwayKind` | CQ-MF-02, V-320b, V-331, V-W13-04 |
| `RegulatorySubjectTarget` | CQ-PF-03, V-W13-01 |
| `RegulatoryAgency` (`agencyCode`, `jurisdiction`, `overseesPathways`) | CQ-MF-02 (who issued). `OVERSEES` is a live element kept for compatibility |
| `RegulatoryPathway` (`pathwayKind`, `jurisdiction`, `submissionCategory` (live verbatim), derived `legalBasisCitation`/`effectiveFrom`/`effectiveTo`, `versions`, `hasSteps`, `overseenBy`, `legacyFollowedBy`) | CQ-MF-02, CQ-MF-C02; legacy FOLLOWS_PATHWAY = live compatibility (V-W13-08) |
| `RegulatoryPathwayVersion` (all fields) | CQ-MF-C02, CQ-TM-03 (codified-text clock), V-334r, V-W13-05/06 |
| `RegulatoryStep` | live compatibility; CQ-MF-02 explanation (NDI 75-day wait). Ingestion failure prevented: steps read as events |
| `RegulatorySubmission` (`submissionKind`, `submissionSubtype`, `identifier`, `submittedAt`, `receivedAt`, `filingDate`, `conditionsOfUseText`, edges) | CQ-MF-02/03, CQ-TM-03, CQ-PF-04, V-W13-04, V-331 |
| `RegulatoryResponse` (`responseKind`, `decisionTextVerbatim`, `issuedAt`, `conditionsOfUseText`, `agencyDisclaimerText`, edges) | CQ-MF-03, CQ-PF-04, V-320a, V-336, V-W13-03/09 |
| `RegulatoryStatus` (`statusKind`, `jurisdiction`, `scopeText`, `productCode`, `pcccAuthorized`, `legalBasisCitation`, `statusCodeVerbatim`, edges incl. `legacyHeldBy`) | CQ-MF-02, CQ-AX-23, CQ-PF-03, INV-304, V-322r, V-323, V-333r, V-334r, V-336; `statusCodeVerbatim` = live migration |
| `OrphanDesignation` (`designationId`, `indication`, `designatedNameVerbatim`, `designationFor`) | CQ-MF-02, CQ-AX-23, V-321 |
| `DrugApproval` (`applicationNumber`, `indication`, `approvalFor`) | CQ-MF-02, CQ-AX-23, V-321, V-336 |
| `RegulatoryInspection` (CANDIDATE) | CQ-MF-C01, CQ-MF-06, V-W13-11 |

No owned element is unmapped.
