# W07 completion report

- Worker: W07 Diagnostics and measurement, model **Opus 5.5** (`claude-opus-5-5`), coordinator Fable 5.1.
- Start: 2026-10-04T00:54Z (first tool call after reading the run files). End: 2026-10-04T01:32Z.
- Wrote only inside `workers/W07/`. Scratch harness files (test stubs, run logs, JSON results) are in the session scratchpad and are not deliverables.

## Tools actually used and availability

| Tool | Use | Result |
|---|---|---|
| Firecrawl `firecrawl_scrape` | loinc.org 4548-4 and 59261-8; Mayo test-definition PDF; Labcorp test page and sample report PDF; Quest test page; TruDiagnostic platform page and linked PDF; DunedinPACE DESCRIPTION (raw GitHub); CLSI EP28 page and free sample PDF (query mode); Everlywell page (query mode) | all succeeded; Quest PARTIAL (service-area sections not rendered) |
| Firecrawl `firecrawl_search` | Mayo catalog discovery; TruDiagnostic; vendor version strings | succeeded (search extracts) |
| Owkin MCP | `pathology_explorer_help`, `features_description` | succeeded; same content as 2026-10-03 |
| curl via proxy | NLM Clinical Tables LOINC API | BLOCKED (403 CONNECT) |
| GitHub MCP | DunedinPACE repository | refused (repository outside session scope); fetched the raw file through Firecrawl instead |
| PubMed, ClinicalTrials.gov, Tavily, bioRxiv | not needed (PMIDs inherited) | not used |
| `@neo4j/graphql` 7.6.3 / `graphql` 16.14.2 (run harness) | build of fragment + stubs; `@declareRelationship` verification; `merge-fragments.mjs` check | build OK; probe confirms implementer must carry `@relationship`; fragment: 23 definitions, 0 duplicates, 0 extend, 0 forbidden directives, 23 undefined names all owned by W00/W01/W03/W08/W20 (plus string-referenced property types StructuralEdgeProperties, AssertedEdgeProperties, DerivedEdgeProperties, IdentifierLinkProperties, MechanismLinkProperties, AssociationProjectionProperties, DerivedSupportProperties) |
| Neo4j 5.26.31 Community (embedded) | all fixtures, W07 validation, repository suite, CQ queries, operations.cypher | run (06 and 07 record counts) |

## Deliverables

All eight deliverables are present: 01 to 08, `sdl-fragment.graphql`, `migration-map.yaml` (80 entries), `seam-requests.yaml` (18 requests), `operations.cypher`, `fixtures/` (7 load files, 1 validation file, 1 CQ query file).

## Research findings that change inherited text

1. LOINC 59261-8's "standardized per IFCC-RMP for CDT" is the component adjustment part (LP310257-3) in the fully specified name, not a display artifact (round 0004 "Unverified items" corrected).
2. OQ-L3-01 probe (5 records): no software version and no EP28 derivation kind is published by Mayo, Labcorp, Quest or Everlywell; one instrument is named (Mayo, Bio-Rad D-100); the consumer vendor names no performing lab. Same LOINC 4548-4 maps to three different public procedures and three different printed intervals.
3. OQ-L3-02 (one vendor): TruDiagnostic's MSA clocks, including DunedinPACE, are "custom algorithms trained directly on our arrays", with no vendor version string on the page; the authors' reference implementation is `0.99.0` for 450K/EPIC. Vendor implementation = distinct AlgorithmVersion.
4. Catalog validator gaps found by execution: V-302 does not check INV-302 (needs V-305c); V-302 accepts a malformed three-way assessment as a licence (V-302r); V-303 has no pending state for MEASURED results whose lab is unnamed (V-303r); V-313's lower-case privacy values contradict contract B5 (V-313r); V-112 reports same-version COMPARED_TO because the edge is not `ruleOnly` (W07-SR-10).

## Research gaps

- OQ-L3-01 sample is 5 records, not the 20 labs + 5 vendors OPEN-QUESTIONS asks for; no NGSP certified-method PDFs opened; Quest's LOINC and performing lab not captured.
- OQ-L3-02 covers one vendor; no vendor version string found in the pages consulted (not a proof of absence).
- OQ-L3-03 (reliability source per vendor version) not researched beyond the inherited PMID 36277076.
- CLSI EP28 full text not read (paywalled); only the free sample.
- No bytes were hashed (Firecrawl returns converted text).

## Unresolved seams (seam-requests.yaml)

