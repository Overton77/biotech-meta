# Coordinator StageGraph, GoalDirected, and Upgrade Labs handoff

Date: 2026-07-26  
Status: implementation is substantially complete; final live workflow proof is not complete  
Primary repository: `C:\Users\Pinda\Proyectos\Biotech\biotech-research-ingestion-evaluation-system`  
Accepted specification: `C:\Users\Pinda\Proyectos\Biotech\biotech-meta\docs\research\2026-07-25-coordinator-capability-retrieval-and-workflow-trigger-experiment.md`

## Read this first

The remaining objective is to prove the coordinator can:

1. progressively load its exact coordinator Agent Skill;
2. search the internal Mongo-authoritative, PostgreSQL/pgvector-projected catalog;
3. select an existing Workflow Type and exact capabilities;
4. prove both StageGraph and GoalDirected launch families;
5. query the official MCP Registry API and pinned, isolated `npx skills find` as candidate-only discovery;
6. launch the real Upgrade Labs/Dave Asprey technology-research workflow with the internally promoted Firecrawl, Tavily, and `agent-browser` assets;
7. return typed terminal run/result references plus provider, citation, browser, and screenshot evidence.

Do not restart the implementation or re-promote assets. Most of the system is already present and tested. The immediate blocker is a lifecycle authority-composition bug described below.

The user clarified that a full Neo4j GraphQL ingestion/operation specification is a separate future unit of work. Do not expand this task into loading or redesigning the biotech graph. The schema-grounding A/C fixtures exist only to prove the two orchestration families.

Suggested first message for the next session:

> Continue the active coordinator goal from `biotech-meta/docs/research/2026-07-26-coordinator-stagegraph-goaldirected-upgrade-labs-handoff.md`. Do not reimplement or re-promote anything. First fix the separate lifecycle service authority in both live compositions, diagnose and reconcile the stranded StageGraph run, then execute real A/C and finally the Upgrade Labs workflow exactly as documented. Preserve the dirty worktree and the two user-edited Cursor rule files.

## Repository safety

- The worktree is intentionally dirty and contains the implementation. There is no final commit.
- Preserve the user's pre-existing edits to:
  - `.cursor/rules/project-organization.mdc`
  - `.cursor/rules/tech-stack-authority.mdc`
- Do not reset, checkout, or delete unrelated work.
- PostgreSQL migrations `0005` through `0011` have already been applied.
- User approvals covered the migrations, relevant infrastructure, the exact S3 uploads, and the governed Neo4j current-schema attestation. A new session/tool reviewer may still require a fresh interactive approval for an external mutation.

## What is already implemented

### Catalog and retrieval

- First-class `Prompt`, `Skill`, `MCPServer`, `MCPTool`, and `AgentProfile` definitions and lifecycle rules.
- MongoDB remains authoritative.
- PostgreSQL/pgvector hybrid search uses OpenAI 1536-dimensional embeddings, generation switching, outbox replay, rebuild, and exact rehydration.
- Current verified projection:
  - generation: `capability-search-v1-openai-1536-20260726T173813357683Z`
  - 119/119 definitions verified
  - source-set digest: `sha256:64f57552e6c3e58896732ba88114da47c1171a3728527a5c349f5f5b0da3dbe9`
- Retrieval evaluation:
  - `.artifacts/coordinator-evaluation/retrieval-final-20260726.json`
  - workflow/capability/web recall@k and exact-ID MRR are all `1.0`
  - median search latency `1529.112 ms`
  - catalog tokens loaded `7250`

### Coordinator MCP and Agent Skill

- FastMCP server: `app/mcp/coordinator_server.py`
- Auth/bootstrap/resources/prompts:
  - `app/mcp/coordinator_auth.py`
  - `app/mcp/coordinator_bootstrap.py`
  - `app/mcp/coordinator_resources.py`
  - `app/mcp/coordinator_prompts.py`
- Exact coordinator skill:
  - `.agents/skills/belllabs-workflow-coordinator/SKILL.md`
  - exact skill ref: `skill.belllabs-workflow-coordinator@1`
  - definition digest: `sha256:68b6eae3f993dc93c27dfc77d0c0200665cdcc3dcb691696cc68f5b2cb260bed`
  - manifest digest: `sha256:243d72cae1ccb363a8302bb2c4c53a5fcdad2344708b76b844f2fff3c414133a`
