# W16 completion report

- Worker: W16 Protocols and public workflow definitions. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Start 2026-10-04T00:54:50Z; end 2026-10-04T01:36Z (UTC).
- Wrote only inside `workers/W16/`. Read order followed (04-worker-brief, 01 contract incl. D-004/D-013/A9, 02 registry W16 row and CL-007/008/013/018, 03 ledger, 00 baseline, handoff §6, media-protocol review, catalog `protocols` + `HAS_PROTOCOL_EDITION` exclusivity, architecture §13, round 0008, CQ tables, QS-2/QS-6, live alignment rows, property cards PR-01..13, V-113..117/V-5xx, recommendation-snapshot fixture, OPEN-QUESTIONS P2 item 4, live schema lines 1756–2040, 176–187, 217–226, delta Lane 5).

## Tools used and availability

| Tool | Used for | Result |
|---|---|---|
| Firecrawl `firecrawl_scrape` | Blueprint live page; Wayback CDX listing and 2026-01-24 capture; protocols.io V.1/V.2; NICE CG185; NAD.com; ProLon FAQ | worked; ProLon FAQ returned no text |
| Firecrawl `firecrawl_search` | locating NICE wording, ProLon cadence, protocols.io versions | worked (SEARCH_EXTRACT, locators only) |
| PubMed MCP | PMID 28202779 metadata/abstract | worked (DOI 10.1126/scitranslmed.aai8700) |
| ClinicalTrials.gov MCP | NCT02158897 | worked; registry history not retrieved |
| curl to archive.org | Wayback availability/CDX | **BLOCKED** (proxy 403); reached via Firecrawl instead |
| Tavily, bioRxiv, ICD-10, NPI, WebFetch | not needed | not used |
| Run harness (scratchpad copy): `@neo4j/graphql` 7.6.3 build; embedded Neo4j 5.26.31 Community; `run-cypher.mjs` | SDL build with stubs; all fixtures, validators, operations | all executed (see 06) |

## Results

- SDL fragment: 10 node types, 4 relationship-property types, 17 enums, 5 unions (36 definitions); parses alone; builds with stubs of imported types under 7.6.3 (1,766 generated types); no `extend`, no `@cypher`, no private type or value.
- 13 required/mandatory fixtures, 594 statements, all executed without error; every expected validator row observed, including the leak probe that fails V-113, V-520, V-521, V-524 as required.
- 18 validator proposals (V-525p…V-542p) incl. restating catalog V-525/V-526 on `HAS_PROTOCOL_STEP` (the catalog versions match `HAS_STEP` and would silently pass on D-004 data).
- Real-source findings that changed the model: silent dose changes on a protocol page with an unchanged byline (SNAPSHOT_DIFF); 37 raw Wayback digests ≠ editions (canonical payload hash); step renumbering across protocols.io versions (order on the edge); OR and "otherwise" conditions in NICE and Blueprint (CNF on HAS_CONSTRAINT); event-anchored repeat-until schedules (lag on DEPENDS_ON, `repeatUntilText`); per-dose vs per-day ambiguity on one page (explicit basis); third-party report conflicting with the owner (Assertion, not edition).

## Research gaps

- Only 2 of 37 Blueprint captures were read; the instant of each change is unknown (kept unknown; V-509 review row).
- protocols.io V.1 was captured partially (diff qualifier ADDED_OR_NOT_CAPTURED).
- No source found where one PDF is both a study ProtocolVersion and a public ProtocolEdition (CL-007 minimal pair documented instead).
- ProLon's own cadence statement not captured (dynamic FAQ); FMD cycle grounded in the PubMed/CT.gov record only.
- No extraction pilot for stepKey alignment (OPEN-QUESTIONS P2 item 4 remains provisional).

## Unresolved seams

W16-SR-01..20 (`seam-requests.yaml`): tokens and predicates (W00), DiagnosticResult field types (W07), privacyClass casing (W00), Person fields (W01), ruleOnly derived edge (W00), CadenceUnit YEAR/MINUTE and ConstraintRole REPEAT_UNTIL (ledger), route vocabulary (W00/W09), CL-007 confirmation (W09), private contract and CNF evaluation semantics (W23), substance classes (W02), step applicability (W10), validator ids (Fable), instrument boundary (W08), union members (W05), pinned/floating materials (W04), MENTIONS meaning (W00/W20), contraindication boundary (W17), RULE_TRIGGERED_BY rename (W10). One divergence from the live-alignment table: protocol-level schedule fields move to the edition instead of staying as a Protocol projection (W16-D16).

## Confidence per dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Edition/versioning model | high | three real provenance kinds executed |
| Step dependency/recurrence separation | high | executed positives and negatives |
| Conditional CNF representation | medium-high | two real sources; evaluator semantics executed with hypothetical facts; private evaluator not built |
| Schedule ranges and units | medium | YEAR/MINUTE missing; month→day rule is a convention |
| stepKey alignment rule | medium-low | small sample; needs pilot |
| Observation/DiagnosticResult conformance | medium | depends on W07's final interface types |
| Privacy boundary | high | leak probe fails exactly the required validators; QS-6a holds |
| Operations on Enterprise | unverified | only Community executed |

