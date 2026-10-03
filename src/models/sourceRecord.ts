import mongoose, { Schema, type InferSchemaType } from "mongoose";

export const sourceTypeValues = [
  "company_site",
  "product_page",
  "search_result",
  "pubmed",
  "clinical_trials",
  "regulatory",
  "youtube",
  "podcast",
  "conference",
  "investor_portfolio",
  "news",
  "community",
  "document",
  "other",
] as const;

const sourceRecordSchema = new Schema(
  {
    url: { type: String, required: true, index: true },
    canonicalUrl: { type: String, index: true },
    title: String,
    sourceType: { type: String, enum: sourceTypeValues, default: "other", index: true },
    publisher: String,
    retrievedAt: { type: Date, default: Date.now, index: true },
    publishedAt: Date,
    summary: String,
    contentHash: String,
    artifactPath: String,
    relatedDivisionSlugs: [String],
    relatedEntityNames: [String],
    trustNotes: String,
    metadata: { type: Schema.Types.Mixed },
  },
  { timestamps: true },
);

sourceRecordSchema.index({ url: 1, retrievedAt: -1 });

export type SourceRecordDocument = InferSchemaType<typeof sourceRecordSchema>;

export const SourceRecord = mongoose.models.SourceRecord ?? mongoose.model("SourceRecord", sourceRecordSchema);
