# W08 completion report

- Worker: **W08 Platforms, instruments and devices**; model **Opus 5.5** (`claude-opus-5-5`); coordinator Fable 5.1.
- Run: `run-2026-10-04-fable51-01`. Start 2026-10-04T00:56Z (first read of the brief); end 2026-10-04T01:35Z (approximate; digests computed at the end).
- Authority digests used: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112` (as in `00-baseline.md`).
- Writes: only inside `workers/W08/`. No other worker's directory, run file, catalog or live schema was edited. Scratch files (embedded database store, merged build file) stayed in the session scratchpad.

## Tools actually used and availability

| Tool | Used for | Outcome |
|---|---|---|
| Tavily search | locating WHOOP firmware notes, Oura sleep-staging posts, WHOOP 510(k), Illumina EPIC v2.0, FDA letters | worked |
| Tavily extract | WHOOP firmware page (returned only a "CSS Error" shell), FDA 510(k) record K243236 (returned the full record table from Tavily's store) | partial |
| Firecrawl scrape | WHOOP firmware page (live), WHOOP Locker page (cache), K243236 PDF (live, PDF parser, 10 pages), Illumina product page (live), FDA closeout letter (cache) | worked; FDA 510(k) database page live fetch returned **HTTP 503** (BLOCKED for live capture) |
| curl → openFDA `api.fda.gov` | 510(k) JSON | **BLOCKED** by the egress proxy (CONNECT 403); not treated as absence |
| PubMed, ClinicalTrials.gov, bioRxiv, ICD-10, NPI MCP | not needed (no study or registry question in W08 scope; NCT06622265 named by FDA was not opened) | not used |
| Embedded Neo4j 5.26.31 Community (run harness) | fixtures, W08 validators, CQ queries, full 0.2.0 baseline suite, DDL | worked |
| `@neo4j/graphql` 7.6.3 / graphql 16.14.2 / neo4j-driver 6.2.0 (run harness) | fragment build, GraphQL round trip, `merge-fragments.mjs` over all current fragments | worked |
| Exa, bigdata.com, Figma, GitKraken | — | failed to connect (session notice); not needed |

## Results in one paragraph

Five live types kept (TechnologyPlatform, ToolOrInstrument, Device = catalog DeviceModel, Sensor, Modality), one candidate VersionedState (`FirmwareVersion`), the live union `ProductClassification` renamed `EquipmentModelTarget`, one relationship-property type (`UsageEdgeProperties`), no enum. A device model never carries a regulatory status or a performance figure: the K243236 clearance attaches to the software Product "WHOOP ECG (electrocardiogram) Feature", which `RUNS_ON_DEVICE` WHOOP MG; the applicant's 96.2 % / 99.4 % figures are Assertions asserted by WHOOP. Platform class and instrument model are a tested minimal pair (Infinium / iScan vs NextSeq 550). Firmware is versioned per device and component; the assay's `softwareVersion` stays the materialized label. All fixtures, 11 W08 validators, 10 CQ queries, the 174-query baseline suite and 27 DDL statements ran; positives produce zero failing rows; each negative fires its named validator.

## Research gaps

1. FDA 510(k) database page: live capture blocked (503); the record table came from a search-provider store with unknown capture time. openFDA blocked by proxy.
2. WHOOP firmware page has no release dates and repeats rows; no source tied the July 2026 heart-rate update to a firmware version or device model.
3. Which WHOOP MG strap firmware builds contain the cleared ECG Feature 1.0 is not public in the captured sources.
4. Oura (OSSA 2.0 sleep staging) was not captured; it would exercise W07 AlgorithmVersion, not W08's types.
5. The July 14, 2025 warning letter was seen only as a search snippet (not used in fixtures).
6. NextSeq 550Dx regulatory status was not retrieved; the fixture does not model it.

## Unresolved seams (see `seam-requests.yaml`)

W08-SR-01 (W07: `RUNS_ON_INSTRUMENT` range and `PERFORMED_WITH_ASSAY_VERSION` domain), W08-SR-02 (W07: drop Sensor from `MEASURES_METRIC`), W08-SR-03/04 (W04: `EMBODIES_MODEL`, `RUNS_ON_DEVICE` fields), W08-SR-05 (W07: `RUNS_FIRMWARE_VERSION` field if FirmwareVersion is admitted), W08-SR-06 (W00: uid tokens, predicates, FirmwareVersion in `AssertionSubjectTarget`), W08-SR-07 (W01: Organization fields), W08-SR-08 (Fable registry, consumer_devices forbidden implications and maturity), W08-SR-09 (W13 subject set, version-scoped clearance), W08-SR-10 (W21 `QUALIFIED_BY` on generic Assertions), W08-SR-11 (W16), W08-SR-12 (W07 operating mode, optional), W08-SR-13 (W11, agreement).

## Confidence by dimension

| Dimension | Confidence | Why |
|---|---|---|
| Platform vs instrument vs method vs kit separation | high | first-party Illumina page states all four; minimal pair runs |
| Device ≠ regulatory status; clearance ≠ approval | high | FDA record + letter + applicant summary; W13 subject set already agrees |
| Performance claims as Assertions | high | applicant authorship visible in the PDF; validators run |
| FirmwareVersion as a separate candidate type | medium | failing cases are real (S1, S4) but CQ-DX-09 is Expansion; fallback documented |
| Device-run AssayVersion via W07 edges | medium | depends on W07 accepting the range/domain widening |
| Sensor / Modality semantics | medium-low | live seams with thin CQ support; kept PROVISIONAL |
| Operations on Enterprise | unverified | Community only |

## Review status

Self-checked only: no independent reviewer has read this packet. Mechanical checks passed: graphql-js parse, `Neo4jGraphQL.getSchema()` with a stub, `merge-fragments.mjs` over all current worker fragments (0 duplicates, 0 unresolved references from W08), YAML parse of both YAML files, Cypher execution of every fixture/validator/query/DDL statement.

## What remains qualified

- uids with requested tokens (`device`, `technology-platform`, `sensor`, `modality`, `firmware-version`) fail INV-106 until W00 registers them.
- Candidate predicates and candidate relationship types are not registered; V-101 will not cover the new asserted types until `$assertedTypes` includes them.
- Snapshot hashes are over stored excerpt files, not original page bytes.
- Qualifier text for performance claims is in `Assertion.description` pending W08-SR-10.

## Artifacts and SHA-256 digests

Computed with `sha256sum` at the end of the run (listing below is reproduced verbatim from the command output; this report's own digest is not included in itself).

```
845a7442ac8660c3f0a2b1a6c91e749d68647d6b1cce6f7f3f8a075a935d98c7  ./01-domain-recommendation.md
8fd49d57bad2f3045279496e4aad973ab7accb26ebac22bd5e62fdcea95e28f4  ./02-cq-coverage.md
07ad48cf2771d033b8c4ce07090b8d0e6bb44b4832c020a7825f5593fbe8eae7  ./03-source-manifest.md
b5e787afa294bf6bbe9877103133c47413a23aba555d8a98d652ed240ed9d2aa  ./04-model-cards.md
56cfdedd17f5eefb27552d0626538c26e052f56e37107b7e5b713f86ebab84da  ./05-decision-seam-ledger.md
af44cacc2b9f3a96bcd7ffc059133adce6da57a50da9fa3e3dee03515d2b18a1  ./06-fixtures-and-queries.md
73672cb74fdfe5cd661b3ed627b7142139452024d479b31f8de8573e9f61606d  ./07-operations.md
374eb57a9e6d8824bb8364ab48b8c8e7835561e249e569702c0a0b798aaae819  ./checks/build-and-roundtrip.mjs
ce92675135e44d2086954de44e5d877bc1c4e950a46b2bbb42a168fd9b856905  ./checks/build-stub.graphql
d4154cc900b5dd28b70c688caffe4ce1da5a99745e968eef2c5f071e31e7e973  ./checks/gen_fixtures.py
7290f3680f88e8e3843847b2c142a0beaaaa6379d5b7237c739e380bd4da2194  ./checks/results/baseline-suite-positive.json
5a3fdd3cd1b61cb0baa74289e289caf6865da8c4c0f8d2d8bd3cadd5a7cda10f  ./checks/results/baseline-suite-with-negatives.json
b1ad52522d856ef5a8b5fe94c15a79177b2019c2a1cd270b52939181fc5114f4  ./checks/results/graphql-roundtrip.json
e5c58d29584efff221f179bcbbb65f15eb2715c20f314d3045676c9532c4e58d  ./checks/results/load-w08-clearance-and-performance-claim.json
9154767962306dc2df3fead3f095fff85de055407175d559b5c60ae343b8da23  ./checks/results/load-w08-device-firmware-assay.json
f3ffee693d6800dc5f1a26c1783713976fd59ad31a028808ddebfda888a1c6bb  ./checks/results/load-w08-negatives.json
67b6da44f6c6e9edc83f6b09df2c4375b9f3be8bb812083e3dbf411c89553a63  ./checks/results/load-w08-platform-vs-instrument.json
2d4eae018db27b568f292f32f6e66ace1ca02ccf8c70cfe70f2bd8645bab1d94  ./checks/results/operations.json
83fcce89c4ba82d3c08169465e33273b5e9697c4944a632a8aedb14af34d91c5  ./checks/results/queries-positive.json
490244f23c9216b1a70e5497dae8ff5f437d849ad487b996618f9cf624f53ca1  ./checks/results/validation-positive.json
95705071effe0291c4550029c92b44becb63a69289f9ae239b4fa398cf4819b8  ./checks/results/validation-with-negatives.json
75794a94b0f88ed7e9b2e64268755c4e5b9d8b2078dc2365715622a7a6b49180  ./checks/run-all.sh
6e7a8032601b28ebbbe09414b03356bd3085c9aa855a364a29155e7a1e06fcbf  ./checks/summarize.py
6459819a708003f003d5b4537dc04905ea17428831579ffe5562c163a4f0277e  ./fixtures/excerpts/fda-510k-K243236-record-2026-10-04.txt
be748355ee5e19244e9b35f51554eac5f315aa8df972bd9d28cc58e96d450e70  ./fixtures/excerpts/fda-K243236-pdf-2026-10-04.txt
3a4719b2fd975d8ba7c2dc715805f5a958cdb4b69fc368324ee434257e5be95a  ./fixtures/excerpts/fda-whoop-closeout-709755-2026-10-04.txt
4eb3ad2196607618fa69f2a20ec590a56ba0b86f29ad457af5f9741719a96a34  ./fixtures/excerpts/illumina-epic-v2-product-page-2026-10-04.txt
b3a580ffbcea0915a56c0da674fb2d9f2c8911811b931953c32f52fce3dcb1df  ./fixtures/excerpts/whoop-4-0-firmware-release-notes-2026-10-04.txt
518ec912ffef67e7844f6350f99837cebf17be3db90bb545e7e19301fb0372b7  ./fixtures/excerpts/whoop-locker-heart-rate-2026-10-04.txt
79749a46b4ef58ba0d032704ab040d7067f2f4b2da74781ece8804dd6365b9b3  ./fixtures/w08-clearance-and-performance-claim.cypher
88c9ada84c1dab5d3061c1e583d15787a02d67d44ba714649820a6a7a55b50b5  ./fixtures/w08-device-firmware-assay.cypher
25f2d4528005318768cff0bd38e145f92a156692e04d67bc7becb6e5097b0254  ./fixtures/w08-negatives.cypher
71f8577a7c81e759152ec6e9eba3492494c0cc47e42abb2c2b722d258af8c85e  ./fixtures/w08-platform-vs-instrument.cypher
69c6c1b84f4e61bdf60710c5f8ae34af0c9446540a8d02a6d1e385d4c8ba2591  ./fixtures/w08-queries.cypher
41d4c3ef7514ac7323bb214e502ade0c59a09c340b24f0da2a0914740d4ce295  ./fixtures/w08-validation.cypher
4a954dd671094d26fe147fcfdbf82949e5911e39276374d0be959db6f2982826  ./migration-map.yaml
d60c53be078c0ee93c0e959d9966482179b396b9c485e0b51312a30f6400191e  ./operations.cypher
c010f324f9bd22a5489ece653419a40d194c85fa172340fb642e9b6a09296760  ./sdl-fragment.graphql
a7a6f45643421b1f94cb68eff00186119223738bb8e3b2b75ff1e934872bb45f  ./seam-requests.yaml
```
