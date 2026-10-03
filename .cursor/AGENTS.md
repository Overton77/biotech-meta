# biotech-meta Agent

**Role:** Idea Factory · Presentation Factory · Meta-Orchestrator for the Biotech Suite  
**Scope:** System maps, visualizations, diagrams, demos, cross-repo documentation, specification management, and agentic tooling reference.

---

## Biotech Suite — 8 Repos

| #   | Repo                         | Path                                                          | Purpose                                                                                                                           |
| --- | ---------------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `biotech-meta`               | `C:\Users\Pinda\Proyectos\Biotech\biotech-meta`               | **This repo.** Specs, docs, diagrams, system maps, demos                                                                          |
| 2   | `biotech-kg`                 | `C:\Users\Pinda\Proyectos\Biotech\biotech-kg`                 | Knowledge Graph — biotech entities (people, organizations products compounds ... ) biological entities, ontologies, relationships |
| 3   | `biotech-research-ingestion` | `C:\Users\Pinda\Proyectos\Biotech\biotech-research-ingestion` | Research data ingestion pipelines (papers, datasets, sources)                                                                     |
| 4   | `biotech-research-web`       | `C:\Users\Pinda\Proyectos\Biotech\biotech-research-web`       | Research exploration frontend                                                                                                     |
| 5   | `biotech-user-api`           | `C:\Users\Pinda\Proyectos\Biotech\biotech-user-api`           | User-facing backend API                                                                                                           |
| 6   | `biotech-user-web`           | `C:\Users\Pinda\Proyectos\Biotech\biotech-user-web`           | User-facing frontend application                                                                                                  |
| 7   | `biotech-mcp`                | `C:\Users\Pinda\Proyectos\Biotech\biotech-mcp`                | MCP servers and tool definitions for the suite                                                                                    |
| 8   | `biotech-infra`              | `C:\Users\Pinda\Proyectos\Biotech\biotech-infra`              | Infrastructure as code (cloud, containers, CI/CD)                                                                                 |

**Build order:** `biotech-infra` → `biotech-kg` → `biotech-research-ingestion` → `biotech-mcp` → `biotech-user-api` → `biotech-research-web` → `biotech-user-web` → `biotech-meta` (iterate)

---

## Specification-Driven Development

Specifications are the source of truth. Code follows specs — not the other way around.

- All features begin as a spec in `biotech-meta/specs/`
- Specs are written in Markdown and version-controlled
- Each repo has a `SPEC.md` or `specs/` directory that references the canonical spec
- Agent changes must not contradict the active specification without explicit human approval
- Spec format: `[status: draft|active|deprecated]` frontmatter

---

## Agentic Engineering Toolkit

Reference for all agentic mechanisms available in Cursor. Each layer has a distinct role.

---

### 1. AGENTS.md — Agent Instructions (this file)

**What:** Plain Markdown file read by the agent at session start. The simplest way to set persistent instructions.  
**Location:** `AGENTS.md` in project root **or** `.cursor/Agents.md` (subdirectory scope)  
**Scope:** Applies to the project/directory it lives in. Supports nesting — global → repo → subdirectory.  
**When to use:** Project context, architecture decisions, build commands, style rules, security constraints.  
**vs Rules:** No YAML frontmatter, no glob scoping. Pure Markdown. Simpler but less granular than `.cursor/rules/`.

```markdown
# AGENTS.md minimal example

## Build

- `npm run build` — production build

## Style

- TypeScript only, strict mode
```

> Source: [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules)

---

### 2. Rules — `.cursor/rules/*.mdc`

**What:** Structured rule files with YAML frontmatter. Four types:

| Type              | When applied                                 | Config                          |
| ----------------- | -------------------------------------------- | ------------------------------- |
| **Always**        | Every context, every request                 | `alwaysApply: true`             |
| **Auto-Attached** | When matched files are in context            | `globs: ["src/**/*.ts"]`        |
| **Agent-Decided** | Agent reads description, decides if relevant | `description: "..."` (no globs) |
| **Manual**        | Only when explicitly called via `@ruleName`  | No auto-trigger                 |

**Location:** `.cursor/rules/` (project) · Cursor Settings → Rules (user-global) · Dashboard (team)  
**Format:** `.mdc` files. Can reference other files with `@filename`.

```yaml
---
description: API route conventions for biotech-user-api
globs: ["src/routes/**/*.ts"]
alwaysApply: false
---
- Use Zod for request validation
- Return consistent { data, error } envelope
```

> Source: [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules)

---

### 3. MCP Servers — Model Context Protocol

