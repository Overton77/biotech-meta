import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { Agent, Cursor, CursorAgentError, JsonlLocalAgentStore } from "@cursor/sdk";
import { connectMongo, disconnectMongo } from "../../db/mongoose.js";
import { ResearchRun } from "../../models/index.js";
import { cursorStoreDir, shardDir, stageDir, timestampRunId, workflowRunDir } from "./artifacts.js";
import {
  dedupeReportSchema,
  groupOutputSchema,
  type GroupOutput,
  type KnownOrganization,
} from "./schemas.js";
import {
  ingestGroupOutput,
  knownOrganizationsFromOutputs,
  loadKnownOrganizations,
  mergeKnownOrganizations,
} from "./persistence.js";
import type {
  ResearchPromptContext,
  ResearchShardConfig,
  ResearchStageConfig,
  ResearchWorkflowConfig,
  RunWorkflowOptions,
  SynthesisResult,
} from "./types.js";

type AgentHandle = Awaited<ReturnType<typeof Agent.create>>;

type ScoutRunResult = {
  output: GroupOutput;
  researchRunId: string;
};

function selectedItems<T>(items: T[], offset: number, limit?: number): T[] {
  const start = Math.max(0, offset);
  const count = limit === undefined ? items.length : Math.max(0, limit);
  return items.slice(start, start + count);
}

function errorMessage(error: unknown): string {
  if (error instanceof CursorAgentError) {
    return `Cursor agent failed: ${error.message}; retryable=${error.isRetryable}; requestId=${
      error.requestId ?? "unknown"
    }`;
  }

  return error instanceof Error ? error.message : String(error);
}

function defaultRepairPrompt(context: ResearchPromptContext & { previousOutput: string }): string {
  return `
Your previous response did not satisfy the required machine-readable output contract.

You must now continue immediately and call the write_group_output custom tool with the final JSON object for:
${context.resultPath}

Do not ask for confirmation. Do not return a plan. Do not use shell commands to write JSON.

Use the same mission and divisions:
- groupSlug: ${context.shard.slug}
- groupTitle: ${context.shard.title}
${context.shard.divisionSlugs.map((slug) => `- ${slug}`).join("\n")}

If you already gathered source-backed candidates, convert them into the required JSON shape. If coverage is incomplete, return the best source-backed candidates available and list missing areas in missingOrUncertainAreas.

Previous output:
${context.previousOutput}

After writing the file, respond with only a short summary and the JSON file path.
`.trim();
}

async function resolveModelId(
  apiKey: string | undefined,
  workflow: ResearchWorkflowConfig,
  explicitModelId?: string,
): Promise<string> {
  const configuredModel =
    explicitModelId ??
    workflow.modelEnv.map((envName) => process.env[envName]).find((value): value is string => Boolean(value)) ??
    workflow.defaultModel;

  if (!apiKey) return configuredModel;

  try {
    const models = await Cursor.models.list({ apiKey });
    const exact = models.find((model) => model.id === configuredModel);
    if (exact) return exact.id;

    const mini = models.find((model) => /gpt.*5\.4.*mini/i.test(model.id));
    if (mini) return mini.id;

    const fallback = models.find((model) => model.id === "auto");
    return fallback?.id ?? configuredModel;
  } catch {
    return configuredModel;
  }
}

async function sendAndWait(agent: AgentHandle, prompt: string, timeoutMs: number) {
  const run = await agent.send(prompt, {
    mode: "agent",
    onStep: ({ step }) => {
      console.log(`[${agent.agentId}] completed step ${step.type}`);
    },
  });

  console.log(`[${agent.agentId}] run=${run.id} request=${run.requestId ?? "unknown"}`);
  const timeout = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error(`Agent run timed out after ${timeoutMs}ms`)), timeoutMs);
  });

  try {
    const result = await Promise.race([run.wait(), timeout]);
    return { run, result };
  } catch (error) {
    if (run.supports("cancel")) {
      await run.cancel();
    }
    throw error;
  }
}

