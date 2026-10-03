import mongoose, { Schema, type InferSchemaType } from "mongoose";
import { provenanceSchema, scoreSchema } from "./shared.js";

const ecosystemDivisionSchema = new Schema(
  {
    name: { type: String, required: true, index: true },
    slug: { type: String, required: true, unique: true, index: true },
    description: String,
    scope: String,
    userFacingRelevance: String,
    commercialMaturity: String,
    safetyAndRegulatorySensitivity: String,
    importantSourceTypes: [String],
    parentDivisionSlugs: [String],
    relatedDivisionSlugs: [String],
    keyMechanisms: [String],
    keyBiomarkers: [String],
    keyTechnologies: [String],
    openQuestions: [String],
    schemaImplications: [String],
    score: scoreSchema,
    provenance: [provenanceSchema],
  },
  { timestamps: true },
);

export type EcosystemDivisionDocument = InferSchemaType<typeof ecosystemDivisionSchema>;

export const EcosystemDivision =
  mongoose.models.EcosystemDivision ?? mongoose.model("EcosystemDivision", ecosystemDivisionSchema);