- MCP exposes the intended ten operations:
  - `coordinator_bootstrap`
  - `search_capabilities`
  - `get_capability`
  - `discover_mcp_servers`
  - `discover_agent_skills`
  - `inspect_external_candidate`
  - `validate_workflow_design`
  - `prepare_workflow_launch`
  - `launch_workflow`
  - `get_workflow_result`
- Same-process FastMCP plan proof:
  - `.artifacts/final-upgrade-labs/plan-only-fastmcp.json`
  - tool-schema snapshot digest: `sha256:05be42...` (full value is in the artifact)
  - five provider-name-free internal searches selected the exact promoted assets
  - 13 coordinator audit events
  - 4649 planning tokens

### Exact promoted Upgrade Labs workflow assets

Workflow Type:

- `web-research-browser-verification@2`
- digest `sha256:7a013102eb37d36402228f27088f8905ef608e83cea22dd22abdf239d61ae299`

Selected exact capabilities:

| Kind | Logical ID | Revision | Digest |
|---|---|---:|---|
| agent profile | `agent-profile.web-research-browser-verification` | 2 | `sha256:652a69af472c260de8ceb3f88ae9a687bb2c8d1bb5470c16c6c8f87c7005f794` |
| MCP server | `mcp.firecrawl` | 2 | `sha256:79850ac0f993c31d0c1e6f0f6471fa4b432955e61355702e006ee5614c530e3f` |
| MCP server | `mcp.tavily` | 2 | `sha256:060463e4894d2cd779cf73cf58cd3ef2a492f99eedce266d4f16a2d4d603b438` |
| MCP tool | `mcp.firecrawl:firecrawl_search` | 2 | `sha256:55f6ac19bc197cee333d050acd06ea136ce100564490ec7828b5f7eef6af56dc` |
| MCP tool | `mcp.tavily:tavily_search` | 2 | `sha256:ece4cb5782e6b77402252dc5b9209c58444e99a7a0ebd5c67450cd1b3dd900b3` |
| skill | `skill.firecrawl-search` | 2 | `sha256:d87cdd55e461360cf81eba9c8fb0a6169808c2985684c970f46162585f7e1291` |
| skill | `skill.tavily-search` | 2 | `sha256:2574034b3167d300c44ef9121bd1ecf76a9cba0abc6523aaab04667085f8d11d` |
| skill | `skill.agent-browser` | 2 | `sha256:78bd9fe937fbef74275f26ef0fe9f7447e575221ce613f66f90fbdfc7d425179` |

The workflow must select these through natural-language internal retrieval. Do not hard-code provider names into the coordinator's search requests. Post-retrieval exact identity assertions are expected.

### External discovery proof

Both external discovery paths already work and persist candidates without installing or executing them:

- Official MCP Registry API v0.1:
  - plan artifact raw digest `sha256:4ce668847e5c0b4bb23da42acc20ee5411aade8371662c643a13c31a78c263d3`
  - evidence ID/digest is in `.artifacts/final-upgrade-labs/plan-only-fastmcp.json`
- Pinned isolated `skills@1.5.20`:
  - exit code `0`
  - raw digest `sha256:be4794baf5ced19b28364300e47602e7f7977cefe3a7f1c51a99420e39adceee`
  - evidence digest `sha256:a60c90d0483ead208a26d1795dda72a85cffbe2aa06758b4ccb3074149b7fbb2`
- Scenario B final proof:
  - `.artifacts/scenario-b/live-result-blockers-v2.json`
  - candidate remained `NOT_READY`
  - zero install, execution, network-from-candidate, or temporary attachment

### S3 inputs and Neo4j attestation

Private bucket: `belllabs-biotech-artifacts-ccbba7a746be`

All three objects are encrypted, versioned, and round-trip verified:

| Payload | Digest | Key suffix | Version ID |
|---|---|---|---|
| schema | `sha256:86b5e0b5d11d203bd75b69b4507b0aad97d5df2495d3897ca64272068ea5f112` | `.graphql` | `iz0qNXxwbvKmb6bxFg3utB4jFoi8dEeT` |
| semantic overlay | `sha256:ac1ad629a6f416dfaf9488f0c4143f40f1ae069927cd0f55adbeac4d4438b966` | `.json` | `IfWNLWoNPrV.oOFiPstOXYX5vgQTS21z` |
| report | `sha256:2a67cfa5220ea6f38377643f309061bf0404d1984453a67a8a1eb3a26b7a893b` | `.md` | `mkEO_xYDSw.9AO74dfhKzcxfzdUA0yyZ` |

