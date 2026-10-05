# W05 completion report

- Worker: W05 Food, lifestyle and exposures. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start: 2026-10-04T01:00:30Z (first research call). End: 2026-10-04T01:37:54Z (digests below computed at that time).
- Authority digests used: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112` (as in `00-baseline.md`).
- Writes: only inside `workers/W05/`. Scratch work (harness copies, JSON results, DB stores) stayed in the session scratchpad.

## 1. Tools actually used

| Tool | Use | Availability |
|---|---|---|
| Firecrawl `firecrawl_scrape` | FDC API JSON (abridged, full), FDC documentation and FAQ, CT.gov API v2 modules, EPA IRIS landing page and summary PDF | available; used because direct egress was blocked |
| Firecrawl `firecrawl_search` | locating FDC documentation pages | available |
| ClinicalTrials.gov MCP (`search_trials`, `get_trial_details`) | finding Brazil-nut / diet trials; NCT03728127, NCT03111355 summaries | available |
| `curl` to `api.nal.usda.gov`, `clinicaltrials.gov` | direct retrieval | **BLOCKED** (proxy CONNECT 403); recorded as blocked, not absence |
| PubMed, Tavily, bioRxiv, WebFetch | not needed for the settled questions | not used |
| Run harness (`@neo4j/graphql` 7.6.3, `graphql` 16.14.2, `neo4j-driver` 6.2.0, Node 22, embedded Neo4j 5.26.31 Community) | parse/build of the fragment with stubs, GraphQL round trip, fixture runs, W05 and baseline validation, operations and constraint probe | available (shared scratchpad harness; other workers' JVMs were running concurrently, so runs were slow) |

## 2. What was executed (run, not just parsed)

| Check | Result |
|---|---|
| `sdl-fragment.graphql` graphql-js parse | OK |
| `new Neo4jGraphQL({typeDefs: stubs + fragment}).getSchema()` | OK (638 generated types, 39 queries, 45 mutations; `searchFoodItems`, `searchLifestyles` generated) |
| Merge checker over all fragments present at 01:35Z | no duplicate W05 definitions; only W05 reference unresolved: `SafetySignal` (W17 fragment not yet present) |
| GraphQL round trip on fixture data | Exposure agents resolve one typed row per edge; `FoodItem.variantOfConnection` and composition connections resolve; earlier union with both `FoodItem` and `IngredientMaterial` returned the same node twice (`run-evidence/graphql-union-overlap-before-fix.json`) → D-W05-11, W05-SR-09 |
| Final fresh-store run (`run-evidence/final-run.log`, `final-run-summary.json`) | `operations.cypher` 11/11; fixtures 01–06, 08: 100/100 statements ok; W05 validation 0 rows; 9 CQ queries return the expected rows (06 §3); baseline suite 174/174 ok with V-221 (1 row) and V-231 (2 rows) as seam-backed findings plus informational V-118/V-401b/V-514b; after negatives: every V-W05 check fires on its target, baseline V-10x, V-112, V-423 also fire; probe: P1–P3 rejected by constraints, P4 accepted (Community does not enforce presence) |

## 3. Research gaps

- IARC processed-meat monograph not retrieved → source-defined food groups and physical agents remain candidates (CQ-FL-C05).
- SR Legacy's own documentation PDF not retrieved; the per-100 g edible-portion basis is quoted from FDC Foundation Foods documentation and the FAQ portion formula.
- No primary publication for DICA-NUTS or SUBRANUT read; the DicaBr diet definition is unknown (recorded as `notReportedFields`).
- CT.gov registry history versions not retrieved.
- IRIS summary PDF pages 7–23 unread; Firecrawl `query` mode quotes are LLM-selected (`directQuote`) and were not compared to raw PDF bytes.

## 4. Unresolved seams (owner: request)

W00: tokens `exposure`, `lifestyle` (SR-01); union rule (SR-09); assertion subject range (SR-13). W02: FoodItem as IngredientMaterial specialization + `materialKind FOOD` (SR-02); taxon link (SR-03); six composition qualifiers on `QuantitativeContentProperties` (SR-04). W03: Lifestyle domain for derived mechanism/association edges, route vocabulary, V-231 scope (SR-05); ambient-level basis (SR-07). W09: Protocol in `InterventionDefinitionTarget`, V-221 refinement, overlap in `LegacyEvaluatedIntervention` (SR-06). W16: `StepSubstanceTarget` overlap, Exposure out of `StepInstrumentTarget`, step practice target (SR-08). W18: `INVOLVES` single meaning (SR-10). W21: `SELF_REPORTED_PRACTICE`, RECOMMENDS range and its citation property name (SR-11). W17: safety subject range, `HAS_REFERENCE_DOSE` (SR-12). W06, W01, W04, W22, W10: union member replacements and applicability inputs (SR-14…18).

## 5. Confidence

| Dimension | Confidence | Why |
|---|---|---|
| FoodProduct retirement into Product | high | every live field has a home; W04 enum already has CONVENTIONAL_FOOD; fixture and probe show one identity |
| FoodItem as IngredientMaterial specialization | medium-high | reuse is demonstrated end to end; depends on W02 accepting the label (fallback documented) |
| Exposure as Entity characterization | high for the shape; medium for enum completeness | one agency record (IRIS) and one synthetic practice case; physical agents untested |
| Lifestyle boundary (concept vs Protocol vs assertion speech act) | high | matches catalog forbidden implication and baseline fixture shapes; validators fire |
| Composition modeling | medium | aligned to W02's current type; six qualifiers pending |
| Diet-arm modeling | medium | aligned to W09's `FOLLOWS_INTERVENTION_DEFINITION`; Protocol target and V-221 refinement pending |
| Enum values | medium | small, source-grounded; ExposureSetting OCCUPATIONAL/ENVIRONMENTAL lack a fixture |

## 6. Review status

Self-reviewed against contract sections A and B, the brief's fixture rules, and the baseline validators. Not reviewed by other workers or Fable. Nothing here is accepted ontology.

## 7. What remains qualified

- The fragment builds only with stubs for other owners' types; the merged build is Fable's.
- Enterprise existence constraints are untested.
- `hu:exposure:*` and `hu:lifestyle:*` uids use unregistered tokens until SR-01 is ruled.
- Synthetic fixtures (product, podcast, protocol page, 2025 composition record) say nothing about the real world.

## 8. Artifacts and SHA-256 digests

Computed at the end of the run over the files as written (this report excluded, since it contains the list):

```
b7adb39d9b32ddffc5173b2c3a910696c2c5be8f2db1ec5b1ce704ba03c09bf6  ./01-domain-recommendation.md
c755e6adab5732901782859c00bcc01b36986e79828d05f91fd04683ce43366d  ./02-cq-coverage.md
863caa19b2dcb6bbe51b764285d61f332a5e302cfb9ee4b12a5bba00765a59dd  ./03-source-manifest.md
507fc19f80e653990600f7ae80fcd582a18117b8e061e000b3ce460c1d9216a9  ./04-model-cards.md
6789bd49e8cd9209454cf3fd42606ae4c636169499daba134b9e332eb837d522  ./05-decision-seam-ledger.md
abd66bf87da07e47b94eef5f39d0b9d242dcc8550567d90694fa12a6ae6faf05  ./06-fixtures-and-queries.md
617bba40e64ebb5b03fef1edb8c19b3fae7f462fed771f6ffd9d0d0bde17d995  ./07-operations.md
1149997a5ced0290e9711c379c5660bfddce8100c092551a00d722983b016fdf  ./excerpts/ctgov-excerpt.txt
39f83269d723fe22bb3bfc1957e5665e4ce69729fd9708ec2e9aa6f5a43570c5  ./excerpts/epa-iris-selenium-excerpt.txt
86d97e417b00933a34777cc446364844f244d21b16aa9abded7188ea80ebfb8f  ./excerpts/fdc-170569-excerpt.txt
b5903b8df1df3d1e7c51a363928026ee3f346d16f48d9a3b45dff776a22d4b12  ./excerpts/fdc-docs-excerpt.txt
8aa8015aa1279172de10214e61837baef7153531d1e523b67a89748e39b1556b  ./fixtures/w05-01-food-study-intervention.cypher
36cad8fd57db4e55f023cb40a81d5d6b664fae9a49841c243842a309047835d9  ./fixtures/w05-02-diet-arm-composite.cypher
9cdbfe04c72ec6967088c97ffd69874de33b194607e68f504f66d48d779ea653  ./fixtures/w05-03-food-product-is-product.cypher
cb43a4611588263025eaebaaf3d97015b23445574f5709254f355b1d39e5ab56  ./fixtures/w05-04-exposure-vs-protocol-step.cypher
0476ac7c29b7464b9cf1529ba8bc6b26d4301ef9bffc863cf080b9bcb0ed1e5e  ./fixtures/w05-05-lifestyle-reported-vs-recommended.cypher
b779fbb1cddd8608e29c9dc46d1ff8bb84a07ac15a483e039f2e9dbfeb29c06f  ./fixtures/w05-06-temporal-correction-late-arrival.cypher
107233721dead8449d552c387cb353dbfb6eba4e4c6fb0f3bee76ed0864ad4e8  ./fixtures/w05-07-negatives.cypher
5c11e0c0163b21fc9e77d43b74b223c9c826668b2bad0824837d6ce5b31c342e  ./fixtures/w05-08-capture-adjudications.cypher
3a48b4705a5df53d10f3d1304a7c0a09c58b882b88ba74e2547c18feb0c6b0e1  ./fixtures/w05-09-constraint-probe.cypher
88f0ee3e612ccafadf6584b19f8818ab0a283070b93d4a3c188d86e1f8d57140  ./fixtures/w05-cq-queries.cypher
1c98ea450b6a6ac4a20133d4c21fedf40cb6bb64815e5ec2268b82c77fd86233  ./fixtures/w05-validation.cypher
94bd45a660926ea4366e69696b507588ae29219b941cff9fb68c5b68dcecc0cb  ./migration-map.yaml
62151f1e6997dfba418e9a4cb9d34dceccedd8803de86bef165f4b96543ab3b4  ./operations.cypher
6014baf639f8d4e93f04a61ea9b10a8dbe2c32912118dd2367d89acc27696edc  ./run-evidence/final-run-summary.json
ab93a9f5a44c4c89dae2f2c1ab09fb84d09f68c602bc4bcdf26d01b4e8af3449  ./run-evidence/final-run.log
45ea410bdcf65b0a764d7b7c086c506f32d595c0a4fe08835293dd8681a97f06  ./run-evidence/graphql-roundtrip-final.log
45cbf39b71c2ec1e287ca4c0da8149e70f14f692243bcaeebadd8962f5ac1f1b  ./run-evidence/graphql-union-overlap-before-fix.json
69ebeededcea446a5ac889283b043b4a350e786703c8a63a9ea03a2ad7292d83  ./sdl-fragment.graphql
2ff522a7c36c9aedd14b4405159ee9395a4da81db08031c177a6786dd563af2a  ./seam-requests.yaml
```
