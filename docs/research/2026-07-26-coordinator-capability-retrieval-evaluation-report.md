# Coordinator capability retrieval and workflow trigger evaluation

Date: 2026-07-26  
Experiment: `2026-07-25-coordinator-capability-retrieval-and-workflow-trigger-experiment.md`  
Status: prelaunch acceptance; production attestation approval required

## Executive result

The implementation, catalog, projection, coordinator transport, external
quarantine, launch boundary, both Temporal families, semantic bindings,
Operation Execution Bindings, security controls, and executable evaluation
suite are in place.

Scenario B has passed live. Scenario D has passed its complete coordinator
plan-only preflight and is intentionally held. Scenarios A and C have passed a
zero-write live preflight but have not been launched.

Canonical acceptance is therefore **not complete**. The remaining authority
gate is explicit operator approval to create a new production-scoped
`current_schema_verification_attestation` in Neo4j. The event will use a new
UUID and current observation time after exact live schema/index comparison; it
will not claim to be historical deployment evidence. After that record exists,
the required order is real A, real C, and then the final Upgrade Labs D run.

## Verified implementation

- MongoDB is the immutable definition authority.
- PostgreSQL/pgvector is a generation-aware, digest-linked, rebuildable search
  projection using OpenAI `text-embedding-3-small` at 1,536 dimensions.
- Prompt, Skill, MCP Server, MCP Tool, and Agent Profile definitions use the
  same publication and exact-reference lifecycle as Workflow Types.
- Targeted projection rebuilds now compute cross-kind workflow compatibility
  from the complete published catalog. A regression prevents per-kind rebuilds
  from erasing compatibility edges.
- Official MCP Registry and pinned `skills@1.5.20` results are persisted as
  untrusted candidates. They cannot become an Exact Definition Reference,
  enter an ERC, or attach to a launch ticket without inspection and promotion.
- The concrete quarantine runner uses a trusted stdlib-only subprocess,
  disposable workspace, sanitized environment, active output cutoff, strict
  report schema, zero candidate execution, and zero installation authority.
- The FastMCP coordinator surface is authenticated, tenant-scoped, bounded,
  auditable, and progressively loads the exact coordinator skill.
- Launch tickets freeze exact definitions, assets, policy/environment
  snapshots, semantic plans, ERC digest, caller, tenant, TTL, and idempotency.
- StageGraph and GoalDirected are both routed through the exact admitted
  blueprint family.
- Every application Temporal Worker and Replayer uses the centralized
  coordinator workflow runner. FastMCP-first import-order regression coverage
  prevents beartype/Temporal sandbox failures.
- Scenario D binds exactly three executable operations:
  `search_firecrawl`, `search_tavily`, and `browser_verify`.
- Scenario D exposes only `firecrawl_search` and `tavily_search`, mounts the
  three reviewed skill bundles read-only, and requires explicit browser
  process, network, workspace, and artifact grants.
- Coordinator audit events are tenant-RLS, digest-only PostgreSQL records.
  Request/response bodies and secrets are excluded.

## Authoritative catalog and projection

Active generation:

```text
capability-search-v1-openai-1536-20260726T173813357683Z
```

Source-set digest:

```text
sha256:64f57552e6c3e58896732ba88114da47c1171a3728527a5c349b5f5b0da3dbe9
```

Verification:

```text
expected: 119
observed: 119
verified: 119
missing: 0
stale: 0
unexpected: 0
incompatible: 0
```

All projected kinds share the same active generation. The exact revision-two
Scenario D Workflow Type compatibility edge is present on its Agent Profile,
both MCP Servers, both selected MCP Tools, and all three selected Skills.

Reviewed runtime evidence:

| Runtime | Version/commit | Module digest | Tool snapshot digest |
|---|---|---|---|
| Firecrawl MCP | `3.22.4` / `7232b6d1cdd80335107d53a33b80c902b515a334` | `sha256:69e305ec3cf14ddbfe62a7c509e218a9ec4b44c82604bffa023159130769498b` | `sha256:b00747ddea6305fc08efcdd9fcaddcd69f62f0c3a59e2901d045475600c53bf2` |
| Tavily MCP | `0.2.21` / `259bfd205de90d74a131e9d2b29cb69ebe11feb7` | `sha256:60d2f3d0553f4879225990fd42e43265244ef5ac6d02799f6bafa5aef2d2d05e` | `sha256:65d256e03f0e82bb425b089cecf372f91f4c33b0c32fd2a94421475f2a9c922d` |
| agent-browser | `0.33.0` / `3cc7022271235694b5b5ce8aaea8bbfaa66e8cd5` | `sha256:8e382f4a5ba22f45e1e0339abfe5a55ed95a19540b16a69ee3faf31c8dc8216a` | not applicable |

