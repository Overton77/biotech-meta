# Agent Tooling Skill Options

## OpenAI Agents SDK Documentation

OpenAI's official read-only developer-documentation MCP server is the primary live documentation source:

```powershell
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
```

Server URL: `https://developers.openai.com/mcp`

An existing `openai-agents-sdk` skill is available at:

```text
C:\Users\Pinda\Proyectos\Biotech\humanupgrade-research-ingestion\.agents\skills\openai-agents-sdk
```

It is an offline aid for agents, tools, structured output, streaming, handoffs, guardrails, sessions, and common patterns. Prefer the Docs MCP and official SDK docs for current details. See [OpenAI Agents SDK and Temporal Architecture Notes](openai-agents-sdk-and-temporal.md).

These skills were discovered with `npx skills find` while setting up the BellLabs TypeScript workspace.

## Tavily

- `tavily-ai/skills@tavily-search`
- `tavily-ai/skills@search`
- `tavily-ai/skills@tavily-research`
- `tavily-ai/skills@tavily-best-practices`
- `tavily-ai/skills@tavily-extract`
- `tavily-ai/skills@tavily-cli`

Recommended starting point:

```bash
npx skills add tavily-ai/skills@tavily-search -g -y
npx skills add tavily-ai/skills@tavily-research -g -y
npx skills add tavily-ai/skills@tavily-extract -g -y
```

## Firecrawl

- `firecrawl/cli@firecrawl`
- `firecrawl/cli@firecrawl-scrape`
- `firecrawl/cli@firecrawl-search`
- `firecrawl/cli@firecrawl-agent`
- `firecrawl/cli@firecrawl-crawl`
- `firecrawl/cli@firecrawl-map`

Recommended starting point:

```bash
npx skills add firecrawl/cli@firecrawl -g -y
npx skills add firecrawl/cli@firecrawl-search -g -y
npx skills add firecrawl/cli@firecrawl-scrape -g -y
npx skills add firecrawl/cli@firecrawl-crawl -g -y
```

## Browser / Vercel Agent Options

- `vercel/vercel-plugin@vercel-agent`
- `vercel/vercel-plugin@vercel-sandbox`
- `skills.volces.com@agent-browser-cli`
- `vercel-labs/vercel-plugin@vercel-agent`
- `pedronauck/skills@agent-browser`
- `vercel-labs/vercel-plugin@vercel-sandbox`

Recommended options to inspect first:

```bash
npx skills add vercel/vercel-plugin@vercel-agent -g -y
npx skills add vercel/vercel-plugin@vercel-sandbox -g -y
npx skills add pedronauck/skills@agent-browser -g -y
```

## Notes

Install only the skills that become part of a concrete workflow profile. BellLabs should keep a single tool profile registry so local schedules, Cursor SDK runs, and Cursor Cloud schedules stay aligned.

## Local Verification

The repo includes a local readiness check:

```bash
pnpm tools:web:check
```

This verifies:

- `firecrawl --help`
- `firecrawl --status`
- `tvly --help`
- `tvly --status`

Current local status: Firecrawl CLI and Tavily CLI are both installed and authenticated. Firecrawl reports `.firecrawl/` is ignored by `.gitignore`.
