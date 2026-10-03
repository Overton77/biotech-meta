import { groupOutputSchema } from "../schemas.js";
import type { ResearchShardConfig, ResearchWorkflowConfig } from "../types.js";
import {
  buildSupplementDedupePrompt,
  buildSupplementFinalSynthesisPrompt,
  buildSupplementScoutPrompt,
} from "../prompts.js";

const supplementDivisionSlugs = ["supplements-functional-nutrition"];

const anchorShards: ResearchShardConfig[] = [
  {
    slug: "longevity-and-senolytics",
    title: "Longevity, NAD, Senolytics, And Healthy Aging Supplements",
    mission:
      "Identify prominent supplement organizations centered on longevity, NAD metabolism, senolytics, urolithin A, spermidine, fisetin, quercetin, mitochondrial health, and healthy aging stacks.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 30,
    categoryTags: ["longevity", "senolytics", "nad", "healthy-aging"],
    sourceHints: [
      "longevity supplement brands NAD senolytics",
      "urolithin A supplement company",
      "spermidine supplement brands",
      "healthy aging nutraceutical companies",
      "mitochondrial health supplement companies",
    ],
    promptAddendum:
      "Include major DTC brands, scientifically positioned startups, ingredient-linked brands, and organizations with notable longevity or geroscience positioning.",
  },
  {
    slug: "clinical-practitioner-and-medical-grade",
    title: "Clinical, Practitioner, And Medical-Grade Supplement Channels",
    mission:
      "Identify practitioner-oriented, clinical, medical-grade, and professional supplement organizations, including dispensary platforms and brands used by clinicians.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 30,
    categoryTags: ["clinical", "practitioner-channel", "medical-grade"],
    sourceHints: [
      "professional supplement brands clinicians",
      "practitioner supplement dispensary companies",
      "medical grade supplements companies",
      "functional medicine supplement brands",
      "clinician recommended supplement companies",
    ],
    promptAddendum:
      "Separate supplement brands from dispensary platforms. Capture channel role explicitly in organizationType or prominenceRationale.",
  },
  {
    slug: "sports-performance-and-recovery",
    title: "Sports Performance, Recovery, Protein, Electrolytes, And Creatine",
    mission:
      "Identify leading organizations in performance supplements, protein, creatine, electrolytes, recovery, pre-workout, endurance, and sleep-performance categories.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 30,
    categoryTags: ["sports-nutrition", "recovery", "protein", "electrolytes"],
    sourceHints: [
      "sports nutrition supplement companies",
      "creatine supplement brands",
      "electrolyte supplement companies",
      "protein powder brands market leaders",
      "recovery supplement companies athletes",
    ],
    promptAddendum:
      "Include incumbents and newer premium brands, but avoid generic grocery food brands unless supplements are a major business.",
  },
  {
    slug: "ingredient-platforms-and-suppliers",
    title: "Ingredient Platforms, Branded Ingredients, And Nutraceutical Suppliers",
    mission:
      "Identify organizations that supply branded nutraceutical ingredients, supplement raw materials, delivery technologies, formulation platforms, and contract manufacturing infrastructure.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 30,
    categoryTags: ["ingredients", "suppliers", "manufacturing", "formulation"],
    sourceHints: [
      "branded nutraceutical ingredient companies",
      "supplement contract manufacturers",
      "dietary supplement ingredient suppliers",
      "nutraceutical formulation companies",
      "capsule gummy supplement manufacturers",
    ],
    promptAddendum:
      "This shard should not over-focus on DTC brands. Prioritize suppliers and infrastructure that many brands depend on.",
  },
];

