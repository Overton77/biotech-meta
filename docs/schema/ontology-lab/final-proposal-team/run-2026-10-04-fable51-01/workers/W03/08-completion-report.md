# W03 completion report

- Worker: W03 Biology and mechanisms; model **Opus 5.5** (`claude-opus-5-5`); coordinator Fable 5.1.
- Start 2026-10-04T00:45Z; end 2026-10-04T01:28Z (UTC, from `date -u` in the session).
- Admitted against: catalog `8fb50ff0…84f0`, live schema `86b5e0b5…f112`, contract `01-shared-contract.md` as frozen at Wave 0. Writes only inside `workers/W03/`.

## Tools actually used

| Tool | Availability | Use |
|---|---|---|
| PubMed MCP | available | metadata for PMIDs 29184669, 27721479, 31412242, 27127236, 29685734, 35584623; full text PMC5062546, PMC5932087 |
| Firecrawl scrape | available | Reactome ContentService record and database version; EBI OLS4 (MONDO metadata, two searches, one term); PubChem PUG REST CID 5892; HGNC REST SIRT1 |
| ICD-10 Codes MCP | available | search/lookup/hierarchy/validate for M62.84, E88.81, E88.819 |
| curl via proxy | **BLOCKED** (CONNECT 403) for reactome.org and www.ebi.ac.uk | recorded as BLOCKED, recovered through Firecrawl |
| Embedded Neo4j 5.26.31 Community + run harness | available (scratch copy of the run harness) | all fixtures, validators, CQ queries, constraint tests run |
| `@neo4j/graphql` 7.6.3 / graphql 16.14.2 | available | fragment parse and full library build with stubs |
| ClinicalTrials.gov, Tavily, bioRxiv, NPI, WebFetch | available, not needed | — |
| Exa, bigdata.com | failed to connect at session start | not needed |

## Deliverables and SHA-256

```
139df0466dd020d7f2f46d123a1b438fafa4833b9a10976e5c7e184b8a561ee9  01-domain-recommendation.md
235ecf2f5583cfe09d041cbd661f61e0a6cfef0498cae7f8a7235b0f4520fa76  02-cq-coverage.md
829efc27361dd0e4b4c878f5d9ffec8f200bd118a2a0e6148cdb70f657711817  03-source-manifest.md
9953615dc7f12859147802fe83c7ddd8dcb238c22ed5e80b79498b534f788a41  04-model-cards.md
b2aed57188e91e4cd1ca0f4416f0bfa4df7873e0e9343d2318972e61359e42a2  05-decision-seam-ledger.md
8e6aeb2b4e1214f38acb945a844603ee8c50b03ede27eb1f9bb50adcb9cf9314  06-fixtures-and-queries.md
523b65a9dbf8c66e4c6805c1a655b9f11d047fc152b6ebbd13b8f74ce260838a  07-operations.md
53568db393875c87f9cc33fb3f9a0edc44d0cff28df563ae8d06b8f4850271a7  operations.cypher
8d7cfc914c1f45c6778370c7c566cfc2cc377bef312ae2af0c4cfa2c821fa253  sdl-fragment.graphql
24823d6cfe52134461b530212983438a329a22bcf01730638cca5371bca39096  migration-map.yaml
2a4e5a12e2e75dbd7d3c2960284b54d087cadd7f8509f5c4e158f1f7a8ef8b82  seam-requests.yaml
3f53c73cb8761ddced4e2dc1d0e2d0813dfe723c26bbe4271076c4f231a5572c  fixtures/build-stubs.graphql
28d872bf4d29ccb787e9e2f6128cb22a556d10ce301dd62e2729c6669b1cd5a7  fixtures/gen_w03_positive.py
5152a48c2238232b5715ea7ee0bb3c730bbcb6bca0d3bcda8fc0298c9cc1ed7b  fixtures/run-results.json
8b1dca66bf3f2bc1e21c147960b9063d9e91436e5efd562faa5ca0ec11502dc6  fixtures/w03-cq-queries.cypher
d4f35a4c166aa2ec6c5111ce520c3928a94054e70620bd9f931d6e55eee3bebb  fixtures/w03-negative.cypher
377c7d088ff199fae557604062bfe25ef9528c907526a6c4912dfb97839c7e61  fixtures/w03-positive.cypher
df03e3bb90d0f6dd28d6ff2891a8f6ca2ac167041ac0a93ecf1308bd9d12e836  fixtures/w03-projection-job.cypher
39864292ba391bad9e0f2c7e346c1b4ec2a922cbd7a97634874c344b0fd6bc64  fixtures/w03-validation.cypher
```

