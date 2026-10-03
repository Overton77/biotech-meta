import "dotenv/config";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { Agent, JsonlLocalAgentStore } from "@cursor/sdk";

const MODEL_ID = process.env.CURSOR_ORG_RESEARCH_MODEL ?? process.env.CURSOR_MODEL ?? "gpt-5.4-mini";
const RUN_ID = `tooling-smoke-${new Date().toISOString().replace(/[:.]/g, "-")}`;
const RUN_DIR = path.resolve(".belllabs-runs", "tooling-smoke", RUN_ID);
const RESULT_PATH = path.join(RUN_DIR, "agent-smoke-report.json");

const apiKey = process.env.CURSOR_API_KEY;

if (!apiKey) {
  throw new Error("CURSOR_API_KEY is required.");
}

await mkdir(RUN_DIR, { recursive: true });

const prompt = `
You are running a tiny BellLabs Cursor SDK smoke test.

Goal:
Verify that this SDK agent can use its local file space and can access the installed web research skills/CLIs.

Strict limits:
- Do not browse the web.
- Do not perform broad research.
- Do not run long commands.
- Do not create or edit files outside this run directory: ${RUN_DIR}
- Finish in one response.

Tasks:
1. Read these local skill files:
   - skills/tavily-cli/SKILL.md
   - skills/firecrawl/SKILL.md
   - skills/agent-browser/SKILL.md
2. Run:
   - tvly --status
   - firecrawl --status
3. Write a JSON report to:
   ${RESULT_PATH}

The JSON report must have this shape:
{
  "ok": true,
  "model": "${MODEL_ID}",
  "checkedAt": "ISO timestamp",
  "skillFiles": [
    { "path": "skills/tavily-cli/SKILL.md", "read": true, "notes": "short" },
    { "path": "skills/firecrawl/SKILL.md", "read": true, "notes": "short" },
    { "path": "skills/agent-browser/SKILL.md", "read": true, "notes": "short" }
  ],
  "cliChecks": [
    { "command": "tvly --status", "exitCode": 0, "summary": "short" },
    { "command": "firecrawl --status", "exitCode": 0, "summary": "short" }
  ],
  "fileWrite": {
    "path": "${RESULT_PATH}",
    "success": true
  },
  "notes": ["short notes only"]
}

After writing the file, respond with only a short markdown summary and the report path.
`.trim();

await writeFile(path.join(RUN_DIR, "prompt.md"), prompt);

await using agent = await Agent.create({
  apiKey,
  name: "BellLabs tooling smoke test",
  model: { id: MODEL_ID },
  mode: "agent",
  local: {
    cwd: process.cwd(),
    settingSources: ["project", "user", "plugins"],
    store: new JsonlLocalAgentStore(path.join(RUN_DIR, "cursor-agent-store")),
  },
});

const run = await agent.send(prompt, {
  mode: "agent",
  onStep: ({ step }) => {
    console.log(`[${agent.agentId}] completed step ${step.type}`);
  },
});

console.log(`[${agent.agentId}] run=${run.id} request=${run.requestId ?? "unknown"}`);

const timeoutMs = Number(process.env.TOOLING_SMOKE_TIMEOUT_MS ?? 4 * 60 * 1000);
const timeout = new Promise<never>((_, reject) => {
  setTimeout(() => reject(new Error(`Smoke test timed out after ${timeoutMs}ms`)), timeoutMs);
});

try {
  const result = await Promise.race([run.wait(), timeout]);
  await writeFile(path.join(RUN_DIR, "assistant-result.md"), result.result ?? "");

  const report = await readFile(RESULT_PATH, "utf8");
  JSON.parse(report);

  console.log(`Smoke test status: ${result.status}`);
  console.log(`Report path: ${RESULT_PATH}`);
  console.log(result.result ?? "");
} catch (error) {
  if (run.supports("cancel")) {
    await run.cancel();
  }
  throw error;
}
