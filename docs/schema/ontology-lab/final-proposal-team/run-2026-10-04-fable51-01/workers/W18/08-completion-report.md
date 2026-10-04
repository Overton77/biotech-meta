# W18 08 Completion report

- **Worker:** W18 Communities, events and narrative arcs. **Model:** Opus 5.5 (`claude-opus-5-5`). **Coordinator:** Fable 5.1.
- **Start:** ≈ 2026-10-04T01:15Z (reading of the run files; first scratch artifact 01:32Z). **End:** 2026-10-04T02:06Z.
- **Wrote only inside** `workers/W18/`. Scratch work (harness copies, run JSON, merged test schema) lives in the session scratchpad, not in the repository.

## 1. Tools actually used and availability

| Tool | Use | Result |
|---|---|---|
| Tavily MCP `tavily_search`, `tavily_extract` | Madrigal releases, 8-K, EMA EPAR, Entrepreneur/MarketBeat article, Madrigal IR events page, JPM 2026 listings, AASLD release and TLM page | worked; extracts are text renderings (no bytes hashed) |
| PubMed MCP `search_articles`, `get_article_metadata` | NEJM MAESTRO-NASH (PMID 38324483), AASLD resmetirom guidance (PMID 39422487) and correspondence | worked (one oversized result read with `jq`) |
| ClinicalTrials.gov MCP `get_trial_details` | NCT03900429 dates and results flag | worked |
| Firecrawl, WebFetch, bioRxiv, ICD-10, NPI | not needed | — |
| Exa | not used | failed to connect (session notice) |
| Run harness (`validation/harness`: `merge-fragments.mjs`, `build-schema.mjs`, `run-cypher.mjs`, `query.mjs`, `EmbeddedNeo4j`) + W00's APOC launcher and APOC Core 5.26.31 jars | merged build, Cypher runs, GraphQL round trip | worked; Neo4j telemetry call to `udc.neo4j.com` denied by the proxy (harmless) |
| graphql-js 16.14.2, `@neo4j/graphql` 7.6.3, `neo4j-driver` 6.2.0, Node 22.22.0, Python 3.11 | parse/build/round trip; fixture generation and NFC-WS1 hashes | worked |

## 2. What was run (all on Neo4j 5.26.31 Community, embedded)

- `sdl-fragment.graphql` parses standalone (15 definitions). Merged with every fragment present at 01:56Z plus `fixtures/w18-build-stubs.graphql` (types other workers have not delivered) → `Neo4jGraphQL` build **OK** (38,911 generated types). Two test-only patches to other workers' text were needed and are not W18 defects: duplicate `ResultQualifier` (W07/W12) dropped; W16 `Observation implements DiagnosticResult` removed in the test copy.
- `operations.cypher` 43/43 OK (incl. relationship-property uniqueness on Community); fixtures 01–04: 220/75/168/22 statements OK; all 13 W18 validators and 11 baseline validators **zero rows** on the positive graph; 11 queries OK with the expected rows; GraphQL round trip 6/6 OK (APOC required); fixture 90: 39/39 OK and every negative caught by the named check(s) (`06-fixtures-and-queries.md`).
- Not run: Enterprise existence constraints; the full 174-query baseline suite (11 relevant validators run); W21's V-W21-03; the GraphQL round trip against Fable's merged file.

## 3. Research findings that changed the model

1. Company and regulator clocks differ for the same milestone: EU conditional authorisation **effective 18 August 2025 (EMA)**, **announced 19 August 2025 (Madrigal)**, stated as "August 2025" in the company boilerplate. US launch: planned (announced 2024-03-14), happened April 2024 (MONTH), first reported 2024-05-07.
2. A data-readout retelling asserts causation in **both directions** within one article and separately states mere order ("after"); the company's "approval was based on Phase 3 data" is an evidentiary basis, not an event cause.
3. A conference session can have a recording that later disappears ("The recording of this session is not available any more") while transcript and deck remain; a session can have a recording and deck but no stated speaker; a conference name containing a bank does not tell us the host.
4. A company-supported award at a society's meeting coexists with an independent practice guidance from the same society; nothing in the graph may connect the two as endorsement.
5. The registry's primary completion (2028-01) is unrelated to the 2022 readout disclosure.

## 4. Research gaps

- JPM organizer page (dates, host) not captured — only third-party listings; host left unknown.
- No raw bytes hashed; all snapshots SYNTHETIC_FIXTURE.
- EC decision record / Union Register not fetched (EMA page used for the date).
- AASLD guidance text and COI statements not captured; no recommendation assertion written.
- Publication date of the Entrepreneur/MarketBeat article not established.
- No recall, financing, M&A or litigation event researched (eventType values reserved, CQ coverage via the general timeline only).
- `Community` has no researched real case (synthetic only).

## 5. Unresolved seams (see `seam-requests.yaml`)

