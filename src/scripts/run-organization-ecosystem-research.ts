import "dotenv/config";
import { organizationEcosystemWorkflow } from "../research/workflows/configs/organization-ecosystem.js";
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

const dryRun = process.env.RESEARCH_DRY_RUN === "1" || process.env.RESEARCH_DRY_RUN === "true";
const apiKey = process.env.CURSOR_API_KEY;

if (!apiKey && !dryRun) {
  throw new Error("CURSOR_API_KEY is required unless RESEARCH_DRY_RUN=1.");
}

const result = await runResearchWorkflow(organizationEcosystemWorkflow, {
  workflowSlug: organizationEcosystemWorkflow.slug,
  apiKey,
  modelId: process.env.RESEARCH_MODEL,
  runId: process.env.RESEARCH_RESUME_RUN_ID,
  dryRun,
  stageOffset: parseNumber(process.env.RESEARCH_STAGE_OFFSET, 0),
  stageLimit: parseOptionalNumber(process.env.RESEARCH_STAGE_LIMIT),
  shardOffset: parseNumber(
    process.env.RESEARCH_SHARD_OFFSET ?? process.env.ORGANIZATION_RESEARCH_GROUP_OFFSET,
    0,
  ),
  shardLimit: parseOptionalNumber(process.env.RESEARCH_SHARD_LIMIT ?? process.env.ORGANIZATION_RESEARCH_GROUP_LIMIT),
  concurrency: parseOptionalNumber(process.env.RESEARCH_CONCURRENCY ?? process.env.ORGANIZATION_RESEARCH_CONCURRENCY),
});

console.log(`Organization ecosystem workflow complete.`);
console.log(`Run id: ${result.orchestratorRunId}`);
console.log(`Artifacts: ${result.artifactPath}`);
