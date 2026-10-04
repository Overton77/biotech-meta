# 04 Standard worker brief (applies to W00–W23)

You are one research/modeling worker in run `run-2026-10-04-fable51-01`. Fable 5.1 is the coordinator and final synthesizer; you do not write the final schema. You write **only** inside `docs/schema/ontology-lab/final-proposal-team/run-2026-10-04-fable51-01/workers/<Wxx>/`. You never edit `current_biotech_schema.graphql`, the catalog, rounds, CHANGELOG, OPEN-QUESTIONS, other workers' directories, or the run's numbered files.

## Read first, in this order

1. `../../01-shared-contract.md` (frozen), `../../02-ownership-registry.md` (your row and the rows you depend on), `../../03-conflict-ledger.md`, `../../00-baseline.md` (runtime facts).
2. `docs/schema/ontology-lab/domain-discovery-and-cursor-team-handoff.md` sections 2–6 (your worker row in section 3, the mandatory cases in section 6).
3. Authority: `docs/schema/catalog/schema.yaml` (your module and `conventions`), `docs/schema/architecture.md`, `docs/schema/ontology-lab/proposal-index.md`, `competency-questions.md` (your CQ families), `query-shapes.md`, `live-schema-alignment.md` (your live lines), `property-cards.md` (your cards), the rounds named in your registry row, `docs/schema/neo4j/validation.cypher` (your V-family), `docs/schema/examples/*.cypher` (fixtures that touch your types), `docs/schema/sources/source-registry.yaml` (entries in your area), the live schema lines for your types.
4. The two independent reviews in `docs/schema/ontology-lab/` for your area.

## Deliverables (fixed file names)

| File | Content (handoff section 6 item) |
|---|---|
| `01-domain-recommendation.md` | (1) boundaries and subdomains; actual baseline names and canonical modules; keep/refine/merge/split/seam/defer disposition for **every** live and catalog element in your scope; identity vs state vs artifact vs occurrence; alternatives considered; smallest recommended model. No industry survey. |
| `02-cq-coverage.md` | (2) matrix: existing CQ ids (priority, answerability) → example answer → distinction → evidence requirement → proposed node/property/edge/edge property → query shape → prevented failure. New CQs are `CQ-<AREA>-C<nn>` candidates with rationale. Every SDL element appears in this matrix or in the invariant/ingestion-failure list; unmapped elements are candidates and stay out of the fragment. |
| `03-source-manifest.md` | (3) one row per source actually consulted: primary URL/id; title; source kind; publisher/asserter and authority scope (`authorityFor` / `notAuthorityFor`); publication, observation and retrieval times; exact page/field/quote/timecode/region; capture method and completeness (COMPLETE / PARTIAL_EXCERPT / SEARCH_EXTRACT / BLOCKED); hash basis if you hashed; excerpt; restrictions; **cannot-establish** statement. Mark each as NEW_RETRIEVAL, INHERITED_REPO_CITATION or SYNTHETIC_FIXTURE. |
| `04-model-cards.md` | (4) one card per owned node, relationship, relationship-property type and enum: meaning, archetype, labels, uid token, properties (type, nullability, units, value-state semantics, privacy class, temporal behaviour, kind asserted/observed/calculated/inferred/operational), edges (domain, range, direction, cardinality, class, properties), identity keys and aliases, derived inputs and rules, enum ownership, source references, maturity. |
| `sdl-fragment.graphql` | (4) full definitions of every element you own, exactly per contract section B. No `extend`. No other owner's types. Must parse with graphql-js; Fable builds the merged file. Start with a comment banner naming the worker, module(s), CQs and digest `8fb50ff0…84f0`. |
| `migration-map.yaml` | list of `{live: <Type.field or relationship>, final: <element or null>, action: keep|rename|move|split|merge|derive|retire, note}` for every live element in your scope. |
| `05-decision-seam-ledger.md` + `seam-requests.yaml` | (5) decisions with evidence-linked alternatives; accepted-for-proposal vs unresolved; kernel-change requests (primary source + failing case); seam requests as YAML list `{id: <Wxx>-SR-nn, targetOwner, request, cq, failingCase, proposedRuling}`. No fabricated consensus. |
| `06-fixtures-and-queries.md` + `fixtures/*.cypher` | (6) realistic public or synthetic positive, negative and minimal-pair cases; temporal correction/late arrival; identity collision; missing facts; access leakage where relevant. Each `.cypher` file: statements separated by `;`, **every statement binds its own nodes by uid** (variables never cross `;`), nodes carry the primary label **and** the archetype label, uids use registered tokens, snapshots use `contentHashBasis: 'SYNTHETIC_FIXTURE'` unless real bytes were hashed. Document expected rows/values/violation ids per query in the `.md`; tag each as run / EXPLAIN / parser-only / not-run (you may not have a database; say so). Include at least one query per Essential CQ you cover. |
| `07-operations.md` (+ optional `operations.cypher`) | (7) uniqueness/index needs with stored property names; retrieval patterns; application validation and transaction/concurrency requirements; capability/edition conditions (Community vs Enterprise; 5.26 minor); idempotence, lifecycle, migration/compatibility, ingestion overhead. No runtime implementation. |
| `08-completion-report.md` | (8) tools actually used and their availability; research gaps; unresolved seams; confidence per dimension; artifact paths with SHA-256 digests (`sha256sum`); review status; what remains qualified. |

## Research rules

- Inventory tools before use: PubMed MCP, ClinicalTrials.gov MCP, Firecrawl search/scrape, Tavily search/extract, WebFetch/WebSearch, bioRxiv, ICD-10, NPI. Fallback: connector → official API/record/first-party HTML or PDF → search extract marked SEARCH_EXTRACT → repository citation marked INHERITED → unresolved evidence request. Never invent a fetch, locator, quotation, registry version or tool result. A 403/blocked fetch is recorded as BLOCKED, never as absence.
- Search to settle a modeling question (is a dose basis stated? is a version identifier public? does a label name the salt?), not to collect papers. Three to eight decisive sources are typical; prefer first-party records (trial registry, label, filing, publisher page, agency database) for their own statements. Company pages establish what a company says, not approval or capability.
- Preserve what a source cannot establish. Unknown stays unknown.

## Modeling rules (in addition to the contract)

- Keep the kernel. Kernel changes need a primary source plus a failing case and go to `seam-requests.yaml` targeting W00.
- Candidate types (handoff "E" rows) enter the fragment only with a named candidate CQ and a failing case in your fixtures; otherwise they stay in the model cards as CANDIDATE.
- Prefer refining an existing live or catalog element over adding a new one; name the smallest model.
- Every forbidden implication in your module gets at least one negative fixture or one validation query reference.
- Where your scope has mandatory cases (W16 protocols; W21, W22 media; cross-domain scenarios named in handoff section 7), each mandatory minimal pair gets a fixture file and expected outcomes.

## Working style

Be decisive and finish all eight deliverables; a shorter complete packet beats an unfinished long one. Do not ask the coordinator questions; record the question as a seam request or an open item and proceed under a stated assumption. Record your start and end time and the model you ran as (Opus 5.5) in the completion report.