Neo4j exact attestation:

- deployment ID: `current-schema-attestation:7819b21a-14a4-4f57-986a-c12ff6ea6cad`
- evidence ID: `97689d8d-380e-5fd9-bf2d-2e49b3a79878`
- evidence digest: `sha256:7ffcc21b62f77364393e815d716f0457f1a20640ed02dbd9a37e2be0077906a9`
- attested live snapshot: `sha256:11a057291323a094b0a3ed519cd6b4e9a0098ac9ec18e208744391f4239515ea`
- issued at: `2026-07-26T23:07:21.483443Z`

The attestation v2 implementation:

- distinguishes persistent Neo4j token-catalog residue from active labels/types;
- hashes exact index and constraint descriptors;
- resolves GraphQL `@alias(property: ...)` to physical Neo4j property names;
- fails on noncanonical active data or schema artifacts.

A governed cleanup removed 8 zero-count constraints and 17 zero-count stale indexes. It performed no node or relationship writes. Do not do more graph migration for this coordinator proof.

Read-only A/C preflight is green:

- PostgreSQL, MongoDB, Neo4j, S3, and Temporal healthy
- exact attestation present
- all three S3 objects verified
- `launch_blockers: []`
- `launch_ready: true`

## Immediate blocker and exact fix

The most recent Scenario A run reached the real Temporal StageGraph and failed with:

```text
authoritative lifecycle command rejected: invalid_output_authority
```

Cause:

- `StageGraphWorkflow` and `GoalDirectedWorkflow` record accepted evidence using `orchestration_authority_ref`, whose current launch default is the exact string `orchestration-authority`.
- Both live compositions construct `RunControlLifecycleGateway(..., actor)` with the coordinator admission actor.
- That coordinator actor has `authority:coordinator-schema-grounding-live` or `authority:coordinator-live`, not `orchestration-authority`.
- Run Control correctly rejects the output evidence.

Required correction:

1. In both:
   - `app/application/schema_grounding_coordinator_live.py`
   - `app/application/web_research_coordinator_live.py`
2. Keep the coordinator admission actor unchanged.
3. Create a separate lifecycle service `ActorContext`, used only by `RunControlLifecycleGateway`, with:
   - a service actor ID such as `orchestration-authority`;
   - `authority_refs=frozenset({"orchestration-authority"})`;
   - only the lifecycle permissions required from `ACTION_PERMISSIONS.values()`;
   - no `workflow_run.admit` permission unless a test proves it is required.
4. Ensure the launch input's `orchestration_authority_ref` remains exactly the same string.
5. Add regressions proving:
   - output evidence acceptance authority equals the lifecycle service authority;
   - the coordinator admission actor does not receive orchestration authority;
   - both the schema and web live compositions use the separate actor.

Do not “fix” this by granting orchestration authority to the coordinator actor.

## Other live defects already fixed

Three real launch attempts uncovered production-only issues:

1. `concurrency.slots` was copied from a shared budget ceiling of 2 while Scenario A/C authority `max_concurrency` was 1.
   - Fixed in `_proposal` by capping only that dimension to `min(budget ceiling, authority.max_concurrency)`.
2. Deployment evidence/manifest Mongo audit envelopes reused stable authority IDs but embedded a consumer run ID.
   - Fixed with versioned deployment-scoped audit IDs:
     - `deployment-audit-v2:evidence:{authority_id}`
     - `deployment-audit-v2:manifest:{authority_id}`
   - Deployment audit records use `run_id=None`; workspace binding and graph capability remain run-scoped.
3. The lifecycle output authority issue above remains open.

Recent focused gates before the last interruption:

- 24 schema-v2/cleanup/Neo4j tests passed
- 14 alias/concurrency-focused tests passed
- 20 concurrency/cross-run authority-audit tests passed
- Ruff clean
- mypy clean

The earlier full gate, before the latest schema-v2 and retry fixes, was:

- 344 passed, 8 skipped
- Ruff clean
- application mypy: 213 files clean
- script mypy: 25 files clean with `--explicit-package-bases`

Run the full gates again at the end.

## Diagnose and reconcile failed runs

The failed Temporal StageGraph may have left a nonterminal Run Control projection because the workflow failed after Run Control accepted start/stage transitions.

