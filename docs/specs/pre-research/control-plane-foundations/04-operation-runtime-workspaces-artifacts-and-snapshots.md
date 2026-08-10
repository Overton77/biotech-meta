## Problem Statement

Durable blueprint orchestration needs a safe way to execute one semantic operation through concrete agent, tool, MCP, and sandbox providers. The current target contains a direct bootstrap workflow that constructs an OpenAI sandbox agent and Docker manifest inside Temporal workflow code. That probe proves connectivity but does not provide the accepted production boundary: it has no compiled operation binding, authority intersection, workspace ownership model, artifact-promotion transaction, delegation ceiling, or immutable clone-on-restore snapshot semantics.

Without a provider-neutral operation runtime layer, SDK defaults and process environment could become hidden configuration, Temporal retries could duplicate semantic work, agents could delegate beyond their authority, parallel writers could corrupt shared files, workspace-local outputs could be mistaken for durable artifacts, and restoring a snapshot could accidentally restore stale credentials or mutate an old workspace in place.

## Solution

Introduce an operation execution application service and provider-neutral runtime adapters. Before any semantic side effect, the service resolves one operation against the exact Effective Run Configuration, accepted control revision, budget reservation, capability selection, and workspace contract, then persists an immutable Operation Execution Binding in MongoDB/Beanie. The binding records exactly what may and did execute: prompt and instruction revisions, model policy, tools, MCP servers and filters, skills and plugin assets, agent/delegation definitions, workspace and snapshot lineage, runtime/image/package digests, authority, secrets references, budgets, tracing policy, and configuration revisions.

Implement an OpenAI Agents runtime adapter behind the provider-neutral contract. It maps validated bindings to current SDK primitives, translates SDK events into project event envelopes, and rejects unsupported policy mappings rather than silently dropping them. SDK sessions remain runtime context projections, not canonical Workflow Run or Conversation state.

Provision isolated Sandbox Workspaces inside a logical Run Workspace Namespace. Shared inputs and governed assets are read-only; every writable slot has one owner; delegates receive child namespaces and only explicit read mounts. Files become durable only through typed artifact promotion into object storage plus immutable metadata and Workspace Materialization Manifest updates.

Support operation-local `handoff` and `task_subagent` delegation under a strict Delegation Ceiling. Work with an independent lifecycle, reusable output, materially distinct authority or budget, or a recognized Workflow Type boundary uses specification 3 linked-run requests instead.

Sandbox Snapshots are immutable resumable state. Restoring always clones into a new workspace with explicit lineage, re-resolves all credentials and external leases, verifies environment compatibility, and never mutates or resumes the original workspace in place.

## User Stories

