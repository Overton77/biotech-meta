# W06 completion report

- **Worker:** W06 Treatments, procedures and intervention modalities. Ran as **Opus 5.5** (`claude-opus-5-5`).
- **Run:** `run-2026-10-04-fable51-01`, coordinated by Fable 5.1.
- **Times:** first recorded timestamp 2026-10-04T00:59:08Z, taken after the mandatory reading had started; reading began a few minutes earlier, and its exact start was not recorded. End 2026-10-04T01:35:24Z.
- **Repository:** HEAD at work time was `b48a21a`. This differs from the baseline `530e05c` because other workers committed in parallel. No authority file in W06's scope changed. W06 wrote only inside `workers/W06/`.

## Deliverables

All eight are complete: `01-domain-recommendation.md`, `02-cq-coverage.md`, `03-source-manifest.md`, `04-model-cards.md`, `sdl-fragment.graphql`, `migration-map.yaml`, `05-decision-seam-ledger.md` + `seam-requests.yaml`, `06-fixtures-and-queries.md` + `fixtures/*.cypher`, and `07-operations.md` + `operations.cypher`.

## Tools actually used and their availability

| Tool | Use | Availability |
|---|---|---|
| ClinicalTrials.gov MCP | NCT03745287, NCT06597656, NCT01561053; `AREA[InterventionType]` filter counts | available. It does not expose per-intervention types; the pairing in NCT06597656 is an inference from 2 interventions and 2 matching types. |
| Firecrawl scrape/search | FDA CBER CASGEVY page, package insert PDF (directQuote), OOPD records 714319 and 465514, NDA 209176 search | available |
| Tavily extract/search | Next Health TPE page; Circulate and GeekWire snippets | available (partial extracts) |
| ICD-10 Codes MCP | ICD-10-PCS 6A55* (FY2027) | available |
| WebFetch (fda.gov) | — | **BLOCKED** by the egress proxy |
| curl to ClinicalTrials.gov API v2 | — | **BLOCKED** (CONNECT 403). Registry version history was not retrieved. |
| Embedded Neo4j 5.26.31 Community + `run-cypher.mjs` | all fixtures, validators, the baseline 174-query suite and operations | available. Results are in `fixtures/results/`. |
| `@neo4j/graphql` 7.6.3 / graphql-js 16.14.2 | fragment parse and build with stubs | available. Build OK (714 types, 43 queries, 51 mutations). |
| `merge-fragments.mjs` over all current worker fragments | collision check | no W06 duplicates. Undefined W06 references remain to MerchantListing/ListingEdgeProperties (W15), SafetySignal/SafetyEdgeProperties (W17) and EvidenceStrength (W10), whose fragments were not yet present. |
| PubMed, bioRxiv, NPI | not used; no modeling question required them | — |
| Exa, bigdata.com | — | failed to connect this session |

## Research gaps (qualified, not invented)

- **RADICAVA approval.** Known only from a search extract. Date, applicant and action letter are not captured, so the approval assertion is EXTRACTED and V-W06-01 still reports `edaravone-als`.
- **Treeway designation.** The source does not say whether it was withdrawn or revoked, nor when. statusKind is null (W06-SR-05).
- **CASGEVY dose basis.** The label dosing sentence was not returned, so the dose is NOT_REPORTED.
- **CASGEVY STN mapping.** Which STN each OOPD approval belongs to is inferred by date only.
- **Next Health page.** Sections were elided by the extractor: no plasma volume, replacement fluid or performer.
- **Circulate and GeekWire.** Captured as search extracts only, so their assertions are EXTRACTED and not projected.
- **ICD-10-PCS.** The first fiscal year of each code was not captured, so mapping valid time is UNKNOWN.

## Seams and coordination

- **Adopted W09's `FOLLOWS_INTERVENTION_DEFINITION`.** On reading W09's fragment, W06 withdrew its own proposal of two separate relationship types for the study-side concept link, so that one meaning keeps one relationship type. W06 declares inverse views only.
- **Dropped FoodProduct from `TreatmentComponentTarget`.** W05 retires FoodProduct into W04 Product.
- **Matched W13's ruling.** W13's `STATUS_OF`-only storage (DESIGNATION_FOR and APPROVAL_FOR as field names) matches fixture 05.
- **Open requests in `seam-requests.yaml`:**
  - W06-SR-01: registry additions.
  - W06-SR-02: uid tokens `treatment` and `procedure`.
  - W06-SR-03: W09 promotes the concept link.
  - W06-SR-04: W16 EMPLOYS → Procedure.
  - W06-SR-05: W13 ended-designation kind and the V-333 alias.
  - W06-SR-06: W01 predicates and offeringRole.
  - W06-SR-07: W05 FoodProduct re-pointing.
  - W06-SR-08: W15 session bundles.
  - W06-SR-09: W17 property type.
  - W06-SR-10: W10 hint and forbidden implication.
  - W06-SR-11: W03 `treatedBy`.
  - W06-SR-12: W00 predicate registration and news SourceKind.
  - W06-SR-13: W02 cell/gene material, a scope candidate.
  - W06-SR-14: W21/W23 Recommendable.
