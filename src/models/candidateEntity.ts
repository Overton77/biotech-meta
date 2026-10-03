import mongoose, { Schema, type InferSchemaType } from "mongoose";
import { provenanceSchema, scoreSchema } from "./shared.js";

export const entityKindValues = [
  "organization",
  "person",
  "product",
  "service",
  "lab_test",
  "compound",
  "device",
  "technology_platform",
  "biomarker",
  "mechanism",
  "protocol",
  "study",
  "community",
  "source",
  "other",
] as const;

const expansionEdgeSchema = new Schema(
  {
    relation: { type: String, required: true },
    targetName: { type: String, required: true },
    targetKind: { type: String, enum: entityKindValues, default: "other" },
    targetCanonicalUrl: String,
    notes: String,
    confidence: Number,
  },
  { _id: false },
);

const candidateEntitySchema = new Schema(
  {
    name: { type: String, required: true, index: true },
    normalizedName: { type: String, required: true, index: true },
    kind: { type: String, enum: entityKindValues, required: true, index: true },
    description: String,
    canonicalUrl: String,
    aliases: [String],
    divisionSlugs: [{ type: String, index: true }],
    sourceRecordIds: [{ type: Schema.Types.ObjectId, ref: "SourceRecord" }],
    score: scoreSchema,
    expansionEdges: [expansionEdgeSchema],
    provenance: [provenanceSchema],
    kgStatus: {
      type: String,
      enum: ["unknown", "missing", "partial", "covered", "duplicate", "deferred"],
      default: "unknown",
      index: true,
    },
    kgEntityIds: [String],
    notes: String,
  },
  { timestamps: true },
);

candidateEntitySchema.index({ normalizedName: 1, kind: 1 }, { unique: true });

export type CandidateEntityDocument = InferSchemaType<typeof candidateEntitySchema>;

export const CandidateEntity =
  mongoose.models.CandidateEntity ?? mongoose.model("CandidateEntity", candidateEntitySchema);
