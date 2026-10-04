# W19 completion report

- Worker: W19 Source Intelligence, model **Opus 5.5** (`claude-opus-5-5`); synthesizer Fable 5.1.
- Start: 2026-10-04T00:48:54Z. End: 2026-10-04T01:25Z (approximate; digests below computed at the end).
- Inputs read (in brief order): `04-worker-brief.md`, `01-shared-contract.md` (A8, D-005), `02-ownership-registry.md` (W19 row; CL-003, CL-012), `03-conflict-ledger.md`, `00-baseline.md`; handoff §2–6; catalog `provenance` module, `claims_and_documents`, `conventions` (sourceKind, contentHashBasis, captureCompleteness, uid tokens), invariants; architecture §2, §4, §12; round 0006 (full, D1–D9) and round 0007 §6–9 (SourceRevisionEvent); `sources/source-registry.yaml` (all 127 entries, analysed by script); competency questions CQ-PV-01…06, CQ-AX-05/06/07, CQ-ST-08, CQ-EV-05; query-shapes QS-1, QS-7; live-schema-alignment Document/Source rows and notes; validation V-000…V-5xx (V-111, V-111b, V-120, V-235, V-401, V-401b, V-402…V-414, V-426, V-512); `examples/claim-retelling-provenance.cypher`; both independent reviews' Source Intelligence paragraphs; live schema lines 2589–2695; proposed-delta Source/Document sections.

## Tools actually used

| Tool | Result |
|---|---|
| PubMed MCP (`get_article_metadata`, `convert_article_ids`, `get_full_text_article`) | worked (PMIDs 29184669, 30155270; PMC5701244) |
| ClinicalTrials.gov MCP (`get_trial_details`) | worked (NCT02678611; no version or update-date fields in output) |
| Tavily extract / search | worked (PubMed page, nature.com page, transcript page, YouTube captions, CT.gov history tab shell only, API search) |
| Firecrawl scrape | worked with caveats: CT.gov history tab returned 200 with an embedded 403 error page (BLOCKED); RSS feed truncated (PARTIAL; served from cache 2026-10-03T06:00:23Z) |
| curl (direct) | BLOCKED by egress proxy: eutils.ncbi.nlm.nih.gov, clinicaltrials.gov, doi.org, feeds.megaphone.fm |
| WebFetch | BLOCKED (`EGRESS_BLOCKED` clinicaltrials.gov) |
| Neo4j 5.26.31 Community embedded (run harness) | 5 fresh isolated instances; all fixtures, queries, negatives and operations run; all stopped |
| `@neo4j/graphql` 7.6.3 / graphql 16.14.2 | fragment parsed; built together with a W00 stub (316 generated types) |
| Exa, bigdata.com | failed to connect (session-level), not needed |

## Research gaps (qualified, not invented)

- ClinicalTrials.gov record history and API v2 for NCT02678611: **BLOCKED**; whether the record has prior versions is unknown.
- PubMed CommentsCorrections ("Erratum in") for 29184669: not returned by the connector, E-utilities blocked.
- The pre-correction nature.com HTML: no archive capture retrieved; fixture S0 is synthetic.
- Whether PMC ever showed the uncorrected text; PMC version history (`versions=no`).
- RSS item for episode 52 (guid, enclosure, length): not reached in the truncated feed capture.
- YouTube caption provenance (uploaded vs automatic): not stated in the extract.
- No real slide-deck/talk pair researched (synthetic pair only).

## Unresolved seams

W19-SR-01…SR-16 (`seam-requests.yaml`); open items in `05-decision-seam-ledger.md` §4: multi-author asserter (W21/W01), deck–talk predicate (W21), PMC manuscript version marker (W09/W00), CT.gov history path (W09), caption authorship (W20/W21). CL-003 and CL-012: proposed rulings written; not ruled.

## Confidence

| Dimension | Confidence | Basis |
|---|---|---|
| CL-003 identity rule (R1–R5) | high | real records with observed rendition differences; positive and negative fixtures run |
| `renditionCoverage` need | high | PubMed abstract-only rendition vs PMC/publisher Methods sentence (run) |
| AuthorityScope (12 values) | medium | covers 127/127 entries; the cut lines are judgment calls tied to CQs; 11 manual overrides |
| SourceKind additions | medium–high | 46/127 entries lack a value; OTHER and TECHNICAL_DOCUMENTATION are lower priority |
| Candidate types admitted | medium | CQs and failing cases exist and run; whether Fable wants operational records in the shared graph is a policy call |
| V-409/V-512 ordering defect | high | reproduced with a late archive capture; corrected rule returns 0 |
| Operations | medium | Community run only; Enterprise constraints untested |

## Review status

Self-checked: every fixture statement changed the graph (no MATCH-miss no-ops); all queries' actual rows recorded; all YAML files parse; SDL parses and builds with a stub. Not reviewed by another worker. No file outside `workers/W19/` was written (scratch files only in the session scratchpad).

## Artifact digests (SHA-256)

