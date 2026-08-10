# Governed Agentic Capability Catalogs and Exact Bindings

## Problem Statement

Prompts, Agent Skills, MCP servers and tools, and plugin packages are privileged runtime inputs, but the implementation target currently hard-codes one agent, prompt, model, sandbox manifest, and runtime plugin. Public registry metadata, local files, installed packages, and deployment availability can easily be mistaken for reviewed capability or runtime authority. Without separate durable catalogs and a governed intake path, production operations may silently resolve mutable aliases, expose unprobed tools, install untrusted code, or become impossible to replay and evaluate.

## Solution

Build separate PostgreSQL-authoritative catalogs for Prompt Definitions, Agent Skill Definitions, MCP Server Definitions and observed MCP Tool revisions, Plugin Package revisions and installations, labels, availability, evaluations, source snapshots, and promotion decisions. Ingest external or repository sources through immutable provenance snapshots, normalization, quarantine, static inspection, disposable least-privilege probes, evaluation, and authorized promotion. Search only the governed internal catalog using exact, lexical, vector, and structured retrieval; apply hard authority and trust gates before ranking or model presentation. Record every selection as an immutable Capability Selection Decision, freeze exact revisions and digests into Effective Run Configuration, and record actual prompt, skill, server, tool, plugin, materialization, and authority details in Operation Execution Binding. Catalog content and model selection remain non-authoritative.

## User Stories

1. As a workflow author, I want prompts, Agent Skills, MCP servers, MCP tools, and plugin packages represented as separate versioned asset families, so that their different lifecycles are explicit.
2. As a catalog owner, I want stable logical identities and immutable revisions, so that changes never rewrite assets used by prior runs.
3. As a catalog owner, I want mutable aliases and environment labels resolved to exact revisions before run admission, so that convenient authoring does not weaken replay.
4. As an auditor, I want every revision to preserve content digest, source provenance, authorship, review, compatibility, license, sensitivity, and lifecycle state, so that selection is explainable.
5. As a prompt author, I want Prompt Definitions to declare format, variables, trust classification, rendering policy, and evaluation references, so that runtime compilation is controlled.
6. As an auditor, I want rendered prompt digests and redacted variable provenance recorded, so that actual model instructions can be traced without exposing secrets.
7. As a skill maintainer, I want each Agent Skill revision to preserve its complete file manifest, Skill metadata, source revision, bundle digest, inspection results, dependencies, and capability requirements, so that executable and instructional content is reviewable.
8. As a sandbox agent, I want an authorized skill materialized by exact digest into a read-only location, so that mutable local installations cannot alter the operation.
9. As an MCP owner, I want each MCP Server revision to declare transport, connection recipe, secret references, network class, timeout, approval, and exposure policy, so that connection behavior is governed.
10. As a security operator, I want raw secret values excluded from catalog records, effective configurations, prompts, and bindings, so that catalog reachability does not reveal credentials.
11. As an MCP consumer, I want tool inventory derived from an isolated protocol probe, so that registry descriptions cannot invent production tools.
12. As an auditor, I want each MCP Tool revision tied to one exact server revision with observed input and output schemas, annotations, schema digest, observation time, and probe binding, so that exposed tools are reproducible.
13. As a plugin operator, I want Plugin Package revisions separated from Plugin Installations and effective component bindings, so that packaged, installed, and authorized are not conflated.
14. As a security operator, I want every bundled prompt, skill, MCP definition, hook, app, executable, and asset independently classified and authorized, so that package inclusion grants no blanket capability.
15. As a source operator, I want catalog sources and sync cursors recorded, so that imports are incremental, attributable, and retry-safe.
16. As an auditor, I want every external import to create an immutable raw snapshot before normalization, so that later source changes do not erase evidence.
17. As a security reviewer, I want new or changed assets quarantined by default, so that discovery never makes them production-usable.
18. As a security reviewer, I want static inspection of manifests, files, scripts, dependencies, licenses, secret patterns, and declared capabilities, so that obvious risks are identified before execution.
19. As a security reviewer, I want Skill evaluation and MCP probing run in disposable least-privilege sandboxes with controlled egress and synthetic or scoped credentials, so that intake cannot attack internal systems.
20. As an evaluator, I want compatibility, correctness, safety, health, schema stability, and task-quality results recorded separately, so that promotion does not rely on one opaque score.
21. As an authorized promoter, I want promotion decisions to identify exact evidence, policy, scope, environment, and permitted use, so that active status is auditable.
22. As an operator, I want revocation and deprecation to block future use without rewriting historical bindings, so that incidents can be contained while preserving evidence.
23. As a workflow author, I want a Capability Requirement to name an exact revision, stable alias, or governed search query plus required capability and attachment target, so that authoring is convenient and bounded.
24. As a workflow author, I want each requirement classified required, degradable, optional, or advisory with explicit missing, ambiguity, substitution, and fallback behavior, so that run admission is deterministic.
25. As an operator, I want explicit requirements to take precedence over model-proposed discovery, so that the model cannot replace a named capability silently.
26. As an agent, I want hybrid internal-catalog search over exact names, aliases, descriptions, tags, files, schemas, capabilities, and evaluations, so that relevant managed assets are discoverable.
27. As a security operator, I want Workflow Type allowlists, caller authority, Delegation Ceiling, promotion, source, compatibility, license, freshness, health, network, secret, filesystem, data-classification, and approval gates applied before ranking, so that forbidden assets never reach the model.
28. As an agent, I want only a small policy-bounded candidate set presented for judgment, so that descriptions cannot broaden the search or grant authority.
29. As an auditor, I want each Capability Selection Decision to preserve request, policy, hard-gate exclusions, candidates, component scores, selected exact revisions, ambiguity, fallback, and deciding actor, so that selection is reproducible.
30. As a workflow operator, I want publication to validate every required requirement to exactly one usable revision, so that production does not discover unresolved dependencies mid-operation.
31. As a workflow operator, I want missing or ambiguous capabilities to fail, degrade, or be omitted exactly as authored, so that similarly named assets are never silently substituted.
32. As an operation, I want the Effective Run Configuration to freeze exact asset revisions, content digests, attachment plans, and authority ceilings, so that later alias moves do not alter execution.
33. As an operation, I want an Operation Execution Binding to record what was actually rendered, mounted, connected, filtered, exposed, read, and executed, so that planned and actual use are distinguishable.
34. As a security operator, I want MCP tool exposure to be the intersection of server policy, operation allowlist, caller authority, Delegation Ceiling, approval policy, and current revocation state, so that connection does not expose all tools.
35. As a runtime operator, I want unsupported policy mappings to fail or record an explicitly approved degradation, so that adapters never silently ignore controls.
36. As a model evaluator, I want traces and outcomes joinable to exact prompt, skill, MCP tool, plugin, model, and selection revisions, so that capability effectiveness can be measured.
37. As a workflow author, I want external registry lookup limited to authoring, publication, deployment preparation, or explicitly allowed preflight, so that production operations cannot auto-install from the public web.
38. As a security operator, I want catalog descriptions, Skill instructions, MCP metadata, plugin manifests, and prompt text treated as untrusted data, so that supply-chain content cannot authorize itself.
39. As a coordinator, I want read-only governed catalog search through application tools, so that discovery is possible without catalog mutation authority.
40. As an implementation agent, I want digest conflicts, probe drift, alias ambiguity, policy failures, revoked dependencies, and component collisions to produce typed outcomes, so that fallback is never improvised.