1. As an orchestrator, I want to request a semantic operation through one application service, so that provider SDKs are not invoked directly.
2. As an auditor, I want an immutable Operation Execution Binding persisted before side effects, so that intended execution is known even if the provider fails.
3. As an auditor, I want the binding tied to the exact Effective Run Configuration and accepted Run Control Revision, so that historical execution cannot be explained by current defaults.
4. As an operator, I want operation attempts distinct from Temporal activity attempts, so that retries do not create duplicate semantic executions.
5. As a runtime adapter, I want a fully resolved binding, typed input, materialized workspace, and budget reservation, so that I do not query mutable catalogs.
6. As a security operator, I want unsupported runtime policy mappings rejected or explicitly degraded by authored policy, so that controls are never silently ignored.
7. As an agent operator, I want the OpenAI Agents SDK behind a project-owned adapter, so that SDK types and beta sandbox APIs do not become domain contracts.
8. As an auditor, I want exact prompt template, rendered prompt digest, dynamic instructions, model, effort, fallback, tools, MCP servers, skills, and plugin components recorded, so that the operation is reproducible and reviewable.
9. As a security operator, I want every prompt segment trust-classified, so that retrieved or starter content cannot masquerade as system authority.
10. As a security operator, I want dynamic instructions to describe only already resolved capabilities, so that text cannot grant tools, credentials, filesystem access, or budget.
11. As an operator, I want secrets resolved just in time from references, so that values never enter compiled configuration, Temporal history, bindings, prompts, traces, snapshots, or manifests.
12. As an MCP operator, I want exact server revisions, transports, tool filters, timeouts, retries, approvals, and schema digests bound, so that a mutable server inventory cannot change an operation.
13. As a skill operator, I want exact immutable skill bundle and file-manifest digests materialized read-only, so that a changed local folder cannot alter execution.
14. As an agent operator, I want SDK sessions treated as replaceable context projections, so that compaction or restart does not rewrite canonical Conversation or Workflow Run state.
15. As an event consumer, I want SDK lifecycle, tool, handoff, subagent, usage, and stream events translated into project envelopes, so that consumers are not coupled to SDK event classes.
16. As a client, I want accepted final messages and operation results durable before acknowledgement, so that reconnect does not lose authoritative output.
17. As a client, I want token deltas allowed to remain ephemeral, so that fine-grained streaming does not become a correctness dependency.
18. As an agent, I want to hand off active turn ownership to a validated agent inside the same operation, so that specialization can occur without creating a hidden Workflow Run.
19. As an agent, I want to run a bounded task subagent and receive its result, so that specialist work can return to the delegator.
20. As a security operator, I want both delegation modes capped by the operation’s Delegation Ceiling, budget, depth, concurrency, tools, data, and workspace policy, so that dynamic authorship cannot escalate.
21. As an auditor, I want every Dynamic Agent Definition and delegation result recorded immutably, so that novel runtime roles are not invisible.
22. As a workflow owner, I want delegation rejected when proposed work crosses a recognized Workflow Type boundary, so that SDK handoffs and agents-as-tools cannot become hidden durable schedulers.
23. As an agent, I want substantial independent work routed to `request_workflow_run`, so that it receives its own admission, lifecycle, budget, and reusable output contract.
24. As a run operator, I want a logical Run Workspace Namespace containing multiple Sandbox Workspaces, so that one run is not forced into one shared filesystem.
25. As a workflow author, I want logical workspace slots compiled from a versioned Workspace Template and Workflow Workspace Contract, so that host paths do not define domain identity.
26. As a parallel branch, I want exclusive writable locations, so that another branch cannot race my files.
27. As a delegate, I want a child-private workspace and only explicit inherited read mounts, so that I cannot observe or alter unrelated branch state.
28. As an operation, I want immutable inputs, schema resources, skills, plugins, and memory packs mounted read-only, so that execution cannot rewrite its governing inputs.
29. As an auditor, I want a Workspace Materialization Manifest to map every governed path to durable input, local candidate, promoted artifact, or stale/superseded materialization, so that filesystem lineage is explicit.
30. As a security operator, I want unmapped files to remain workspace-local, so that merely creating a file cannot make it a domain artifact.
31. As an artifact producer, I want to propose selected workspace files for promotion, so that candidates can be validated before durability.
32. As an artifact consumer, I want promoted files content-addressed with media type, size, producer binding, provenance, and object-store reference, so that later runs use exact immutable payloads.
33. As a workflow owner, I want artifact promotion to validate the declared output slot, permissions, required checks, and accepted operation binding, so that arbitrary files cannot satisfy obligations.
34. As an operator, I want promotion idempotent for the same operation, slot, content digest, and candidate identity, so that activity retry does not duplicate artifacts.
35. As an operator, I want cross-stage and cross-run exchange to use promoted artifacts or typed messages, so that shared paths do not become hidden APIs.
36. As a run operator, I want policy-controlled sandbox retention, so that successful ephemeral work can be destroyed while selected failures or cycles remain inspectable.
37. As an operator, I want an immutable Sandbox Snapshot for reproducibility, debugging, resumption, or audit, so that execution state can be preserved without becoming a domain artifact.
38. As an auditor, I want snapshot metadata to include parent workspace/snapshot, provider identity, filesystem digest, runtime/image/package/environment digests, creation reason, producer binding, capability shape, and retention policy, so that lineage and compatibility are explicit.
39. As an operator, I want restoring a snapshot to always create a new workspace identity, so that the old workspace and snapshot remain immutable.
40. As a security operator, I want secrets, expiring credentials, live MCP connections, sockets, and leases excluded from restored authority, so that stale access cannot be revived.
41. As a runtime operator, I want restored credentials and external connections re-resolved and revalidated against the current accepted operation, so that the clone cannot exceed current authority.
42. As an operator, I want a restore rejected on incompatible or digest-mismatched runtime state unless an authored migration policy explicitly permits a new semantic operation, so that resumption is not silently altered.
43. As an auditor, I want snapshot clone and rollback lineage separate from artifact and workflow lineage, so that a snapshot is not mistaken for a Starter Package, output, SDK session, or graph version.
44. As a budget owner, I want operation usage reconciled through PostgreSQL budget services, so that MongoDB execution details cannot independently charge or enlarge budgets.
45. As a graph owner, I want operation adapters prohibited from treating Neo4j access as implicit mutation authority, so that only admitted governed ingestion operations can write canonical knowledge.
46. As a maintainer, I want the existing direct sandbox probe replaced or retained only as bootstrap diagnostics, so that production execution cannot bypass bindings and adapters.

