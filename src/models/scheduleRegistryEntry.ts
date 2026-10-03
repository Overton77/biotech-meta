import mongoose, { Schema, type InferSchemaType } from "mongoose";

const scheduleRegistryEntrySchema = new Schema(
  {
    name: { type: String, required: true, unique: true, index: true },
    description: String,
    owner: String,
    enabled: { type: Boolean, default: false, index: true },
    trigger: {
      type: {
        type: String,
        enum: ["manual", "cron", "cursor_cloud_schedule", "event"],
        required: true,
      },
      expression: String,
      eventName: String,
    },
    runtime: {
      type: String,
      enum: ["local", "cursor_cloud", "external"],
      required: true,
      index: true,
    },
    workflowConfigPath: String,
    promptPath: String,
    toolProfile: [String],
    dataPermissions: [String],
    expectedArtifacts: [String],
    relatedProjectGoals: [String],
    budget: {
      maxCostUsd: Number,
      maxMinutes: Number,
      maxTokens: Number,
    },
    frequencyNotes: String,
    lastSuccessfulRunAt: Date,
    lastRunId: { type: Schema.Types.ObjectId, ref: "ResearchRun" },
    failurePolicy: String,
  },
  { timestamps: true },
);

export type ScheduleRegistryEntryDocument = InferSchemaType<typeof scheduleRegistryEntrySchema>;

export const ScheduleRegistryEntry =
  mongoose.models.ScheduleRegistryEntry ??
  mongoose.model("ScheduleRegistryEntry", scheduleRegistryEntrySchema);