async function buildKnownOrganizations(
  stage: ResearchStageConfig,
  previousOutputs: GroupOutput[],
): Promise<KnownOrganization[]> {
  const outputKnown = knownOrganizationsFromOutputs(previousOutputs);
  if (stage.kind !== "scout" || !stage.injectKnownOrganizations) {
    return outputKnown;
  }

  const divisionSlugs = [...new Set(stage.shards.flatMap((shard) => shard.divisionSlugs))];
  const mongoKnown = await loadKnownOrganizations(divisionSlugs);
  return mergeKnownOrganizations(mongoKnown, outputKnown);
}

async function writeDryRunPrompt(
  workflow: ResearchWorkflowConfig,
  runId: string,
  stage: ResearchStageConfig,
  shard: ResearchShardConfig,
  prompt: string,
) {
  const dir = shardDir(workflow.artifactRoot, runId, stage.slug, shard.slug);
  await mkdir(dir, { recursive: true });
  await writeFile(path.join(dir, "prompt.md"), prompt);
}

async function runScoutShard(args: {
  workflow: ResearchWorkflowConfig;
  stage: Extract<ResearchStageConfig, { kind: "scout" }>;
  shard: ResearchShardConfig;
  apiKey: string;
  modelId: string;
  orchestratorRunId: string;
  previousOutputs: GroupOutput[];
  knownOrganizations: KnownOrganization[];
}): Promise<ScoutRunResult> {
  const { workflow, stage, shard, apiKey, modelId, orchestratorRunId, previousOutputs, knownOrganizations } = args;
  const dir = shardDir(workflow.artifactRoot, orchestratorRunId, stage.slug, shard.slug);
  await mkdir(dir, { recursive: true });

  const resultPath = path.join(dir, "result.json");
  const promptContext: ResearchPromptContext = {
    workflow,
    stage,
    shard,
    resultPath,
    knownOrganizations,
    previousOutputs,
  };
  const prompt = stage.promptBuilder(promptContext);
  await writeFile(path.join(dir, "prompt.md"), prompt);
  await writeFile(path.join(dir, "known-organizations.json"), `${JSON.stringify(knownOrganizations, null, 2)}\n`);

  const runRecord = await ResearchRun.create({
    name: `${workflow.name}: ${stage.title}: ${shard.title}`,
    mode: stage.mode ?? "division_scout",
    status: "running",
    goal: shard.mission,
    prompt,
    agentRuntime: workflow.runtime.kind,
    model: modelId,
    toolProfile: workflow.tools,
    skillProfile: workflow.skills,
    divisionSlugs: shard.divisionSlugs,
    startedAt: new Date(),
    budget: {
      maxMinutes: Math.ceil(workflow.limits.scoutTimeoutMs / 60000),
    },
    metadata: {
      workflowSlug: workflow.slug,
      stageSlug: stage.slug,
      shardSlug: shard.slug,
      orchestratorRunId,
      categoryTags: shard.categoryTags ?? [],
    },
  });

  try {
    await using agent = await Agent.create({
      apiKey,
      name: `BellLabs ${workflow.slug}: ${shard.title}`,
      model: { id: modelId },
      mode: "agent",
      local: {
        cwd: workflow.runtime.cwd ?? process.cwd(),
        settingSources: workflow.runtime.settingSources,
        store: new JsonlLocalAgentStore(cursorStoreDir(workflow.artifactRoot, orchestratorRunId, stage.slug, shard.slug)),
        customTools: {
          write_group_output: {
            description:
              "Submit the final BellLabs organization scout JSON. This validates the payload and writes it to result.json without using shell commands.",
            inputSchema: {
              type: "object",
              properties: {
                groupSlug: { type: "string" },
                groupTitle: { type: "string" },
                researchSummary: { type: "string" },
                coverageNotes: { type: "array" },
                missingOrUncertainAreas: { type: "array" },
                candidateOrganizations: { type: "array" },
                sourceRecords: { type: "array" },
                schemaPressureNotes: { type: "array" },
              },
              required: ["groupSlug", "groupTitle", "researchSummary", "candidateOrganizations"],
            },
            async execute(args: unknown) {
              const parsed = stage.outputSchema.parse(args);
              await mkdir(dir, { recursive: true });
              await writeFile(resultPath, `${JSON.stringify(parsed, null, 2)}\n`);
              return {
                content: [
                  {
                    type: "text",
                    text: `Wrote ${parsed.candidateOrganizations.length} organization candidates to ${resultPath}`,
                  },
                ],
                structuredContent: {
                  ok: true,
                  path: resultPath,
                  candidateCount: parsed.candidateOrganizations.length,
                },
              };
            },
          },
        },
      },
      agents: {
        "source-scout": {
          description: "Finds source-backed organization candidates using Tavily, Firecrawl, and browser skills.",
          prompt:
            "Find source-backed organization candidates. Use the local Tavily, Firecrawl, and agent-browser skills when helpful. Return concise notes with URLs. Inherit the parent model.",
          model: "inherit",
        },
        "dedupe-reviewer": {
          description: "Reviews organization candidates for aliases, duplicates, and weakly sourced entries.",
          prompt: "Review candidates for duplicates, aliases, weak sourcing, and category fit. Inherit the parent model.",
          model: "inherit",
        },
      },
    });

    let { run, result } = await sendAndWait(agent, prompt, workflow.limits.scoutTimeoutMs);
    let rawResult = result.result ?? "";
    await writeFile(path.join(dir, "assistant-result.md"), rawResult);

    let parsed: GroupOutput;
    let repaired = false;

    try {
      parsed = stage.outputSchema.parse(JSON.parse(await readFile(resultPath, "utf8")));
    } catch (parseError) {
      const repairPrompt = (stage.repairPromptBuilder ?? defaultRepairPrompt)({
        ...promptContext,
        previousOutput: rawResult,
      });
      await writeFile(path.join(dir, "repair-prompt.md"), repairPrompt);
      await writeFile(
        path.join(dir, "parse-error.txt"),
        parseError instanceof Error ? parseError.stack ?? parseError.message : String(parseError),
      );

      const repairedRun = await sendAndWait(agent, repairPrompt, workflow.limits.scoutTimeoutMs);
      run = repairedRun.run;
      result = repairedRun.result;
      rawResult = result.result ?? "";
      repaired = true;

      await writeFile(path.join(dir, "assistant-repair-result.md"), rawResult);
      parsed = stage.outputSchema.parse(JSON.parse(await readFile(resultPath, "utf8")));
    }

    await writeFile(resultPath, `${JSON.stringify(parsed, null, 2)}\n`);

    await ResearchRun.updateOne(
      { _id: runRecord._id },
      {
        $set: {
          status: result.status === "finished" ? "completed" : "failed",
          completedAt: new Date(),
          resultSummary: parsed.researchSummary,
          cursorAgentId: agent.agentId,
          cursorRunId: run.id,
          artifacts: [
            { kind: "prompt", path: path.join(dir, "prompt.md") },
            { kind: "known_organizations", path: path.join(dir, "known-organizations.json") },
            { kind: "assistant_result", path: path.join(dir, "assistant-result.md") },
            ...(repaired
              ? [
                  { kind: "repair_prompt", path: path.join(dir, "repair-prompt.md") },
                  { kind: "assistant_result", path: path.join(dir, "assistant-repair-result.md") },
                ]
              : []),
            { kind: "json_result", path: resultPath },
          ],
          metadata: {
            workflowSlug: workflow.slug,
            stageSlug: stage.slug,
            shardSlug: shard.slug,
            orchestratorRunId,
            requestId: run.requestId,
            durationMs: result.durationMs,
            knownOrganizationCount: knownOrganizations.length,
          },
        },
      },
    );

    return {
      output: parsed,
      researchRunId: String(runRecord._id),
    };
  } catch (error) {
    await ResearchRun.updateOne(
      { _id: runRecord._id },
      { $set: { status: "failed", completedAt: new Date(), error: errorMessage(error) } },
    );

    throw error;
  }
}

