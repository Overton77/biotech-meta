import path from "node:path";

export function timestampRunId(prefix: string): string {
  return `${prefix}-${new Date().toISOString().replace(/[:.]/g, "-")}`;
}

export function workflowRunDir(artifactRoot: string, runId: string): string {
  return path.join(path.resolve(artifactRoot), runId);
}

export function stageDir(artifactRoot: string, runId: string, stageSlug: string): string {
  return path.join(workflowRunDir(artifactRoot, runId), stageSlug);
}

export function shardDir(artifactRoot: string, runId: string, stageSlug: string, shardSlug: string): string {
  return path.join(stageDir(artifactRoot, runId, stageSlug), shardSlug);
}

export function cursorStoreDir(artifactRoot: string, runId: string, stageSlug: string, shardSlug?: string): string {
  return path.join(
    path.resolve(artifactRoot),
    "cursor-agent-store",
    runId,
    stageSlug,
    shardSlug ?? "synthesis",
  );
}
