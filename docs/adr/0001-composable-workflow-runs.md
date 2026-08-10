# ADR 0001: Use Composable Workflow Runs

## Status

Accepted

## Context

Human Upgrade research, ingestion, content creation, and evaluation cannot be modeled as one rigid pipeline. A full Research Mission may run the complete sequence from Starter Content through evaluation, but operators also need to run specific mini-workflows independently from the dashboard or API.

Examples:

- refine messy starter content without starting full research
- map official sources for one organization
- build a source corpus from selected PDFs
- ingest a completed report
- evaluate already-published content
- repair provenance for prior graph records

The system also needs durable decision reports, source cache records, sandbox metadata, approval gates, and learning-loop feedback at workflow and sub-workflow levels.

## Decision

Use **Workflow Type** and **Workflow Run** as first-class domain concepts.

A **Workflow Type** defines schema, control configuration, execution rules, outputs, decision reports, and evaluation expectations.

A **Workflow Run** is one execution of a Workflow Type. It may be part of a Research Mission or may run independently from a dashboard/API action.

A **Research Mission** remains the central orchestration unit for deep research, but it composes Workflow Runs rather than owning all possible workflow execution.

## Consequences

Positive:

- workflows can be reused inside and outside full Research Missions
- dashboard actions remain traceable
- ingestion can happen after research or from a completed report
- evaluation and repair can run after publication
- control configuration can vary by trust level, budget, and risk
- decision reports can support recursive system improvement

Negative:

- schema design becomes more important
- workflow identity, parent attachment, and artifact lineage must be modeled carefully
- the dashboard must explain independent runs versus mission-owned runs
- evaluation must handle partial workflows, not only full missions

## Notes

The first accepted Workflow Types are:

- `StarterContentRefinementWorkflow`
- `MissionInstructionWorkflow`
- `EntitySeedExtractionWorkflow`
- `OfficialSourceMappingWorkflow`
- `SourceDiscoveryWorkflow`
- `SourceCorpusBuildWorkflow`
- `ResearchExecutionWorkflow`
- `EvidenceAdjudicationWorkflow`
- `ReportCreationWorkflow`
- `IngestionPlanWorkflow`
- `IngestionExecutionWorkflow`
- `ContentCreationWorkflow`
- `EvaluationWorkflow`

# We will surely add to this the Verification / Deterministic Validator Workflows.
