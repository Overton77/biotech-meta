import { Schema } from "mongoose";

export const provenanceSchema = new Schema(
  {
    sourceRecordId: { type: Schema.Types.ObjectId, ref: "SourceRecord" },
    url: String,
    title: String,
    quote: String,
    observedAt: Date,
    confidence: Number,
    notes: String,
  },
  { _id: false },
);

export const scoreSchema = new Schema(
  {
    userDecisionRelevance: { type: Number, min: 0, max: 5, default: 0 },
    graphCentrality: { type: Number, min: 0, max: 5, default: 0 },
    marketProminence: { type: Number, min: 0, max: 5, default: 0 },
    evidenceImportance: { type: Number, min: 0, max: 5, default: 0 },
    freshnessVolatility: { type: Number, min: 0, max: 5, default: 0 },
    commercialActionability: { type: Number, min: 0, max: 5, default: 0 },
    coverageGap: { type: Number, min: 0, max: 5, default: 0 },
    trustRiskSensitivity: { type: Number, min: 0, max: 5, default: 0 },
    platformStorytellingValue: { type: Number, min: 0, max: 5, default: 0 },
    schemaPressure: { type: Number, min: 0, max: 5, default: 0 },
    total: { type: Number, default: 0 },
    rationale: String,
  },
  { _id: false },
);

export type CoverageScore = {
  userDecisionRelevance: number;
  graphCentrality: number;
  marketProminence: number;
  evidenceImportance: number;
  freshnessVolatility: number;
  commercialActionability: number;
  coverageGap: number;
  trustRiskSensitivity: number;
  platformStorytellingValue: number;
  schemaPressure: number;
  total: number;
  rationale?: string;
};