- **No kernel-change requests.**
- **Baseline naming inconsistency noticed** (for Fable, not W06's to fix): validator V-432 counts `COMPARES`, while the registry and catalog name `COMPARES_IDENTITIES` for EquivalenceAssessment.

## Confidence by dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Concept vs administered intervention vs product separation | high | Three real records (CBER, label, registry); executed Q-01 and Q-02 |
| Designation and stage text not read as approval | high | OOPD records; V-W06-01 and V-W06-03 fire on negatives and on the unverified edaravone approval |
| Procedure definition vs offering vs step vs performance | medium-high | One real offerer page (partial); the protocol step is SYNTHETIC; the W16 range change is still pending |
| Modality as a list; registry type kept separate | high | Label wording plus registry types |
| Modality-specific detail (cell, gene) | deliberately deferred | No failing CQ; scope candidates SC-W06-01..03 |
| Intent enums (vocabulary completeness) | medium | Derived from the live free-text fields and these cases; not calibrated against a large corpus |
| Operations on Community | high | All constraints and indexes executed; Enterprise constraints unverified |
| Merge readiness | medium | Depends on W15, W17 and W10 fragments, and on W09 promoting its candidate relationship |

## Review status

Self-checked: the fragment builds; every fixture statement, every W06 validator and query, and the 174 baseline queries run with expected rows. Positive-state baseline rows are limited to documented, expected items (V-336, V-333, informational V-401b, V-514b, V-118). Not reviewed by another worker or by Fable.

## What remains qualified

- Every fixture node owned by another worker is a minimal reference shape, not that owner's model.
- `SourceSnapshot.contentHash` proves the stored excerpt (basis STORED_EXCERPT_TEXT), not the publisher bytes.
- FI-W06-15 (an offerer's benefit claim never creates intent) has no automatic validator.
- The `interventions` module is a candidate.

## Artifact digests (SHA-256)

```
ba8ad8531eb02fc31faa2288a2e2320ad4b31619150fad9a0b3bcc06da2570c6  01-domain-recommendation.md
bd683ca5cd173f487e2b63b2626a3c229bb782d73ebcaca1d8185e3bd6d73ee6  02-cq-coverage.md
d7c9ee60b172e7af54765380d948f5fdceeb9672b5b97d8c6327d90034666556  03-source-manifest.md
634306896f2d06d474855e6312f19a6ba82817942fc33b0e6b7a81091be6190b  04-model-cards.md
d0174550857f212d5ac6a28af665793446c5d9cae47ed0318f18ae459f497249  05-decision-seam-ledger.md
e36bd7c9c46626354018d5cde4460dcc2129b5b331ca8d613081a9988ddbd222  06-fixtures-and-queries.md
4fdaec196f7e6b2a2c4d068b035f15074f19f32b4ca34a39c4caa47ce7c59e8e  07-operations.md
1d0a30288ef17bca3829ac510342d3573aa3b2b1eb409bdc8ad9adacfbaf1f1a  fixtures/00-shared-sources-and-referenced-identities.cypher
0daf3ba6f0d340d2c67b573a8cc17d41a1fe1cb875fc8bec435b1e042bab4316  fixtures/01-three-identities-exa-cel.cypher
32926fb94957b7f44132965d446c9a005fd194a5c860429734aab63e1e781eb4  fixtures/02-modality-vs-registry-type-horizon.cypher
ff4412fa825bd733ea5ba6b435367070bf0b76a3982c75b571ab4ac90c1a4b61  fixtures/03-procedure-definition-offering-step.cypher
153f4118613c104f51a6ce0ac9698607c93d273d8b681569fb4e4e85751263eb  fixtures/04-development-stage-vs-regulatory-status.cypher
3055e224b5e83d80af0225178b6b30d5b68d59fc21f0412bfd8ee50b9a5082b3  fixtures/05-orphan-designation-not-approval.cypher
8fb3dc54a7f8d0de5f7fde23b9bbeabba71205ed17178b1d630a2958851fc244  fixtures/98-capture-fidelity-adjudications.cypher
68728f9c842fe3126397e17b65c5c592110641b52ed41dee3f2f102dca8824fd  fixtures/99-negative-cases.cypher
c4ca8eeab23a8b3831002eb317a5a478c608e85bbda0d639ae8b5c5f2573da10  fixtures/excerpts/ctgov-mcp-NCT06597656-NCT03745287-NCT01561053-2026-10-04.txt
f079071292e35a0c4de0d327320458b364e80f0def6d19243c0a2d54abcead74  fixtures/excerpts/fda-casgevy-package-insert-stn125787-2026-10-04.txt
9cc149de82bf314c95adde28bb78ad0660fb1534b1c80a364d301e90bc5d7801  fixtures/excerpts/fda-cber-casgevy-page-2026-10-04.txt
5f36fac79ff1652c0aca38c3e05c201c459701c5c898ff5ad54829a416b963d7  fixtures/excerpts/fda-oopd-edaravone-treeway-465514-2026-10-04.txt
d30dbf65385355d8ddcf7fafb7c0423c3e28fd6643c6ae2352ec2556fa6d3db6  fixtures/excerpts/fda-oopd-exagamglogene-714319-2026-10-04.txt
46a83bc99dd93fb1cc4db2881000f5b07d79eeac723554d5dc01264476b2616c  fixtures/excerpts/icd10pcs-6A55-fy2027-2026-10-04.txt
695a81ff06428f3a0c4ea52e6537a8e0fb1640f72ae44bfc795cf061fd4a6cf8  fixtures/excerpts/next-health-tpe-page-2026-10-04.txt
10e6a6a321aa254ba092f08fdf7de51659ca2f41b1495a83f17974792b67e852  fixtures/excerpts/search-extract-circulate-geekwire-2026-10-04.txt
fd4e79b0a75cad19168233349ed1e6038457cb4c81d450e7cebcec54c8d05d21  fixtures/excerpts/search-extract-radicava-nda209176-2026-10-04.txt
0b686581f5350bc95d5101ddda7fdf0975abe59fb9724885b11090b92ba20ca4  fixtures/results/00-shared-sources-and-referenced-identities.json
ee7bffc39b83af72b72938eae7e024025db1d4b1a704d4ba5999251c71ccb726  fixtures/results/01-three-identities-exa-cel.json
78d88cd3c8152cd8b209f85b38578b49221b01c7a415c3bc8731b4ddfc5bb92a  fixtures/results/02-modality-vs-registry-type-horizon.json
b84641fbc62214a2b68bf5db589bb5c002dc68bdeb01d314e067b5ba01122d01  fixtures/results/03-procedure-definition-offering-step.json
957beb0f5fa5de546466e54eac36731d8daa9fdb031853caa1b2627377cdcf01  fixtures/results/04-development-stage-vs-regulatory-status.json
bfa81a3f14e1fb3b35f57b53a281fdef7a064be3fec16dd900e37ebae5add31c  fixtures/results/05-orphan-designation-not-approval.json
60a3adf8dfd87df7e7b9d7932cd49bb36038ac023bed4c69cbd70e0c6261ff64  fixtures/results/98-capture-fidelity-adjudications.json
084f0e37e82962d15247a7ecd892cdd3151485ab4a5d59231a05def586a75776  fixtures/results/99-negative-cases.json
29f637622d369e22a4f2c383b6f657c3e947cc731f8430223d3e7ca7a18859b0  fixtures/results/baseline-positive.json
966b248efadcc64822124ad4ff239049e03e28e6f655ccb5c043f83f35580f8b  fixtures/results/baseline-with-negatives.json
06a86b4e477a4722aca25e5105e26a24ff8906900342e43d4ae6fb8ecfcc00fc  fixtures/results/constraints-summary.txt
e86e825c9ce1ad23b6d3ede747db6e2be7248031f83edbd430e44d36ed0249d8  fixtures/results/dbms-components.txt
3b544b5a1c9d935f79f2e6efb84ca8642a84114540c311a1d0055f9b388a92cf  fixtures/results/operations.json
909d5d65b3188e9b332490a66f2e8d4378c675dedcfb10b96cc7ae39769a81d0  fixtures/results/queries-positive.json
713bf70e0a5c393390cff2ce23cdd29d8503f19356d3ad229bbfa50f86f28ae5  fixtures/results/validation-positive.json
be1349007026def282cbf9cd7a3751b8abeed84d830b91d61f5e1d1970e192cb  fixtures/results/validation-with-negatives.json
f602f4c9a98644c708350d227c05e51db48935a9f675ca7133552ac8d9e89c41  fixtures/w06-queries.cypher
fb1e99edcdf21aa017932e65a9576610ac05424509080d5d5c9c27383edb2ed2  fixtures/w06-validation.cypher
e06829e180a64bcfcf6cf586a05eacbe7a65b34f15bdc0f87e40a7d5399bd7ef  migration-map.yaml
3072f950d705c7208d2acb8304444aa947ac76bfb9dda9e12c7385dac12d9c0e  operations.cypher
0c76311364ab4e03f9caf839a219f73acd6bfe78a78fa03b5e77b5188b879c98  sdl-fragment.graphql
1a024dbe4deb28ae6fdd7a43275cddc9828d193428e0fdef86c33c03bf359c15  seam-requests.yaml
```

(Digest of this report itself is not self-contained; Fable records it on admission.)
