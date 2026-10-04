# W11 Completion report

- Worker: W11 Manufacturing, specifications and supply readiness. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start: about 2026-10-04T00:56Z (first read of the brief). End: 2026-10-04T01:37Z.
- Admitted against: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112`, frozen contract `01-shared-contract.md`.
- Wrote only inside `workers/W11/`. No repository file outside this directory was changed.

## Deliverables

All eight are complete: `01-domain-recommendation.md`, `02-cq-coverage.md`, `03-source-manifest.md`, `04-model-cards.md`, `sdl-fragment.graphql`, `migration-map.yaml`, `05-decision-seam-ledger.md`, `seam-requests.yaml`, `06-fixtures-and-queries.md` with `fixtures/*.cypher`, `07-operations.md`, and this report. `tools/` holds the scratch runner, the hash renderer, the API round-trip script and the stubs used for the build, so the results can be reproduced. They are not deliverables.

## Tools actually used and availability

| Tool | Use | Availability |
|---|---|---|
| Tavily search / extract | all new retrievals (SEC 10-Ks and 13D, FDA pages and PDF, EFSA copy, company pages) | available |
| WebFetch | sec.gov EDGAR browse | **BLOCKED** (`EGRESS_BLOCKED www.sec.gov`) |
| curl `data.sec.gov` | filing index | **BLOCKED** (proxy 403) |
| Tavily extract of efsa.onlinelibrary.wiley.com | official EFSA page | **failed**. Used a third-party-hosted copy, marked SEARCH_EXTRACT |
| Firecrawl, PubMed, ClinicalTrials.gov, bioRxiv, NPI, ICD-10 | not needed for W11 questions | not used |
| `@neo4j/graphql` 7.6.3, graphql 16.14.2, neo4j-driver 6.2.0, Node 22.22.0 | SDL build and API round trip | the run harness's installed copy (scratchpad `h/node_modules`) |
| Neo4j 5.26.31 Community, embedded (`neo4j-harness`) | fixture, validation and negative runs | ran; one instance was killed mid-run (host memory pressure from parallel workers). Restarted with `-Xmx768m` and the checks were repeated |

## Validation evidence (what was run)

- **SDL:** `sdl-fragment.graphql` parses alone with graphql-js. Stubs plus the fragment build under `@neo4j/graphql` 7.6.3 (649 generated types, 28 queries, 33 mutations, no vector provider).
- **Fixtures:** 01–04 load alone and together with `examples/filing-vs-capability.cypher` (143 W11 statements and 81 inherited statements, 0 errors).
- **Baseline suite:** the 174-query baseline suite gives 0 errors and 0 failing rows. The informational rows (V-118, V-331, V-401b, V-514b, V-522) all come from the inherited fixture or are counts at zero, checked by uid.
- **W11 suite:** the 16 W11 queries return 0 failing rows. The single informational row V-W11-07b is expected.
- **Negative mutations:** all 10 fire exactly their expected validators (06 table). The baseline V-504, V-505 and V-112 miss N2, N4, N6 and N10. That gap is the failing case behind W11-SR-12.
- **CQ queries:** all 13 return the expected rows.
- **Idempotence:** reloading the fixtures leaves 203 nodes and 343 relationships unchanged.
- **API round trip:** reads, connections, a create-and-connect mutation and enum rejection all pass. **DateTime projections need APOC** (`apoc.date.convertFormat`) under 7.6.3. This is a deployment requirement for the whole final schema, not only for W11.
- **Not run:** Enterprise constraints, the merged operations file, and any deployed database.

## Research findings that settled modeling questions

1. **Capacity in filings is rarely an output rate.**
   - Cyanotech states installed capacity as pond area (m2) and volume (L).
   - Meridian (a third party, Schedule 13D) states utilization from imagery (about 50 % of astaxanthin ponds empty).
   - NAI states only "persistent excess capacity".
   - Result: capacity is a value plus a UCUM unit plus a basis, with verbatim text kept, and no derived ratios.
2. **Capability history is real and four-staged.** NAI's Carlsbad facility was:
   - PLANNED from 2021-08-20 (press release);
   - OPERATING from April 2023;
   - SUSPENDED from October 2023;
   - OPERATING again from May 2024 (FY2024 10-K);
   - with a sale announced as planned in the FY2026 10-K.
   This supports immutable states plus episodes. A late filing yields past-valid episodes, and a VALIDITY_BOUNDED correction needs a `derivationRule` (V-503 caught its absence).
3. **Specification versions have no public version label.**
   - The Niagen GRN 000635 dossier (2015) and the EFSA 2019 table give different solvent and water limits for the same branded material. Neither has a label.
   - The EFSA assay limit is explicitly a shelf-life limit.
   - Result: the payload is criteria plus a digest; version identity comes from the payload hash; the criterion needs a `limitStage` (W12). A specification change is not a new material.
4. **A food or supplement facility's FDA registration is not public** (21 CFR 1.243(a)). For NAI, registration is therefore unknown, not absent. A public agency registration record exists for 503B outsourcing facilities, and FDA states that registration is not a CGMP determination. NAI's page calls the FDA GMP standard a "certification". It stays a claim, adjudicated INSUFFICIENT.
5. **CL-005 is closed without ProcessMaterial.** Every input in the GRN 000635 synthesis is either an ingredient material (nicotinamide, same uid) or a defined chemical substance.

## Unresolved seams (owner)

- W12: criterion edge name, plus `thresholdUpper` and `limitStage` (W11-SR-03); material lot traceability (SR-13).
- W00: uid tokens (SR-08), exclusivity partitions (SR-04), candidate predicates (SR-09).
- W01: Organization and Facility field slots (SR-06); deprecate LocationType GMP_FACILITY and PILOT_PLANT (SR-07).
- W02: IngredientMaterial and ChemicalSubstance field slots, confirmation of Material retirement, and `specificationOwnerUid` (SR-05).
- W13: RegulatoryInspection candidate (SR-10).
- Fable: ProcessKind values (SR-01), forbidden implications (SR-02), V-324r (SR-11), assertedTypes and V-504/V-505 lists (SR-12), and T-002 (D-W11-01, needs W04 concurrence).

## Confidence by dimension

| Dimension | Confidence | Why |
|---|---|---|
| Capability model (stage, episodes, INV-305) | high | real four-stage case, run fixtures, 10 negatives |
| Capacity basis and unit | medium-high | three real sources; no output-rate example captured |
| Specification payload (D-009) | medium | two real dossiers; criteria fields depend on W12; the EFSA table was read from a copy |
| CL-005 retirement of Material | medium-high | one detailed route; the reopen criterion is stated |
| T-002 module move | medium | structural argument only; W04 not consulted |
| ProcessKind value set | medium | 7 of 11 values backed by captured cases |
| Source capture fidelity | medium | SEC and EFSA content came through search/extract services, not archived bytes; quotes are verbatim as returned; GRN comparator glyphs are an OCR interpretation |

## What remains qualified

- No snapshot was hashed over real bytes (all SYNTHETIC_FIXTURE).
- SEC filing dates are not captured: only fiscal periods, plus a year for the 13D.
- The USP monograph content is licensed and unknown.
- NSF and SSCI listings for NAI were not captured, so certification scope is unknown.
- No inspection record was captured for NAI.
- Enterprise behaviour and APOC-enabled API reads are unverified.

## Artifact digests (SHA-256, at 2026-10-04T01:35Z, before this report was written)

```
a6dfcda1ec49375e729cef05a00ce4a70eea096672632123a939330473c36e59  01-domain-recommendation.md
b1094f1e6dcd5c7908378ef860f15625dd03f1540849c2e765bedabb11e8892a  02-cq-coverage.md
ba30b6c0138efc0663f7c659292fe4006462cae0cea6c80ea6ae98d648b62d39  03-source-manifest.md
256c2a0cc7fdb3b1659a8ad1d2244cc6b076e6faa2d74fc00be1bf4763c0a37e  04-model-cards.md
3d3d43e65c86674e4162aade2da59eb59edb79c3d20bdb0f054593c75dead2cb  05-decision-seam-ledger.md
74419f04781ca36a69a4e910fed080e038d14efd851ec2027197cf2b6835408c  06-fixtures-and-queries.md
7e874129fff772f9d5920c488d8d99f57d4ff7871eb103cf4e49310ca5a4d0c4  07-operations.md
7dce26aa2225fca262df67f4cb5e670e3f0129de6b74d22721776115cb30b747  migration-map.yaml
54bb295cf3cb008210d401ef97ddfccafe238ef1b44718a15a639eea6e27c1c9  seam-requests.yaml
d2a5905acf612d368308d2ddc9aee467f7da67bf997c88d919128929813c4003  sdl-fragment.graphql
404d773fe53fe65a646690f1a70f0c591e747a30fffae67936b6997602ad226a  fixtures/01-capability-promotion-filing-operating.cypher
8b600e0d33b0394e21f534702b71dbfd6ea0a3a42df40b974ed8ed6c56c3640e  fixtures/02-capacity-basis-nameplate-vs-utilized.cypher
ee7014a16f9a0a29c6127d59177ea578120a9f3cbb96ca8b9a923e71b43675ce  fixtures/03-specification-versions-and-process-inputs.cypher
57eda2d6e9d4414b40f00d7cc36913a88206f6e750c1113c0628bf9be47963b4  fixtures/04-cgmp-claim-vs-certification-registration-inspection.cypher
c4749b77ffa953e6933faed8b5a2c5a8d2d73ee5532be37297f8d60439983e0d  fixtures/05-negative-mutations.cypher
82d9d2f4e2667d37de136863551204fde6e0485cb7224042ebd60c6de1b218ea  fixtures/w11-cq-queries.cypher
5bf0995ddec1918df6023a973b549b2424b57057dc050429b31453dc7d140379  fixtures/w11-validation.cypher
```

## Review status

- Self-review only: the adversarial objections are in the 05 ledger.
- No cross-worker review yet.
- Nothing in this packet is a ruling.
