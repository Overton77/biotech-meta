# W21 completion report

- Worker: W21 Narrative media, speakers and claims. Model: **Opus 5.5** (`claude-opus-5-5`). Coordinator: Fable 5.1.
- Run: `run-2026-10-04-fable51-01`. Start 2026-10-04T00:48:58Z; end 2026-10-04T01:52Z (UTC).
- Authority read: catalog 0.2.0 (digest `8fb50ff0…84f0`), live schema (`86b5e0b5…f112`), contract, registry, ledger, baseline, handoff §3/§6, media review, architecture §2/§3/§9/§12, round 0006 in full, proposal index §2/§4, CQ-CL/PV/EC/AX/CM traces, QS-1/QS-1b/QS-4, alignment round 0006 rows, property cards round 0006, validation V-401..V-434, `examples/claim-retelling-provenance.cypher`, source registry round 0006 entries. Late in the run, the published W00, W01, W02, W03, W04, W05, W06, W08, W14, W19, W20, W22, W23 seam requests and fragments were read for alignment (section "Alignment" of `05-decision-seam-ledger.md`).
- Wrote only inside `workers/W21/`.

## Tools and availability

| Tool | Used for | Status |
|---|---|---|
| Tavily extract (`mcp__Tavily__tavily_extract`) | publisher transcript page, YouTube page and captions, Apple Podcasts record, Megaphone RSS feed, NMN.com article, Merck event page, Merck deck PDF, Merck transcript PDF, J.P. Morgan webcast page, ARPA-H PROSPR page and video | available; all captures partial (query-reranked chunks) |
| Tavily search | finding a conference talk with slides + recording, newsletter retellings, ARPA-H deck | available |
| direct `curl` through the agent proxy | raw bytes of hubermanlab.com, feeds.megaphone.fm, itunes.apple.com lookup, s21.q4cdn.com PDFs | **BLOCKED** (CONNECT 403) for every host tried; recorded as BLOCKED, never as absence |
| WebFetch / WebSearch, Firecrawl, PubMed, ClinicalTrials.gov | not needed (Tavily sufficed for the decisive questions) | loaded or available, unused |
| Exa, bigdata.com, Figma | — | failed to connect (session notice) |
| Neo4j 5.26.31 Community, embedded (run harness classes and libraries, own data directory, 512 MB heap) | all fixtures, the baseline constraint and validation suites, W21 validators, `operations.cypher` | available; the first instance was killed under host memory pressure (many workers' JVMs) and restarted with a smaller heap; all results reported are from complete runs |
| `@neo4j/graphql` 7.6.3 + graphql 16.14.2 (run harness `build-schema.mjs`, `merge-fragments.mjs`) | parse and build of the fragment with stubs; merge check across all published fragments | available |

## Deliverables and digests (SHA-256 of the files as committed by W21; this report excluded)

```
bca2eaa34c18633069d802e40261b2d50ad00b16a10687766abbde878d9d059d  01-domain-recommendation.md
4fbb05561b5b7164a36c1aee5b8a50dad36a34815a186677522c481dfb9bc6d1  02-cq-coverage.md
3a7ad681020042f27cc27a168ad89527a41298af4522386f0911f235b00622c1  03-source-manifest.md
5a6a83e74e1a6f3d4a1991af6d925340ef06d84fd6f20ce72eaf6c850cb766af  04-model-cards.md
0149e271c99d008ad9d828eec7e9ad2c477ffe9d23f5cca6b833395d8065189d  05-decision-seam-ledger.md
a72f2f94c04096ff570962d52e6d501ac9ff2554da46a52e21320e45fa4805a6  06-fixtures-and-queries.md
a18d833319786002a3abd5a373e53a7e6aebc55444e464051c42254cf7b68565  07-operations.md
3f1c82e68793573ec352e4443936f48ee99a11b67397c6da5dd9d3c4f218494e  sdl-fragment.graphql
e76cebe8df82c62111966516f60e6f25907a0587a17e8adc7d97db630e5cea52  migration-map.yaml
e128b11de13d41bc00240878f90b3e8bd762f0dcf8cb0d28188487be2396a547  seam-requests.yaml
c8db803146f664b4d89dd8e1965889ee628478c6d82fa35e9687f2c1b2c90095  operations.cypher
ceff538ab08d85e8d39cb44c5de8cfd10561c5bc92d519bb2427b5158babf961  fixtures/w21-validation.cypher
bc9580a5ebeabc05e7071fa03d468420ca26ebd85745d24c319f1fe99a4faa12  fixtures/fx01-dynamic-ads-renditions.cypher
9b6793adc7da06bec87d65877c22af4577b495cf18b131c28bbb57ab17cb7041  fixtures/fx01-dynamic-ads-renditions.neg.cypher
faa3cb9ef572f51c50eddc94338d680063caf2c062386960ebe5331ca2fff761  fixtures/fx01-dynamic-ads-renditions.queries.cypher
6c9a0e2ad06778c6e7b34d6950c1a95bc03231c301e50181d973304fa0988014  fixtures/fx02a-transcript-correction-cosmetic.cypher
5f5c90daecccf12a907bda630285f51042d7dfc5c91c5ef2cdda337c8f7d6a2e  fixtures/fx02a-transcript-correction-cosmetic.neg.cypher
663fe39d1ae99101af1fe11b291fc37cf8e9114369bfae38ffe83c5c784d256e  fixtures/fx02a-transcript-correction-cosmetic.queries.cypher
e3ad88190f88bd0d25c675580309e6280df0aedec30bd165c5df6125bff76259  fixtures/fx02b-transcript-correction-substantive.cypher
cfd54578c9d362fdb3c700db2e910f026cfa6c3f4cbe4f9fc36b8b32ccc9a78e  fixtures/fx02b-transcript-correction-substantive.neg.cypher
663fe39d1ae99101af1fe11b291fc37cf8e9114369bfae38ffe83c5c784d256e  fixtures/fx02b-transcript-correction-substantive.queries.cypher
e5366ac3f8c6cbf14ab7e204b4c02c7e747b8e97060c376a0df43cade2379957  fixtures/fx03-sponsor-read-vs-practice-report.cypher
0876bbe258511d4349ed9db127026ba0b54f74384a3afd0126ac64088d73c88c  fixtures/fx03-sponsor-read-vs-practice-report.neg.cypher
acc6d8adce3b6a010ad787229590d1eafef11af5aecc8361c232a548db149956  fixtures/fx03-sponsor-read-vs-practice-report.queries.cypher
8f68080f0f2cb84dbb7a673b5bd6309a215304f0816f6c005cbd04bcea2fcb27  fixtures/fx04-practice-qualified-vs-recommends-retelling.cypher
8dabc2a154afa7b4d55b9b098ec76f11ea30aa9b4bf328dca5c0d261d0831fd5  fixtures/fx04-practice-qualified-vs-recommends-retelling.neg.cypher
10ebe938f71d94ef09aeb32921d672972cf03b65e869a291ea0ce8a975ff9076  fixtures/fx04-practice-qualified-vs-recommends-retelling.queries.cypher
d68f30b609927e5abe92e4f861633721ee60908584c0fc8b4bc64116fb2c5c9a  fixtures/fx05-two-speakers-one-utterance.cypher
4a4d4092272889cdb336b6582eb3f43f3c1fdea1d9394e82af8bf26da8ebadee  fixtures/fx05-two-speakers-one-utterance.neg.cypher
cb5e1091a90c71a5943c0db4cc0da85ac4e65822bc185f9931bbc808fd735c94  fixtures/fx05-two-speakers-one-utterance.queries.cypher
9b3c11b724356fb5b65f042445615c2898b114f031a5e8488f485515770ff61b  fixtures/fx06-presentation-slide-vs-talk.cypher
728fb7b6c58c9cc3fcbdfd4862fe0e2445bfec46a47f450cf4ca10f4ebe4c4dc  fixtures/fx06-presentation-slide-vs-talk.neg.cypher
2cb82b8c4a912eb873fda31cd970200c5e6847a720638a771dc302db30c25b6e  fixtures/fx06-presentation-slide-vs-talk.queries.cypher
64a08158ad558dc3861b08260119a3ff99b415499e75e982bf18c33e8b3b8b4e  fixtures/fx07-recommends-derived-projection.cypher
bf0bb6f42d6200cafc79a5a0fcb99f429e4c0973849beb4a316bce2c2b23867e  fixtures/fx07-recommends-derived-projection.queries.cypher
56ac214aeb8d64798ea991354a9c8f4ac41fa8669eec44b334929922775ccdee  excerpts/hl-feed-2026-10-04.txt
927cf1ae11a304ff180fa429898f6524e5bfca33c15c8cbd25551d50bd3e9926  excerpts/hl52-apple-2026-10-04.txt
251dc7632d905d181662f7b5a5535bc98766ea985baf8c44dc0bb6b92567593a  excerpts/hl52-page-2026-10-04.txt
b988d2687a7425adad526e0274f6d1d33f23c9cf10b16a3ddab730eca5847735  excerpts/hl52-youtube-2026-10-04.txt
76d91053abb3ed5b2b2f380f91b3cb6d94b08b4dc173774c31395701639848f5  excerpts/merck-deck-2026-10-04.txt
b6d68af554079a5948280a3374a1d9e0831aa708f09ae17d06ced3cf393ecb53  excerpts/merck-event-page-2026-10-04.txt
465a9a77fe00ba4d1593a950b1003bb8ced44329a1c375a48d9433e8d4bc8c2a  excerpts/merck-transcript-2026-10-04.txt
fcda8e29bc288fce1674be4a4699eaaaa89c86d95aa234a440fe8f02b496aa8a  excerpts/merck-webcast-2026-10-04.txt
497076e98fb918883cef66e1c341dc48399d5cf57d2c080a1f93673348e9e9d5  excerpts/nmncom-essentials-2026-10-04.txt
2b1188f933e6a35c6102d2d78e67a1fddc5ac890c8656b75fec43ff2d5b25edd  excerpts/nfc_ws1_sha256.py
```

(File digests are over file bytes. Snapshot `contentHash` values in fixtures are over the NFC-WS1-normalized excerpt text and therefore differ from these file digests by design; reproduce them with `python3 excerpts/nfc_ws1_sha256.py -f excerpts/<file>`.)

## Verification performed

| Check | Result |
|---|---|
| `sdl-fragment.graphql` parse (graphql-js 16.14.2) | OK: 14 object types (11 nodes, 3 relationship-property types), 1 enum, 3 unions |
| `Neo4jGraphQL` 7.6.3 build of the fragment plus stubs of the referenced foreign names (stubs not delivered as proposals) | OK, 2282 generated types; no top-level `delete*` mutation for any W21 type (`@mutation` without DELETE) |
| `merge-fragments.mjs` over all fragments published at 01:49Z | 471 definitions, 0 duplicates, 0 forbidden directives, 0 extend blocks; W21 references no undefined name; W00/W22 still reference the retired `ExperienceReport` (W21-SR-25) |
| Fixtures fx01, fx02a, fx02b, fx03, fx04, fx05, fx06, fx07 on Neo4j 5.26.31 Community | all statements executed; baseline validation 174/174 statements ran; 0 failing rows on every positive fixture except the intended V-423 row in fx07 (W21-SR-07 evidence) |
| Negative injections | every injected defect produced its expected rows (V-007, V-112, V-404, V-409, V-410, V-411, V-414, V-416, V-422, V-423, V-424, V-426, V-504, and V-W21-01..09, 11, 12) |
| Inherited `claim-retelling-provenance.cypher` under W21 validators | V-W21-02 1 row, V-W21-09 2 rows (upgrade requested, W21-SR-17) |
| `operations.cypher` on Community | 37 statements: 30 applied, 7 Enterprise-only rejected as expected; fx01 + fx04 loaded together under it without conflict |

Not verified: Enterprise constraints; GraphQL queries against the generated API; the full merged schema build (fails on other packets' references, not W21's); any audio.

## Research gaps (qualified conclusions)

- No raw bytes were hashed for any real source (direct fetch BLOCKED); all hashes are over stored excerpts.
- Whether YouTube captions for n9IxomBusuw are auto-generated or uploaded: not established. Which rendition's wording matches the audio: not established (no audio verification).
- The Merck deck's PDF page index for printed slide "11" is ASSUMED equal; the webcast offset of the CEO's statement cannot be obtained (recording withdrawn).
- Apple Podcasts role label for the host: not established from the 2026-10-04 extract.
- No real newsletter retelling of the specific episode-52 NMN sentence was found; the "recommends" retelling remains the inherited SYNTHETIC digest; the real NMN.com retelling's citation does not resolve to a captured work.
- When the feed's sponsor set changed from the 2021 sponsors: unknown (OBSERVATION_ONLY).

## Unresolved seams (owner)

W21-SR-01 platform token (W00); SR-02 enums (Fable); SR-03/04/05/22 new relationship types (Fable); SR-06 OCCURS_IN Publication (Fable/W09; W19 and W00 concur); SR-07 V-423 amendment (W00); SR-09 RoleType values (W01); SR-10 MENTIONS naming (W00/W20); SR-12 V-417 wording (W00); SR-13 sourceKind/DocumentType values (W19/W00/W20); SR-14 relevanceBasis value (W00); SR-15 predicates (W00); SR-16 validators and params (W00/Fable); SR-17 inherited fixture upgrade (Fable); SR-18 RecommendableTarget ownership (Fable/W01); SR-19 re-edit link (deferred); SR-20 talk-to-session link (W18); SR-21 caption-discrepancy gap code (W00); SR-23 QUALIFIED_BY on generic Assertion (W00); SR-24 multi-author asserter rule (W01/W09); SR-25 ExperienceReport in W00/W22 unions. SR-11 resolved by W03-SR-13; SR-08 is field text for W01/W18/W20.

## Confidence

| Dimension | Confidence | Why |
|---|---|---|
| Work/rendition/segment model (D01-D03) | high | grounded in three real renditions with different text and different sponsor timing; executed |
| Presentation decision (D06) | medium-high | one real talk (deck + transcript; recording withdrawn) plus a synthetic talk for the MEDIA_TIME half; no failing case for a new type, but only one real case |
| RECOMMENDS as derived (D07) | medium | consistent with CL-016 and D-011; requires a validator change Fable must rule |
| Assessments and qualifiers | high | executed with real qualifier spans; partial-capture null handling demonstrated |
| Source facts | medium | partial extracts; no byte hashes; no audio verification |
| SDL compatibility | medium-high | builds alone; full merge pending other packets |

## Review status

Self-reviewed against contract sections A, B and C. Not yet challenged by another worker (handoff Wave 5 rotation: W22 for media source/asset confusion, W00 for time/provenance).