## Implementation Decisions

- Define provider-neutral operation, agent-runtime, sandbox-runtime, MCP-runtime, secret-resolution, event-translation, artifact-promotion, and snapshot interfaces. Domain and application contracts must not expose OpenAI Agents SDK, Docker, or provider-specific sandbox types.
- The orchestrator schedules an operation activity with stable semantic identity. The activity invokes the operation execution application service, which verifies the accepted run/configuration/control revision, obtains an authoritative PostgreSQL budget reservation, resolves exact capabilities, materializes a workspace, creates the immutable binding, and then calls the runtime adapter.
- Persist Operation Execution Bindings and detailed agent/delegation execution records in MongoDB/Beanie. The binding is immutable and uses a stable logical operation-attempt identity plus exact configuration, asset, authority, workspace, and digest references.
- Persist a binding before external side effects. If preparation fails before a provider invocation, preserve the failed preparation result against that binding. Temporal retry reuses the same binding and side-effect idempotency keys unless the orchestrator authorizes a new semantic operation attempt.
- The binding records exact prompt and instruction source revisions, rendered digests and trust classes; model/provider/effort/fallback; tools and approval rules; MCP server/tool revisions and filters; skills and plugin/package revisions; agent profile or Dynamic Agent Definition; delegation policy; workspace/snapshot lineage; runtime/image/package digests; tracing and sensitive-data policy; budget reservation; authority and capability grants; Effective Run Configuration and control revision; and actual resolved use.
- The OpenAI Agents runtime adapter maps bindings to Agents SDK agents, dynamic instructions, handoffs, agents-as-tools where used for bounded task subagents, sessions, input-history shaping, Runner execution/streaming, hooks, tool approvals, structured output, guardrails, tracing, MCP connections, and sandbox integration.
- SDK sessions and serializable run state are runtime context. Canonical Conversations, Threads, messages, Workflow Run lifecycle, approvals, and outputs remain application-owned records. Session restart, compaction, or replacement does not mutate those records.
- SDK hooks and middleware may observe execution and request typed application actions. They cannot write domain stores, grant capabilities, accept completion, alter budgets, or create linked runs directly.
- If the SDK’s Temporal durable-agent integration is used inside an operation, it remains subordinate to the application operation boundary and must reject nested scheduling that would create an unrecorded workflow engine.
- Support exactly two operation-local Agent Delegation modes initially: `handoff` transfers active turn ownership; `task_subagent` executes a bounded specialist task and returns its result. Both remain within one operation attempt.
- Delegation validation intersects the operation grant, parent agent grant, Delegation Ceiling, actor/data permissions, tool and MCP allowlists, model policy, budget, concurrency, depth, workspace mounts, and environment availability. Missing authority fails or follows an explicitly authored degradation path.
- Each delegate receives a child-private workspace namespace and explicitly listed read-only mounts. No delegate inherits credentials, environment variables, tools, network access, or writable paths merely because the delegating process has them.
- Work requiring an independent lifecycle, substantial separate budget, reusable output, different authority, durable waits/cycles, or a recognized Workflow Type contract is rejected as operation-local delegation and routed through the linked-run request contract from specification 3.
- Compile logical workspace slots from the exact Workspace Template and Workflow Workspace Contract. A Run Workspace Namespace can contain operation-, stage-, cycle-, iteration-, evaluator-, agent-, and subagent-owned Sandbox Workspaces.
- Shared durable inputs, exact skills/plugins, schema resources, and mission memory packs are mounted read-only. Every writable slot has one owner. Network egress, environment access, package installation, shell, browser, code execution, and external APIs are explicit capabilities.
- The Workspace Materialization Manifest is an immutable/versioned mapping between logical governed paths and durable references or local candidate identities. Host paths are runtime details and never portable domain identifiers.
- Artifact promotion is the only path from workspace-local candidates to durable output. It validates slot ownership, candidate identity and digest, media metadata, permissions, malware/content checks where declared, producer binding, output contract, and promotion authority.
- Object storage owns promoted file payloads. MongoDB owns immutable workflow-shaped artifact metadata and Workspace Materialization Manifest versions unless a workflow-specific specification assigns a PostgreSQL transactional record. PostgreSQL stores lifecycle/outbox/budget effects and exact durable references needed by its transactions.
- Promotion uses a deterministic idempotency identity derived from run, semantic operation attempt, declared output slot, candidate identity, and content digest. Exact retry returns the existing promoted artifact; a conflicting digest under the same identity is rejected.
- Promotion progresses through typed `candidate`, `payload_staged`, `metadata_committed`, `admitted`, `rejected`, and `reconciliation_required` states. Only `admitted` is publicly consumable or eligible to satisfy an obligation.
- The authoritative visibility predicate is an immutable admitted artifact-metadata revision whose content digest matches the verified object payload and whose current Workspace Materialization Manifest revision maps the declared output slot to that artifact. PostgreSQL events and projections reference this admitted revision; an object-store write or metadata row alone is never visibility.
- The promotion service stages the content-addressed payload, commits immutable metadata and manifest linkage idempotently, validates the complete predicate, then emits the accepted durable reference through the control-plane transaction/outbox boundary. Failure before admission leaves no public artifact. Orphaned payloads or incomplete metadata enter reconciliation and may be safely completed or garbage-collected under retention policy; they are never inferred as admitted by consumers.
- Cross-workspace exchange uses promoted immutable artifact references or typed durable messages. No uncontrolled shared writable directory or implicit folder synchronization is permitted.
- Sandbox retention supports authored policies equivalent to ephemeral, snapshot on declared conditions, snapshot each semantic cycle/iteration, or retained until an explicit time. Exact defaults are deferred.
- A Sandbox Snapshot is immutable metadata plus a content-addressed payload. MongoDB/Beanie owns snapshot metadata; object storage owns the filesystem or provider snapshot payload.
- Snapshot metadata records source workspace, optional parent snapshot, provider and snapshot identity, filesystem/content manifest and digest, runtime/image/package/environment digests, creation reason, producer binding, capability shape without secret values, and retention/deletion policy.
- Restore always clones into a new Sandbox Workspace and creates explicit parent-workspace and parent-snapshot lineage. The source workspace and snapshot are never mutated or resumed in place.
- Restore revalidates the requested operation binding, current accepted authority, runtime compatibility, payload digest, mounts, and retention. It re-resolves secrets, credentials, MCP connections, sockets, and external leases just in time and never treats snapshot contents as an authority grant.
- A snapshot is not a Workflow Run record, domain artifact, Starter Package, SDK session, Effective Run Configuration, or graph version. Durable outputs still require artifact promotion after clone/restore.
- Usage and external charges are reported idempotently to the PostgreSQL budget service from specification 2. MongoDB execution records preserve detailed evidence but cannot authoritatively reserve, charge, release, or enlarge budget.
- Runtime adapters may read or query Neo4j only when the binding contains admitted exact graph capability and compatibility context. Graph mutation is prohibited except for a governed ingestion operation whose Workflow Type and approvals explicitly grant it.
- Replace the bootstrap sandbox probe as a production path. It may remain a smoke diagnostic only if clearly isolated from application commands and unable to produce domain state.
- The first runtime tracer bullet may consume pre-provisioned exact prompt, skill, MCP/tool, model, and sandbox fixture bindings to avoid a circular dependency on the governed capability-catalog specification. Those fixtures are immutable and digest-verified; they cannot resolve aliases or discover capabilities. The later catalog capability replaces fixture provisioning without changing this runtime contract.
- Dependency note: this specification depends on specifications 1 through 3 for compiled bindings, admission/lifecycle/budgets, and durable operation scheduling. It completes the dependency chain for the foundational tracer bullet.

