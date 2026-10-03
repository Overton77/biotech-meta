import { z } from "zod";

export const entityKindSchema = z
  .enum([
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
  ])
  .default("other");

export const organizationSchema = z.object({
  name: z.string().min(1),
  aliases: z.array(z.string()).default([]),
  canonicalUrl: z.string().optional(),
  organizationType: z.string().optional(),
  divisions: z.array(z.string()).default([]),
  whyItMatters: z.string().min(1),
  prominenceRationale: z.string().min(1),
  productsOrServices: z.array(z.string()).default([]),
  relatedPeople: z.array(z.string()).default([]),
  relatedTechnologies: z.array(z.string()).default([]),
  evidenceSourceUrls: z.array(z.string()).default([]),
  expansionEdges: z
    .array(
      z.object({
        relation: z.string(),
        targetName: z.string(),
        targetKind: entityKindSchema,
        targetCanonicalUrl: z.string().optional(),
        notes: z.string().optional(),
        confidence: z.number().min(0).max(1).optional(),
      }),
    )
    .default([]),
  score: z.object({
    userDecisionRelevance: z.number().min(0).max(5),
    graphCentrality: z.number().min(0).max(5),
    marketProminence: z.number().min(0).max(5),
    evidenceImportance: z.number().min(0).max(5),
    freshnessVolatility: z.number().min(0).max(5),
    commercialActionability: z.number().min(0).max(5),
    coverageGap: z.number().min(0).max(5),
    trustRiskSensitivity: z.number().min(0).max(5),
    platformStorytellingValue: z.number().min(0).max(5),
    schemaPressure: z.number().min(0).max(5),
    rationale: z.string().optional(),
  }),
});

export const sourceSchema = z.object({
  url: z.string().min(1),
  title: z.string().optional(),
  sourceType: z
    .enum([
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
    ])
    .default("other"),
  publisher: z.string().optional(),
  summary: z.string().optional(),
  relatedEntityNames: z.array(z.string()).default([]),
  relatedDivisionSlugs: z.array(z.string()).default([]),
  trustNotes: z.string().optional(),
});

export const groupOutputSchema = z.object({
  groupSlug: z.string(),
  groupTitle: z.string(),
  researchSummary: z.string(),
  coverageNotes: z.array(z.string()).default([]),
  missingOrUncertainAreas: z.array(z.string()).default([]),
  candidateOrganizations: z.array(organizationSchema),
  sourceRecords: z.array(sourceSchema).default([]),
  schemaPressureNotes: z.array(z.string()).default([]),
});

export const knownOrganizationSchema = z.object({
  name: z.string(),
  normalizedName: z.string(),
  aliases: z.array(z.string()).default([]),
  canonicalUrl: z.string().optional(),
  canonicalHost: z.string().optional(),
  divisionSlugs: z.array(z.string()).default([]),
  source: z.enum(["mongo", "stage_output"]).default("stage_output"),
  notes: z.string().optional(),
});

export const dedupeReportSchema = z.object({
  knownOrganizations: z.array(knownOrganizationSchema).default([]),
  duplicateNotes: z.array(z.string()).default([]),
  parentSubbrandNotes: z.array(z.string()).default([]),
  weakOrUncertainEntries: z.array(z.string()).default([]),
  recommendedGapPasses: z.array(z.string()).default([]),
});

export type OrganizationOutput = z.infer<typeof organizationSchema>;
export type SourceOutput = z.infer<typeof sourceSchema>;
export type GroupOutput = z.infer<typeof groupOutputSchema>;
export type ScoreInput = OrganizationOutput["score"];
export type KnownOrganization = z.infer<typeof knownOrganizationSchema>;
export type DedupeReport = z.infer<typeof dedupeReportSchema>;

export function normalizeName(name: string): string {
  return name
    .trim()
    .toLowerCase()
    .replace(/&/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export function calculateTotal(score: ScoreInput): number {
  return [
    score.userDecisionRelevance,
    score.graphCentrality,
    score.marketProminence,
    score.evidenceImportance,
    score.freshnessVolatility,
    score.commercialActionability,
    score.coverageGap,
    score.trustRiskSensitivity,
    score.platformStorytellingValue,
    score.schemaPressure,
  ].reduce((sum, value) => sum + value, 0);
}

export function canonicalHost(url?: string): string | undefined {
  if (!url) return undefined;

  try {
    return new URL(url).hostname.replace(/^www\./, "").toLowerCase();
  } catch {
    return undefined;
  }
}

export function buildGroupOutputShape(group: {
  slug: string;
  title: string;
  divisionSlugs: string[];
}) {
  return {
    groupSlug: group.slug,
    groupTitle: group.title,
    researchSummary: "string",
    coverageNotes: ["string"],
    missingOrUncertainAreas: ["string"],
    candidateOrganizations: [
      {
        name: "string",
        aliases: ["string"],
        canonicalUrl: "string",
        organizationType: "company | clinic | lab | nonprofit | platform | media | community | research institute | other",
        divisions: group.divisionSlugs,
        whyItMatters: "string",
        prominenceRationale: "string",
        productsOrServices: ["string"],
        relatedPeople: ["string"],
        relatedTechnologies: ["string"],
        evidenceSourceUrls: ["https://..."],
        expansionEdges: [
          {
            relation: "SELLS | OPERATES | FOUNDED_BY | ADVISES | DEVELOPS | STUDIES | COMPETES_WITH | CONNECTED_TO",
            targetName: "string",
            targetKind: "product",
            targetCanonicalUrl: "string",
            notes: "string",
            confidence: 0.8,
          },
        ],
        score: {
          userDecisionRelevance: 5,
          graphCentrality: 5,
          marketProminence: 5,
          evidenceImportance: 5,
          freshnessVolatility: 5,
          commercialActionability: 5,
          coverageGap: 5,
          trustRiskSensitivity: 5,
          platformStorytellingValue: 5,
          schemaPressure: 5,
          rationale: "string",
        },
      },
    ],
    sourceRecords: [
      {
        url: "https://...",
        title: "string",
        sourceType: "company_site",
        publisher: "string",
        summary: "string",
        relatedEntityNames: ["string"],
        relatedDivisionSlugs: group.divisionSlugs,
        trustNotes: "string",
      },
    ],
    schemaPressureNotes: ["string"],
  };
}