## Implementation Decisions

- The system maintains separate versioned families for Prompt Definition revisions, Agent Skill Definition revisions, MCP Server Definition revisions, MCP Tool Definition revisions, Agent Profile revisions, Plugin Package revisions, and Plugin Installations.
- PostgreSQL is the transactional authority for catalog logical identities, revisions and searchable projections, labels, availability, source snapshots and sync cursors, evaluations, promotion decisions, tool inventories, selection decisions, and authorization-relevant state.
- Object storage owns large immutable Skill bundles, plugin packages, raw source snapshots, evaluation artifacts, and archived prompt attachments. PostgreSQL stores exact digests and durable references.
- Agent Profiles and Effective Run Configurations may reference catalog assets, but catalog presence, active status, installation, or deployment availability never grants capability.
- Logical asset identity is stable; immutable revisions carry canonical content digests. Mutable labels and aliases point to exact revisions under optimistic concurrency and audit.
- Workflow publication and Effective Run Configuration compilation resolve every floating alias to an exact immutable revision. Run admission accepts only pinned revisions and verifies digest, usability, authority, compatibility, promotion, and current revocation state. Label movement affects only future compilation and never rewrites a running or historical Effective Run Configuration.
- Prompt revisions declare instruction format, template variables and types, trust classes, rendering rules, attachments, evaluation references, and content digest. Rendering uses only authorized typed state.
- Prompt compilation records source revision, compiler version, segment trust classes, variable keys and redacted values or hashes, truncation decisions, and rendered digest.
- Agent Skill revisions use the Agent Skills folder model and preserve the complete normalized file manifest, source commit or revision, bundle digest, metadata, body, dependencies, inspections, compatibility, and required capabilities.
- Skill-declared allowed tools and capability requirements are metadata, not grants. Effective authority comes from validated application policy.
- MCP Server revisions are recipes and exposure policies, not live connections. They record transport, endpoint or command template, secret references, connection policy, timeouts, retries, approvals, health policy, network class, and declared tool-filter ceiling.
- MCP tool inventory is accepted only from an isolated protocol handshake and tools-list probe bound to the exact server revision. Registry prose alone cannot create a tool revision.
- Each MCP Tool revision records exact server revision, name, description, input and output schemas, annotations, schema digest, observation time, probe environment and result, and compatibility state.
- Plugin Package revision, Plugin Installation, and effective component binding are distinct. Installing a package makes a revision available in a scope; it enables no component automatically.
- Every plugin component receives a qualified identity and independent kind, provenance, digest, compatibility, execution class, inspection, evaluation, authority, and approval decision. Name collisions resolve deterministically by qualified identity or fail.
- External sources include approved registries, approved repositories, direct operator imports, and authorized discovery tools. Every source adapter creates an immutable raw snapshot and provenance record before normalization.
- Intake follows immutable snapshot, normalization, quarantine, static inspection, isolated probe or bundle evaluation, evaluation, authorized promotion, and searchable active catalog. No step is skipped because an asset is popular or officially listed.
- Quarantine is the default for new or changed external assets. Quarantined assets cannot be selected for production operation execution.
- Static inspection and active probes execute with least privilege, SSRF-resistant egress, blocked internal metadata endpoints, bounded resources, no ambient credentials, and synthetic or narrowly scoped test credentials.
- Promotion is an immutable decision over an exact revision and evaluation set. It declares allowed environment, tenant or system scope, purpose classes, conditions, expiry or review triggers, and deciding authority.
- Revocation may prevent future operations from using a pinned component. An already running operation receives a typed policy intervention, stop, degrade, or approval decision; the runtime never silently substitutes another revision.
- Internal catalog search combines exact and alias lookup, keyword and full-text retrieval, vector similarity, and structured filters. PostgreSQL executes tenant, authorization, promotion, compatibility, source, status, freshness, sensitivity, and capability filters before ranking.
- Capability Requirements support exact revision, stable logical name or alias, or a governed internal search query. Each declares asset kind, required capabilities, source and trust constraints, attachment target, requirement class, and explicit failure policy.
- External lookup is not part of production operation selection. It may occur during authoring, publication, deployment preparation, or an explicitly authorized preflight that produces quarantined candidates for later evaluation and promotion.
- Explicit requirements outrank model proposals. A model sees only candidates surviving deterministic hard gates and cannot name, install, connect, promote, or authorize an excluded asset.
- Capability Selection Decision is immutable and records requirement, context, policy revisions, hard-gate exclusions, candidate revisions and component scores, model input candidate set where used, selected exact revisions, ambiguity, fallback or degradation, deciding actor, and digest.
- Publication requires every required capability requirement to resolve to exactly one usable revision, and compilation freezes that resolution. Run admission revalidates the pinned result without performing alias or search resolution. Degradable, optional, and advisory requirements follow their authored behavior; silent substitution is prohibited.
- The Effective Run Configuration freezes exact assets, digests, plugin component lineage, materialization plans, MCP tool ceilings, secret references without values, approval requirements, compatibility decisions, and selection decision references.
- Operation Execution Binding records actual prompt render, Skill bundle and materialization, Skill files read or executed where observable, MCP server and tool schema revisions, exposed tool set, plugin components, model, runtime, workspace, authority, approvals, and configuration revisions.
- MCP runtime exposure is the intersection of catalog server ceiling, exact probed tool inventory, Workflow Type contract, Effective Run Configuration, operation policy, caller authority, Delegation Ceiling, permissions, approval state, and current revocation policy.
- Runtime adapters verify content and schema digests before use. Unsupported enforcement mappings fail compilation or produce an explicit policy-approved degraded decision.
- Catalog descriptions, prompts, Skill files, MCP schemas, probe responses, plugin manifests, and model selections are non-authoritative. They cannot grant capability, change workflow topology, approve themselves, or mutate catalog state.
- Synchronization, inspection, probing, evaluation, promotion, materialization, connection, and health checks execute as application services or nondeterministic Temporal activities, never deterministic Workflow code.
- Row-level security is mandatory defense in depth. Catalog write APIs are separated from read and selection APIs; coordinator-facing catalog tools are read-only unless a distinct authorized proposal command is explicitly defined.

