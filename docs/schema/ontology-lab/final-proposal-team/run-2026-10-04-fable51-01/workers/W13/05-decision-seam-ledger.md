# W13 decision and seam ledger

**Status values:**

| Status | Meaning |
|---|---|
| ACCEPTED-FOR-PROPOSAL | W13 proposes it, the fragment and fixtures implement it, and it is executed |
| UNRESOLVED | It needs a ruling. The fragment holds the catalog-compatible default |

No other worker has been consulted, so nothing here records consensus.

## Decisions

| Id | Decision | Evidence | Alternatives rejected (why) | Status |
|---|---|---|---|---|
| W13-D01 | Keep the round-0005 split: submission, response and status are three records. Only APPROVAL is approval. | S1, S3, S8–S11; round 0005 C1–C4 | One status node with `statusCode` (fails C1–C4) | ACCEPTED-FOR-PROPOSAL (catalog) |
| W13-D02 | **Pathway versioning (OQ-L3-07):** `RegulatoryPathway` is the stable program identity. New `RegulatoryPathwayVersion` (VersionedState) is attached by `HAS_PATHWAY_VERSION` episodes (StateEpisodeProperties). Statuses and submissions may point `UNDER_LEGAL_BASIS_VERSION` at a version. The pathway's catalog fields become read-only projections. | S12 (effective 2024-07-05), S13 (vacated 2025-03-31; text reverted 2025-09-19), S14 (GRAS final rule effective 2016-10-17), S1 (GRN 000635 under proposed 170.36). Executed Q-MF-C02 (as-of 2025-02-01 vs as-of now). | (A) Effective bounds on the pathway: overwrite loses recorded history, one bound for two clocks, and the inherited fixture misattributes GRN 000635. (B) One node per regime: loses program identity. | ACCEPTED-FOR-PROPOSAL; tokens and exclusivity need W13-SR-04/05 |
| W13-D03 | `UNDER_LEGAL_BASIS_VERSION` on a **status** means dependency (V-334r ends the status with the regime). On a **submission** it records the filing regime. | First fixture run: V-334r flagged the GRN 000635 status linked to the 1997 regime. No source says such letters lapsed on 2016-10-17. | A single meaning would either force false endings or lose the filing regime | ACCEPTED-FOR-PROPOSAL |
| W13-D04 | `RegulatoryAgency` is labelled `["RegulatoryAgency","Organization","Entity"]` with uid token `org`. | Registry note; catalog parentLabel | A separate token: two identities for one agency | ACCEPTED-FOR-PROPOSAL (SR-02) |
| W13-D05 | `DESIGNATION_FOR` / `APPROVAL_FOR` are GraphQL field names over the stored `STATUS_OF`, not separate relationship types. | Catalog note "alias of STATUS_OF"; executed GraphQL round trip (`drugApprovals.approvalFor`, `orphanDesignations.designationFor` resolve) | Two stored types for one fact: duplicate history, and QS-4a predicate mismatch | ACCEPTED-FOR-PROPOSAL |
| W13-D06 | `AssayVersion` joins `RegulatorySubjectTarget` (LDT subject). | S12, S13; synthetic LDT fixture | Product: an LDT is not a sold product. AlgorithmVersion: wrong grain for a wet-lab assay | ACCEPTED-FOR-PROPOSAL (SR-12 confirm) |
| W13-D07 | `MaterialMixture` joins the union. A designation subject is the designated drug, never a consumer product sharing an ingredient. | S10 | Basis Product: asserts a designation the record does not make | ACCEPTED-FOR-PROPOSAL (SR-11 confirm) |
| W13-D08 | Jurisdiction partition. One status node per jurisdiction, with the jurisdiction code convention from SR-01. GB register coverage is England, Scotland and Wales. NI is NOT_RECORDED. | S15, S16; executed Q-MF-C03 | A single 'UK' or 'GB' code | UNRESOLVED (SR-01) |
| W13-D09 | `RegulatoryInspection` enters the fragment as **CANDIDATE**: an Occurrence with `INSPECTED_FACILITY` (asserted) and `CONDUCTED_BY`. Classification, findings and periods are agency assertions. The warning letter and Form 483 are Sources, not types. | S17–S19; failing case: the inspection collapsed into a status fires V-333, V-333r, V-W13-01, -02, -07 and -09 (executed). CMS #698661 states two end dates. | `WarningLetter` / `Form483` node types (no CQ needs them as nodes). Classification as a property (it is per project area). Inspection as a RegulatoryStatus (fails). | ACCEPTED-FOR-PROPOSAL as candidate (CQ-MF-C01); predicates need SR-07 |
| W13-D10 | Legacy `HAS_REGULATORY_STATUS` / `FOLLOWS_PATHWAY` are derived with `derivationRule` and `derivedFromAssertionUids` (rules W13-DR-01/02). They never use `projectionOfAssertionUid`, because the cited predicate (`STATUS_OF`, `SUBMISSION_ABOUT`) differs from the edge type and its direction. | QS-4a check `CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE`; executed V-W13-08 | Asserted legacy edges: two authorities for one fact | ACCEPTED-FOR-PROPOSAL (SR-08 for the W04 fields) |
| W13-D11 | Catalog V-333 is not episode-aware. Proposed V-333r counts DISTINCT subjects and at most one current episode. | Executed: V-333 fires on the valid LDT status with two recorded-time episodes | — | ACCEPTED-FOR-PROPOSAL (SR-15) |
| W13-D12 | Catalog V-322 is satisfied by an unbacked APPROVAL. Proposed V-322r requires an approving response and a current episode. | Executed N-07: V-322 = 0 rows, V-322r = 1 row | — | ACCEPTED-FOR-PROPOSAL (SR-15) |
| W13-D13 | Correction of inherited material. (a) The round-0005 adjudication rationale "180 mg/day is not in the captured FDA text" is superseded: it is in the letter, as the notifier's UL. (b) The FDA letter date is 2016-08-03 (company: August 05). (c) The inherited fixture's GRAS pathway citation of subpart E is anachronistic for GRN 000635. | S1, S2, S14 | Leaving round 0005 as is: an answer would assert that FDA never mentioned 180 mg/day | ACCEPTED-FOR-PROPOSAL (fixture: SUPERSEDES {RE_REVIEW}; verdict unchanged PARTIALLY_SUPPORTED) |
| W13-D14 | NDI filing acknowledgment vs response. The 2018-03-07 NDI 1062 letter is procedural. The company "no objection, March 07, 2018" is adjudicated INSUFFICIENT (not CONTRADICTED, because a later response letter was not captured). | S3, S5, S6, S7 | Treating the filing letter as NDI_ACKNOWLEDGED_WITHOUT_OBJECTION | UNRESOLVED enum value (SR-06); adjudication ACCEPTED-FOR-PROPOSAL |
| W13-D15 | EU and GB novel-food authorisations use status kind APPROVAL, jurisdiction-qualified, with response kind NOVEL_FOOD_AUTHORISED added to the approving set. | S15, S16 | Introduce AUTHORIZATION. More precise, but it adds a status kind that every approval guard must learn. | UNRESOLVED (SR-03) |
| W13-D16 | Per-pathway response closure is enforced as V-W13-03; the catalog had it only as structure. | Executed N-10 | Separate enums per pathway: 10 enums for one field | ACCEPTED-FOR-PROPOSAL |
| W13-D17 | A De Novo or 510(k) status attaches to the device product. An `AlgorithmVersion` is a subject only when the record names a version. | S9 "PCCP Authorized No", no build named; SRC-FDA-DEN200080 notAuthorityFor | Catalog example attached it to AlgorithmVersion | ACCEPTED-FOR-PROPOSAL |
| W13-D18 | `submissionKind: PathwayKind!`, plus `submissionSubtype` (verbatim) and `receivedAt` (new clock). | S1 (dated, received and filed are three dates); S8, S9 "Date Received", "Type" | String submissionKind | ACCEPTED-FOR-PROPOSAL |
| W13-D19 | `decisionTextVerbatim` on the response and `statusCodeVerbatim` on the status keep agency or live wording beside the closed kinds. | S2 "FDA has no questions", S8 "SESE", S9 "DENG" | Dropping the wording: answers could not quote the agency | ACCEPTED-FOR-PROPOSAL |
| W13-D20 | Runtime: @neo4j/graphql 7.6.3 reads of DateTime fields need APOC. | Executed round trip | — | Reported to W00/Fable (SR-16) |