**What:** External servers that give the agent access to tools, resources, and prompts beyond the IDE.  
**Protocol:** JSON-RPC 2.0 over stdio or HTTP/SSE. Standardized by Anthropic, supported natively in Cursor.  
**Config:** `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (project)  
**Repo:** `biotech-mcp` contains all custom MCP servers for this suite.

```json
{
  "mcpServers": {
    "biotech-kg": {
      "command": "node",
      "args": ["../biotech-mcp/servers/kg-server.js"]
    }
  }
}
```

**Capabilities MCP exposes:**

- `tools` — callable functions (search KG, query DB, run pipeline)
- `resources` — readable data (files, API responses)
- `prompts` — reusable prompt templates

**Note:** Prefer wrapping MCP calls in a **Skill** for token-efficient reuse.

---

### 4. Skills — `SKILL.md` ⭐ PREFERRED

**What:** Portable, version-controlled packages of domain-specific knowledge and workflows. Token-efficient: agent reads the skill only when relevant.  
**Location:** `.cursor/skills/<skill-name>/SKILL.md` (project) · `~/.agents/skills/<skill-name>/SKILL.md` (user-global)  
**Format:** Markdown file with YAML frontmatter (`name`, `description`)  
**Discovery:** Agent auto-discovers skills and applies them when context is relevant. Also invokable via `/skill-name` slash command.

```yaml
---
name: ingest-paper
description: Ingest a research paper into biotech-research-ingestion pipeline
---
# Ingest Paper Skill
1. Validate PDF/DOI input
2. Run `python ingest.py --source <input>`
3. Verify record appears in KG
```

**Skills vs Rules:**

|            | Skills                                               | Rules                                      |
| ---------- | ---------------------------------------------------- | ------------------------------------------ |
| Best for   | Procedural "how-to" workflows                        | Declarative style/architecture constraints |
| Token cost | Low (loaded only when relevant)                      | Higher (always-on types always loaded)     |
| Format     | `SKILL.md` with frontmatter                          | `.mdc` with frontmatter                    |
| Invocation | Auto-discovered + `/skill-name`                      | Auto/manual per type                       |
| Portable   | Yes — works across any Agent Skills-compatible agent | Cursor-specific                            |

**Migrate old rules/commands:** Run `/migrate-to-skills` (built-in Cursor 2.4 skill).

> Source: [cursor.com/docs/context/skills](https://cursor.com/docs/context/skills)

---

### 5. Subagents — `.cursor/agents/*.md`

**What:** Independent agents specialized for discrete subtasks. Run in their own context window, in parallel, and return results to the parent agent.  
**Location:** `.cursor/agents/` (project) · `~/.cursor/agents/` (user-global)  
**Format:** Markdown file with YAML frontmatter (`name`, `description`) + prompt body.

```yaml
---
name: kg-explorer
description: Explores the biotech knowledge graph for entities and relationships
---
You are a KG specialist. Use available MCP tools to query Neo4j.
Return structured JSON summaries. Never modify data.
```

**Built-in subagents (auto-used, not manually invokable):**

- `explore` — codebase research (faster/cheaper model)
- `bash` — terminal command execution
- `browser` — web browsing and scraping

**Custom subagents enable:**

- Parallel workstreams (e.g., 8 agents analyzing 8 repos simultaneously)
- Context isolation — heavy token work stays out of main thread
- Model flexibility — assign cheaper models to lighter tasks
- Specialized expertise per domain

**When to use subagents vs skills:**

| Use subagents when...                   | Use skills when...                  |
| --------------------------------------- | ----------------------------------- |
| Long research needing context isolation | Single-shot, quick repeatable task  |
| Multiple parallel workstreams           | No separate context window needed   |
| Multi-step specialized expertise        | Simple workflow (format, changelog) |
| Independent verification of work        | Task completes in one round-trip    |

> Source: [cursor.com/docs/context/subagents](https://cursor.com/docs/context/subagents)

---

### 6. Commands — `.cursor/commands/*.md`

**What:** Reusable workflows triggered via `/command-name` in the chat input.  
**Location:** `.cursor/commands/` (project) · `~/.cursor/commands/` (user-global) · Dashboard (team)  
**Status:** Beta — syntax may evolve. Consider migrating to Skills (more portable).  
**Format:** Plain Markdown file. Filename becomes the command name.

```markdown
# /spec-review

Review the current specification against the codebase.

1. Read `biotech-meta/specs/` for active specs
2. Check each repo's implementation against spec
3. Report gaps as a checklist
```

**Slash commands can orchestrate subagents:**  
`/analyze-pipeline` → spawns parallel subagents for ingestion, KG, and API validation.

> Source: [cursor.com/docs/context/commands](https://cursor.com/docs/context/commands)

---

### 7. Cursor Cloud Agent API

**What:** Programmatic REST API for launching agents against a GitHub repository. Enables fully automated, headless agentic workflows.  
**Base URL:** `https://api.cursor.com`  
**Auth:** API key as HTTP basic auth username

**Launch an agent (POST `/v0/agents`):**

```json
{
  "prompt": { "text": "Update biotech-user-api to match the latest spec" },
  "source": {
    "repository": "https://github.com/org/biotech-user-api",
    "ref": "main"
  },
  "target": {
    "autoCreatePr": true,
    "branchName": "agent/spec-sync"
  }
}
```

**Key parameters:** `model`, `source.repository`, `source.ref`, `source.prUrl`, `target.autoCreatePr`, `target.branchName`

> Source: [cursor.com/docs/cloud-agent/api/endpoints](https://cursor.com/docs/cloud-agent/api/endpoints)

---

### 8. GitHub Automations

**What:** Trigger Cursor agents directly from GitHub events (PRs, issues, comments).  
**Mechanism:** Install the **Cursor GitHub App** on your repositories. Mention `@cursor` in a PR or issue to trigger an agent.  
**Use cases:**

- Auto-fix failing CI on PR
- Implement issue descriptions as code changes
- Spec compliance review on every PR
- Auto-generate changelogs

**Integration with Cloud API:** GitHub webhooks → Cloud Agent API → auto-create PR.

---

### 9. Plugins (Super Skills)

**What:** Extended skills that bundle multiple MCP servers, subagents, commands, and rules into a single installable package. A plugin is a self-contained capability module.  
**Status:** Emerging pattern — not yet a formal Cursor primitive. Implemented as a structured directory:

```
.cursor/plugins/<plugin-name>/
  PLUGIN.md        # entry point, manifest
  SKILL.md         # main skill
  agents/          # subagents used by this plugin
  commands/        # commands exposed by this plugin
  rules/           # rules loaded by this plugin
  mcp/             # MCP server config
```

**Examples for biotech suite:**

- `kg-explorer-plugin` — full KG traversal + visualization
- `paper-ingestion-plugin` — end-to-end paper → KG pipeline
- `spec-enforcer-plugin` — spec compliance across all 8 repos

---

## Meta Agent Directives

As the `biotech-meta` agent, I:

1. **Maintain specifications** in `specs/` as the authoritative source of truth
2. **Generate system maps** showing data flow across all 8 repos
3. **Produce diagrams** (Mermaid, draw.io) for architecture, data flow, and entity relationships
4. **Create demos** and proof-of-concept notebooks in `demos/`
5. **Track cross-repo dependencies** and integration contracts
6. **Manage the agentic tooling** — skills, subagents, and commands that work across the suite
7. **Serve as the idea factory** — prototype new features here before distributing to target repos
8. **Never modify other repos directly** — produce specifications and migration instructions instead

---

## Quick Reference — Where Does It Go?

| Artifact           | Location                           | Purpose                          |
| ------------------ | ---------------------------------- | -------------------------------- |
| Agent instructions | `AGENTS.md` or `.cursor/Agents.md` | Persistent context for this repo |
| Scoped rules       | `.cursor/rules/*.mdc`              | Style, architecture, glob-scoped |
| Skills             | `.cursor/skills/<name>/SKILL.md`   | Reusable domain workflows        |
| Subagents          | `.cursor/agents/<name>.md`         | Parallel / isolated task workers |
| Commands           | `.cursor/commands/<name>.md`       | Slash-command workflows          |
| MCP config         | `.cursor/mcp.json`                 | Tool server connections          |
| Specs              | `specs/<domain>.md`                | Source of truth for features     |
| Diagrams           | `diagrams/`                        | System maps, architecture        |
| Demos              | `demos/`                           | Prototypes, notebooks            |

---

_Sources: [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules) · [cursor.com/docs/context/skills](https://cursor.com/docs/context/skills) · [cursor.com/docs/context/subagents](https://cursor.com/docs/context/subagents) · [cursor.com/docs/context/commands](https://cursor.com/docs/context/commands) · [cursor.com/docs/cloud-agent/api/endpoints](https://cursor.com/docs/cloud-agent/api/endpoints) · [cursor.com/changelog/2-4](https://cursor.com/changelog/2-4)_
