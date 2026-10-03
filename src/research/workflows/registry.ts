import { organizationEcosystemWorkflow } from "./configs/organization-ecosystem.js";
import { supplementOrganizationsWorkflow } from "./configs/supplement-organizations.js";
import type { ResearchWorkflowConfig } from "./types.js";

export const researchWorkflows = {
  [organizationEcosystemWorkflow.slug]: organizationEcosystemWorkflow,
  [supplementOrganizationsWorkflow.slug]: supplementOrganizationsWorkflow,
} satisfies Record<string, ResearchWorkflowConfig>;

export type ResearchWorkflowSlug = keyof typeof researchWorkflows;

export function getResearchWorkflow(slug: string): ResearchWorkflowConfig {
  const workflow = researchWorkflows[slug as ResearchWorkflowSlug];
  if (!workflow) {
    throw new Error(`Unknown workflow "${slug}". Available workflows: ${Object.keys(researchWorkflows).join(", ")}`);
  }

  return workflow;
}
