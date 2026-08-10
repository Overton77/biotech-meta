# Reusable Schema Catalog, Deployment Manifest, and Schema Workspace Materialization

## Problem Statement

Workflow agents need a compact, navigable, and reproducible view of a large Neo4j schema without treating a live database, a prompt-sized excerpt, or sandbox files as canonical schema state. The current implementation target has infrastructure clients and a sandbox probe but no reusable Schema Catalog build, no deployment attestation, and no shared materialization operation. If each workflow independently parses or copies schema content, builds drift, compatibility is guessed, graph-reading work can run against the wrong deployed schema, and workspace paths become accidental authority.

## Solution

Build a deterministic, content-addressed Schema Catalog from one exact Schema Definition, make the graph-schema deployment process issue and revoke immutable Schema Deployment Manifests, verify that modular authoring inputs cannot drift from the authoritative directive SDL, and expose one shared Schema Workspace Materialization operation at Workflow Run or stage scope. The operation validates exact references and hashes, selects governed catalog resources and optional accepted schema-selection products, mounts them read-only into a declared workspace slot, updates the Workspace Materialization Manifest, and emits an immutable Schema Workspace Binding. Schema resources remain navigation and execution context; they never grant graph access, mutation authority, or semantic truth.

## User Stories

1. As a schema maintainer, I want one deterministic catalog build for an exact Schema Definition, so that workflows reuse identical schema resources instead of rebuilding them per run.
2. As a schema maintainer, I want each build to preserve the Schema Definition identity and content hash, so that every projection can be traced to its authoritative source.
3. As a schema maintainer, I want catalog generation to fail on malformed or internally inconsistent schema input, so that invalid resources cannot be published.
4. As a schema maintainer, I want repeated builds from identical inputs and generator versions to produce the same logical digest, so that reproducibility can be verified.
5. As an agent author, I want a compact global module and topology index, so that an agent can orient itself before loading detailed schema material.
6. As an agent author, I want a Compact Schema Overview with names, descriptions, aliases, module membership, immediate topology, and compact identity and search indicators, so that selection has useful semantics without a full-schema prompt.
7. As an agent author, I want overlapping governed Schema Modules, so that agents can navigate conceptual views without mistaking them for ownership partitions.
8. As an agent author, I want node, relationship, enum, union, pattern, and drill-down resources, so that complete details are available through progressive disclosure.
9. As a retrieval service, I want lexical, alias, semantic, and topology indexes tied to one catalog build, so that high-recall candidate retrieval remains reproducible.
10. As a workflow author, I want workflow-specific selections and expanded slices to remain separate from the reusable catalog, so that run meaning does not mutate shared schema resources.
11. As a graph deployment operator, I want a Schema Deployment Manifest attesting the exact deployed SDL hash, so that graph-reading work can prove compatibility.
12. As an auditor, I want the deployment manifest to identify environment, deployment event, schema definition, deployed SDL hash, issuer, time, and manifest digest, so that the attestation is reviewable.
13. As a workflow operator, I want strict equality between the deployed SDL hash and the Schema Definition hash behind the selected catalog, so that graph work never proceeds on inferred compatibility.
14. As a workflow operator, I want a missing, revoked, or mismatched deployment manifest to fail admission before graph access, so that agents do not discover incompatibility after substantive work.
15. As a diagnostician, I want Neo4j introspection results preserved separately, so that they can explain drift without replacing the deployment attestation.
16. As a Workflow Run, I want to request schema materialization by exact catalog build reference, policy, scope, and workspace slot, so that setup is explicit and idempotent.
17. As a stage, I want to request only required modules, indexes, cards, selections, expanded slices, and operation projections, so that context and storage stay bounded.
18. As a sandbox agent, I want all materialized schema resources to be read-only, so that local edits cannot masquerade as schema revisions.
19. As a sandbox agent, I want a governed navigation skill included when authorized, so that read order and validation rules are available without granting additional capability.
20. As a workspace service, I want every materialized path mapped to its durable source and digest, so that files have explicit lineage.
21. As an auditor, I want an immutable Schema Workspace Binding containing the exact catalog, manifest, policy, selected resources, workspace identity, and resulting digest, so that operation execution is reproducible.
22. As a retrying Temporal activity, I want identical requests to converge on the same materialization result, so that infrastructure retries do not duplicate state or create divergent bindings.
23. As a workflow author, I want bounded inline schema selection and standalone Schema Context Selection Workflow outputs to use the same admitted selection contract, so that materialization is independent of how selection was produced.
24. As a reviewer, I want only accepted Schema Context Selections materialized as execution selections, so that an agent cannot self-approve semantic membership.
25. As a reviewer, I want deterministic expansion to include required endpoint, enum, union, directive, property, and relationship-property closure, so that an accepted selection is structurally complete.
26. As a workflow author, I want purpose-specific Schema Operation Projections, so that query, search, identity, ingestion, and validation views do not silently share incompatible purposes.
27. As a workflow operator, I want reuse of a selection or projection for a new purpose to require admission, so that historical context does not become universal authority.
28. As a security operator, I want graph credentials and graph capability checked independently from schema materialization, so that possessing schema files grants no access.
29. As a system operator, I want catalog build payloads stored as immutable objects with queryable metadata, so that large bundles do not overload transactional records.
30. As an implementation agent, I want invalid references, digest mismatches, slot conflicts, and unsupported catalog versions to produce typed failures, so that no fallback is invented.