## Kernel-change requests

None. Every proposal uses the frozen kernel types:

- `StateEpisodeProperties` for a new attachment;
- `DerivedEdgeProperties` for legacy edges;
- `SUPERSEDES {RE_REVIEW}` and `{VALIDITY_BOUNDED}`.

Two items touch W00-owned conventions and are seam requests, not kernel changes: the predicateExclusivity entry (SR-05) and the jurisdiction value convention (SR-01).

## Seam requests

Eighteen seam requests (W13-SR-01 … W13-SR-18) are in `seam-requests.yaml`. Each has a target owner, a failing case and a proposed ruling.

Closure criteria for the open items:

| Seam | Closed when |
|---|---|
| SR-01 | W00 publishes `conventions.jurisdictionCode` with GB coverage verified against ISO 3166-2:GB |
| SR-03 / SR-06 | Fable rules on the enum additions; V-336 and V-320a lists are updated; the pending fixture returns zero rows |
| SR-04 / SR-05 / SR-07 | Tokens, predicates and exclusivity are registered |
| SR-08 … SR-13, SR-18 | The owning worker's fragment declares the fields or behaviour named |
| SR-15 | Fable adopts the r-validators |
| SR-16 | APOC is added to the harness and deployment prerequisites |

## Unresolved items kept open

1. The EU authorisation status kind (D15).
2. ISO code for Great Britain (D08).
3. Northern Ireland novel-food position: not captured.
4. NDI 1062 substantive response: not captured.
5. NAI/VAI/OAI classification for the two inspected facilities: the dashboard API needs credentials, so it was not captured.
6. Whether pre-2016 GRAS "no questions" letters carry over unchanged to subpart E. Not stated in the captured sources, so no status is bounded at 2016-10-17.