## Artifacts (SHA-256)

```
930b8d08a87de47455975d205b0e73aa2d4d593f38096b37d012ca35b90e0655  01-domain-recommendation.md
cd6566f0174fb95060318f0586b15a603434ed536dc44ca8db7910d67f102287  02-cq-coverage.md
efd3f65d5ebfb181b9f4c9b79cb55aa074f26ec8abfbadfbcb3c4f58c5bd3976  03-source-manifest.md
8a99a74f61651d49d242148b86165dff8139eff76340bc5681daa3bdf913b70a  04-model-cards.md
8bcf7859e33b5823d96e3d2ba43588e9786e9ac65066eae978c0a6d70f4b7f64  05-decision-seam-ledger.md
9c6500132b41c387bdb19924ecb3f2ccb493012273b50528bb10676ff3939080  06-fixtures-and-queries.md
6118a02c15cb2ec35b75becf9308d95e44703fc9e8311deb8078746e950746c0  07-operations.md
45c53b83f0b1ef6d15c72e7d669c0fba0fbcb4983521f9544e32e10a2a61231b  sdl-fragment.graphql
a20cdda3f19c137ae55c3f17f13c2e98883b84aa557039a60fd3c9e54faf53aa  migration-map.yaml
c4cb8b37a51705b4094692650f5ce9c97221cebed3d4d217af0df306562c44a9  seam-requests.yaml
cb2fceb6c515aea90566a9f7b189d92fa7f7aface77e80d4ce4ec87e4271f761  operations.cypher
30d9cff3bbcad904cb43ed6b4e4ff5d618777ae5b1fd9d0d89fb3aa95b6c6f86  fixtures/00-w16-validators.cypher
20976b66a629b4542631051841d89065ebfb79cf0ce16adc856d9141b8b92f6a  fixtures/01-edition-diff-by-stepkey.cypher
073bbc16f05d29bec90ab4114249b910a0d23d6512a9e22baff88fe5a4086969  fixtures/02-source-change-same-identity.cypher
733b850f14acd56dac57727980264d4feb3608caa5d3fafa96446c6b6eb6058b  fixtures/03-repeated-step-plus-prerequisite.cypher
338992e67e731379452302433a8ff40639708ac121d61be6043952439458d082  fixtures/04-conditional-branch-missing-condition.cypher
76adf9d4f62fe9e497a04a9d401a99043207d15a555cd6a7adcff5102e822b78  fixtures/05-parallel-steps-concurrent.cypher
a052f57f2e9976252fd44f1002c758b757c3e61318d1f07b0a1bdff1ea17a080  fixtures/06-optional-step-no-nonadherence.cypher
d86a85f7c3261181abc32ed2f083de117fd28ad1aa40d33e3d7c1ee377669721  fixtures/07-public-vs-private-leak-probe.cypher
c2c70d99e91b7403f3ef698401e017acc3d696911bec4b62b97d71d242cf5aef  fixtures/08-device-assay-formulation-version-change.cypher
56802ea4e444bba79a7c560a1874febfad2374edc4c61620b47a5b98cd24f844  fixtures/09-assertion-backed-role-evidence.cypher
20f36d2158d3c6e50748a0a9ccd75517f387aeca8412b4ffb33cea6dca7999f9  fixtures/10-cadence-range-3-to-6-months.cypher
39cef9864bda7d2642335b2b95fb053302da3d3ec40d8a219634cc9e14fef1de  fixtures/11-wait-for-lab-result.cypher
aedf43e0cb0c2f908254e3d355df4ec42c5d9c42ab99c41ef2fa5b7ed42d5338  fixtures/12-mutually-exclusive-steps.cypher
caa4e56fa2aa69e80c5c1609ecacd3e5375604c81c593d65d55dae0fcde95f84  fixtures/13-subprotocol-edition-binding.cypher
94f7ae3a8be22514490aaa7fc978ec027294f4c1e2c1f9551bf02a25fd398fd5  fixtures/run-summary.txt
0fb4178b9939c48214747fb9e177a9399ca4eb8a7fe57009bd283cbbbe264516  fixtures/generator/lib.py
a265ef8a639002f706a8dd4321b5409f42addd5053c147121c8783282aa08df0  fixtures/generator/gen_fixtures.py
```

(This report's own digest is not self-listed.)

## Review status and what remains qualified

- Self-reviewed only; no peer worker packet available for joint seam review. Fable ruling needed on W16-D04 (ruleOnly), W16-D16 (schedule fields on edition), W16-D19/D20 (enum values) and the validator ids.
- Qualified: diffs across partially captured or unobserved states; stepKey alignment; route vocabulary; DiagnosticResult field types; Enterprise constraint behaviour; the generator writes absolute output paths (edit `OUT` to reuse).
