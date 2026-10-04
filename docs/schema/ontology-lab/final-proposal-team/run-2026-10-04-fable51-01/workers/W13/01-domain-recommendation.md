# W13 Regulation and jurisdictions: domain recommendation

Worker W13 (Opus 5.5), run `run-2026-10-04-fable51-01`, catalog 0.2.0 (`8fb50ff0…84f0`), live schema `86b5e0b5…f112`. Canonical module: `regulatory_and_ip` (the regulatory half; patents and trademarks are W14's).

## 1. Boundary and subdomains

The domain covers the regulatory standing of things, by jurisdiction and over time. It has five parts. Each part is a different kind of record:

| Subdomain | What it records | Archetype | Types |
|---|---|---|---|
| Programs and legal basis | which program exists in which jurisdiction, and which legal instrument governed it at a given time | Entity + VersionedState | `RegulatoryAgency`, `RegulatoryPathway`, `RegulatoryPathwayVersion` (new), `RegulatoryStep` |
| Filings | what a firm filed (notice, notification, 510(k), De Novo request, NDA, designation request) | InformationArtifact | `RegulatorySubmission` |
| Agency answers | what the agency said, in its own words, with its own disclaimers | InformationArtifact | `RegulatoryResponse` |
| Standing | a bounded, jurisdiction-specific status of exactly one subject | VersionedState | `RegulatoryStatus`, specialization labels `OrphanDesignation`, `DrugApproval` |
| Agency oversight events | an inspection of a facility over an interval (candidate) | Occurrence | `RegulatoryInspection` (CANDIDATE) |

The following are **outside** this domain and are only referenced:

- Who the firm is: W01 (`Organization`, `Facility`).
- What the subject is: W02 (`IngredientMaterial`, `MaterialMixture`), W04 (`Product`, `ProductVariant`), W07 (`AssayVersion`, `AlgorithmVersion`), W09 (`StudyIntervention`).
- Certification programs and scope: W12.
- Whether a response's conditions of use cover a given formulation (CQ-PF-04 matching): W10, as an applicability assessment.
- Patent claims: W14.
- Company statements about agency actions are kernel `Assertion`s (W00) with the catalog predicates `CHARACTERIZES_REGULATORY_RESPONSE` and `CHARACTERIZES_REGULATORY_STATUS`. This domain owns only the agency side they are compared with.

Rule for the whole domain (INV-010, INV-304): the following are different records and none implies another:

- a notification and its response;
- a designation;
- a registration;
- a clearance;
- a De Novo authorization;
- enforcement discretion;
- an approval.

Only `statusKind: APPROVAL` is approval, and it needs an approving response. A marketed product with no status is not approved. The absence of a status node means NOT_RECORDED, never "not approved".

## 2. Dispositions for every element in scope

Live = `current_biotech_schema.graphql` lines 1546–1595 plus the regulatory fields on other live types. Cat = catalog 0.2.0 module `regulatory_and_ip` and `conventions`.

| Element | Origin | Disposition | Final element | Reason (failing case or CQ) |
|---|---|---|---|---|
| `RegulatoryAgency` | live + cat | **refine** | `RegulatoryAgency` `["RegulatoryAgency","Organization","Entity"]`, token `org` | One organization identity per agency. Live `overseesPathways` is kept with structural edge properties. CQ-MF-02 |
| `RegulatoryAgency.agencyCode`, `jurisdiction` | live/cat | keep | same | |
| `OVERSEES` (RoleMetadata) | live | **refine** | `OVERSEES` structural, `StructuralEdgeProperties` | The role fields have no meaning on agency→program |
| `RegulatoryPathway` | live + cat | **refine** | `RegulatoryPathway` (Entity), `pathwayKind: PathwayKind!`, `jurisdiction` | Stable program identity. CQ-MF-02 |
| `RegulatoryPathway.pathwayKind` (String) | live | refine to enum | `PathwayKind` | Free text blocks V-320b and V-331 |
| `RegulatoryPathway.submissionCategory` | live | keep (verbatim) | same | No CQ filters on it |
| `RegulatoryPathway.jurisdictionCode` | live | merge | `jurisdiction` | Same meaning |
| `RegulatoryPathway.legalBasisCitation`, `effectiveFrom`, `effectiveTo` | cat | **derive** (read-only) | the same names, projected from version episodes | The LDT and GRAS failing cases (§4) |
| — | new | **add** | `RegulatoryPathwayVersion` + `HAS_PATHWAY_VERSION` + `UNDER_LEGAL_BASIS_VERSION` | Closes OPEN-QUESTIONS diagnostics item 4 (OQ-L3-07). Decision W13-D02 |
| `RegulatoryStep` (+`stepKind`, `milestoneCode`) | live + cat | keep | same | A template step, not an event |
| `HAS_REGULATORY_STEP` (OrderingMetadata) | live + cat | refine | structural, `StructuralEdgeProperties.orderIndex` | Only `orderIndex` has meaning here |
| `RegulatorySubmission` | cat | keep and refine | `submissionKind: PathwayKind!`, `submissionSubtype`, `receivedAt` added | GRN 000635 has three filing clocks (dated, received, filed). K234070 "Date Received". CQ-TM-03 |
| `RegulatoryResponse` | cat | keep and refine | `responseKind!`, `decisionTextVerbatim` added | Agency wording is kept beside the closed kind (SESE, DENG, "FDA has no questions") |
| `RegulatoryResponse.agencyDisclaimerText` | cat | keep | verbatim, all disclaimer sentences in letter order | GRN 000635 has three disclaimers, not one (§5) |
| `RegulatoryStatus` | live + cat | **split** (as the catalog decided) **and refine** | `RegulatoryStatus` (VersionedState) | The live node mixed submission, response and status |
| `RegulatoryStatus.statusCode` | live | seam → keep verbatim | `statusCodeVerbatim`; filters use `statusKind` | |
| `RegulatoryStatus.applicationNumber` | live | move | `RegulatorySubmission.identifier` + `Identifier`; also `DrugApproval.applicationNumber` (verbatim) | The number belongs to the filing |
| `RegulatoryStatus.decisionDate` | live | move | `RegulatoryResponse.issuedAt` | The date belongs to the answer |
| `RegulatoryStatus.effectiveDate`, `expirationOrRenewalDate` | live | merge | `effectiveFrom`, `effectiveTo` (payload). Query validity comes from the `STATUS_OF` episode | Kernel time names |
| `RegulatoryStatus.jurisdictionCode` | live | merge | `jurisdiction` (required) | V-333 |
| `RegulatoryStatus.issuedBy` / `ISSUED_BY` (RoleMetadata) | live | keep, drop RoleMetadata | `ISSUED_BY` structural | |
| `OrphanDesignation`, `DrugApproval` | cat | keep as **specialization labels** | `["OrphanDesignation","RegulatoryStatus","VersionedState"]`, `["DrugApproval","RegulatoryStatus","VersionedState"]` | V-321. The library build reads both through `regulatoryStatuses` (verified) |
| `DESIGNATION_FOR`, `APPROVAL_FOR` | cat | **merge** into `STATUS_OF` | GraphQL field names `designationFor` / `approvalFor` over the stored `STATUS_OF` | One fact, one relationship type (W13-D05) |
| `STATUS_OF` | cat | keep and refine range | union `RegulatorySubjectTarget` adds `AssayVersion` and `MaterialMixture` | LDT subject (W13-D06). Orphan combination (W13-D07) |
| `UNDER_PATHWAY`, `SUBMITTED_BY`, `SUBMISSION_ABOUT`, `SUPERSEDES_SUBMISSION`, `SUBMISSION_HAS_RESPONSE`, `RESULTS_FROM_RESPONSE`, `UNDER_LEGAL_BASIS` | cat | keep | same class and cardinality as the catalog | CQ-MF-02/03 |
| `Product.hasRegulatoryStatuses` / `HAS_REGULATORY_STATUS` | live | **derive** (read-only legacy) | `DerivedEdgeProperties`, rule W13-DR-01 | Seam to W04 (W13-SR-08) |
| `Product.followsRegulatoryPathways` / `FOLLOWS_PATHWAY` | live | **derive** (read-only legacy) | rule W13-DR-02 from `SUBMISSION_ABOUT` | Seam to W04 |
| `Product.status = APPROVED`, `approvedYear` | live (W04) | derive, guarded | V-322r; `approvedYear` = YEAR of the APPROVAL `STATUS_OF` validFrom | W13-SR-08 |
| `Product.regulatoryAuthorizationId`, `primaryRegulatoryIdentifier`; `ProductSnapshot` copies | live (W04) | derive | projection of `Identifier` on the submission | W13-SR-08 |
| `Treatment.orphanDrugDesignation` | live (W06) | derive | projection of an `OrphanDesignation`, never approval | W13-SR-09 |
| `PhysicalLocation.establishmentIdentifier` | live (W01) | move | `Identifier` + `RegulatoryStatus{ESTABLISHMENT_REGISTRATION}` on `Facility` | W13-SR-10 |
| `Material.regulatoryCategoryHint` | live (W02/W11) | seam | `RegulatoryStatus` when sourced; otherwise kept as a hint | W13-SR-11 |
| `OrganizationType.REGULATORY_AGENCY` | live (W01) | keep | the `organizationKind` value on agency nodes | |
| `EvidenceSubject` / `ClaimSubject` / `MediaSubject` members `RegulatoryPathway`, `RegulatoryStep`, `RegulatoryStatus`, `RegulatoryAgency` | live (W21/W22 unions) | keep members | — | The union owners decide. W13 types stay `@node` |
| `regulatoryStatusKind` (9 values) | cat | keep (frozen) | `RegulatoryStatusKind` | Additions only through W13-SR-03 |
| `regulatoryResponseKind` (per pathway, 22 values) | cat | keep (frozen) | `RegulatoryResponseKind`; per-pathway closure enforced by V-W13-03 | NDI filing acknowledgment proposed (W13-SR-06) |
| PathwayKind (round 0005 list, 12 values) | round 0005 / V-320b | keep | `PathwayKind` | EU and GB novel food proposed (W13-SR-03) |
| `RegulatoryInspection` | handoff "E" | **candidate in the fragment** | Occurrence, `INSPECTED_FACILITY`, `CONDUCTED_BY` | CQ-MF-C01 plus the failing case in `fixtures/w13-inspection.cypher` |
| Forbidden implications (12) | cat | keep verbatim | V-320a/b, V-321, V-323, V-336, V-W13-12 | Mapping in `02-cq-coverage.md` §3 |

## 3. Identity, state, artifact, occurrence

- **Identity (Entity).** An agency, a program and a template step.
  - "FDA GRAS notification program" stays one identity across the 1997 proposal and the 2016 final rule.
  - "FDA oversight of LDTs" stays one identity across the general enforcement-discretion approach, the 2024 rule and the post-vacatur text.
- **State (VersionedState).**
  - A legal-basis regime of a program (`RegulatoryPathwayVersion`).
  - A standing of a subject (`RegulatoryStatus`).
  - Payloads are immutable (payloadHash). When the state held is carried by the attachment episode: `HAS_PATHWAY_VERSION` uses the StateEpisodeProperties profile; `STATUS_OF` is an asserted edge.
- **Artifact (InformationArtifact).** A filing and an agency answer. Neither changes after it is issued. A later letter is a new response. A reset NDI filing date is a superseding assertion, projected to `filingDate`.
- **Occurrence.** An inspection (candidate). It happened over days at one facility. Letters and dashboard rows describe it and may disagree.

## 4. Alternatives considered for pathway versioning (OQ-L3-07)

Sources: 89 FR 37286 ("This rule is effective July 5, 2024"); FR Doc. 2025-18239 ("On March 31, 2025, a federal district court vacated that rule … This rule is effective September 19, 2025"); 81 FR 54960 ("This rule is effective October 17, 2016"); the GRN 000635 letter ("in accordance with … proposed 21 CFR 170.36 (62 FR 18938; April 17, 1997)").

| Alternative | Failing case | Verdict |
|---|---|---|
| A. Catalog 0.2.0: `effectiveFrom`/`effectiveTo`/`legalBasisCitation` as plain properties on `RegulatoryPathway` | (1) Late fact. On 2025-02-01 the LDT program was "in force, end unknown". The vacatur was ingested on 2025-04-02 and overwrote `effectiveTo`. A query "as known on 2025-02-01" then returns 2025-03-31, which is backdated knowledge (INV-502, CQ-TM-03). (2) Two clocks. Legal effect ended 2025-03-31, but the CFR text was not reverted until 2025-09-19, and one `effectiveTo` cannot hold both. (3) The program continues after the vacatur, so one bound either ends the program (wrong) or never ends the 2024 regime (wrong). (4) GRN 000635 was answered under the 1997 proposal. The inherited fixture `examples/filing-vs-capability.cypher` gives its pathway `legalBasisCitation: '21 CFR Part 170 Subpart E'`, a regime that took effect 2016-10-17, after the letter. The current-value property misattributes every historical response. | rejected |
| B. One `RegulatoryPathway` node per regime | A query for "all 510(k) clearances" or "every GRAS notice" must union across regime nodes. Submissions would re-point `UNDER_PATHWAY` at each rule change. Program identity is lost. | rejected |
| C. **Program Entity + legal-basis VersionedState attached by bitemporal episodes** (`HAS_PATHWAY_VERSION`). A status or submission optionally points `UNDER_LEGAL_BASIS_VERSION` at the regime it depends on or was filed under. | All four cases pass. In fixture Q-MF-C02, "known as of 2025-02-01" returns the 2024 rule with an open end, and "known as of 2026-10-04" returns the post-vacatur regime. V-334r ends dependent statuses at the vacatur. The GRAS submission cites the 1997 proposal. | **recommended** |

C adds one node type and two relationship types. That is the smallest model that keeps recorded-time history. The pathway's catalog fields survive as read-only projections, so the catalog and live names still resolve.

One semantic rule was learned while running the fixtures (W13-D03). On a **status**, `UNDER_LEGAL_BASIS_VERSION` means the status subsists only under that regime, and V-334r enforces it. On a **submission**, it records the regime the filing was made under.

The first fixture run linked the GRN 000635 status to the 1997 regime, and V-334r correctly flagged it, because no source says that "no questions" letters lapsed on 2016-10-17. The status therefore carries no version link. The filing regime is recorded on the submission.

## 5. What the evidence changed

- **GRN 000635.** The full letter was captured in this session. The round-0005 adjudication rationale ("the 180 mg/day figure is not in the captured FDA text") was based on a truncated capture and is corrected. The letter contains "180 mg/day", but only as ChromaDex's estimated upper tolerable intake level (3 mg/kg bw/day × 60 kg), not as an FDA condition of use. The letter is dated **August 3, 2016**; the company page says "August 05, 2016". The fixture records a superseding SUPPORT adjudication (`RE_REVIEW`, verdict still PARTIALLY_SUPPORTED) with the corrected rationale.
- **GRN 000635 disclaimers.** The letter has three agency disclaimers:
  - "has not, however, made its own determination";
  - the section 301(ll) disclaimer;
  - "neither consulted with ONFL … nor evaluated … claims".

  `agencyDisclaimerText` holds all three verbatim. The disclaimer wording also differs between regimes: the 2016 final rule's model letter says "has not affirmed the GRAS status … in accordance with 21 CFR 170.35". So disclaimer text belongs to each response, never to the pathway.
- **NDI 1062.** The letter FDA dated 2018-03-07 is a **filing acknowledgment**. It says "acceptance of this notification for filing is a procedural matter, and thus, does not constitute a finding by FDA that the new dietary ingredient … is safe". The company lists "FDA NDIN no objection … March 07, 2018 … NDI 1062". The catalog response enum has no procedural kind, so the gap is filed as W13-SR-06. The FDA NDIN guidance separates "acknowledgement of receipt" from the later "response letter".
- **Jurisdiction.**
  - The EU authorised NR chloride as a novel food: Implementing Regulation (EU) 2020/16, "Authorised on 20 February 2020", food supplements at 300 mg/day for adults.
  - The GB register entry NOVEL-96 "Applies in England, Scotland, Wales" through assimilated law.
  - A jurisdiction code "UK" or "GB" would wrongly extend that coverage to Northern Ireland.
  - The catalog enums are US-only, so EU and GB statuses cannot be written with catalog values (W13-SR-01, W13-SR-03).
- **Inspections.** FDA Data Dashboard: classifications are "assigned … for each project area within an inspection", "FDA does not issue CGMP certificates at the conclusion of an inspection", and "Not all inspections are included". So:
  - a classification is a per-project-area agency assertion;
  - an inspection is never CGMP-compliance evidence by projection;
  - a missing dashboard row is not "not inspected".

  Warning letter CMS #698661 states two different inspection end dates in its own text. That makes the inspection a real occurrence-identity case.

## 6. Smallest recommended model

**Types and relationships:**

- Nine node types, of which `RegulatoryPathwayVersion` is new and `RegulatoryInspection` is a candidate.
- Three enums, frozen at catalog values.
- One union.
- Fifteen relationship types: the catalog's eleven plus `HAS_PATHWAY_VERSION`, `UNDER_LEGAL_BASIS_VERSION`, and the candidates `INSPECTED_FACILITY` and `CONDUCTED_BY`.
- Two legacy derived types.
- No new relationship-property type.

**Validators:**

- Every catalog validator is kept.
- Three revisions are proposed: V-322r, V-333r and V-334r.
- Twelve new checks: V-W13-01..12.

**Not proposed:**

- No new status kinds in the fragment.
- No `WarningLetter` or `Form483` type: those documents are Sources with agency assertions.
- No device-listing status: there is no failing case yet beyond the forbidden-implication guard.
