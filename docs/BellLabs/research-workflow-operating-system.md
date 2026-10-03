# Research Workflow Operating System

BellLabs needs a research workflow operating system: a way to design, run, observe, pause, resume, evaluate, and ingest agentic research missions. Users should be able to deploy computation and intelligence toward their health questions, starting from a deep biotech knowledge graph instead of a blank chat window.

## Architecture Recommendation

Use Temporal as the durable control plane and the OpenAI Agents SDK for Python as the primary agent harness inside workers.

Recommended split:

- Temporal: workflow durability, retries, timers, pause/resume, cancellation, human checkpoints, event history, long-running execution, and operational visibility.
- OpenAI Agents SDK: agent cognition, tool use, guardrails, sessions, streaming, handoffs, agents-as-tools, sandbox agents, and model interaction.
- Neo4j: shared biotech knowledge graph, graph retrieval, entity context, provenance, and relationships.
- Supabase PostgreSQL: Agents SDK sessions and relational control-plane records.
- PostgreSQL/JSONB or MongoDB with async PyMongo and Beanie: still-open choice for flexible missions, stages, artifacts, research records, and intermediate outputs.
- S3 or equivalent object storage: documents, reports, transcripts, screenshots, exported bundles, and large artifacts.
- Redis or managed queues: low-latency event streams, live notifications, locks, and ephemeral coordination.
- LangSmith, OpenTelemetry, and custom eval stores: traces, metrics, prompt/version tracking, and evaluation runs.
- OpenAI's native Responses model path by default; LiteLLM only when a workflow intentionally uses non-OpenAI models.

Temporal should own time, reliability, and lifecycle. The OpenAI Agents SDK should own the agent loop and reasoning patterns. BellLabs application code must own the domain model and the still-open scheduling algorithm for dependency-aware and cyclic stages.

See [OpenAI Agents SDK and Temporal Architecture Notes](openai-agents-sdk-and-temporal.md) for the accepted boundary, documentation setup, SDK capability notes, and remaining design decisions.

## Workflow Primitive Model

Every research workflow should compile from configuration into an execution plan.

Core primitives:

- Goal: the top-level question, decision, or investigation target.
- Context packet: user context, KG seeds, prior notes, constraints, safety boundaries, and allowed data.
- Stage: a unit of work with inputs, outputs, tools, models, prompts, policies, and completion criteria.
- Agent: a configured actor inside a stage.
- Subagent: a delegated actor with narrower instructions.
- Tool profile: MCP servers, APIs, browser control, filesystem access, KG queries, vector stores, and sandbox capabilities.
- Skill profile: domain or execution skills available to an agent.
- Source policy: allowed sources, preferred sources, disallowed sources, source procurement strategy, and citation requirements.
- Guardrail policy: medical boundary rules, claim requirements, evidence labeling, privacy restrictions, and unsafe-output checks.
- Checkpoint: a human or agent approval gate.
- Artifact: any durable output, including notes, extracted entities, evidence bundles, datasets, reports, code, charts, or ingestion candidates.
- Evaluation: tests that score quality, coverage, safety, retrieval, citation fidelity, or usefulness.

## How Research Should Start

Research should usually start with a KG preflight, then adaptively discover sources.

The KG preflight should:

- Resolve entities mentioned in the user goal.
- Identify nearby products, companies, biomarkers, mechanisms, studies, claims, protocols, adverse effects, and documents.
- Pull prior BellLabs research runs and evidence bundles.
- Detect gaps in graph coverage.
- Create an initial research map and source procurement plan.

The system should not require all sources to be procured before research begins. Biology is too open-ended for that. Instead:

1. Start with KG seeds and known trusted source classes.
2. Ask the workflow planner to produce an initial source plan.
3. Let stages discover sources when the goal or intermediate findings demand it.
4. Require source registration before sources can influence final conclusions.
5. Feed newly discovered entities and claims into ingestion candidates.

This gives the workflow grounding without making it rigid.

## Workflow Modes

### 1. Stage DAG Mode

Stages form a directed acyclic graph. A stage runs after dependencies complete and receives selected outputs from upstream stages.

Best for:

- Structured reports.
- Product comparisons.
- Evidence reviews.
- Lab test landscape mapping.
- Ingestion pipelines.

Example:

1. KG preflight.
2. Source procurement.
3. Evidence extraction.
4. Safety review.
5. Product comparison.
6. Final report and decision bundle.

### 2. Iterative Stage Mode

Each stage can cycle until a goal is met, a confidence threshold is reached, a budget is consumed, or max cycles are reached. Downstream stages can receive the latest cycle output or an aggregate.

Best for:

- Sparse evidence domains.
- Long-tail testimonial discovery.
- Hypothesis refinement.
- Expert or community source mining.

### 3. Ralph Loop

A goal-based research loop evolves across sessions. Each session receives the goal, prior distilled outputs, unresolved questions, and a fresh context window. The loop continues until budget, confidence, time, or user approval criteria are met.

Best for:

- Large exploratory campaigns.
- New domain mapping.
- Ongoing surveillance.
- "Keep digging until this becomes legible" investigations.

### 4. Debate And Adjudication Mode

Multiple agents argue different positions, then an adjudicator identifies consensus, disagreement, missing evidence, and decision implications.

Best for:

- Controversial interventions.
- Conflicting supplement or treatment claims.
- Vendor-vs-literature comparisons.
- Risk-benefit analysis.

### 5. Red Team Safety Mode

A primary researcher proposes a conclusion or protocol candidate. A safety agent searches for harms, contraindications, interactions, regulatory warnings, and overclaiming.

Best for:

- Protocol activation.
- Treatment exploration.
- Lab result interpretation.
- Purchase decisions with health risk.

### 6. Evidence Triangulation Mode

Separate agents investigate independent source classes: clinical literature, regulatory documents, patents, vendor claims, practitioner protocols, testimonials, and KG history. A synthesis stage reconciles them.

Best for:

- High-stakes product decisions.
- New mechanism exploration.
- Competitive landscape analysis.
- Claims where marketing and evidence may diverge.

### 7. Monitoring And Surveillance Mode

A workflow runs on a schedule or event trigger and watches for new documents, studies, regulatory updates, product changes, safety signals, price changes, or user-relevant content.

Best for:

- Tracking a lab testing company.
- Following a treatment class.
- Monitoring a product in the user's protocol.
- Watching for newly published studies.

### 8. Protocol Sprint Mode

The workflow is organized like a software sprint but aimed at a biomarker, metric, subjective outcome, or adherence goal.

Best for:

- Personal biohacking experiments.
- Wearable integration projects.
- Lifestyle or supplement trials.
- Biomarker-improvement cycles.

### 9. Replication And Fork Mode

The workflow starts from an existing public protocol, guide, practitioner stack, or user-shared template and adapts it to a new user's constraints.

Best for:

- Bryan Johnson-style protocol exploration.
- Community protocol sharing.
- Product guide forks.
- Personalization workflows.

### 10. Corpus Build Mode

The goal is not a report but a high-quality corpus: documents, chunks, claims, entities, relationships, and eval cases.

Best for:

- Expanding graph coverage.
- Preparing fine-tuning or retrieval datasets.
- Building test suites for Graph RAG.

## Human In The Loop

Checkpoints should be configurable, but BellLabs should ship strong defaults.

Recommended checkpoint locations:

- Before using sensitive personal health data in a workflow.
- Before starting expensive or long-running workflows.
- Before browsing or interacting with authenticated external accounts.
- Before adding a product to cart.
- Before purchase facilitation.
- Before protocol activation.
- Before high-risk health interpretation is presented as actionable.
- Before writing to the durable personal graph.
- Before publishing a community guide or protocol.
- Before ingestion changes that merge or replace important graph entities.

Checkpoints should support approve, reject, edit instructions, add context, change budget, change model, change sources, pause, resume, fork, or stop.

## Intervening Into Running Processes

Temporal makes intervention tractable through signals, queries, updates, cancellation, and workflow state. BellLabs should expose these as product actions.

Possible interventions:

- Inject a user message into a running stage.
- Add a new source or uploaded file.
- Change the goal or priority.
- Request a safety review.
- Pause before the next tool call.
- Cancel a subagent.
- Fork the workflow from the current state.
- Add a checkpoint before proceeding.
- Change budget or maximum cycles.

For model context, intervention should not mutate an already-sent model context window. Instead, the system should append a durable event to the workflow log. The next agent turn or next stage receives a compiled context packet that includes the intervention, relevant prior messages, current state, and instructions for how to treat the update.

## Supplying Tools And Skills Mid-Session

Tool and skill changes should be treated as workflow events, not invisible runtime magic.

Rules:

- A running model call cannot gain tools mid-call.
- A running agent loop can receive a new tool profile before the next turn.
- A stage can be paused and resumed with a modified tool profile.
- A workflow can fork if the new tool set changes the validity of earlier outputs.
- Tool changes should be recorded for reproducibility and evaluation.

## Cross-Stage And Inter-Agent Communication

Agents should communicate through durable events, not ad hoc hidden messages.

Recommended model:

- Each stage publishes typed events: finding, claim, source, risk, question, blocker, artifact, request, opportunity.
- A coordinator watches events and routes relevant ones to stages or agents.
- Cross-stage messages include identifiers, sender, recipient, urgency, evidence links, and requested action.
- Receiving agents decide whether and how to incorporate the event at their next turn.
- Human-visible timelines show important cross-stage messages.

This supports the "cross-stage agent" idea: an agent that looks across running stages and notices when one stage's output can improve another.

## Sandbox Environments

Research workflows need sandboxed execution environments with explicit capability profiles.

Capabilities may include:

- Read-only filesystem.
- Writable artifact directory.
- Terminal execution.
- Browser control.
- Web search.
- MCP servers.
- KG access.
- Vector store access.
- Subagent invocation.
- Package installation.
- External API calls.

Each capability should be logged. Sensitive workflows should default to least privilege.

## Workflow Composition

Workflows should be composable. A research workflow can contain ingestion workflows. An ingestion workflow can trigger evaluation workflows. A protocol sprint can call a product comparison workflow. A monitoring workflow can trigger a user checkpoint when new evidence affects an active protocol.

The long-term goal is a workflow compiler:

1. User or agent defines intent.
2. Planner selects mode, stages, tools, models, budgets, checkpoints, and evals.
3. Compiler turns configuration into Temporal workflows and agent runtime configs.
4. Control plane runs, observes, and records execution.
5. Outputs become artifacts, graph updates, user decisions, eval cases, or future workflow seeds.