W00: SR-01 (`@declareRelationship` in B1), SR-03 (ResultQualifier ownership), SR-06 (ADOPTED_FROM_GUIDELINE), SR-09/10/11/15 (validators), SR-12 (uid tokens panel-definition, reference-range), SR-13 (CHANGED_BETWEEN). W16: SR-02 (Observation implements DiagnosticResult with the label), SR-04, SR-05 (FOR_METRIC). W03: SR-07. W08: SR-08. W23: SR-14. W12: SR-16. W13: SR-17. W01: SR-18.

## Confidence

| Dimension | Confidence | Basis |
|---|---|---|
| Module shape (catalog types and edges) | high | catalog + round 0004 + real minimal pairs reproduced in fixtures |
| SDL executability | high for the fragment with stubs; medium for the merge (depends on other owners' names: AssociationProjectionProperties, MechanismLinkProperties, DerivedSupportProperties, Observation field names) | built under 7.6.3 |
| `@declareRelationship` behaviour | high | installed source + negative build probe |
| Fixture/validator behaviour | high on Community 5.26.31 | run, counts recorded |
| OQ-L3-01 generalization | low-medium | 5 records |
| OQ-L3-02 generalization | low-medium | 1 vendor |
| Enterprise constraints | unverified | Community rejects them |

## Review status

Self-reviewed only; not reviewed by another worker or by Fable. Everything in this packet is a recommendation; proposed validators (V-302r, V-303r, V-304r, V-305c, V-313r, V-314..V-318), the candidate predicate `CHANGED_BETWEEN`, the RIV bound-status fields and the ResultQualifier ownership remain qualified until ruled.

## Artifact digests (SHA-256; this report excluded)

```
9ab546a1fc860555c5874661047535fd226e787f88754ce3424129ff7f3e8f74  01-domain-recommendation.md
1f9d741e0576be72013f624783fd52f6128931d5f30c38757a161fe5ee07200f  02-cq-coverage.md
65a68552d2342793408d4b081fca97b132f573b45ebcc3f6ae25770129a27738  03-source-manifest.md
e8a8f470b8c9ffadf8b7c13f3dc5567fd6d4d54f1f18ef571e0595bb8d9fb236  04-model-cards.md
cf8f9c7d457cd6d0a707d8ced2097dff78c2f56d959f07196a53383f99fdbd1a  05-decision-seam-ledger.md
542a04eedb89c107990ac3303f2fc434a194805e8417efead52037fd15d2d2a0  06-fixtures-and-queries.md
48ab665c3cd3ed91ff333534d48918a8b503416385fad38d4754eb46c207fc9f  07-operations.md
68f99c7d4c02e3ccb85826aec43dd35c67718873d6918ee7e79b881fde298896  operations.cypher
aae1d525d99e1d61f53cccad9426d4b6a871a6c73bdb3a7780b93964307530c0  sdl-fragment.graphql
3d5d8c59b1ae243e4b812a48373f08aa369dad1265d2d4df5087df6c00ffce1d  migration-map.yaml
03240535782cd71b1ca16c6ea7250e12e1905b524fb24178c4556f5c22e74e6b  seam-requests.yaml
47126c64ac1a0ef4af5082eca009ad9a2daa708524a91bd58a216d178c2375d3  fixtures/w07-00-sources.cypher
46a726fec1bac9a63e77a243873cbc8a33cf69c019407ce4946553c95b7ed5f7  fixtures/w07-01-measurands-tests-assays.cypher
19a37df73dac5aac9647c3f64f7b18d3201f763e4fee8ae7bc9b456e5f7fa38f  fixtures/w07-02-reference-intervals.cypher
46edc3ad4b48e3e5e7b3b7a999abb753f555f9610cee1676b7f7af9abcb04782  fixtures/w07-03-algorithms.cypher
bbf3bd4466303770f99c716c7b6f32500b8dfca1bcb65d467320aee32a9636cd  fixtures/w07-04-results-and-comparability.cypher
1e888437ac1c6931eca8b6f4b5e0b5c65b67bfdde9e47915009acc2b275bf7ed  fixtures/w07-90-negative-overlays.cypher
ec6fa556dc43d55b82873309de7a0c4a6d2b71250f2c93fe411edb9aa1402ba8  fixtures/w07-91-negative-masking.cypher
b3d37107b97937b0f6feacd7f57e7388375aebe4e31c91d202220e92abf42c02  fixtures/w07-cq-queries.cypher
0f30301ec888644590947dd755388d0b6976f2fa49b1d34b6f872517977cf064  fixtures/w07-validation.cypher
```
