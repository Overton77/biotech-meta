# Decision packet: Control-plane foundations and blueprint split

Status: interview decisions confirmed and extracted  
Interview date: 2026-08-09  
Owner confirmation: explicit, one decision at a time

## Immediate implementation consequence

Freeze the Stage 0–8 planning system, replace its authority with requirement-derived work packages, and implement a cohesive path from immutable Workflow Type configuration through Temporal macro execution into exact Deep Agent capability materialization. The path must lead directly to governed MCP, Agent Skill, sandbox, and other advanced-capability catalogs without reopening the foundation architecture.

## Sources read

- `biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md`
- The four documents under `biotech-meta/docs/specs/pre-research/control-plane-foundations/`
- Frozen implementation index and current Stage 3 execution ledger.
- Current graph-runtime identity, definition, execution-binding, operation-executor, and async-subagent implementation observations.
- `biotech-meta/docs/tech_stack_and_operational_authority.md`, ADR 0001, ADR 0002, and canonicalization skill references.

## Current understanding

Temporal is the sole production macro-workflow runtime. BellLabs application services and pure interpreters retain semantic authority; PostgreSQL owns transactional authority. Deep Agents is the primary bounded cognitive framework, currently at version 0.7.5. LangGraph supports graph/checkpoint/store/middleware behavior where applicable. LangSmith supplies tracing, evaluation, sandboxes, development, and selected separately qualified remote operation placement.

The control plane must compile exact agent capability configuration—not discover or improvise it during execution. StageGraph and GoalDirected are BellLabs blueprint families, not provider graphs. Async subagents are required first-class Deep Agents capabilities and need BellLabs-owned parent/child contracts.

## Confirmed decision ledger

| # | Confirmed decision | Consequence |
|---:|---|---|
| 1 | Freeze the current Stage 0–8 implementation-package organization as superseded planning history. | Preserve evidence, stop gate authority, replace with `WP-*` packages. The last frontier remains Stage 3 planning with `05A = REWORK_REQUIRED`; no agent was active. |
| 2 | Remove the OpenAI Agents SDK from the current target. Do not prohibit a future separately qualified adapter. | No current `SPEC-*`, `REQ-*`, or `WP-*` may require it; provider-neutral seams remain. |
| 3 | Introduce an immutable versioned `DeepAgentProfile` referenced by generic operation assembly and compiled to an exact `DeepAgentExecutionBinding`. | Deep Agents becomes first-class without contaminating workflow semantics. |
| 4 | Separate logical Deep Agent definition from execution placement. | `local_in_worker` and `remote_langsmith_deployment` are exact separately qualified placement variants; no silent fallback. |
| 5 | Permit exact reusable composition at authoring time but require a flattened immutable binding for execution. | Aliases, inheritance, conflicts, authority intersections, and overlays resolve before admission. |
| 6 | Foundations own universal capability references, selection, compatibility, attachment, binding, drift, and failure behavior; capability specifications own detailed catalogs and lifecycles. | The foundation stays bounded while immediately enabling the capability wave. |
| 7 | Split shared durable orchestration from StageGraph and GoalDirected semantics. | One shared Temporal foundation specification and one canonical specification per blueprint family. |
| 8 | Foundation completion requires an end-to-end tracer that materializes at least one exact MCP server, Agent Skill bundle, and sandbox profile into a Deep Agent inside a Temporal-managed operation. | Capability integration cannot remain conceptual; full catalogs may follow. |
| 9 | Async subagents are required, not deferred or reduced to synchronous delegation. | Canonical async parent/child contracts are in scope now. |
| 10 | An async subagent is a durable subordinate of the parent `OperationWorkflow`, with its own identity, binding, lifecycle, messages, cancellation, usage, evidence, and result admission; it is not automatically another Workflow Run. | Parent operation owns start-bind-wait/reconcile; governance boundary controls escalation. |
| 11 | Every async spawn freezes a parent dependency class: `required_blocking`, `degradable_blocking`, `nonblocking`, or `advisory`, plus timeout, cancellation, budget, admission, fallback, and late-result behavior. | A model cannot retroactively decide whether a child matters or weaken its policy. |
| 12 | Implement the async lifecycle as well as the current scope permits, then optimize provider-specific lifecycle/functionality later. | The first implementation must be correct and traceable; advanced optimization is deferred, not foundational semantics. |
| 13 | Deep Agents 0.7.5 is already installed; no separate compatibility probe is required. | Implement from official documentation and architecture, resolving concrete errors in the real vertical and recording evidence. |
| 14 | Preserve the detailed architecture proposal as source/interview evidence and create a concise normative ADR. | ADR-0003 and canonical specs become implementation authority. |

## Durable decisions already supported by evidence

- One `BellLabsRunWorkflow` root per admitted run.
- Family workflows apply pure StageGraph or GoalDirected semantics.
- Generic `OperationWorkflow` owns independently durable semantic operation attempts.
- Application command/message ledgers and product events remain authoritative over Temporal/provider transport.
- Continue-As-New preserves run and epoch and advances only a technical segment.
- Product forks create a new run at epoch 1 from immutable semantic snapshots.
- Linked Workflow Runs compile and admit independently and require parent-side result admission.
- Deep Agents/graph checkpoints, traces, prompts, tools, Skills, MCP availability, and provider tasks grant no authority merely by existing.

## Conflicts and supersession candidates

- Pre-research foundation 04 explicitly targets the OpenAI Agents SDK: rewritten and superseded by `SPEC-CP-DEEP-AGENT-RUNTIME`.
- Pre-research foundation 03 combines shared orchestration with both blueprint families: split among three canonical owners.
- Old stage packages contain multiple framework eras and oversized mixed-authority packages: frozen for extraction under WP-CP-001.
- Current async models provide partial remote-graph-shaped observations but lack the accepted complete lifecycle: version/replace through WP-CP-045.

## Canonical destinations

- `ADR-0003`
- `SPEC-CP-DEFINITIONS`
- `SPEC-CP-RUN-CONTROL`
- `SPEC-CP-DURABLE-EXECUTION`
- `SPEC-CP-DEEP-AGENT-RUNTIME`
- `SPEC-BP-STAGEGRAPH`
- `SPEC-BP-GOAL-DIRECTED`
- `implementation_work_packages_v2/WP-*`

## Recommended source dispositions

- Architecture proposal: preserve and promote into ADR/spec lineage.
- Pre-research foundations 01–02: supersede/archive after extraction.
- Pre-research foundation 03: split, supersede, then archive.
- Pre-research foundation 04: rewrite, supersede, then archive.
- Stage 0–8 packages and Stage 3 ledger: preserve as historical until per-document extraction is complete.

## Decisions that may safely remain deferred

- Exact remote LangSmith placement promotion evidence.
- Provider-specific async task mechanism and optimization details that do not weaken the canonical contract.
- Numeric budgets, child limits, timeouts, history thresholds, and fairness tuning.
- Final worker sizing and AWS service topology.
- Full capability catalog ingestion, evaluation, promotion, and retirement behavior.

## Open architecture-changing questions

None for the current foundation documentation slice. Workflow-specific topology, verifier rubrics, and first production Workflow Type selection remain future bounded decisions.

