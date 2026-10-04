# W14 completion report

- **Worker:** W14 Intellectual property and licensing. **Model:** Opus 5.5 (`claude-opus-5-5`). **Coordinator:** Fable 5.1.
- **Start:** about 2026-10-04T00:50Z. The first web retrieval was at 00:57:09Z; the first `date` call at 01:03:39Z came after the reading and research phase. **End:** 2026-10-04T01:35Z.
- **Write scope respected:** only `workers/W14/` was written. Scratch work (generator source, stubs, harness runs) is in the session scratchpad.

## Tools actually used

| Tool | Use | Availability |
|---|---|---|
| Bash, Read, Write, Edit, Grep | Repo reading, generation, hashing | available |
| Firecrawl `firecrawl_search`, `firecrawl_scrape` (markdown, query/directQuote, PDF parser) | Google Patents, Justia contract mirror, EDGAR Online mirror, SEC 10-K pages, CAFC opinion, USPTO TSDR | available. **Primary retrieval path** |
| WebFetch | patents.google.com | **BLOCKED** (EGRESS_BLOCKED) |
| curl | tsdr.uspto.gov | **BLOCKED** (proxy CONNECT 403); the same page was retrieved through Firecrawl |
| PubMed, ClinicalTrials.gov, Tavily, bioRxiv, ICD-10, NPI MCPs | not needed. No IP question depends on them; NCT02712593 facts are inherited from the source registry | available, not used |
| Exa, bigdata.com, Figma, GitKraken | — | failed to connect (session notice); not needed |
| `@neo4j/graphql` 7.6.3 / `graphql` 16.14.2 (harness `build-schema.mjs`) | fragment build with stub types for W00/W01/W02 | **build OK** (843 generated types) |
| Neo4j 5.26.31 Community embedded (harness `EmbeddedNeo4j`, `run-cypher.mjs`) | fixtures, W14 validators, kernel `validation.cypher`, CQ queries, operations | **RUN** (one instance was killed externally mid-run, most likely host memory pressure from many parallel instances; the full sequence was rerun on a fresh instance) |

## Results in one paragraph

The fragment defines the six catalog types (refined), the registered union `PatentLicenseTarget`, and two candidates with failing cases: `IpRightStatus`, with `IP_STATUS_OF` and `IpRightStatusSubjectTarget`; and `GRANTS_PATENT_LICENSE`. It has no new relationship-property type and no new enum. The real records settle the modeling questions:

- US 8,197,807 B2 is "Active" on Google Patents (adjusted expiration 2026-11-19), while the Federal Circuit affirmed claims 1–3 patent-ineligible on 2023-02-13. So status is per right **and** per claim, and it is asserter-bound.
- The 2014 Dartmouth→ChromaDex, Inc. exclusive license names specific patents. Its field is "human and animal therapeutics", its territory "worldwide", and it is effective from 2014-05-16. Coverage is exactly what the license names, never the family.
- For the 2012 agreement, Field, Territory and exclusivity were not captured. They are unknown, not unrestricted.
- The USPTO record for NIAGEN shows owner ChromaDex, Inc. (serial 85932490, reg. 4606519, renewed 2025-07-24) and lists a related Madrid IR. The 10-K says the group supplies Niagen. Mark owner ≠ supplier, and the IR is a separate right.

All mandatory fixtures exist and were run. The validators behave as specified: clean data gives 0 violations, and every negative case is caught. The kernel suite stays clean on W14 data and its V-112 independently catches the `OWNS_STUDY` negative.

## Research gaps (evidence requests)

1. The original SEC exhibit bytes for the 2012 and 2014 agreements (accession for 2014 not captured). These would settle whether the 2012 Field and Territory are redactions (U-1).
2. The D. Del. summary-judgment date (W14-D14). It would move the claim-invalid bound earlier than 2023-02-13.
3. EPO DOCDB/INPADOC family records for US 8,197,807 and AU 2006238858 / CA 2,609,633 (U-3). Not attempted.
4. The USPTO Assignment Center record (U-4). Not attempted (JavaScript application).
5. The FY2025 10-K patent table in full (U-2), and which IPR the December 2023 vacatur concerned (U-5).

## Unresolved seams (seam-requests.yaml)

W14-SR-01 tokens (W00) · W14-SR-02 admit IpRightStatus and the enums (Fable/W00/W13) · W14-SR-03 GRANTS_PATENT_LICENSE, projections and forbidden pairs (W01) · W14-SR-04 PATENT_CLAIMS predicate and efficacy predicate list (W00/W10) · W14-SR-05 BrandedIngredientMaterial.marks (W02) · W14-SR-06 NAMED_INVENTOR (deferred, W01/W21) · W14-SR-07 Document→artifact link (W20/W19) · W14-SR-08 PredicateClass confirmation (W00). T-001: **no transfer** requested.