## Testing Decisions

- Test external behavior primarily through the operation execution application service invoked as a real Temporal activity from a test workflow. Use a conformance fake runtime/sandbox at the provider boundary and separate contract tests against the real OpenAI Agents and Docker adapters.
- Observe public operation results, immutable bindings, translated events, budget reconciliation, workspace manifests, promoted artifacts, and snapshot lineage. Do not assert SDK constructor calls or private adapter methods.
- Prove no runtime invocation occurs until a valid immutable binding and authoritative budget reservation exist.
- Retry the same Temporal activity and prove it reuses the semantic operation attempt and binding, does not duplicate provider-side idempotent effects, budget charges, events, or promoted artifacts.
- Start a new semantic attempt and prove it receives a new binding while preserving lineage to the prior attempt.
- Prove runtime mapping rejects a required unsupported control and records an authored policy-approved degradation only when the configuration explicitly allows it.
- Prove prompt segments preserve exact revisions, rendered digests, truncation decisions, and trust classes, and that untrusted content cannot expand capabilities.
- Prove secrets do not appear in persisted configuration, binding serialization, Temporal inputs/history payloads, prompts, traces, manifests, snapshots, events, or exception responses.
- Prove an MCP tool outside the exact allowlist or with a schema/digest mismatch is unavailable even if the server exposes it.
- Prove a changed skill/plugin payload fails digest verification and cannot execute.
- Prove SDK session compaction or restart changes only runtime context and leaves canonical messages, run lifecycle, bindings, and outputs unchanged.
- Prove final accepted operation output is durable before acknowledgement while loss of ephemeral token deltas does not change the final result.
- Exercise handoff and task-subagent modes and prove both remain within the same operation, receive child workspace namespaces, and produce typed immutable delegation records.
- Attempt delegation above tool, data, network, budget, depth, concurrency, model, and workspace ceilings and prove validation rejects each case before side effects.
- Attempt to hide recognized Workflow Type work inside delegation and prove the service returns the declared linked-run escalation requirement without launching the delegate.
- Run parallel workspace owners and prove no two receive the same writable slot; prove shared mounts are read-only and cross-branch writes require promotion.
- Create unmapped files and prove they remain local and cannot appear in output manifests or satisfy completion.
- Promote a valid candidate and prove object payload, immutable metadata, manifest update, producer binding, and PostgreSQL event reference agree on digest and identity.
- Retry promotion and prove exact idempotency; change content under the same promotion identity and prove conflict rejection.
- Inject object-store or metadata failure and prove no public artifact is reported as promoted until the promotion contract is complete and reconcilable.
- Exercise every promotion state and prove consumers trust only the admitted metadata-plus-payload-plus-manifest predicate; orphan payloads, committed metadata without manifest linkage, and emitted-event retries never become visible early or satisfy obligations.
- Snapshot a workspace and prove payload and metadata are immutable and content-addressed.
- Restore the same snapshot twice and prove two new workspace identities with the same parent lineage, leaving the source workspace and snapshot unchanged.
- Prove clone restore does not carry secret values, live MCP connections, sockets, leases, or prior writable ownership and that all authority is revalidated.
- Tamper with snapshot payload or runtime digest and prove restore fails before operation execution.
- Prove files present after restore still require a new or existing valid promotion decision before downstream use.
- Exercise runtime failure, cancellation, timeout, and worker restart and prove workspace retention, snapshot, budget settlement, and final operation result follow the authored policy.
- For the real OpenAI Agents adapter, use the smallest non-destructive compatibility scenario and assert only provider-visible contract outcomes. Keep model-dependent assertions tolerant of wording while strict on structured result, bounds, and side effects.
- Avoid tests of Docker implementation details, local host paths, SDK event class internals, object-store SDK calls, or Mongo repository call order.

