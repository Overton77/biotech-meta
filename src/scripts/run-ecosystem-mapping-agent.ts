import "dotenv/config";
import { Agent, CursorAgentError } from "@cursor/sdk";
import { connectMongo, disconnectMongo } from "../db/mongoose.js";
import { ResearchRun } from "../models/index.js";

const apiKey = process.env.CURSOR_API_KEY;

if (!apiKey) {
  throw new Error("CURSOR_API_KEY is required to launch Cursor SDK agents.");
}

const prompt = `
You are running the first BellLabs ecosystem mapping cycle.

Read docs/BellLabs/ecosystem-mapping-cycle.md and produce a concise first-pass mapping plan:
1. The top 12-20 biotech/longevity ecosystem divisions to scout first.
2. The top corporate entity discovery strategy for each division.
3. Recommended source surfaces: Firecrawl, Tavily/search, browser, PubMed, ClinicalTrials.gov, YouTube, regulatory, investor/conference sources.
4. A proposed top-250 entity backlog artifact schema.
5. Any schema pressure expected for biotech-kg.

Do not modify files. Return markdown with sections and concrete next actions.
`.trim();

await connectMongo();

const runRecord = await ResearchRun.create({
  name: "First BellLabs ecosystem mapping SDK run",
  mode: "ecosystem_mapping",
  status: "running",
  goal: "Create the first execution plan for broad biotech ecosystem mapping.",
  prompt,
  agentRuntime: "local",
  model: process.env.CURSOR_MODEL ?? "auto",
  toolProfile: ["cursor-sdk", "local-repo"],
  startedAt: new Date(),
});

try {
  const result = await Agent.prompt(prompt, {
    apiKey,
    model: { id: process.env.CURSOR_MODEL ?? "auto" },
    local: { cwd: process.cwd() },
  });

  await ResearchRun.updateOne(
    { _id: runRecord._id },
    {
      $set: {
        status: result.status === "finished" ? "completed" : "failed",
        completedAt: new Date(),
        resultSummary: String(result.result ?? ""),
        metadata: { cursorResult: result },
      },
    },
  );

  console.log(result.result);
} catch (error) {
  const message =
    error instanceof CursorAgentError
      ? `Cursor agent startup failed: ${error.message}; retryable=${error.isRetryable}`
      : error instanceof Error
        ? error.message
        : String(error);

  await ResearchRun.updateOne(
    { _id: runRecord._id },
    {
      $set: {
        status: "failed",
        completedAt: new Date(),
        error: message,
      },
    },
  );

  throw error;
} finally {
  await disconnectMongo();
}