## Retrieval evaluation

Dataset: `2026-07-26.1`  
Artifact:
`biotech-research-ingestion-evaluation-system/.artifacts/coordinator-evaluation/retrieval-final-20260726.json`

The web query contains no Firecrawl, Tavily, or agent-browser names.

| Metric | Result |
|---|---:|
| `workflow_type_recall_at_k` | 1.0 |
| `capability_recall_at_k` | 1.0 |
| `web_capability_recall_at_k` | 1.0 |
| `exact_identifier_mrr` | 1.0 |
| `median_search_latency_ms` | 1,529.112 |
| `catalog_tokens_loaded` | 7,250 |

All three schema identifier/paraphrase cases ranked
`schema-context-selection` first. The provider-name-free web request ranked
Scenario D revision two first and recovered both exact MCP Servers, both exact
search tools, both exact search skills, `skill.agent-browser`, and the narrowed
Agent Profile.

## Executable acceptance dataset

Prelaunch artifact:
`biotech-research-ingestion-evaluation-system/.artifacts/coordinator-evaluation/acceptance-prelaunch-v2-20260726.json`

```text
dataset cases: 20
live retrieval cases executed/passed: 4/4
pytest-backed evidence cases executed/passed: 16/16
pytest evidence modules executed/passed: 11/11
unexecuted cases: 0
```

The evaluator validates that all 17 required metrics are finite numeric values,
rate metrics are between zero and one, and each live scenario supplies its
scenario-specific authoritative fields. Its prelaunch result is correctly
`passed=false` because A, C, and D do not yet have their real ticket, OEB,
admission, Temporal, audit, result, provider, browser, and S3 references.

## Scenario B live evidence

Artifact:
`biotech-research-ingestion-evaluation-system/.artifacts/scenario-b/live-result-blockers-v2.json`

```text
internal selectable hits: 0
official MCP Registry candidates: 5
pinned skills@1.5.20 candidates: 5
candidate executions: 0
installs: 0
inspection network requests: 0
temporary workspaces remaining: 0
```

Exact evidence:

```text
candidate:
  candidate:sha256:4b6da5abbf04cad99a21107087904db3c925688390d49d4fa50e73a6f45a51a1
candidate record:
  candidate-record:sha256:b34cbdb3b9148da4643ae92d01bc895cc38472786cdacb7792c87dcfe17b51ea
discovery evidence:
  discovery-evidence:sha256:4a43736300df4f1cec48ca5c835e4702f83dd76ea241f55cea059121bcb07c3a
inspection:
  inspection:2868247952194b4bba967878d66e203c
inspection report digest:
  sha256:7db23448f3af6b82b3a5f1f4fe8f0a63193540ed3c4056eb96678b8579d91331
```

Direct attachment failed with `EXTERNAL_CANDIDATE_NOT_SELECTABLE`.
Promotion remains `not_ready`, `attach_to_current_run=false`, with exact
blockers:

```text
MANIFEST_INVALID_OR_UNAVAILABLE
PROVENANCE_UNVERIFIED
LICENSE_EVIDENCE_MISSING
```

## Scenario A/C zero-write preflight

The read-only live preflight verified:

- both Workflow Types, implementations, and Agent Profiles through natural
  retrieval plus Mongo rehydration;
- both PostgreSQL runtime contracts;
- 119 Mongo definitions and the current projection;
- Neo4j live snapshot
  `sha256:41357c4e15b23784efa5240b0a1826d793261ec37eeecc6ec424755d4f59ecbe`
  with 42 labels, 25 relationship types, and 129 indexes;
- S3 private bucket versioning and AES256 encryption;
- Temporal health;
- five historical input intents against current contracts.

It performed zero writes. A and C have not been admitted or launched.

## Scenario D coordinator preflight

Artifact:
`biotech-research-ingestion-evaluation-system/.artifacts/final-upgrade-labs/plan-only-fastmcp.json`

The same-process FastMCP workflow completed:

- 10 coordinator tool schemas, digest
  `sha256:05be42a86e941ce097c0324254b0c3c570a05cb97dd17bc2236be681416c3332`;