SR-01 uid tokens; SR-02 catalog module content and forbidden pairs; SR-03 registry admission of renamed/new elements; SR-04 `statedTense` FUTURE and `ActivityKind.CURATION`; SR-05 W01 field slots (exact text supplied); SR-06 W21 `Episode.recordingOf`, `SponsorableTarget` use, deck–talk answer to W19-SR-07; SR-07 W20 `Document.presentedAt` and reuse of `DerivedSupportProperties`; SR-08 program-level sponsorship target; SR-09 W13 regulatory basis predicate and EU record shape; SR-10 NARRATIVE_ARC excluded from provenance state 3; SR-11 announcing-capture pointer; SR-12 W17 union members.

## 6. Confidence per dimension

| Dimension | Confidence | Why |
|---|---|---|
| Event clocks and assertion-backed materialization | high | real minimal pairs (FDA, EMA, launch) and as-recorded queries run |
| CAUSED_BY asserted-only with basis; FOLLOWED_BY derived | high | real retelling with contradictory claims; four negatives caught by V-112 and W18-V01 |
| NarrativeArc as EvidenceAssessment | medium-high | consistent with the kernel and the alignment ruling; depends on W00 accepting the state-3 exclusion (SR-10) |
| Conference/session/recording/deck split | medium-high | two real sessions; needs W21/W19 agreement on PRESENTED_AT vs a deck→Episode predicate |
| Sponsorship vs endorsement | high | real case; existing catalog pair plus V-422 and W18-V05 |
| EventImpactAssessment | medium | shape is sound; judgments in the fixture are synthetic; kept CANDIDATE |
| Community | low-medium | live seam kept with no real case |
| SDL/runtime | high for build and round trip on 7.6.3 + Community 5.26.31 with APOC; Enterprise unverified |

## 7. Review status and what remains qualified

Self-reviewed against the contract (sections A, B1–B7, C) and the worker brief; no independent review. Qualified: the materialization rules (`event-time-materialization-v1`, `announced-at-v1`) are specified in prose and exercised by fixtures, not implemented as a service; NarrativeArc state-3 exclusion is a proposed rule; EventSubjectTarget members SafetySignal/AdverseEffect depend on W17; conference dates come from third-party listings; the GraphQL round trip used stubs for undelivered types.

## 8. Artifacts and SHA-256 (computed 2026-10-04T02:05Z; this report excluded)

```
31d64c4173abe6a8307f86e0f2c04be6df3526f4c4f76f53ffb7431503421215  01-domain-recommendation.md
31b2b2248ce7f0e69632e9b7f75d423b55894abdb35ed4f08660f0ba323286a2  02-cq-coverage.md
5804a78f3d3de2258eb216573f63506eecec1cec5e55b464a948fa85d5864aec  03-source-manifest.md
d8b8e2e964c7a9469ef56ed3d06472511d4c039cd8118be4c6b97b2aba1710e2  04-model-cards.md
294477e3ec03a53b91e90983c7ba81d8c98c22ff817591ea6e9289dff089d895  05-decision-seam-ledger.md
3dd5ab67a15960773febc0eccf1d3c012b17f79187f610b27a1c6be34032bd87  06-fixtures-and-queries.md
70aca106191cf11cf2a3c627298123000ca417cba331dda2bc83edd5b5702a8f  07-operations.md
708d063a230ff98551562fbc234e88dd4bdc9321c44271e67605db08fd2638f7  fixtures/gen_w18.py
b20aab27aa388e5d7a3ee81fc69b66536464a753d7b0d8d276b5507132af8da3  fixtures/w18-01-rezdiffra-milestone-clocks.cypher
e04b1f9e8e8e2de974753f433dbf58a3dab0da1337e4257b67e5cf60a1fe2d58  fixtures/w18-02-readout-causal-retelling.cypher
bcccfe628185e38546e3096c041d3d74c246191cf7b359e81069c234b74b4c16  fixtures/w18-03-conference-sessions-sponsorship.cypher
446f5f72a4104b41966768e0a44dbb6f07b94b870f0642ee4389d73c4c271dbb  fixtures/w18-04-narrative-arc.cypher
55906e6704eb4e9fe102d81eceed5d7548c3ea1109830426a90a17a7f1e03216  fixtures/w18-80-queries.cypher
a568437051cbbbe00faff3ef317fee47a3bdae94ad16afba5478490c8ee867fe  fixtures/w18-90-negatives.cypher
def1557f4fd0245bd3ff651d2c479f394423066933853eca7face2efc6921ad9  fixtures/w18-build-stubs.graphql
7b910101ab6badcf396732d28a44b47d4e16d670fb14b68f8c077aca8f726840  fixtures/w18-gql-roundtrip.mjs
4f2a567dd45618039fa5f2f05d642c907e83a7e793dfb458cb52d666b9e72e2a  fixtures/w18-validation-params.json
ef0c3069018a29aaa90b5cc04e5615ac865389a14b4ca927a138395667ee43eb  fixtures/w18lib.py
b9feda9329e5bd1070bec8456312080d65a5d0a590f282d64f7ed42d15128c14  migration-map.yaml
748fe00111a05021cff284f2e4b8806f32f002d5518637330f1772d9d669444a  operations.cypher
7080b91df7e4d6a77f978917235e1c3290f782bb65364f84e9317b89fd11d8c5  sdl-fragment.graphql
40d7fc0a386ecb92fd4dce5476084285eac364b73cc6c8031d8e196d2f8562fe  seam-requests.yaml
```