## Verification status

- SDL: graphql-js parse OK (fragment alone); `Neo4jGraphQL.getSchema()` OK with stubs (1,235 types, 46 queries, 54 mutations); `@settable(false)` removes derived fields from create/update inputs. No `extend`, no `@cypher`, no new `@alias`.
- Fixtures: positive 295/295, projection 7/7 twice (idempotent), negative 20/20, CQ 11/11, W03 validators 25/25, repository suite 174/174 statements executed; expected rows matched (06, section 2). Constraints: 12/12 Community statements applied twice; five violating writes rejected.
- Not run: Enterprise constraints and RBAC; the merged final schema (Fable's step); fixtures of other workers combined with W03's.

## Key findings for Fable

1. **Validator conflict (kernel, W03-SR-01):** verbatim V-233/V-234 reject every mechanism projection that V-112 accepts, and vice versa (N12). Proposed V-233r/V-234r included and run.
2. **CL-002 boundary implemented** in the fragment (genome-encoded MolecularEntity; metabolites are ChemicalSubstance) pending W02's ruling (W03-SR-05).
3. **Organ is an AnatomicalContext specialization**; `ACTS_IN` unified; `Metric.measuredInOrgans` must leave the `MEASURED_IN` name (W03-SR-06).
4. **Pathway revision** handled without VersionedState (unversioned id = identity; revision on snapshot and curated link).
5. **ICD codes are never node keys** (E88.81 FY2022 leaf vs FY2027 header).

## Research gaps and qualified conclusions

- Dose, route and duration for Zhang 2016 remain unextracted (`NOT_EXTRACTED`); Liu 2018 gavage-cohort sex not found (`UNKNOWN`).
- Elhassan muscle NAD+ itself (vs NAAD) not verified; no assertion was created for it.
- ICD-10-CM history before FY2020 is outside the MCP's range; the E88.81 `validFrom` is null (unknown).
- Revision 7 of R-HSA-196807 is evidenced only by the DOI suffix; its capture is synthetic (F1).
- No RiskFactor or INFLUENCES_OUTCOME positive case was captured; those rules are exercised only by validator syntax and zero-input runs.
- CQ-MX-06 (dose reversal) not populated.

## Unresolved seams

W03-SR-01 (W00 validators), SR-02 (W00 Assertion field), SR-03 (W07 HAS_ANALYTE), SR-04 (W00 uid tokens), SR-05 (W02 CL-002 and derived fields), SR-06 (W07 legacy edges and MEASURED_IN collision), SR-07 (W16 OPERATIONALIZED_BY), SR-08 (W17 AFFECTS_ORGAN), SR-09 (W09), SR-10 (W05 ruling given), SR-11 (W10 exposure basis mapping), SR-12 (registry/catalog registrations), SR-13 (W21 polarity enum).

## Confidence

| Dimension | Confidence | Basis |
|---|---|---|
| Extraction of cited facts | high for quoted spans; medium for inherited round-0003 quotes not re-read | captured text in 03 |
| Identity decisions (CL-002, Organ, Pathway, Condition codes) | high | primary records plus failing negatives |
| Derivation rule mx-proj/v1 | high for mechanism edges; medium for risk/association one-to-one mode (no positive case) | run results |
| Executability of fragment | high in isolation; merge-dependent on W00/W02/W07/W09 type names | library build with stubs |
| Operations | high for Community constraints tested; Enterprise unverified | run |

Review status: self-checked only; no cross-worker challenger review yet (Wave 5).
