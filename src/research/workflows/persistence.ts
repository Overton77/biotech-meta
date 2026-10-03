import { CandidateEntity, SourceRecord } from "../../models/index.js";
import {
  calculateTotal,
  canonicalHost,
  type GroupOutput,
  type KnownOrganization,
  normalizeName,
} from "./schemas.js";
import type { IngestionResult, ResearchWorkflowConfig } from "./types.js";

type IngestContext = {
  workflow: ResearchWorkflowConfig;
  orchestratorRunId: string;
  stageSlug: string;
};

export async function loadKnownOrganizations(divisionSlugs: string[]): Promise<KnownOrganization[]> {
  const records = await CandidateEntity.find({
    kind: "organization",
    divisionSlugs: { $in: divisionSlugs },
  })
    .select("name normalizedName aliases canonicalUrl divisionSlugs notes")
    .lean();

  return records.map((record) => ({
    name: record.name,
    normalizedName: record.normalizedName,
    aliases: record.aliases ?? [],
    canonicalUrl: record.canonicalUrl,
    canonicalHost: canonicalHost(record.canonicalUrl),
    divisionSlugs: record.divisionSlugs ?? [],
    source: "mongo",
    notes: record.notes,
  }));
}

export function knownOrganizationsFromOutputs(outputs: GroupOutput[]): KnownOrganization[] {
  const knownByKey = new Map<string, KnownOrganization>();

  for (const output of outputs) {
    for (const organization of output.candidateOrganizations) {
      const normalizedName = normalizeName(organization.name);
      const key = canonicalHost(organization.canonicalUrl) ?? normalizedName;
      knownByKey.set(key, {
        name: organization.name,
        normalizedName,
        aliases: organization.aliases,
        canonicalUrl: organization.canonicalUrl,
        canonicalHost: canonicalHost(organization.canonicalUrl),
        divisionSlugs: organization.divisions,
        source: "stage_output",
        notes: organization.prominenceRationale,
      });
    }
  }

  return [...knownByKey.values()];
}

export function mergeKnownOrganizations(
  fromMongo: KnownOrganization[],
  fromOutputs: KnownOrganization[],
): KnownOrganization[] {
  const merged = new Map<string, KnownOrganization>();

  for (const organization of [...fromMongo, ...fromOutputs]) {
    const key = organization.canonicalHost ?? organization.normalizedName;
    if (!merged.has(key)) {
      merged.set(key, organization);
    }
  }

  return [...merged.values()];
}

export async function ingestGroupOutput(output: GroupOutput, context: IngestContext): Promise<IngestionResult> {
  const sourceIdsByUrl = new Map<string, string>();

  for (const source of output.sourceRecords) {
    const sourceRecord = await SourceRecord.findOneAndUpdate(
      { url: source.url },
      {
        $set: {
          canonicalUrl: source.url,
          title: source.title,
          sourceType: source.sourceType,
          publisher: source.publisher,
          summary: source.summary,
          relatedDivisionSlugs: source.relatedDivisionSlugs,
          relatedEntityNames: source.relatedEntityNames,
          trustNotes: source.trustNotes,
          metadata: {
            workflowSlug: context.workflow.slug,
            orchestratorRunId: context.orchestratorRunId,
            stageSlug: context.stageSlug,
            groupSlug: output.groupSlug,
          },
        },
        $setOnInsert: { retrievedAt: new Date() },
      },
      { upsert: true, returnDocument: "after" },
    );

    sourceIdsByUrl.set(source.url, String(sourceRecord._id));
  }

  const candidateIds: string[] = [];

  for (const organization of output.candidateOrganizations) {
    const score = {
      ...organization.score,
      total: calculateTotal(organization.score),
    };

    const sourceRecordIds = organization.evidenceSourceUrls
      .map((url) => sourceIdsByUrl.get(url))
      .filter((id): id is string => Boolean(id));

    const candidate = await CandidateEntity.findOneAndUpdate(
      { normalizedName: normalizeName(organization.name), kind: "organization" },
      {
        $set: {
          name: organization.name,
          normalizedName: normalizeName(organization.name),
          kind: "organization",
          description: `${organization.whyItMatters}\n\n${organization.prominenceRationale}`,
          canonicalUrl: organization.canonicalUrl,
          aliases: organization.aliases,
          divisionSlugs: organization.divisions,
          sourceRecordIds,
          score,
          expansionEdges: organization.expansionEdges,
          provenance: organization.evidenceSourceUrls.map((url) => ({
            url,
            title: `${output.groupTitle} organization ecosystem mapping`,
            observedAt: new Date(),
            confidence: 0.7,
            notes: organization.prominenceRationale,
          })),
          notes: [
            `Organization type: ${organization.organizationType ?? "unknown"}`,
            `Products/services: ${organization.productsOrServices.join(", ")}`,
            `Related people: ${organization.relatedPeople.join(", ")}`,
            `Related technologies: ${organization.relatedTechnologies.join(", ")}`,
            `Workflow: ${context.workflow.slug}`,
            `Stage: ${context.stageSlug}`,
            `Shard: ${output.groupSlug}`,
          ]
            .filter(Boolean)
            .join("\n"),
        },
        $setOnInsert: { kgStatus: "unknown" },
      },
      { upsert: true, returnDocument: "after" },
    );

    candidateIds.push(String(candidate._id));
  }

  return {
    sourceRecordCount: sourceIdsByUrl.size,
    candidateEntityCount: candidateIds.length,
    candidateIds,
    sourceRecordIds: [...sourceIdsByUrl.values()],
  };
}