## Out of Scope

- Definition publication and Effective Run Configuration compilation, except consuming their exact resolved operation and workspace sections.
- Generic Run Request admission, lifecycle reduction, transition ledger, outbox relay, and authoritative budget accounting.
- StageGraph and GoalDirected scheduling, linked-run creation, dependency classes, and linked result admission.
- Full prompt, Skill, MCP, plugin/package, memory, and capability-catalog ingestion, evaluation, discovery, and promotion pipelines.
- Workflow-specific operation catalogs, prompts, models, evaluator thresholds, artifact schemas, and numeric budget values.
- Selecting the long-term sandbox provider, production container platform, network fabric, secret manager, or object-storage vendor.
- Canonical Conversation and memory subsystem implementation.
- Neo4j ingestion planning, graph-write transactions, compensation, or post-commit validation.
- Dashboard UI and durable broker selection.

## Further Notes

- This is the final specification in the dependency chain: specification 1 compiles exact operation and workspace policy; specification 2 admits the run and reserves budget; specification 3 schedules semantic operations; this specification performs bounded side effects and returns typed evidence.
- The current target’s OpenAI Agents plus Docker Temporal probe is diagnostic prior art only. Its hard-coded model, prompt, image, manifest, and environment behavior must not become production defaults.
- Deferred tuning choices include the first production sandbox provider, default retention durations, snapshot frequency, object-store multipart thresholds, exact trace sampling, model defaults, and adapter-specific concurrency tuning.
- Delegation, workspace ownership, artifact promotion, snapshot immutability, and clone-on-restore authority semantics are not deferred. Provider limitations must produce failure or an explicitly authored degradation, never silent weakening.
- PostgreSQL remains authoritative for lifecycle, budgets, command results, and outbox. MongoDB remains authoritative for Operation Execution Bindings, detailed delegation records, workspace/snapshot metadata, and workflow-shaped output metadata. Temporal owns durable orchestration. Object storage owns promoted and snapshot payloads. Neo4j owns approved canonical graph knowledge and is mutated only by governed ingestion.
