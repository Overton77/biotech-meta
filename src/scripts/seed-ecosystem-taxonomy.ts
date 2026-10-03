import "dotenv/config";
import { connectMongo, disconnectMongo } from "../db/mongoose.js";
import { EcosystemDivision } from "../models/index.js";

// optimized divisions

const divisions = [
  [
    "consumer-lab-testing-biomarker-panels",
    "Consumer lab testing and biomarker panels",
  ],
  [
    "genomics-inherited-risk-pharmacogenomics",
    "Genomics, inherited risk, and pharmacogenomics",
  ],
  [
    "biological-age-longevity-diagnostics",
    "Biological age and longevity diagnostics",
  ],
  ["microbiome-testing-interventions", "Microbiome testing and interventions"],
  [
    "wearables-biosensors-continuous-monitoring",
    "Wearables, biosensors, and continuous monitoring",
  ],
  [
    "preventive-imaging-whole-body-screening",
    "Preventive imaging and whole-body screening",
  ],
  [
    "cancer-screening-multi-cancer-detection",
    "Cancer screening and multi-cancer detection",
  ],
  [
    "biomarker-analytics-health-copilots",
    "Biomarker analytics and health copilots",
  ],
  [
    "longevity-clinics-preventive-medicine",
    "Longevity clinics and preventive medicine",
  ],
  [
    "metabolic-health-obesity-medicine",
    "Metabolic health and obesity medicine",
  ],
  [
    "cardiovascular-prevention-lipid-management",
    "Cardiovascular prevention and lipid management",
  ],
  ["sleep-recovery-autonomic-health", "Sleep, recovery, and autonomic health"],
  [
    "womens-health-fertility-menopause",
    "Women's health, fertility, and menopause",
  ],
  [
    "mens-health-hormone-sexual-health",
    "Men's health, hormone, and sexual health",
  ],
  [
    "supplements-functional-nutrition",
    "Supplements, nutraceuticals, and functional nutrition",
  ],
  [
    "musculoskeletal-performance-recovery",
    "Musculoskeletal health, performance, and recovery",
  ],
  [
    "modality-devices-light-heat-cold-oxygen",
    "Modality devices including light, heat, cold, and oxygen",
  ],
  [
    "neurotechnology-cognitive-mental-performance",
    "Neurotechnology and cognitive or mental performance",
  ],
  [
    "psychedelic-medicine-neuroplasticity",
    "Psychedelic medicine and neuroplasticity",
  ],
  [
    "regenerative-medicine-cell-orthobiologics",
    "Regenerative medicine, cell therapies, and orthobiologics",
  ],
  ["genetic-medicines-gene-editing", "Genetic medicines and gene editing"],
  ["geroscience-senotherapeutics", "Geroscience and senotherapeutics"],
  [
    "ai-biology-multiomics-data-platforms",
    "AI biology, multi-omics, and data platforms",
  ],
  [
    "clinical-trial-real-world-data-platforms",
    "Clinical trial and real-world data platforms",
  ],
  [
    "research-tools-assays-bioinstrumentation",
    "Research tools, assays, and bioinstrumentation",
  ],
  [
    "biomanufacturing-delivery-infrastructure",
    "Biomanufacturing and delivery infrastructure",
  ],
  [
    "biohacking-media-educators-communities",
    "Biohacking media, educators, and communities",
  ],
] as const;
await connectMongo();

for (const [slug, name] of divisions) {
  await EcosystemDivision.updateOne(
    { slug },
    {
      $setOnInsert: {
        slug,
        name,
        description: "Initial BellLabs ecosystem mapping division.",
        provenance: [
          {
            title: "BellLabs ecosystem mapping cycle",
            url: "docs/BellLabs/ecosystem-mapping-cycle.md",
            observedAt: new Date(),
            confidence: 0.7,
          },
        ],
      },
    },
    { upsert: true },
  );
}

console.log(`Seeded ${divisions.length} ecosystem divisions.`);

await disconnectMongo();