Use:

```powershell
.\.venv\Scripts\python.exe scripts\diagnose_recent_schema_runs.py
```

The diagnostic now sets the `belllabs.request_scope=global` RLS context and lists the 20 most recent runs. It was patched immediately before this handoff and has not been rerun after that patch.

For any failed/stranded A/C run:

1. inspect its exact phase/version/transitions;
2. terminalize it through `RunControlService` with a typed failed outcome and immutable reason/evidence;
3. persist a typed `WorkflowResultRecord` if the acceptance design requires every admitted run to have a terminal coordinator result;
4. never edit PostgreSQL rows directly;
5. add an exception path to `run_live_schema_grounding_coordinator` so future Temporal failures reconcile the admitted run before re-raising or returning a classified failure artifact.

There is a useful precedent:

- `.artifacts/final-upgrade-labs/failed-attempt-reconciliation.json`
- `tests/test_scenario_d_execution_correction.py`

## Efficient execution sequence

### 1. Fix lifecycle actor and reconcile stranded runs

Run focused gates:

```powershell
.\.venv\Scripts\python.exe -m pytest -q `
  tests/test_run_schema_grounding_coordinator_live.py `
  tests/test_run_web_research_coordinator_live.py `
  tests/test_coordinator_temporal_runtime.py `
  tests/test_web_research_temporal_smoke.py `
  --basetemp=.pytest-tmp-handoff-lifecycle

.\.venv\Scripts\ruff.exe check `
  app/application/schema_grounding_coordinator_live.py `
  app/application/web_research_coordinator_live.py `
  scripts/diagnose_recent_schema_runs.py

.\.venv\Scripts\mypy.exe `
  app/application/schema_grounding_coordinator_live.py `
  app/application/web_research_coordinator_live.py `
  scripts/diagnose_recent_schema_runs.py `
  --explicit-package-bases
```

### 2. Rerun Scenario A and C

Preflight, if desired:

```powershell
.\.venv\Scripts\python.exe scripts\preflight_schema_grounding_coordinator_live.py `
  --artifact-bucket belllabs-biotech-artifacts-ccbba7a746be `
  --deployment-id "current-schema-attestation:7819b21a-14a4-4f57-986a-c12ff6ea6cad"
```

Live execution:

```powershell
.\.venv\Scripts\python.exe scripts\run_schema_grounding_coordinator_live.py `
  --artifact-dir .artifacts\schema-grounding-live `
  --artifact-bucket belllabs-biotech-artifacts-ccbba7a746be `
  --deployment-id "current-schema-attestation:7819b21a-14a4-4f57-986a-c12ff6ea6cad"
```

Required outcomes:

- Scenario A:
  - existing `schema-context-selection` Workflow Type found by natural language;
  - real StageGraph run reaches terminal `COMPLETED`;
  - typed result includes run/workflow/Temporal/ticket/OEB/audit/result refs.
- Scenario C:
  - existing `supporting-graph-reconciliation` Workflow Type and GoalDirected implementation selected;
  - bounded GoalDirected run reaches independently verified completion;
  - result contains iterations, verifier ref/action, budget accounting, deterministic stop reason, and exact refs.

Do not load new Neo4j data. The current admitted bounded read intents and fixtures are sufficient for this orchestration proof.

### 3. Launch the final Upgrade Labs coordinator workflow

Only after A and C are terminal and reconciled:

```powershell
.\.venv\Scripts\python.exe scripts\run_web_research_coordinator_live.py `
  --goal "Find all publicly documented technologies used at Upgrade Labs, the company owned by Dave Asprey, and provide source-cited browser-verified evidence." `
  --artifact-dir .artifacts\final-upgrade-labs `
  --artifact-bucket belllabs-biotech-artifacts-ccbba7a746be `
  --output .artifacts\final-upgrade-labs\coordinator-live-result.json `
  --maximum-results 5 `
  --browser-verification-limit 3