## Testing Decisions

- The highest practical behavioral seam is an end-to-end capability-resolution operation invoked through the application API: import a source snapshot, quarantine and inspect it, probe or evaluate it, promote it, search the internal catalog, compile a Capability Selection Decision, prepare an operation, and persist the Operation Execution Binding. Tests use a transactional PostgreSQL database, object-storage test adapter, disposable sandbox, and controlled fake MCP server.
- Revision tests prove immutable prior versions, audited alias movement, exact resolution during publication/compilation, admission of pinned bindings only, and unchanged historical execution after aliases move.
- Prompt tests cover typed variables, unauthorized variable sources, trust labeling, deterministic rendering, redacted secret handling, content digest verification, and exact rendered-binding audit.
- Skill tests cover complete file manifests, path traversal, symlink or archive escape, modified bundle bytes, undeclared executables, dependency findings, read-only materialization, and declared tools that exceed effective authority.
- MCP tests probe actual tool inventory, schema changes, duplicate tool names, malformed schemas, unhealthy servers, timeout behavior, tool-filter intersections, approval requirements, and rejection of registry-only inventory.
- Plugin tests prove package installation grants no component, qualified identities handle collisions, unknown files remain inert, each executable class is independently authorized, and package mutation fails digest verification.
- Quarantine tests prove newly discovered and changed revisions cannot appear in production selection until an authorized promotion decision exists.
- Sandbox security tests probe SSRF attempts, internal address access, ambient credential access, filesystem escape, excessive resources, and network requests outside the egress policy.
- Hybrid-search tests cover exact names, aliases, full text, vectors, structured filters, ranking fusion, ambiguity, stale health, license and compatibility constraints, and hard-gate exclusion before model presentation.
- Selection tests prove deterministic requirements take precedence, required ambiguity fails, authored degradations are explicit, optional omissions are recorded, and similarly named assets are never silently substituted.
- Binding tests compare Effective Run Configuration plans with actual prompt, Skill, MCP tool, plugin, workspace, approval, and model use. Unexpected runtime assets or unprobed tool schemas fail preparation.
- Revocation tests cover future admission denial and recorded intervention for pinned active work without silent version replacement.
- Retry and synchronization tests prove source cursors, raw snapshots, probes, promotions, selections, bundle writes, and bindings are idempotent under duplicate or concurrent delivery.
- Adversarial tests place self-authorizing instructions in prompts, Skills, MCP descriptions, schemas, plugin manifests, and registry metadata and prove capability exposure remains unchanged.
- Evaluation-join tests prove operation outcomes and traces can be queried by exact asset, selection, model, and binding revisions without depending on mutable labels.
- Prior art is the current sandbox-backed OpenAI Agents SDK Temporal probe. The new suite extends that vertical seam from one hard-coded runtime configuration to one governed, exact, replayable capability path.
- Tests avoid assertions about SQL table names, internal resolver classes, exact search weights, SDK object constructors, or sandbox directory layout.