const gapFillShards: ResearchShardConfig[] = [
  {
    slug: "personalized-nutrition-and-testing-linked",
    title: "Personalized Nutrition And Testing-Linked Supplement Platforms",
    mission:
      "Identify organizations that pair supplements with quizzes, blood testing, microbiome testing, DNA, CGM/metabolic data, practitioner protocols, or algorithmic personalization.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["personalization", "testing-linked", "data-driven"],
    sourceHints: [
      "personalized supplement companies blood test",
      "DNA personalized nutrition supplement companies",
      "microbiome supplement personalization companies",
      "quiz based personalized vitamin companies",
      "CGM nutrition supplement platform",
    ],
  },
  {
    slug: "women-men-hormone-and-life-stage",
    title: "Women, Men, Hormone, Fertility, Menopause, And Life-Stage Supplements",
    mission:
      "Identify supplement organizations focused on fertility, prenatal, menopause, hormone support, testosterone, sexual health, and life-stage-specific nutrition.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["womens-health", "mens-health", "hormones", "fertility"],
    sourceHints: [
      "menopause supplement companies",
      "fertility prenatal supplement brands",
      "testosterone support supplement companies",
      "women's hormone supplement brands",
      "sexual health supplement companies",
    ],
  },
  {
    slug: "gut-microbiome-and-digestive-health",
    title: "Gut, Microbiome, Probiotics, Prebiotics, And Digestive Health",
    mission:
      "Identify organizations centered on probiotics, prebiotics, postbiotics, digestive enzymes, gut lining, microbiome testing-linked interventions, and digestive health supplements.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["gut-health", "microbiome", "probiotics", "digestion"],
    sourceHints: [
      "probiotic supplement companies",
      "prebiotic postbiotic supplement brands",
      "digestive enzyme supplement companies",
      "microbiome intervention companies supplements",
      "gut health supplement brands",
    ],
  },
  {
    slug: "cognitive-mood-and-neuro",
    title: "Cognitive, Mood, Sleep, Nootropic, And Neuro Supplement Brands",
    mission:
      "Identify organizations in nootropics, cognitive performance, mood, stress, adaptogens, magnesium/sleep, and neuro-focused supplement categories.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["nootropics", "mood", "stress", "sleep"],
    sourceHints: [
      "nootropic supplement companies",
      "cognitive performance supplement brands",
      "adaptogen supplement companies",
      "sleep supplement brands magnesium",
      "stress mood supplement companies",
    ],
  },
  {
    slug: "clean-label-functional-food-and-nutraceuticals",
    title: "Clean Label, Functional Food, Greens, Mushrooms, Collagen, And Nutraceuticals",
    mission:
      "Identify organizations in functional nutrition powders, greens, mushrooms, collagen, whole-food supplements, functional beverages, and clean-label nutraceuticals.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["functional-food", "greens", "mushrooms", "collagen"],
    sourceHints: [
      "greens powder supplement brands",
      "mushroom supplement companies",
      "collagen supplement brands",
      "functional beverage nutraceutical companies",
      "whole food supplement companies",
    ],
  },
  {
    slug: "retail-marketplaces-and-distribution",
    title: "Supplement Retail, Marketplaces, Dispensaries, And Distribution",
    mission:
      "Identify major supplement retailers, marketplaces, practitioner dispensaries, Amazon-native ecosystems, subscription platforms, and specialty distribution organizations.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["retail", "marketplace", "distribution", "dispensary"],
    sourceHints: [
      "supplement marketplace companies",
      "practitioner supplement dispensary platform",
      "online supplement retailer market leaders",
      "Amazon supplement brand ecosystem",
      "specialty supplement distributor companies",
    ],
    promptAddendum:
      "Separate marketplace/distribution organizations from brands. Include them when they shape discovery, purchasing, or practitioner workflows.",
  },
];

const targetedShards: ResearchShardConfig[] = [
  {
    slug: "international-and-non-us-leaders",
    title: "International And Non-US Supplement Leaders",
    mission:
      "Identify prominent supplement, nutraceutical, functional nutrition, ingredient, and distribution organizations outside the United States that may be missed by US-centric search.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 25,
    categoryTags: ["international", "non-us", "gap-fill"],
    sourceHints: [
      "European nutraceutical supplement companies",
      "Japanese supplement companies",
      "Indian nutraceutical companies",
      "global supplement market leading companies",
      "non US functional nutrition brands",
    ],
  },
  {
    slug: "regulatory-risk-and-high-claim-categories",
    title: "Regulatory-Risk, High-Claim, MLM, And Safety-Sensitive Supplement Categories",
    mission:
      "Identify supplement organizations that are prominent because of disease-positioned claims, MLM structures, weight-loss claims, testosterone or hormone claims, contamination concerns, regulatory scrutiny, or trust-risk relevance.",
    divisionSlugs: supplementDivisionSlugs,
    targetCount: 20,
    categoryTags: ["regulatory-risk", "claims", "mlm", "safety"],
    sourceHints: [
      "supplement companies FDA warning letters",
      "MLM supplement companies",
      "weight loss supplement companies claims",
      "testosterone supplement brands claims",
      "supplement brands regulatory scrutiny",
    ],
    promptAddendum:
      "Do not sensationalize. Include organizations only when source-backed prominence or trust-risk relevance is clear.",
  },
];

