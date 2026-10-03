import "dotenv/config";
import { getResearchWorkflow } from "../research/workflows/registry.js";
import { runResearchWorkflow } from "../research/workflows/runner.js";

function parseOptionalNumber(value: string | undefined): number | undefined {
  if (value === undefined || value.trim() === "") return undefined;
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new Error(`Expected a number, received "${value}".`);
  }
  return parsed;
}

function parseNumber(value: string | undefined, fallback: number): number {
  return parseOptionalNumber(value) ?? fallback;
}

export async function runWorkflowFromCli(workflowSlug = process.argv[2] ?? process.env.RESEARCH_WORKFLOW) {
  if (!workflowSlug) {
    throw new Error("A workflow slug is required. Example: pnpm research:workflow supplement-organizations");
  }

  const dryRun = process.env.RESEARCH_DRY_RUN === "1" || process.env.RESEARCH_DRY_RUN === "true";
  const apiKey = process.env.CURSOR_API_KEY;
  if (!apiKey && !dryRun) {
    throw new Error("CURSOR_API_KEY is required unless RESEARCH_DRY_RUN=1.");
  }

  const workflow = getResearchWorkflow(workflowSlug);
  const result = await runResearchWorkflow(workflow, {
    workflowSlug,
    apiKey,
    modelId: process.env.RESEARCH_MODEL,
    runId: process.env.RESEARCH_RESUME_RUN_ID,
    dryRun,
    stageOffset: parseNumber(process.env.RESEARCH_STAGE_OFFSET, 0),
    stageLimit: parseOptionalNumber(process.env.RESEARCH_STAGE_LIMIT),
    shardOffset: parseNumber(process.env.RESEARCH_SHARD_OFFSET, 0),
    shardLimit: parseOptionalNumber(process.env.RESEARCH_SHARD_LIMIT),
    concurrency: parseOptionalNumber(process.env.RESEARCH_CONCURRENCY),
  });

  console.log(`Workflow ${workflow.slug} complete.`);
  console.log(`Run id: ${result.orchestratorRunId}`);
  console.log(`Artifacts: ${result.artifactPath}`);
}

await runWorkflowFromCli();