async function mapWithConcurrency<T, R>(
  items: T[],
  concurrency: number,
  mapper: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = [];
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < items.length) {
      const index = nextIndex;
      nextIndex += 1;
      results[index] = await mapper(items[index]);
    }
  }

  await Promise.all(Array.from({ length: Math.min(Math.max(1, concurrency), items.length) }, worker));
  return results;
}

async function runSynthesisStage(args: {
  workflow: ResearchWorkflowConfig;
  stage: Extract<ResearchStageConfig, { kind: "synthesis" }>;
  apiKey: string;
  modelId: string;
  orchestratorRunId: string;
  previousOutputs: GroupOutput[];
  knownOrganizations: KnownOrganization[];
}): Promise<SynthesisResult> {
  const { workflow, stage, apiKey, modelId, orchestratorRunId, previousOutputs, knownOrganizations } = args;
  const dir = stageDir(workflow.artifactRoot, orchestratorRunId, stage.slug);
  await mkdir(dir, { recursive: true });

  const outputFileName = stage.outputFileName ?? "synthesis.md";
  const artifactPath = path.join(dir, outputFileName);
  const dedupePath = path.join(dir, "dedupe-report.json");
  const prompt = stage.promptBuilder({
    workflow,
    stage,
    previousOutputs,
    knownOrganizations,
    resultPath: stage.writesDedupeReport ? dedupePath : undefined,
  });
  await writeFile(path.join(dir, "prompt.md"), prompt);
  await writeFile(path.join(dir, "known-organizations.json"), `${JSON.stringify(knownOrganizations, null, 2)}\n`);

  await using agent = await Agent.create({
    apiKey,
    name: `BellLabs ${workflow.slug}: ${stage.title}`,
    model: { id: modelId },
    mode: "agent",
    local: {
      cwd: workflow.runtime.cwd ?? process.cwd(),
      settingSources: workflow.runtime.settingSources,
      store: new JsonlLocalAgentStore(cursorStoreDir(workflow.artifactRoot, orchestratorRunId, stage.slug)),
      ...(stage.writesDedupeReport
        ? {
            customTools: {
              write_dedupe_report: {
                description:
                  "Submit a machine-readable dedupe report for supplement organization workflow control.",
                inputSchema: {
                  type: "object",
                  properties: {
                    knownOrganizations: { type: "array" },
                    duplicateNotes: { type: "array" },
                    parentSubbrandNotes: { type: "array" },
                    weakOrUncertainEntries: { type: "array" },
                    recommendedGapPasses: { type: "array" },
                  },
                },
                async execute(args: unknown) {
                  const parsed = dedupeReportSchema.parse(args);
                  await writeFile(dedupePath, `${JSON.stringify(parsed, null, 2)}\n`);
                  return {
                    content: [{ type: "text", text: `Wrote dedupe report to ${dedupePath}` }],
                    structuredContent: {
                      ok: true,
                      path: dedupePath,
                      knownOrganizationCount: parsed.knownOrganizations.length,
                    },
                  };
                },
              },
            },
          }
        : {}),
    },
  });

  const { run, result } = await sendAndWait(agent, prompt, workflow.limits.scoutTimeoutMs);
  const synthesis = result.result ?? "";
  await writeFile(artifactPath, synthesis);

  return {
    cursorAgentId: agent.agentId,
    cursorRunId: run.id,
    synthesis,
    artifactPath,
    status: result.status,
  };
}

