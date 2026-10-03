# Cursor SDLC System

BellLabs should be built with a recursive Cursor-powered software development lifecycle. The application should not only use agents as a product feature. It should use agents to improve the codebase, documentation, test suites, development environment, workflows, and agent system itself.

## Goal

Create a dedicated Cursor SDLC system that can operate as a durable, observable, self-improving engineering layer for BellLabs.

It should:

- Run after each meaningful piece of work.
- Run on scheduled intervals.
- Inspect code, tests, docs, prompts, rules, skills, MCP servers, subagents, and environments.
- Propose and sometimes apply improvements.
- Maintain project conventions.
- Keep Cursor-specific assets current.
- Track engineering debt and opportunities.
- Launch long-running Cursor CLI or Cursor SDK jobs when appropriate.

## Cursor Technology Stack

BellLabs should use:

- Cursor IDE for interactive development.
- Cursor CLI for scriptable local or cloud agent tasks.
- Cursor SDK for programmatic agent orchestration from scripts, CI, dashboards, or backend services.
- Cursor Cloud Agents for long-running or parallel engineering work.
- Cursor rules for durable project guidance.
- Agent skills for repeatable specialized procedures.
- Subagent prompts for review, testing, debugging, documentation, architecture, research, and migration work.
- MCP servers for external systems and project-specific tools.

## SDLC Control Plane

The SDLC control plane should track engineering workflows the same way the product control plane tracks research workflows.

It should expose:

- Active and historical agent runs.
- Run purpose, model, prompt, branch, tool access, cost, and result.
- Changed files and generated artifacts.
- Test and lint results.
- Open blockers.
- Human approvals required.
- Scheduled maintenance jobs.
- Suggestions accepted, rejected, or deferred.

This can start as docs and scripts, then become a dashboard.

## Recursive Improvement Loop

After each piece of work:

1. Summarize the change.
2. Run focused tests or type checks.
3. Run code review agents on modified files.
4. Update docs if behavior changed.
5. Update evals if agent behavior changed.
6. Detect missing rules, skills, or commands.
7. Record follow-up suggestions.

On schedule:

1. Review dependencies and security posture.
2. Review stale docs and architecture drift.
3. Review failing or flaky tests.
4. Review agent traces and prompt performance.
5. Search for repeated manual work that should become scripts or skills.
6. Refresh external documentation indexes.
7. Re-run core eval suites.
8. Propose roadmap updates.

## Cursor Assets To Maintain

The SDLC system should manage:

- `AGENTS.md` files for repository and subdirectory guidance.
- `.cursor/rules/` files for persistent coding standards and domain rules.
- Agent skills for repeated workflows.
- Subagent prompt files for specialized work.
- `commands/` or equivalent scriptable procedures.
- `environments.json` or equivalent cloud/local environment definitions.
- MCP server configuration notes.
- Documentation indexes.
- Evaluation suites.
- Architecture decision records.

The system should avoid creating agent sprawl. Every durable agent asset should have an owner, purpose, trigger, and retirement condition.

## SDLC Agent Types

Recommended agents:

- Architect agent: reviews major design decisions and system boundaries.
- Code reviewer agent: reviews modified code for correctness, maintainability, and regressions.
- Test writer agent: creates focused tests for risky or user-facing changes.
- Debugger agent: investigates failures with logs and reproduction steps.
- Docs maintainer agent: updates architecture docs, guides, and API references.
- Cursor assets agent: updates rules, skills, commands, MCP notes, and agent prompts.
- Dependency agent: monitors package upgrades, vulnerabilities, and migration notes.
- Eval agent: maintains Graph RAG, workflow, ingestion, and safety evals.
- Research infrastructure agent: improves workflow primitives, observability, and sandbox execution.

## Documentation Access

Cursor SDLC agents should have current access to:

- Cursor docs.
- Cursor SDK docs.
- Cursor CLI docs.
- MCP documentation.
- Project architecture docs.
- Local code search and generated schema maps.
- Agent skill libraries.
- Prior agent transcripts and decision logs when relevant.

Agents should cite which documentation versions or sources influenced their changes.

## When Agents Can Act As The Developer

Some jobs can run autonomously. Others need explicit human approval.

Autonomous candidates:

- Documentation index updates.
- Non-invasive doc improvements.
- Eval case generation.
- Test generation on branches.
- Static analysis reports.
- Dependency research.
- Prompt performance reports.

Approval-required candidates:

- Production code changes.
- Schema migrations.
- Dependency upgrades.
- Security-sensitive configuration.
- Changes to medical safety guardrails.
- External API actions.
- Running expensive jobs.
- Publishing docs or user-facing content.

## Long-Running Cursor Jobs

The SDLC system should be able to launch long-running jobs such as:

- "Map all ingestion scripts and propose a unified ingestion workflow."
- "Generate tests for the Graph RAG evaluation harness."
- "Audit safety boundaries across product recommendation prompts."
- "Update all docs to reflect the new workflow architecture."
- "Create a branch that prototypes Temporal orchestration."
- "Run a best-of-N design comparison for the research workflow compiler."

These jobs should produce artifacts, not just chat responses.

## Integration With Product Workflows

The product and SDLC systems should share primitives:

- Workflow configuration.
- Agent profiles.
- Tool profiles.
- Human checkpoints.
- Artifact storage.
- Evals.
- Trace inspection.
- Scheduled runs.
- Intervention events.

The difference is domain. Product workflows investigate biotech and user health questions. SDLC workflows investigate and improve the software system.

## First Implementation Milestone

Start simple:

1. Create an SDLC docs folder.
2. Add project-level agent guidance.
3. Add a post-work checklist.
4. Add a scheduled maintenance prompt.
5. Add focused eval definitions.
6. Add scripts for common checks.
7. Add an agent run registry.
8. Build a lightweight dashboard once run data exists.

The recursive system should become more powerful only after it has basic observability and restraint.