See the block appended below (computed after the last edit of every other file; this report's own digest is not self-referential and is reported to the caller).

```
8a2b6983a01584c9370ea3dc40a5a0fa0a4c30d5ea7c99eea7bb2b87af7e89e2  ./01-domain-recommendation.md
7bf124dd685ae6edcaf152a85058e7f95f9032deb88f3290a32419183ff7d339  ./02-cq-coverage.md
dedeb8d6061e88c3d171d4819b136bcf2d4b05bbfde06cbb5eba1513762a464e  ./03-source-manifest.md
d4156b8d12c6837037b9b245b242f5830fc330497e247cd22b3a9c1f4671878c  ./04-model-cards.md
9f13bcfe1741d1838475a36f41eaf39338f08bf467239009c5673dae382d4edd  ./05-decision-seam-ledger.md
9f71a21f4872cf1bf8b9ee418e2521ca3462857ffe075511c2ff38791a397df2  ./06-fixtures-and-queries.md
923d49804efb9a7f423a87a842e49e437befb3e2c160e7266527c9063de435dc  ./07-operations.md
0074a9920c7cc177e568dab59464d5feac5116ed602abfeb1ab0921dd7fe66f1  ./fixtures/01-cl003-work-rendition-identity.cypher
5363b7ca7561acb580808df9cf2eadb52bb4427c21eaa6fc9a0839bea786deab  ./fixtures/02-primary-vs-retelling.cypher
eae166faff73ffedc3890f65c82f87c68b4d32cac5bf1462e24b462a81dae656  ./fixtures/03-partial-capture-not-found.cypher
bd84771b8ef2b427046ad24bbedf95f854a5b5ba49fb4a0e02e67d85c263b8a6  ./fixtures/04-source-revision-reanchor.cypher
cd2ae37c4072e552bd942bd1fb85575cbe20d1c478a35ed1917b1156c73fca2f  ./fixtures/05-coverage-discovery-authority.cypher
2112dde9569a641745fd0dcc4a700e89dc8a2240fd7a870fe9f017f3685434be  ./fixtures/80-queries.cypher
f2067b198f63dd29f6b8828bbe18d96dec9ca177019e670857292bbad0dabcbe  ./fixtures/90-negative-mutations.cypher
2ed3f7734efeba5d5f9c56ee70b8f225c67a2da4e9271a8ff2e74dcd82cd093e  ./fixtures/91-negative-isolated-n1a.cypher
57e17299e3e761c2393ebabe35fe1d4347113c2064ab26198dd749e94ce0dfb5  ./fixtures/92-negative-isolated-n7.cypher
72840120d9115eb0d20835a907286e3c7d020bc88bc2d66b9ba037175baa5abc  ./fixtures/excerpts/ctgov-NCT02678611-connector-2026-10-04.txt
55fb5d96fefee553356f283949acf6fcfa0372880de6580b433bc261da8e33de  ./fixtures/excerpts/hubermanlab-52-transcript-2026-10-04.txt
2d1db376704079b6a466849f7649dc63e22691c3b98e7696abf6d641915a3d3c  ./fixtures/excerpts/megaphone-hubermanlab-feed-partial-2026-10-04.txt
9af26a88567a68d6aa67103f27b558b22ba8975c19cd5b0c574eb81bc8bc0c07  ./fixtures/excerpts/nature-s41514-017-0016-9-2026-10-04.txt
cdc0c1f3f2b73fe7dec0be493d91144a437d1929dd99820315b2dd6d1e4a2224  ./fixtures/excerpts/pmc-PMC5701244-intervention-2026-10-04.txt
815fd6a105b1b075c3e5b779e220cfffce96ffde1fd40f57eebced9cb5ab7c9b  ./fixtures/excerpts/pubmed-29184669-2026-10-04.txt
ac24370709fcb7e4f52179f7d8b8599c4beab6547922d8acbd816b8037415986  ./fixtures/excerpts/pubmed-30155270-metadata-2026-10-04.txt
9af80572b2fb3282c6e710c1d7b6ad4aee4af9a63ff5eb4d7786781fb613bc0f  ./fixtures/excerpts/youtube-n9IxomBusuw-captions-2026-10-04.txt
a6ae77285d51a20537750147b9e29ece0f74ab9bc2f3edfe6ae2a5b9be5e7b60  ./migration-map.yaml
4f3930ed92bf5a772d765ecb4b0af8f889e9603ec8cfd579cf03662cc313306d  ./operations.cypher
c6eb1edb4647bf346929fa2ffeda167dbe89cccfbd3992745054b99edd59cf91  ./registry-authority-mapping.yaml
2cb4c95ff4385c5edf82f6cd6bfc56879561002dca79ab78ae94e5a4f67047e0  ./sdl-fragment.graphql
80f525b7b89989c6ee866f6bfe049ac8efed90aa6005d01b393ec7dd2732570a  ./seam-requests.yaml
```

End time recorded: 2026-10-04T01:22:46Z.