## Implementation Decisions

- The Schema Definition is the versioned Neo4j GraphQL directive SDL. Live Neo4j introspection is diagnostic and cannot become the source for generated catalog identity.
- If modular schema sources are retained as authoring inputs, the schema build/deployment pipeline must deterministically generate or verify the authoritative directive SDL and fail publication or deployment on semantic or byte-level drift under the declared verification policy. There is one published Schema Definition identity, never two competing authorities.
- Schema Catalog generation is a reusable deterministic build operation. A build binds the exact Schema Definition version and hash, generator version, governed Schema Module definitions, normalization rules, generated resource manifest, object digest, and build decision.
- Catalog build identity is content-addressed over canonical source inputs and generator behavior. Generation timestamps and storage locations do not affect the logical content digest.
- The catalog contains a compact global module index, topology navigation, Compact Schema Overview, governed overlapping modules, cards, drill-down resources, query patterns, machine-readable parsed artifacts, and lexical, alias, semantic, and topology retrieval metadata.
- All generated resources retain the source Schema Definition version and hash. A projection that cannot prove this lineage is invalid.
- Module membership is governed input to deterministic generation. Agents may propose module revisions but cannot redefine canonical module membership during a run.
- Semantic Schema Context Selection remains distinct from deterministic expansion, drill-down, and materialization. Only semantic membership changes create a new selection revision.
- Agent-produced selections require deterministic structural validation and independent semantic coverage review before acceptance. The selecting agent cannot approve its own selection.
- A Schema Deployment Manifest is an immutable attestation issued by the graph-schema deployment process. It records the target graph environment, exact Schema Definition reference, deployed SDL hash, deployment identity, attesting actor or service, occurrence time, and revocation or supersession lineage.
- Manifest issuance occurs only after the deployment transaction reports success and the deployed artifact identity is verified against the exact Schema Definition content hash. The graph deployment service is the sole issuer; workflow agents, graph clients, introspection, and materialization services cannot issue or self-approve manifests.
- Issuance is idempotent for one deployment identity, environment, and deployed SDL hash. A conflicting attestation for the same deployment identity is rejected and raises an operational reconciliation condition.
- Revocation and supersession are immutable authorized records. Failed or rolled-back deployments issue no active manifest; partial failure preserves deployment evidence and leaves the previous active attestation unchanged until an authorized deployment result supersedes or revokes it.
- The compatibility invariant compares the manifest's deployed SDL hash with the source Schema Definition content hash behind the catalog. The manifest digest is not schema identity.
- Graph-reading work uses strict compatibility in the first implementation. Missing, revoked, ambiguous, or unequal manifests fail admission before any Neo4j query.
- Introspection findings may be attached to a compatibility result for diagnosis but cannot turn a failed strict comparison into success.
- Schema Workspace Materialization is one shared application operation callable at Workflow Run or stage scope. Consuming workflows configure it but do not own divergent implementations.
- Materialization input contains exact immutable references, a typed selection policy, a declared workspace slot, purpose, requested resources, and graph-access intent. Unvalidated open-ended extension maps are prohibited.
- When graph access is not requested, a deployment manifest may be omitted only if the consuming contract permits offline schema work. The resulting binding records that no live-graph compatibility was established.
- Materialized resources are read-only. Writable notes or proposed schema changes remain local candidates until promoted through their own governed process.
- The operation updates the Workspace Materialization Manifest and emits an immutable Schema Workspace Binding before dependent work begins.
- Idempotency is defined by catalog digest, deployment-manifest decision where applicable, materialization policy digest, admitted selection and projection references, workspace instance, and slot identity. A conflicting payload under the same key is rejected.
- Slot ownership follows the Workflow Workspace Contract. Materialization cannot overwrite a slot owned by another operation or silently merge incompatible catalog builds.
- Large catalog bundles and indexes reside in object storage. Queryable catalog build metadata, schema selections, expanded slices, projections, compatibility results, and workspace bindings remain in the document-shaped application store.
- Materialization and compatibility checks run as nondeterministic activities or application services, never inside deterministic Temporal Workflow code.
- Schema context, catalog descriptions, navigation skills, and retrieved elements are non-authoritative. They cannot grant graph access, authorize mutation, change workflow topology, satisfy an approval, or override a Workflow Invariant.
- The current implementation target must replace its bootstrap assumption that no application schemas exist: this capability depends on application-owned persistence and migration support while retaining a separate Temporal database.