export async function runResearchWorkflow(workflow: ResearchWorkflowConfig, options: RunWorkflowOptions) {
  const modelId = await resolveModelId(options.apiKey, workflow, options.modelId);
  const orchestratorRunId = options.runId ?? timestampRunId(workflow.slug);
  const runDir = workflowRunDir(workflow.artifactRoot, orchestratorRunId);
  const selectedStages = selectedItems(workflow.stages, options.stageOffset, options.stageLimit);

  await mkdir(runDir, { recursive: true });
  await writeFile(
    path.join(runDir, "workflow-config-snapshot.json"),
    `${JSON.stringify(
      {
        slug: workflow.slug,
        name: workflow.name,
        goal: workflow.goal,
        modelId,
        stages: selectedStages.map((stage) => ({
          slug: stage.slug,
          title: stage.title,
          kind: stage.kind,
          shardCount: stage.kind === "scout" ? stage.shards.length : undefined,
        })),
        dryRun: options.dryRun,
      },
      null,
      2,
    )}\n`,
  );

  if (options.dryRun) {
    const previousOutputs: GroupOutput[] = [];
    for (const stage of selectedStages) {
      const knownOrganizations = knownOrganizationsFromOutputs(previousOutputs);
      if (stage.kind === "scout") {
        const shards = selectedItems(stage.shards, options.shardOffset, options.shardLimit);
        for (const shard of shards) {
          const resultPath = path.join(shardDir(workflow.artifactRoot, orchestratorRunId, stage.slug, shard.slug), "result.json");
          const prompt = stage.promptBuilder({
            workflow,
            stage,
            shard,
            resultPath,
            knownOrganizations,
            previousOutputs,
          });
          await writeDryRunPrompt(workflow, orchestratorRunId, stage, shard, prompt);
        }
      } else {
        const dir = stageDir(workflow.artifactRoot, orchestratorRunId, stage.slug);
        await mkdir(dir, { recursive: true });
        const resultPath = stage.writesDedupeReport ? path.join(dir, "dedupe-report.json") : undefined;
        await writeFile(
          path.join(dir, "prompt.md"),
          stage.promptBuilder({ workflow, stage, previousOutputs, knownOrganizations, resultPath }),
        );
      }
    }

    console.log(`Dry run wrote workflow prompts to ${runDir}`);
    return { orchestratorRunId, dryRun: true, artifactPath: runDir };
  }

  if (!options.apiKey) {
    throw new Error("CURSOR_API_KEY is required unless RESEARCH_DRY_RUN=1.");
  }

  await connectMongo();

  const orchestratorRun = await ResearchRun.create({
    name: workflow.name,
    mode: workflow.mode,
    status: "running",
    goal: workflow.goal,
    prompt: "See per-stage prompt artifacts.",
    agentRuntime: workflow.runtime.kind,
    model: modelId,
    toolProfile: workflow.tools,
    skillProfile: workflow.skills,
    divisionSlugs: selectedStages.flatMap((stage) =>
      stage.kind === "scout" ? stage.shards.flatMap((shard) => shard.divisionSlugs) : [],
    ),
    startedAt: new Date(),
    budget: {
      maxMinutes: Math.ceil(workflow.limits.scoutTimeoutMs / 60000) * selectedStages.length,
    },
    metadata: {
      workflowSlug: workflow.slug,
      orchestratorRunId,
      stageSlugs: selectedStages.map((stage) => stage.slug),
      maxConcurrentShards: options.concurrency ?? workflow.limits.maxConcurrentShards,
      dryRun: false,
    },
  });

  const allOutputs: GroupOutput[] = [];
  const synthesisResults: SynthesisResult[] = [];
  const allCandidateEntityIds = new Set<string>();
  const allSourceRecordIds = new Set<string>();

  try {
    console.log(`Starting ${orchestratorRunId} with model ${modelId}`);

    for (const stage of selectedStages) {
      const knownOrganizations = await buildKnownOrganizations(stage, allOutputs);

      if (stage.kind === "scout") {
        const shards = selectedItems(stage.shards, options.shardOffset, options.shardLimit);
        const concurrency = options.concurrency ?? stage.maxConcurrentShards ?? workflow.limits.maxConcurrentShards;
        const stageScoutResults = await mapWithConcurrency(shards, concurrency, async (shard) => {
          console.log(`Starting ${stage.slug}/${shard.slug}`);
          const scoutResult = await runScoutShard({
            workflow,
            stage,
            shard,
            apiKey: options.apiKey!,
            modelId,
            orchestratorRunId,
            previousOutputs: allOutputs,
            knownOrganizations,
          });
          const ingestion = await ingestGroupOutput(scoutResult.output, {
            workflow,
            orchestratorRunId,
            stageSlug: stage.slug,
          });
          for (const candidateId of ingestion.candidateIds) {
            allCandidateEntityIds.add(candidateId);
          }
          for (const sourceRecordId of ingestion.sourceRecordIds) {
            allSourceRecordIds.add(sourceRecordId);
          }
          await ResearchRun.updateOne(
            { _id: scoutResult.researchRunId },
            {
              $set: {
                candidateEntityIds: ingestion.candidateIds,
                sourceRecordIds: ingestion.sourceRecordIds,
              },
            },
          );
          console.log(
            `Completed ${stage.slug}/${shard.slug}: ${ingestion.candidateEntityCount} organizations, ${ingestion.sourceRecordCount} sources.`,
          );
          return scoutResult;
        });

        const stageOutputs = stageScoutResults.map((result) => result.output);
        allOutputs.push(...stageOutputs);
        const stageOutputsPath = path.join(stageDir(workflow.artifactRoot, orchestratorRunId, stage.slug), "stage-outputs.json");
        await writeFile(stageOutputsPath, `${JSON.stringify(stageOutputs, null, 2)}\n`);
      } else {
        const synthesis = await runSynthesisStage({
          workflow,
          stage,
          apiKey: options.apiKey,
          modelId,
          orchestratorRunId,
          previousOutputs: allOutputs,
          knownOrganizations,
        });
        synthesisResults.push(synthesis);
        console.log(synthesis.synthesis);
      }
    }

    const allOutputsPath = path.join(runDir, "all-group-outputs.json");
    await writeFile(allOutputsPath, `${JSON.stringify(allOutputs, null, 2)}\n`);

    const candidateCount = allOutputs.reduce((sum, output) => sum + output.candidateOrganizations.length, 0);
    const sourceCount = allOutputs.reduce((sum, output) => sum + output.sourceRecords.length, 0);
    const lastSynthesis = synthesisResults.at(-1);

    await ResearchRun.updateOne(
      { _id: orchestratorRun._id },
      {
        $set: {
          status: "completed",
          completedAt: new Date(),
          resultSummary: `Mapped ${candidateCount} organization candidates and ${sourceCount} source records across ${allOutputs.length} scout outputs.`,
          cursorAgentId: lastSynthesis?.cursorAgentId,
          cursorRunId: lastSynthesis?.cursorRunId,
          candidateEntityIds: [...allCandidateEntityIds],
          sourceRecordIds: [...allSourceRecordIds],
          artifacts: [
            { kind: "json_result", path: allOutputsPath },
            ...synthesisResults.map((result) => ({ kind: "synthesis", path: result.artifactPath })),
          ],
          metadata: {
            workflowSlug: workflow.slug,
            orchestratorRunId,
            modelId,
            candidateCount,
            sourceCount,
            synthesisStatuses: synthesisResults.map((result) => result.status),
          },
        },
      },
    );

    return {
      orchestratorRunId,
      dryRun: false,
      artifactPath: runDir,
      candidateCount,
      sourceCount,
    };
  } catch (error) {
    await ResearchRun.updateOne(
      { _id: orchestratorRun._id },
      { $set: { status: "failed", completedAt: new Date(), error: errorMessage(error) } },
    );
    throw error;
  } finally {
    await disconnectMongo();
  }
}
