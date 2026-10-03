import type { z } from "zod";
import type { GroupOutput, KnownOrganization } from "./schemas.js";

export type ResearchRuntimeConfig = {
  kind: "local";
  cwd?: string;
  settingSources: Array<"project" | "user" | "plugins">;
};

export type ResearchWorkflowLimits = {
  maxConcurrentShards: number;
  scoutTimeoutMs: number;
  maxSearchCommandsPerShard: number;
};

export type ResearchShardConfig = {
  slug: string;
  title: string;
  mission: string;
  divisionSlugs: string[];
  targetCount: number;
  sourceHints: string[];
  categoryTags?: string[];
  promptAddendum?: string;
};

export type ResearchPromptContext = {
  workflow: ResearchWorkflowConfig;
  stage: ResearchStageConfig;
  shard: ResearchShardConfig;
  resultPath: string;
  knownOrganizations: KnownOrganization[];
  previousOutputs: GroupOutput[];
};

export type SynthesisPromptContext = {
  workflow: ResearchWorkflowConfig;
  stage: ResearchStageConfig;
  previousOutputs: GroupOutput[];
  knownOrganizations: KnownOrganization[];
  resultPath?: string;
};

export type ResearchStageConfig =
  | {
      kind: "scout";
      slug: string;
      title: string;
      mode?: "division_scout" | "source_procurement" | "entity_research" | "evidence_investigation" | "other";
      shards: ResearchShardConfig[];
      maxConcurrentShards?: number;
      injectKnownOrganizations?: boolean;
      outputSchema: z.ZodType<GroupOutput>;
      promptBuilder: (context: ResearchPromptContext) => string;
      repairPromptBuilder?: (context: ResearchPromptContext & { previousOutput: string }) => string;
    }
  | {
      kind: "synthesis";
      slug: string;
      title: string;
      mode?: "ecosystem_mapping" | "other";
      outputFileName?: string;
      promptBuilder: (context: SynthesisPromptContext) => string;
      writesDedupeReport?: boolean;
    };

export type ResearchWorkflowConfig = {
  slug: string;
  name: string;
  goal: string;
  mode: "ecosystem_mapping" | "division_scout" | "other";
  artifactRoot: string;
  modelEnv: string[];
  defaultModel: string;
  runtime: ResearchRuntimeConfig;
  tools: string[];
  skills: string[];
  limits: ResearchWorkflowLimits;
  stages: ResearchStageConfig[];
};

export type RunWorkflowOptions = {
  workflowSlug?: string;
  apiKey?: string;
  modelId?: string;
  runId?: string;
  dryRun: boolean;
  stageOffset: number;
  stageLimit?: number;
  shardOffset: number;
  shardLimit?: number;
  concurrency?: number;
};

export type IngestionResult = {
  sourceRecordCount: number;
  candidateEntityCount: number;
  candidateIds: string[];
  sourceRecordIds: string[];
};

export type SynthesisResult = {
  cursorAgentId?: string;
  cursorRunId?: string;
  synthesis: string;
  artifactPath: string;
  status: string;
};
