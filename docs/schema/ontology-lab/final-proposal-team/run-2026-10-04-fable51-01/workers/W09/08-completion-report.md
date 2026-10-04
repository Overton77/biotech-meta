# W09 completion report

- **Worker:** W09 Studies, interventions and results.
- **Model:** Opus 5.5 (`claude-opus-5-5`).
- **Run:** `run-2026-10-04-fable51-01`; coordinator Fable 5.1.
- **Start:** about 2026-10-04T00:53Z (first file read; the first recorded `date -u` was 00:57:08Z).
- **End:** 2026-10-04T01:45Z.
- **Authority digests checked:** catalog `8fb50ff0…84f0` and live schema `86b5e0b5…f112`, unchanged.
- **Repository HEAD:** `b48a21a5` at check time. It differs from the baseline `530e05cd` through the coordinator's own commits; authority files are unchanged.
- **Writes:** only inside `workers/W09/`. No authority file, other worker directory or run-numbered file was edited.

## 1. Tools used and availability

| Tool | Used for | Result |
|---|---|---|
| ClinicalTrials.gov MCP (`get_trial_details`, `search_trials`) | NCT02678611, NCT03464500, NCT00938340, NCT02582593, NCT04985630 details; NCT03283462 and urolithin-A search rows | Worked. Current version only; field subset (no enrollment type, date types, version number or last-update date). |
| ClinicalTrials.gov API v2, history endpoint, results tab (`curl`, Firecrawl markdown/rawHtml/query, Tavily extract) | Registry history for NCT02678611; AE assessment type for NCT00938340 | **BLOCKED**: proxy 403 for `curl`; HTTP 403 or error page for Firecrawl; fetch failure for Tavily. Recorded as BLOCKED, never as absence. |
| PubMed MCP (`get_article_metadata`, `get_full_text_article`, `search_articles`) | PMIDs 29184669, 30155270 (+ PMC6102308 full text), 35584623, 23616506, 21871057; search for ATLAS/ENERGIZE reuse | Worked |
| Firecrawl `firecrawl_scrape` (`query` directQuote) | PMC5701244 (AE section, ITT, sites, data availability), PMC9133463 (strength results, multiplicity, AE diary), PMC8777576 (ENERGIZE AE wording) | Worked |
| Tavily | History endpoint | Failed (BLOCKED) |
| Embedded Neo4j 5.26.31 Community (run harness) | All fixtures, the inherited 174-statement suite, W09 queries, `operations.cypher` | Ran. One out-of-memory loss under about 22 concurrent instances; re-run with a 384 MB heap. |
| `@neo4j/graphql` 7.6.3 / graphql-js 16.14.2 | Fragment parse and build (with a stub of other owners' types); live GraphQL read of the fixture data; cross-fragment merge check (`merge-fragments.mjs`) | Fragment builds (1,894 generated types with stub). GraphQL read works except DateTime selection without APOC (W09-SR-17). Merge check: 0 duplicates, no W09 undefined reference, no W09 union overlap after the fix. |
| Exa, bigdata, Figma, GitKraken | — | Not connected (session notice). Not needed. |

## 2. Research gaps (what remains unknown)

- **NCT02678611 registry history.** BLOCKED. The registered priority is derived from the version observed on 2026-10-04 only. Whether outcomes changed is unknown (CQ-ST-04 qualified).
- **A real SYSTEMATIC AE zero.** Not found: ClinicalTrials.gov results modules were BLOCKED, and both supplement papers retrieved leave the elicitation mode undescribed. The fixture uses a SYNTHETIC SYSTEMATIC zero. The inherited 0.2.0 value `SYSTEMATIC` for the Basis AEs is **not supported** by the retrieved text (W09-D08).
- **Enrollment and date types, `lastUpdatePostedDate`, version numbers.** Not exposed by the MCP; null throughout, never defaulted.
- **Real subgroup after a null primary.** None retrieved; the subgroup row in fixture 02 is synthetic. The real non-primary findings (ATLAS secondary between-arm, placebo within-arm decline) are used instead.
- **Real procedure-arm study.** Not retrieved; synthetic sauna arm. W05 cites DICA-NUTS (NCT03728127) as a real definition-only arm in W05-SR-06.
- **Real protocol PDF (ProtocolVersion instance).** Not retrieved; the type has no fixture instance.
- **BEST glossary.** No entry exists in `source-registry.yaml`; not retrieved. W10's area.

## 3. Unresolved seams and conflicts

All are listed in `seam-requests.yaml` and the ledger:

| Requests | Topic |
|---|---|
| W09-SR-01/02 | Registry additions |
| W09-SR-03 | SUPPORTED_BY domain for study records |
| W09-SR-04 | uid tokens |
| W09-SR-05 | W01 investigator and collaborator predicates |
| W09-SR-06 | Shared DosageForm (W04) and AdministrationRoute (owner to rule) |
| W09-SR-08 | Device range |
| W09-SR-09 | Union member survival |
| W09-SR-10 | W17 safety signals |
| W09-SR-11 | W10 inputs and V-215r |
| W09-SR-12 | Assertion qualifier carriage |
| W09-SR-13 | EVALUATES name collision |
| W09-SR-14 | SourceKind values |
| W09-SR-15 | W13 NSR determination |
| W09-SR-16 | Candidate predicates |
| W09-SR-17 | APOC requirement |

**Conflict requests against frozen validators** (each with a real failing case):
- W09-CR-01: V-217 split.
- W09-CR-02: V-221r.
- W09-CR-03: V-211 `count(DISTINCT)`.
- W09-CR-04: V-215r.

**Incoming requests answered** (05 ledger, last section): W02-SR-20, W05-SR-06, W06-SR-03, W16-SR-09, W16-SR-10.

## 4. Confidence by dimension

| Dimension | Confidence | Basis |
|---|---|---|
| Catalog conformance of the fragment | high | 13 catalog nodes written in full; catalog enums verbatim; D-003/D-005/D-007/D-011 applied; parses and builds under 7.6.3 |
| Fixture validity | high | 7 positive files run with 0 errors; on positives every hard validator returns 0 rows except the documented frozen-validator false positives (V-211 1, V-217 5, V-221 4) and informational checks |
| Negative coverage | high | 23 negatives, each detected by its named validator (`run-results-2026-10-04.json`) |
| Source fidelity | medium-high | All real values are quoted from retrieved text. History and results modules are BLOCKED. Snapshot hashes are synthetic; quote hashes are real (NFC-WS1). |
| Candidate elements (device, definition edges, new enums) | medium | Real failing cases for the device and the enums; the procedure case is synthetic here (W05/W06 supply real ones) |
| Validator change requests | medium-high | Reproduced by execution; awaiting Fable's ruling |
| Operations | medium | Community statements applied; Enterprise statements unverified (rejected on Community as expected); APOC dependency observed |

## 5. Review status

- Self-review against the contract (B1–B7, C) is done.
- The merge check against all 24 published fragments was run at 01:4xZ: no duplicate, no W09 undefined reference, no W09 union overlap after the fix.
- No independent reviewer has examined this packet. Wave 5 adversarial review is pending.

## 6. What remains qualified

- **CQ-ST-04:** the earliest registered priority is unknown.
- **CQ-ST-06:** zeros are reported zeros under an undescribed collection method.
- **CQ-ST-07 / CQ-AX-05:** independence is a lower bound on dependence (undeclared reuse is invisible).
- **CQ-ID-02:** OVERLAP_START_UNKNOWN for Basis.
- **CQ-ST-08:** observed versions only.

## 7. Artifacts (SHA-256 at 2026-10-04T01:45Z; this report excluded)

```
5ed5e29fd48ec83db0eee54eeda351b419c54028224b2f5005edc1ba1d5ce260  01-domain-recommendation.md
be47b3640979523f9e974b8ba6384d6ac6a804bc8374c41699beb3df4ba51bff  02-cq-coverage.md
4d6ca522bdf43a557fe25e95eb981b3a3fc8ab193ed9da65df450dfa1f7a3957  03-source-manifest.md
86c8c98dd75c00d23a9c246cf7cb1f02a7a26cf2b0c62c344ed0a9d2b3326cf3  04-model-cards.md
76e51e74c1ae320fbcf8b7937621caf6b23ac9f05ac08ff1a964df8f3629a758  05-decision-seam-ledger.md
55ea96a3ad74404a1fe953ee2d9e429a33c9266b59c9de5d4debec772c7e88bb  06-fixtures-and-queries.md
b5fb4ed1fc7a9dfdb5c1236267da4cf26a6b7e6cd4c3df7383adc0b58ccdcc1e  07-operations.md
e58b06f9f543ea7dca9f98ec0da2908ea666388f3b47ade55a215b6bafc783c1  sdl-fragment.graphql
b3c3f5b7f1a58c58a571f9b957f5355ef66a16c7d0b41687ccdb08dce8ca89d6  migration-map.yaml
3dbca9c6af6510973b589bd8b02c98e329763a2b49955cd24f6bea44e492ecc0  seam-requests.yaml
f88459c70b6c75408f7be8e8eb4068625e32f131357d6956b56dce18aacd5f1e  operations.cypher
d9a1b4a9b421e421f2d191e600e33620c9e67839e40877069ed157a458be39f7  operations-enterprise.cypher
343147144ec5ce5ece8f1e1963f7477910d58938ac0a8a40492887b5ab11a3fc  fixtures/01-registry-versions.cypher
1a35f36db716e156c0f5266395729101d9feb836eb6a5a7a8cbb677fb8d247be  fixtures/02-null-primary-favorable-secondary.cypher
6d6e595075d79227acaae41692140b2012998429c807089909419f80428a702e  fixtures/03-shared-dataset-vs-replication.cypher
1a3f9aa066afb6ea38fa73dfc06597554da0109859c2b111ca72e582b664a3a8  fixtures/04-cross-domain-interventions.cypher
842aa64f68a513cd7a8e3532ceb9bf6f82a96c856bfa37fd7edf569442983cbd  fixtures/05-adverse-events-zero.cypher
96939767241383f575222b233c884c32ea9c0412ef8d852a1e9542769cbdd1b2  fixtures/06-publication-correction.cypher
4b796ec35b61db97a988beab2c8de0f74195b6fd71bee0c1cce7202f909106b1  fixtures/07-historical-label-gap.cypher
f3d6c41e3b205bb26e2603ba460add9d83c5d0dc4df75ca82a94996fbe90892b  fixtures/80-queries.cypher
40b3b895d5d3b7d93ee56edc1f8bf3bdbd3bf0e7b10dc5269c8ab80ade9e1864  fixtures/90-negative-cases.cypher
1fbfe033bdd9f332459a309eca973b56115eb69ac0a299e270df09324331e672  fixtures/run-results-2026-10-04.json
```

**Scratch (not deliverables)** is in the session scratchpad `w09/`:
- `stub-external.graphql` (test stub of other owners' types)
- `gql-read.mjs` and `gql-read-final.json`
- suite JSON outputs
- `final-run.sh`