## Out of Scope

- A public end-user capability marketplace.
- Automatic production installation from public registries or arbitrary repositories.
- Letting prompts, Skill metadata, MCP descriptions, or plugin manifests grant authority.
- Storing secret values in catalog records or bindings.
- Choosing final embedding models, dimensions, ranking weights, or evaluation thresholds.
- Full catalog administration dashboard.
- Making external prompt platforms, hosted Skill services, registries, or plugin marketplaces authoritative.
- Defining every future plugin component type.
- General software package vulnerability management beyond capability intake requirements.
- Automatically promoting procedural memory into active capabilities.

## Further Notes

- Dependency order: this specification depends on the immutable-definition/compiler and transactional-admission foundations plus the operation-runtime/workspace foundation. To break the bootstrap cycle, the initial operation-runtime tracer bullet uses pre-provisioned exact fixture bindings; this specification then replaces those fixtures with governed catalog selection without changing the Operation Execution Binding contract. The canonical conversation specification is needed only for conversational catalog discovery and promotion proposals, not for core CI or operator intake.
- Mission memory may supply advisory retrieval context during capability selection only when its Memory Policy permits it; memory cannot bypass catalog hard gates or promotion.
- Schema navigation Agent Skills and schema MCP servers produced for the schema capability must enter these catalogs through the same revision, evaluation, promotion, selection, and exact-binding path.
- The implementation target's hard-coded sandbox probe is the migration fixture: its prompt, sandbox capability, runtime plugin, model, and binding should become exact governed assets without changing the probe's externally visible success condition.
