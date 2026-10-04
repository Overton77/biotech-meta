# W13 completion report

- **Worker:** W13 Regulation and jurisdictions.
- **Model:** Opus 5.5 (`claude-opus-5-5`).
- **Coordinator:** Fable 5.1.
- **Run:** `run-2026-10-04-fable51-01`.
- **Time:** started 2026-10-04T00:57:48Z; finished 2026-10-04T01:34Z (approximately).
- **Inputs:** catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112`, as in `00-baseline.md`.
- **Writes:** only inside `workers/W13/`. Temporary files went to the session scratchpad.

## Tools used and their availability

| Tool | Used for | Result |
|---|---|---|
| Tavily extract | S1–S6, S8–S19 first-party pages and PDFs | worked; every capture is an extract, not byte-archived |
| Tavily search, WebSearch | locating NDI 1062 documents, the EU act, warning letters | worked; one summary claim was not used as fact (see manifest) |
| Firecrawl, PubMed, ClinicalTrials.gov, bioRxiv, NPI, ICD-10 | not needed (no literature or trial question) | not used |
| Exa, bigdata.com, Figma, GitKraken | — | failed to connect (session notice) |
| FDA Data Dashboard API | facility inspection classifications | **not used**: needs OII Unified Logon credentials. Classification recorded as NOT_CAPTURED |
| Embedded Neo4j 5.26.31 Community (run harness) | ran all fixtures, validators, queries and operations | worked |
| `@neo4j/graphql` 7.6.3 + `graphql` 16.14.2 | fragment build and a GraphQL round trip against the fixture database | build OK; DateTime reads need APOC (not installed) |

## Deliverables

All eight fixed deliverables are present: 01–08, `sdl-fragment.graphql`, `migration-map.yaml`, `seam-requests.yaml`, `fixtures/*.cypher`, and `operations.cypher` (optional).

## Main findings

1. **OQ-L3-07 is answered: version the pathway.** Use program Entity + `RegulatoryPathwayVersion` + `HAS_PATHWAY_VERSION` episodes, with `UNDER_LEGAL_BASIS_VERSION` as a dependency link. Three real failing cases support this:
   - the LDT rule: effective 2024-07-05, vacated 2025-03-31, text reverted 2025-09-19;
   - the GRAS regime change (proposed 21 CFR 170.36 → subpart E, effective 2016-10-17);
   - the inherited fixture's anachronistic GRAS legal basis.
2. **Inherited material is corrected.**
   - FDA's GRN 000635 letter does mention 180 mg/day, as the notifier's UL, not an FDA condition. The round-0005 rationale said it did not.
   - The letter is dated 2016-08-03, not "August 05".
   - The NDI 1062 "no objection March 07, 2018" refers to a procedural filing letter.
3. **Three catalog validator defects were found by execution:**
   - V-333 is episode-unaware;
   - V-322 is satisfied by an unbacked APPROVAL;
   - V-334 cannot see episode-bounded legal bases.

   Revisions V-333r, V-322r and V-334r are proposed and run.
4. **The catalog enums are US-only.** An EU or GB authorisation cannot be written without new values (SR-03). A "UK" or "GB" jurisdiction code over-extends GB coverage to Northern Ireland (SR-01).
5. **Inspections justify a CANDIDATE Occurrence type.** The failing case was run: collapsing an inspection into a status fires six validators. A warning letter can contradict itself on dates.
6. **Runtime fact:** `@neo4j/graphql` 7.6.3 needs APOC for DateTime reads (SR-16).

## Research gaps (qualified, not invented)

- The NDI 1062 substantive response letter and the NDI 882 letters were not captured.
- The filing date of NDI 1062 is not stated in the captured text.
- The ISO 3166-2:GB code for Great Britain was not verified.
- Northern Ireland's novel-food position was not captured.
- The indication text and applicant name for NDA 217785 were not captured.
- NAI/VAI/OAI classifications for Nutratech and Anti L'Age were not captured (credentials needed).
- No source says whether pre-2016 GRAS letters carry over to subpart E, so none is bounded.
- The column headers of FDA's NDI list PDF were not captured.

## Unresolved seams

| Seam | Topic |
|---|---|
| SR-01 | jurisdiction convention |
| SR-03 | EU/GB enum values and status kind |
| SR-06 | NDI filing acknowledgment kind |
| SR-04, SR-05, SR-07 | tokens, exclusivity, predicates |
| SR-08 … SR-13, SR-18 | fields on other owners' types |
| SR-15 | validator revisions |
| SR-16 | APOC |
| SR-17 | patent forbidden implication owner |

## Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Source extraction | High for database record fields (S2, S8–S11) and the GRN letter. Medium for PDF OCR extracts (S3) and partial extracts (S5, S12–S18) | captures as listed |
| Identity and resolution | High for agency numbers. Medium for "ChromaDex = Niagen Bioscience" (inherited W01 identity) | Identifier + inherited org uid |
| Model fit to the CQs | High for CQ-MF-02/03, CQ-AX-23, CQ-TM-03. Medium for CQ-MF-C01 (candidate; classification unverified). Medium for CQ-MF-C03 (enum rulings pending) | run queries |
| Executability | High: fragment builds under 7.6.3 with stubs; all fixtures and validators ran on 5.26.31 Community | run results |
| Enterprise behaviour | Unverified | not available |

## Review status

Self-checked only: no other worker reviewed this packet. Every query and validator expectation in `06-fixtures-and-queries.md` was compared with actual run output. Differences are explained there: V-333 is a catalog defect, and N-07 shows the V-322 defect.

## What remains qualified

- `RegulatoryPathwayVersion` stays NEW until W00 registers the token and the exclusivity entry.
- `RegulatoryInspection` stays CANDIDATE.
- The EU/GB statuses and the NDI filing acknowledgment are in a pending fixture that will not pass validation until SR-03 and SR-06 are ruled.
- The synthetic records (LDT, plant, cGMP claim, earlier captures) are labelled synthetic and must not be read as real records.

## Artifact digests (SHA-256, at 2026-10-04T01:32:58Z; this report excluded)

```
58eeb359bd7e08c7db9151afea8c809120a83dc52d950f8ea0d2fb0f096e9056  01-domain-recommendation.md
f79e874040d64d897f8bdda2dd19a5da04dbb05bf094a45ecab9f25eff785efa  02-cq-coverage.md
049161a36469af8b1bab094644f61ec3a85fb80906e500bf7cece7a5c037b8fc  03-source-manifest.md
5fb82e41dee65e5cdeeab2cc151275543d01573158c9be655395883cc75ee619  04-model-cards.md
f40b91c2b7ad72085feeabdd83aec78682ae4c628f15629cb7aea4226cd7e1e1  05-decision-seam-ledger.md
7fb2651747176af29889c0c366bb4ea8022631b2d4c2be12e543de1085710496  06-fixtures-and-queries.md
66f8184ace7ca488f60fa9b9fafe5342a7045358f52a6543212dd7b1a1643fa6  07-operations.md
953590d23ae3eafb17f0b6109d503e1f39a28016e90cbf91981ba68093b9f132  sdl-fragment.graphql
da94048c4011525c831db2bf8fa4d68686db29d7d90845d43bc8826bb4e6c1de  migration-map.yaml
4fdfc47a04d58bc5236a477c8e7b56276052483a4886401800496c6428854866  seam-requests.yaml
465e0f1f9668dabed2c73e557f4700d516b8fae38eac813ba89eff892285b401  operations.cypher
f4d9ab51a328e543c0657dc7a8a026c816d263c4f33160479a00f1ca7d931c56  fixtures/w13-regulatory-kinds.cypher
28a625c0b099727a3c1ebde656be5c54a8e0d87af2fd85245a0af2c6691d2cc5  fixtures/w13-negative.cypher
cf678946419a4d3b0d614eaba2fc006d080dee6bced3e702832cab7c7837e12b  fixtures/w13-jurisdiction-and-pending-values.cypher
2ba4888aa506c7bb5ef0f87eccdaf1d0e221c4ae02107b34572dbb603d19668b  fixtures/w13-inspection.cypher
791e582c03ef0767c2dde82e761965fa851429531c0cc8fb7a2f00e33d6bb6b1  fixtures/w13-validation.cypher
925e26d1311b3c2b4805a7c6884cbe6ff35e7fdca352fbb2d9671bddbe22a766  fixtures/w13-cq-queries.cypher
3ee1a08c38c671f9c6309d2c11afa7c83bf56c0478fb62b8ae6e5e2a270d4fc5  fixtures/generate_w13_fixtures.py
cd6c48ecfe5e6dae953ea83b28b70aab709a4e5692cac16fd3a6ecf35d5c1eed  fixtures/run-results/build-stubs.graphql
bd8b734d0d6324396ff64418dada8305e8f6e441dc014f07d32bcdbeb6347f17  fixtures/run-results/gql-roundtrip.mjs
115124c5490cba9ce14c8c038b238d6f99a51d5b0569d4055b6c81b392148128  fixtures/run-results/final-cq-positive.json
e9819141946055a63d6dc08e04879f1db7182c3ed153379270936e1243e1a90c  fixtures/run-results/final-insp.json
11787bd14e4b9059a54386c127e7899144554bf8e3d1a4a661c70d432a1b7382  fixtures/run-results/final-kinds.json
e78bd285704cbd22f9e7c7107d2c1850339723cda97079323867069ee3c1bf3f  fixtures/run-results/final-ops.json
70c956d773acbe3fe1ae28fa9cfe3c89a34de28fa114f911d7ed2a72c081a6bf  fixtures/run-results/final-val-inspfail.json
e6d5d46f23c443e670e8cacd75c011378df6ad6dbfd2d08c6a41b260e725e05f  fixtures/run-results/final-val-positive.json
8eb8ec902621cea22e57d87e1a10fbf31c0527f3d3f02aa5d9908956b20502ae  fixtures/run-results/r2-neg.json
b0904ece2901bf3b2431e13696771d714532838a76014ca004a86dd14d130a70  fixtures/run-results/r2-pend.json
d1d98eb2f1188b19083e061797ae4870c34b348d25a8f16bf2f5cae657780ac5  fixtures/run-results/r2c-val.json
c6913a3d5a9be327a12a2e492209ca942f36da0a63fa708dcf9ee24ff1da80bf  fixtures/run-results/r2e-cq.json
ec4661b0942c7d1b8306d8097e78dc686f52e2154ae3ff21243ab1021874a1ed  fixtures/run-results/r2e-val.json
```

## Run-results key

| File | Content |
|---|---|
| `final-*` | scenario A (fresh database): positive + inspection, then the operations file, then the inspection failing case |
| `r2-pend`, `r2c-val` | scenario B (+ pending values) |
| `r2-neg`, `r2e-val`, `r2e-cq` | scenario C (+ negatives) |