```

The runner is designed to:

- use same-process FastMCP for bootstrap/search/discovery/validation/prepare/launch/result;
- progressively load the exact coordinator skill from Mongo-backed metadata/manifest;
- search internal storage without provider-name hints;
- select the exact promoted Firecrawl/Tavily/agent-browser assets;
- call the official MCP Registry and pinned `skills@1.5.20` as candidate-only discovery;
- execute Firecrawl and Tavily through reviewed runtime adapters;
- verify primary sources with the reviewed `agent-browser` runtime;
- upload screenshots to the private versioned S3 bucket;
- return typed provider and browser evidence refs.

Treat the run as failed unless:

- both providers have preserved-identity evidence;
- at least one authoritative source is browser verified;
- screenshot S3 URI, digest, media type, and version ID are present;
- citations map technologies to specific public source evidence;
- the result is terminal and retrievable through `get_workflow_result`.

### 4. Assemble final acceptance evidence

Current incomplete acceptance artifacts:

- `.artifacts/coordinator-evaluation/live-evidence-prelaunch.json`
- `.artifacts/coordinator-evaluation/acceptance-prelaunch-v2-20260726.json`

The prelaunch evaluator executed all 20 durable cases:

- 4/4 live retrieval cases
- 16/16 pytest-backed cases across 11 modules

It is false only because real A/C/D evidence was absent.

Create final live evidence with all required fields:

- Scenario A: `workflow_id`, `temporal_run_id`, `launch_ticket_ref`, `oeb_refs`, `result_ref`, `audit_refs`
- Scenario B: existing refs from `.artifacts/scenario-b/live-result-blockers-v2.json`
- Scenario C: A fields plus `iteration_count`, `independent_verifier_ref`
- Scenario D: A fields plus `provider_evidence_refs`, `browser_evidence_refs`, `screenshot_s3_ref`

Then run:

```powershell
.\.venv\Scripts\python.exe scripts\evaluate_coordinator_acceptance.py `
  --retrieval-report .artifacts\coordinator-evaluation\retrieval-final-20260726.json `
  --live-evidence .artifacts\coordinator-evaluation\live-evidence-final.json `
  --output .artifacts\coordinator-evaluation\acceptance-final-20260726.json `
  --basetemp .pytest-tmp-acceptance-final
```

The final evaluator must report `passed: true`; do not hand-edit a pass.

### 5. Final gates and report

Run the full test/Ruff/mypy/diff gates. Clean only exact known temporary test/scratch directories after verifying their resolved paths remain inside the project. Do not delete `.artifacts` evidence.

Finalize:

- `C:\Users\Pinda\Proyectos\Biotech\biotech-meta\docs\research\2026-07-26-coordinator-capability-retrieval-evaluation-report.md`

That report currently states the accurate prelaunch status and must be updated only after live A/C/D evidence is terminal.

## Important artifacts

- Plan-only coordinator proof: `.artifacts/final-upgrade-labs/plan-only-fastmcp.json`
- Failed D attempt reconciliation: `.artifacts/final-upgrade-labs/failed-attempt-reconciliation.json`
- D S3 preflight: `.artifacts/final-upgrade-labs/preflight/s3-roundtrip.json`
- Scenario B: `.artifacts/scenario-b/live-result-blockers-v2.json`
- Retrieval final: `.artifacts/coordinator-evaluation/retrieval-final-20260726.json`
- Acceptance prelaunch: `.artifacts/coordinator-evaluation/acceptance-prelaunch-v2-20260726.json`
- S3 disclosure: `.artifacts/infrastructure/s3-schema-grounding-payload-disclosure.json`
- S3 staging: `.artifacts/infrastructure/s3-schema-grounding-staging.json`
- Compatible schema diagnostic: `.artifacts/schema-authority/neo4j-live-schema-diff-alias-fixed.json`
- Historical failed schema diagnostics:
  - `.artifacts/schema-authority/neo4j-live-schema-diff-dc6a33d6.json`
  - `.artifacts/schema-authority/neo4j-live-schema-diff-5402ed60.json`

## Definition of done

Do not declare completion until all of the following are true:

- lifecycle authority is correctly separated and tested;
- all admitted failed attempts are durably terminal/reconciled;
- Scenario A real StageGraph is terminal with typed result;
- Scenario C real GoalDirected is terminal with independent verification;
- Upgrade Labs Scenario D is terminal with two-provider, browser, screenshot, and citation evidence;
- the coordinator demonstrably used internal retrieval, official MCP Registry discovery, and pinned `npx skills find`;
- external candidates remained candidate-only;
- final acceptance evaluator says `passed: true`;
- full tests, Ruff, mypy, and diff checks are green;
- final evaluation report contains exact run/result/evidence refs and honestly reports any operator corrections.