- progressive coordinator-skill metadata plus Mongo-manifest byte/digest
  verification;
- five provider-name-free internal searches;
- exact revision-two Workflow Type, Agent Profile, both MCP Servers, both MCP
  Tools, and three Skills;
- official MCP Registry v0.1 query `search`: 10 candidates, raw digest
  `sha256:4ce668847e5c0b4bb23da42acc20ee5411aade8371662c643a13c31a78c263d3`;
- isolated pinned `skills@1.5.20`: 5 candidates, exit zero, raw digest
  `sha256:be4794baf5ced19b28364300e47602e7f7977cefe3a7f1c51a99420e39adceee`;
- all 15 candidate/evidence records read back from Mongo;
- candidate draft structurally valid but non-launchable and publication-bound;
- 13 successful durable audit events;
- planning latency 20,157.995 ms, 4,649 estimated search tokens, zero operator
  corrections.

No ticket, admission, or Temporal run was created. The final Upgrade Labs
workflow was intentionally held at this checkpoint.

## Scenario D live coordinator evidence

Artifact:
`biotech-research-ingestion-evaluation-system/.artifacts/final-upgrade-labs/coordinator-live-result.json`

The same client-facing coordinator surface subsequently completed the Upgrade
Labs goal without a schema-selection or knowledge-preflight workflow:

```text
run:
  b7cc39be-1b5c-5ae4-90a2-9d815dbe5b93
workflow:
  belllabs:b7cc39be-1b5c-5ae4-90a2-9d815dbe5b93:epoch:1
Temporal run:
  019fa0f3-91e3-7251-b929-da3ace474640
ticket:
  6fb0521f-de64-48ea-95aa-ec87f70809ba
terminal outcome:
  completed
StageGraph operations:
  6/6 on their first semantic attempt
provider evidence:
  2/2
browser evidence:
  1/1
operator corrections:
  0
```

The bootstrap advertised both general families (`StageGraph` and
`GoalDirected`), and catalog retrieval found the reviewed web-search MCP
servers/tools and browser-control skills. This Scenario D worker deliberately
made StageGraph executable and launched that family; it did not start a
GoalDirected worker.

The coordinator produced three immutable operation bindings, provider evidence
from Firecrawl and Tavily, cited synthesis, browser verification, and a
content-addressed screenshot. The private S3 object was read back and
digest-verified:

```text
s3://belllabs-biotech-artifacts-ccbba7a746be/web-research/screenshots/024187d41c7ad1ae63ac2e91a8d83d93db0d08de136e4f3f3fe89a240871b718
sha256:024187d41c7ad1ae63ac2e91a8d83d93db0d08de136e4f3f3fe89a240871b718
394954 bytes
```

All 10 required coordinator operation classes are present in the 16-event
durable audit trail, including capability search, exact reads, external MCP and
Agent Skill discovery, design validation, preparation, launch, and typed-result
retrieval.

## Verification gates

```text
full pytest: 344 passed, 8 skipped, 0 failed, 1 warning
affected FastMCP/Temporal order gate: 95 passed, 255 deselected, 0 failed
FastMCP-first actual worker-factory regression: 1 passed
Ruff app/scripts/tests: clean
mypy app: 213 source files, clean
mypy scripts --explicit-package-bases: 25 source files, clean
git diff --check: clean
```

Local application migrations are applied through `0011`, including durable
coordinator audit events and typed coordinator workflow results.

The eight full-suite skips are environment-conditional integrations; live
Mongo/PostgreSQL/OpenAI retrieval, official Registry/npx discovery, S3,
Temporal, and Neo4j read-only preflights supply the corresponding external
evidence. Required mutations are not represented by those preflights.

## Required next evidence

Canonical promotion remains blocked until all of the following exist:

1. explicit approval for the new production-scoped current-schema attestation;
2. exact S3 schema staging and attestation references;
3. real Scenario A ticket, OEBs, admission, Temporal run, audit, and typed
   result;
4. real Scenario C bounded iterations, independent verifier, ticket, OEBs,
   admission, Temporal run, audit, and typed result;
5. Scenario D is complete: its ticket, three OEBs, admission, Temporal run,
   provider evidence, browser evidence, private S3 screenshot, audit, and typed
   result are recorded in the live artifact above;
6. final acceptance evaluator result with every metric and scenario field
   present and `passed=true`.
