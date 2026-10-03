import { groupOutputSchema } from "../schemas.js";
import type { ResearchShardConfig, ResearchWorkflowConfig } from "../types.js";
import { buildOrganizationScoutPrompt, buildOrganizationSynthesisPrompt } from "../prompts.js";

const divisionGroups: ResearchShardConfig[] = [
  {
    slug: "diagnostics-labs-and-analytics",
    title: "Diagnostics, Labs, And Biomarker Analytics",
    mission:
      "Identify major organizations in consumer lab testing, genomics, biological age, microbiome, preventive imaging, cancer screening, and biomarker analytics.",
    targetCount: 30,
    divisionSlugs: [
      "consumer-lab-testing-biomarker-panels",
      "genomics-inherited-risk-pharmacogenomics",
      "biological-age-longevity-diagnostics",
      "microbiome-testing-interventions",
      "preventive-imaging-whole-body-screening",
      "cancer-screening-multi-cancer-detection",
      "biomarker-analytics-health-copilots",
    ],
    sourceHints: [
      "consumer biomarker testing companies",
      "biological age testing companies",
      "microbiome testing companies",
      "multi-cancer early detection companies",
      "whole body MRI screening companies",
      "lab result interpretation platforms",
    ],
  },
  {
    slug: "wearables-devices-and-performance",
    title: "Wearables, Devices, Recovery, And Performance",
    mission:
      "Identify major organizations in wearables, biosensors, recovery devices, modality devices, musculoskeletal performance, sleep, autonomic health, and neurotechnology.",
    targetCount: 30,
    divisionSlugs: [
      "wearables-biosensors-continuous-monitoring",
      "sleep-recovery-autonomic-health",
      "musculoskeletal-performance-recovery",
      "modality-devices-light-heat-cold-oxygen",
      "neurotechnology-cognitive-mental-performance",
    ],
    sourceHints: [
      "wearable health sensor companies",
      "continuous glucose monitor companies consumer metabolic health",
      "red light therapy device companies",
      "EWOT oxygen therapy device companies",
      "sleep recovery HRV platforms",
      "neurotechnology cognitive enhancement companies",
    ],
  },
  {
    slug: "longevity-care-and-preventive-medicine",
    title: "Longevity Care, Metabolic Health, And Preventive Medicine",
    mission:
      "Identify major organizations in longevity clinics, preventive medicine, metabolic health, cardiovascular prevention, women's health, men's health, hormone optimization, and concierge care.",
    targetCount: 25,
    divisionSlugs: [
      "longevity-clinics-preventive-medicine",
      "metabolic-health-obesity-medicine",
      "cardiovascular-prevention-lipid-management",
      "womens-health-fertility-menopause",
      "mens-health-hormone-sexual-health",
    ],
    sourceHints: [
      "longevity clinic companies",
      "preventive medicine platforms",
      "metabolic health telehealth companies",
      "cardiovascular prevention startups",
      "menopause longevity health companies",
      "hormone optimization clinics",
    ],
  },
  {
    slug: "interventions-therapeutics-and-geroscience",
    title: "Interventions, Therapeutics, And Geroscience",
    mission:
      "Identify major organizations in supplements, functional nutrition, regenerative medicine, genetic medicines, geroscience, senotherapeutics, peptides, psychedelics, and intervention-focused biotech.",
    targetCount: 35,
    divisionSlugs: [
      "supplements-functional-nutrition",
      "psychedelic-medicine-neuroplasticity",
      "regenerative-medicine-cell-orthobiologics",
      "genetic-medicines-gene-editing",
      "geroscience-senotherapeutics",
    ],
    sourceHints: [
      "longevity supplement brands",
      "senolytic biotech companies",
      "geroscience therapeutics companies",
      "regenerative medicine cell therapy companies",
      "gene editing biotech companies",
      "psychedelic medicine companies",
    ],
  },
  {
    slug: "biotech-infrastructure-research-and-media",
    title: "Biotech Infrastructure, Research Platforms, And Media",
    mission:
      "Identify major organizations in AI biology, multi-omics, clinical trial platforms, real-world data, research tools, assays, bioinstrumentation, biomanufacturing, delivery infrastructure, and biohacking media communities.",
    targetCount: 35,
    divisionSlugs: [
      "ai-biology-multiomics-data-platforms",
      "clinical-trial-real-world-data-platforms",
      "research-tools-assays-bioinstrumentation",
      "biomanufacturing-delivery-infrastructure",
      "biohacking-media-educators-communities",
    ],
    sourceHints: [
      "AI biology companies",
      "multiomics platform companies",
      "clinical trial platform companies",
      "real world data health companies",
      "life science research tools companies",
      "biomanufacturing companies",
      "biohacking media organizations",
    ],
  },
];

export const organizationEcosystemWorkflow: ResearchWorkflowConfig = {
  slug: "organization-ecosystem",
  name: "BellLabs organization ecosystem mapping",
  goal: "Identify the major organization players across high-value BellLabs ecosystem divisions.",
  mode: "ecosystem_mapping",
  artifactRoot: ".belllabs-runs/organization-ecosystem",
  modelEnv: ["CURSOR_ORG_RESEARCH_MODEL", "CURSOR_MODEL"],
  defaultModel: "gpt-5.4-mini",
  runtime: {
    kind: "local",
    settingSources: ["project", "user", "plugins"],
  },
  tools: ["cursor-sdk", "tavily-cli", "firecrawl", "agent-browser", "mongodb-mcp-ready"],
  skills: ["skills/tavily-cli", "skills/firecrawl", "skills/agent-browser"],
  limits: {
    maxConcurrentShards: Number(process.env.ORGANIZATION_RESEARCH_CONCURRENCY ?? 1),
    scoutTimeoutMs: Number(process.env.ORGANIZATION_RESEARCH_SCOUT_TIMEOUT_MS ?? 8 * 60 * 1000),
    maxSearchCommandsPerShard: 12,
  },
  stages: [
    {
      kind: "scout",
      slug: "division-scouts",
      title: "Division Scouts",
      shards: divisionGroups,
      maxConcurrentShards: Number(process.env.ORGANIZATION_RESEARCH_CONCURRENCY ?? 1),
      outputSchema: groupOutputSchema,
      promptBuilder: buildOrganizationScoutPrompt,
    },
    {
      kind: "synthesis",
      slug: "synthesis",
      title: "Organization Ecosystem Synthesis",
      promptBuilder: buildOrganizationSynthesisPrompt,
    },
  ],
};