export const supplementOrganizationsWorkflow: ResearchWorkflowConfig = {
  slug: "supplement-organizations",
  name: "BellLabs supplement organization discovery",
  goal: "Identify, dedupe, and rank prominent supplement, nutraceutical, functional nutrition, ingredient, marketplace, and distribution organizations for BellLabs pre-ingestion targeting.",
  mode: "ecosystem_mapping",
  artifactRoot: ".belllabs-runs/supplement-organizations",
  modelEnv: ["CURSOR_SUPPLEMENT_RESEARCH_MODEL", "CURSOR_ORG_RESEARCH_MODEL", "CURSOR_MODEL"],
  defaultModel: "gpt-5.4-mini",
  runtime: {
    kind: "local",
    settingSources: ["project", "user", "plugins"],
  },
  tools: ["cursor-sdk", "tavily-cli", "firecrawl", "agent-browser", "mongodb-mcp-ready"],
  skills: ["skills/tavily-cli", "skills/firecrawl", "skills/agent-browser"],
  limits: {
    maxConcurrentShards: Number(process.env.SUPPLEMENT_RESEARCH_CONCURRENCY ?? 2),
    scoutTimeoutMs: Number(process.env.SUPPLEMENT_RESEARCH_SCOUT_TIMEOUT_MS ?? 10 * 60 * 1000),
    maxSearchCommandsPerShard: Number(process.env.SUPPLEMENT_RESEARCH_MAX_SEARCH_COMMANDS ?? 10),
  },
  stages: [
    {
      kind: "scout",
      slug: "wave-1-anchor-scouts",
      title: "Wave 1 Anchor Supplement Scouts",
      shards: anchorShards,
      maxConcurrentShards: Number(process.env.SUPPLEMENT_RESEARCH_CONCURRENCY ?? 2),
      injectKnownOrganizations: true,
      outputSchema: groupOutputSchema,
      promptBuilder: buildSupplementScoutPrompt,
    },
    {
      kind: "synthesis",
      slug: "wave-1-dedupe-synthesis",
      title: "Wave 1 Dedupe And Gap Synthesis",
      outputFileName: "synthesis.md",
      writesDedupeReport: true,
      promptBuilder: buildSupplementDedupePrompt,
    },
    {
      kind: "scout",
      slug: "wave-2-gap-fill",
      title: "Wave 2 Supplement Gap Fill",
      shards: gapFillShards,
      maxConcurrentShards: 1,
      injectKnownOrganizations: true,
      outputSchema: groupOutputSchema,
      promptBuilder: buildSupplementScoutPrompt,
    },
    {
      kind: "synthesis",
      slug: "wave-2-dedupe-synthesis",
      title: "Wave 2 Dedupe And Coverage Synthesis",
      outputFileName: "synthesis.md",
      writesDedupeReport: true,
      promptBuilder: buildSupplementDedupePrompt,
    },
    {
      kind: "scout",
      slug: "wave-3-targeted-passes",
      title: "Wave 3 Targeted Supplement Passes",
      shards: targetedShards,
      maxConcurrentShards: 1,
      injectKnownOrganizations: true,
      outputSchema: groupOutputSchema,
      promptBuilder: buildSupplementScoutPrompt,
    },
    {
      kind: "synthesis",
      slug: "final-synthesis",
      title: "Final Supplement Organization Synthesis",
      outputFileName: "synthesis.md",
      promptBuilder: buildSupplementFinalSynthesisPrompt,
    },
  ],
};
