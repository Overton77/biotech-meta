import mongoose, { Schema, type InferSchemaType } from "mongoose";

const artifactSchema = new Schema(
  {
    kind: { type: String, required: true },
    title: String,
    path: String,
    url: String,
    summary: String,
    metadata: { type: Schema.Types.Mixed },
  },
  { _id: false },
);

const researchRunSchema = new Schema(
  {
    name: { type: String, required: true, index: true },
    mode: {
      type: String,
      enum: [
        "ecosystem_mapping",
        "division_scout",
        "source_procurement",
        "entity_research",
        "evidence_investigation",
        "ingestion",
        "evaluation",
        "sdlc",
        "other",
      ],
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: ["planned", "running", "paused", "completed", "failed", "cancelled"],
      default: "planned",
      index: true,
    },
    goal: { type: String, required: true },
    prompt: String,
    agentRuntime: { type: String, enum: ["local", "cloud", "manual", "other"], default: "manual" },
    cursorAgentId: String,
    cursorRunId: String,
    model: String,
    toolProfile: [String],
    skillProfile: [String],
    divisionSlugs: [String],
    candidateEntityIds: [{ type: Schema.Types.ObjectId, ref: "CandidateEntity" }],
    sourceRecordIds: [{ type: Schema.Types.ObjectId, ref: "SourceRecord" }],
    artifacts: [artifactSchema],
    startedAt: Date,
    completedAt: Date,
    budget: {
      maxCostUsd: Number,
      maxMinutes: Number,
      maxTokens: Number,
    },
    resultSummary: String,
    error: String,
    metadata: { type: Schema.Types.Mixed },
  },
  { timestamps: true },
);

researchRunSchema.index({ mode: 1, status: 1, createdAt: -1 });

export type ResearchRunDocument = InferSchemaType<typeof researchRunSchema>;

export const ResearchRun = mongoose.models.ResearchRun ?? mongoose.model("ResearchRun", researchRunSchema);