## Confidence per dimension

| Dimension | Confidence | Why |
|---|---|---|
| Boundaries and dispositions | high | every catalog and live element is dispositioned; the live schema has no IP types |
| Status model (IpRightStatus) | high | real failing case; kernel-consistent after the V-507 fix |
| License model | high for structure, medium for amendment handling | amendment chain untested on real data (synthetic only) |
| Trademark-as-right | high | real TSDR related-property case |
| Source facts | high for S1, S5, S6 (office/court/aggregator primary pages); medium for S2/S3 (third-party mirrors of SEC exhibits; query-mode excerpts) | — |
| SDL | high | parses; builds under 7.6.3 with stubs; final merge depends on W00/W01/W02 names matching |
| Operations | high on Community | 29/29 statements run; Enterprise not tested |

## Review status

Self-reviewed against the contract (B1–B7, C) and the kernel validation suite on executed data. No independent reviewer has seen this packet. Fixture timestamps (`recordedAt` 01:20/01:30Z, adjudication `reviewedAt` 02:00Z) are fixed illustrative values, not service-assigned commit times. The adjudication stamp is later than the wall-clock end of the run.

## What remains qualified

- Fixture uid tokens are proposed and unregistered (W14-SR-01).
- `MARKETED_UNDER_MARK` resolution from "Niagen®" to the US registration is simplified (it should be a `ResolutionHypothesis`, W14-D12).
- The calculated EXPIRED status rests on an aggregator's adjusted expiration, not an office record.
- The Q-02 statement that the claims were enforceable on 2022-06-01 holds only on the captured data.
- Snapshot content hashes other than S1 are SYNTHETIC_FIXTURE. Locator quote hashes are real.

## Artifacts (SHA-256)

```
7567f226cf5b27d9283dada7d3c273e3fb36b200dec6091d7f7d3d749f86c2f2  01-domain-recommendation.md
f5650d62cc336fba5a0328f83b937a6073aca283f2a7aa3a75541fda2c75218b  02-cq-coverage.md
7dd5f768ccf537149d833cb788ee08aa7f93129cfe4ab945e8e833c68888afb7  03-source-manifest.md
5c044536aadb1d432bd6b6ad9b84c95a3a6916b47cd1a4f1b92f62fc11742bd5  04-model-cards.md
9bea1189142e53e3d5ea17f813b81acb2e6adde021ee918bcfcd8464b647a43a  05-decision-seam-ledger.md
5bcd369d7a804df4961fc88f7e5f53aa14c99c12010454c53e37a02e523019b5  06-fixtures-and-queries.md
280b2698ea09b473221c8970383a1094d5b2c502177ea857ffeb8a5481d28f26  07-operations.md
c727c6d08f8cd9eb9730f651a97f718ab2ab3031979f1c8f9c7c31e8d2e68100  operations.cypher
4b28d83423f080531bf8e6ee0049661a2d84a05fe7b5657bdecada8f32b52390  sdl-fragment.graphql
758c2708a76ed83b5455fd4e643cd32670068243356581e64fd5d4d7f54c3c2f  migration-map.yaml
a16297086942da002e2a534fc793ff10c2781869a0d4ba0b78451c981edde787  seam-requests.yaml
6b669ca1f08c663922878f6058327e38992e59aceac0e2558caed8a8b6001908  fixtures/w14-cq-queries.cypher
c9719250a586aa4308729b9c60c0120cb0283bc7583aa9007336f6fdd2bbf8bd  fixtures/w14-fixture-generator.py
f90fe57b2a1438af7418c8167b1afb7e9644d3ca47cc7ce7d58399a4502f6f80  fixtures/w14-ip-core.cypher
e236cb56c1f8a7fd539c0e3156b1df9b83f7730071522aa3160e9561923c12c4  fixtures/w14-ip-minimal-pairs.cypher
d2be2af5de8f58a41af175a4b63d782bf50de695b39a763fedba88fcb32ecbbd  fixtures/w14-ip-negative.cypher
0fddd2d3942295716e23f6eeff68adb0d9a63f9032d7d783f08cbe1994ec689f  fixtures/w14-run-log.txt
0f64d69771ed4c72adcaf0cd676d2105beadf6e3b2f106d0ba380c6734fbd396  fixtures/w14-validation.cypher
```

(This report's own digest is not listed here; it is given in the final handback.)