## Testing Decisions

- The highest practical behavioral seam is the public application service or command boundary that accepts a materialization request and returns either an immutable Schema Workspace Binding or a typed rejection. Tests exercise real catalog bundle generation, persistence adapters, a temporary workspace, and a fake or test graph deployment attestation; they do not assert internal helper calls.
- A golden deterministic-build suite proves that identical normalized inputs yield identical catalog digests and resource manifests, while source, module-definition, or generator changes yield a successor build.
- Contract tests prove every generated resource carries the correct source identity and that malformed schema, unresolved references, duplicate logical elements, or inconsistent closure fail publication.
- Compatibility tests cover exact match, missing manifest, revoked manifest, wrong environment, wrong Schema Definition, hash mismatch, and diagnostic introspection that disagrees with the attestation.
- Deployment-attestation tests cover successful idempotent issuance, conflicting issuance, failed and rolled-back deployment, revocation, supersession, unauthorized issuer, and recovery while preserving the prior active manifest.
- Drift tests prove modular authoring inputs either deterministically produce the authoritative directive SDL or fail build/deployment before catalog publication and manifest issuance.
- Materialization tests verify read-only resources, bounded resource selection, manifest path lineage, slot ownership, exact binding contents, object digest verification, and cleanup after partial failure.
- Retry tests submit the same idempotency identity repeatedly and concurrently, proving one logical binding and no duplicate object or manifest effects. A conflicting request under the same identity must fail.
- Admission tests prove a graph-reading operation cannot start until strict compatibility succeeds, while an explicitly permitted offline operation records the absence of live compatibility.
- Selection tests admit both bounded-operation and standalone-workflow selections through the same contract, reject unreviewed selections, and verify deterministic expansion adds closure without new semantic membership.
- Purpose tests prove a projection admitted for query use cannot be silently reused for ingestion or graph mutation.
- Security tests prove schema files, navigation-skill text, aliases, retrieved descriptions, and workspace presence cannot grant Neo4j credentials or mutation capability.
- Prior art is the existing FastAPI boundary test, async infrastructure adapters, and sandbox-backed Temporal probe. The new suite raises the seam from individual client creation to observable materialization behavior.
- Tests avoid assertions about collection names, filesystem layout, internal class names, or exact framework calls except where a public versioned contract explicitly exposes them.

## Out of Scope

- Authoring or changing the canonical Neo4j schema.
- Redesigning the schema authoring language or its domain model; this specification still requires a deterministic generation-or-verification chain with the directive SDL as the single published Schema Definition authority.
- Defining the full Schema Context Selection Workflow.
- Canonical report or corpus segmentation.
- Graph mutation, ingestion planning, or ingestion execution.
- Dashboard implementation.
- Final schema MCP tool shapes and cost limits.
- Embedding model, vector dimension, and retrieval-weight tuning.
- Replacing deployment attestation with live introspection.

## Further Notes

- Dependency order: this is the first control-plane capability specification, but it depends on all four control-plane foundation specifications for immutable configuration, admission authority, activity orchestration, workspace ownership, artifact/object handling, and idempotent runtime execution. It does not depend on the other three capability specifications. Conversation, memory, and catalog operations may later consume a Schema Workspace Binding but cannot substitute for it.
- The capability depends on application PostgreSQL, MongoDB/Beanie, object storage, Temporal activity infrastructure, sandbox workspace support, the graph-schema deployment process, and the authoritative Schema Definition being available to the implementation target.
- The accepted synthesis governs persistence: document-shaped build and binding records belong in MongoDB/Beanie, large bundles in object storage, and transactional run admission or command effects in PostgreSQL where applicable.
- A later implementation slice should prove one reusable build, one strict deployment check, one read-only materialization, one durable binding, and one dependent graph-reading admission decision end to end.
