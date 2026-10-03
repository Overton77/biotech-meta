# Durable Catalogs for Prompts, Agent Skills, and MCP Servers

Date: 2026-07-18

Status: Architecture proposal for research-ingestion-evaluation; hypotheses for grill, not yet accepted domain decisions

Related:

- [CONTEXT.md](../CONTEXT.md) — Agent Profile, Operation Execution Binding, Workflow Agentic Configuration Contract, Effective Run Configuration
- [2026-07-15 workflow catalog / agent sandbox checkpoint](../checkpoints/system-level/2026-07-15-workflow-catalog-agent-sandbox-and-system-state-special-checkpoint.md)
- [OpenAI Agents SDK and Temporal notes](../BellLabs/openai-agents-sdk-and-temporal.md)
- [Agent tooling skill options](../BellLabs/agent-tooling-skill-options.md)

## Research Question

How should BellLabs manage **Prompts**, **Agent Skills**, and **MCP Servers** as:

1. **Durable catalogs** — versioned, reviewable, environment-labeled configuration assets with clear lifecycle
2. **Reachable data** — queryable at configuration time, resolution time, and execution/audit time
3. **Binding inputs** — exact versions recorded on Effective Run Configuration and Operation Execution Binding

…while using **OpenAI Agents SDK (Python)**, **MongoDB + Beanie**, Temporal, and sandbox/workspace materialization?

## Executive Verdict

Treat the three resources as one **Agentic Asset Catalog** with a shared identity/version/label/binding pattern, three specialized document families, and one runtime **Catalog Resolver** that materializes SDK objects only after policy validation.

Do **not** keep prompts, skills, and MCP wiring as repo-only or env-only secrets of the runtime. Do **not** let Langfuse, OpenAI Skills API, or Cursor/local skill installs be systems of record unless they are optional mirrors. The system of record for configuration, lifecycle, and replay must be **MongoDB (Beanie) plus content-addressed blob storage for skill bundles**.

Authority still comes from Workflow Type contracts and capability profiles — catalogs describe what *may* be selected and what *was* selected; they do not grant capability by themselves.

## Why This Matters Now

Existing domain language already assumes exact bindings:

| Concept | Catalog role |
| --- | --- |
| Workflow Agentic Configuration Contract | Declares *which catalog assets are permitted* (by id / label policy / allowlist) |
| Agent Profile | Composes prompt + skill + MCP references into a logical agent |
| Effective Run Configuration | Resolves overlays to exact catalog versions |
| Operation Execution Binding | Freezes the actual prompt/skill/MCP/tool bindings used for one semantic operation |
| Dynamic Instruction | May *describe* resolved catalog assets; cannot enlarge authority |

Without durable catalogs, those records become opaque strings (“whatever was in the worker image”), and evaluation / replay / grill decisions cannot bind to inspectable configuration.

## External Patterns Reviewed

### Prompt management (Langfuse / Hub-style)

Industry prompt registries converge on:

- stable **name** (logical identity)
- immutable **versions** on every change
- mutable **labels** (`production`, `staging`, experiment tags) as pointers
- runtime fetch by **name + label** or **name + exact version**
- compile/render of template variables at use time
- optional link from traces back to prompt version

Langfuse documents this as create → version → label → `get_prompt(name)` with production default ([Langfuse Prompt Management](https://langfuse.com/docs/prompt-management/get-started)). Production practice often uses a hybrid: Git for review, runtime store for resolution ([discussion of Langfuse vs Git hybrids](https://www.reddit.com/r/AI_Agents/comments/1rsji8z/prompt_management_in_production_langfuse_vs_git/)).

**BellLabs implication:** adopt the name/version/label pattern in Beanie. Optionally sync to Langfuse later for playground/eval UI — never invert ownership for workflow replay.

### Agent Skills (open standard + OpenAI platform)

[Agent Skills](https://agentskills.io/home) define a directory with `SKILL.md` (YAML frontmatter + Markdown), optional `scripts/`, `references/`, `assets/`, and progressive disclosure (metadata → body → resources). Spec constraints: lowercase hyphenated `name`, rich `description`, validation via `skills-ref` ([specification](https://agentskills.io/specification)).

OpenAI Skills API adds hosted versioning (`skill_id`, integer versions, `default_version` / `latest`, mount via shell `skill_reference`) and stresses **developer-gated** skill catalogs — not open end-user skill browsing ([Skills guide](https://developers.openai.com/api/docs/guides/tools-skills)). Local shell mode mounts paths you control; hosted mode uses uploaded references.

**BellLabs implication:** store skills as catalog entries + content-addressed zip/tree in S3; materialize into sandbox/workspace paths for local shell / Agents SDK use; optionally mirror to OpenAI hosted skills when a workflow requires hosted containers. Keep `SKILL.md` as the interchange format.

### MCP servers (Agents SDK)

OpenAI Agents SDK treats MCP as first-class: `MCPServerStdio`, `MCPServerStreamableHttp`, `MCPServerManager`, static/dynamic **tool filters**, and `Agent.mcp_config` (strict schemas, failure handling, server-prefixed tool names) ([Agents SDK MCP docs](https://openai.github.io/openai-agents-python/mcp/)). Hosted vs SDK-managed MCP is an explicit split: remote public tools vs runtime-owned connections and approvals ([MCP connectors](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)).

MCP can also expose **prompts** as server resources; that is a transport feature, not a substitute for the durable Prompt Catalog.

**BellLabs implication:** catalog **connection recipes + policy** (transport, endpoint/command template, tool allow/deny, health, credential *references*), not live sockets. Instantiation happens in the trusted harness under Operation Execution Binding.

### Beanie / MongoDB

Beanie supports indexed documents, `Link`/`BackLink`, state management, and revision/optimistic locking — suitable for catalog heads and concurrent label moves. Large skill payloads belong in object storage; Mongo holds metadata, hashes, and pointers.

## Proposed Shared Catalog Model

### Layered identity

```text
Catalog Asset (logical)
  ├── Asset Identity          mutable head: name, kind, status, owners, tags
  ├── Asset Version           immutable snapshot: content + schema + content hash
  ├── Label Pointer           mutable: label -> exact version (env/channel)
  ├── Availability Record     deployment: which envs/runtimes may resolve it
  └── Usage Binding           immutable copy on Effective Run Config / Operation Binding
```

Shared fields for every asset kind:

| Field | Purpose |
| --- | --- |
| `kind` | `prompt` \| `agent_skill` \| `mcp_server` |
| `slug` | Stable unique name (`research.seed-extraction.system`) |
| `display_name` | Human title |
| `status` | `draft` \| `active` \| `deprecated` \| `retired` |
| `owners` | Operator identities / teams |
| `tags` / `domains` | Discovery (`starter-refinement`, `source-intelligence`, …) |
| `schema_version` | Catalog document schema |
| `content_hash` | Hash of immutable payload |
| `created_by` / `created_at` / `change_summary` | Audit |
| `compatibility` | Required runtime, SDK version range, sandbox features |
| `policy_hints` | Sensitivity, network needs, approval class — not authority grants |

### Labels and resolution modes

| Resolution mode | When used |
| --- | --- |
| Exact version id | Effective Run Configuration, Operation Execution Binding, replay, eval |
| Label (`production`, `canary`, `dev`) | Operator defaults, UI “current”, undeployed profiles |
| Pin policy | Workflow Type may require exact pins; forbid floating labels at run start |

**Rule:** starting a Workflow Run resolves floating labels to exact versions once and stores those versions. Later label moves do not rewrite historical runs.

### Lifecycle

```text
draft -> review -> active (labeled) -> deprecated -> retired
         |              ^
         +-- rejected --+
```

- Creating a version never mutates prior versions.
- Moving `production` is an auditable label transaction (Beanie revision / optimistic lock on the label document).
- Deprecation blocks new selections but keeps historical bindings resolvable (read-only).
- Retirement may tombstone content after retention policy; bindings keep hash + archival pointer.

## Catalog A — Prompts

### What a Prompt Catalog Entry is

A versioned instruction artifact used as:

- Agent base instructions
- Operation-class templates
- Structured message templates (system / developer / user segments)
- Optional few-shot or rubric attachments referenced by hash

Not the same as Dynamic Instruction. Dynamic Instruction is run-assembled and may *cite* catalog prompts; it is not itself a catalog version unless promoted through review.

### Suggested Beanie shape

```text
PromptAsset
  slug, status, owners, tags, default_label

PromptVersion
  prompt_asset_id
  version (monotonic int or semver+build)
  format: text | chat_messages | multipart
  template_engine: mustache_double_brace | none
  variables: [{ name, type, required, description }]
  body: string | [{ role, content }]
  content_hash
  eval_hooks: optional rubric ids / suite refs
  change_summary
```

### Reachability

- Admin/API: CRUD versions, promote labels
- Resolver: `resolve_prompt(slug, label|version) -> PromptVersion`
- Runtime: compile variables from authorized run state only
- Audit: Operation Execution Binding stores `prompt_slug`, `prompt_version`, `content_hash`, compiled fingerprint (hash of rendered text), variable keys used (not necessarily secret values)

### Agents SDK mapping

Resolved text becomes `Agent(instructions=...)` or middleware-injected developer/system messages. Do not load “latest” inside an activity without going through the resolver and recording the binding.

## Catalog B — Agent Skills

### What a Skill Catalog Entry is

A versioned bundle conforming to Agent Skills:

- `SKILL.md` frontmatter + body
- optional scripts, references, assets
- content-addressed archive (zip or tree) in S3
- progressive-disclosure metadata for discovery

### Suggested Beanie shape

```text
SkillAsset
  slug (= agentskills name constraints)
  status, owners, tags
  default_label
  openai_skill_id?          # optional hosted mirror
  source_repo_uri?          # optional git origin

SkillVersion
  skill_asset_id
  version
  skill_md_frontmatter      # name, description, license, compatibility, metadata, allowed-tools
  skill_md_body
  bundle_uri                # s3://...
  bundle_content_hash
  file_manifest             # path -> hash, size
  materialization:
    local_path_template     # e.g. {workspace}/.skills/{slug}/{version}
    hosted_skill_ref?       # { skill_id, version } when mirrored
  required_capabilities     # shell, network, fs read/write — still validated against Execution Capability Profile
  change_summary
```

### Reachability and materialization

1. Catalog lists skills by tag/domain for operators and Agent Profile editors.
2. At run start / operation prep, resolver selects exact `SkillVersion`s allowed by contract ∩ capability profile.
3. Activity downloads bundle by hash into sandbox path (or mounts hosted `skill_reference` when policy says hosted shell).
4. Dynamic Instruction may list available skill names/descriptions/paths; model still cannot attach an unapproved skill.

### Safety (from OpenAI guidance, adopted as policy)

- Skills are privileged code + instructions; review before `active`.
- No open end-user skill marketplace inside product surfaces.
- Map skills to Workflow Types / operation classes.
- High-impact script actions remain behind tool approvals and capability profiles.
- `allowed-tools` in SKILL.md is advisory metadata; authority remains Execution Capability Profile.

## Catalog C — MCP Servers

### What an MCP Server Catalog Entry is

A versioned **server recipe + exposure policy**, not a live process:

- transport: `stdio` | `streamable_http` | `hosted_remote`
- launch or URL template
- env/secret references (never raw secrets in Mongo)
- tool allowlist / denylist (maps to SDK static filter)
- optional dynamic filter policy id
- health check definition
- rate / budget dimensions (aligns with Linked Run Budget Reservation MCP dimensions)
- tool schema snapshot hash (captured at connection probe time)

### Suggested Beanie shape

```text
McpServerAsset
  slug, status, owners, tags
  default_label
  sensitivity_class

McpServerVersion
  mcp_server_asset_id
  version
  transport
  stdio: { command, args, cwd?, env_ref[] }
  http: { url_template, headers_ref[], timeout_ms }
  hosted: { server_url, connector_id? }
  tool_policy:
    mode: allowlist | denylist | all_then_filter
    tool_names: [...]
  mcp_config_defaults: { convert_schemas_to_strict, include_server_in_tool_names, ... }
  credential_refs: [secret_store_keys]
  healthcheck: { method, interval, failure_threshold }
  discovered_tools_snapshot?: [{ name, description_hash, schema_hash }]  # from last successful probe
  change_summary
```

### Reachability and runtime

1. Catalog is browsable for configuration UIs and Workflow Agentic Configuration Contracts.
2. Resolver returns recipes; **MCPServerManager** (or equivalent) connects only inside the trusted harness.
3. Tool filter from catalog is applied before tools are exposed to the model.
4. Operation Execution Binding stores: server slug/version, connected endpoint fingerprint, allowed tool names, schema snapshot hash, credential *ref* ids used (not values).

### Important boundary

Deployment availability of an MCP server ≠ authorization. Catalog `active` + Workflow Type allowlist + Delegation Ceiling + Permission Assessment must all pass ([Linked Run Authority Resolution](../checkpoints/system-level/2026-07-18-pre-research-architecture-synthesis-and-grill-entry-checkpoint.md)).

## Unifying: Agentic Asset Catalog + Resolver

```text
┌─────────────────────────────────────────────────────────────┐
│  Operator UI / Admin API / Git import jobs                  │
│  create versions, move labels, deprecate                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            v
┌─────────────────────────────────────────────────────────────┐
│  MongoDB (Beanie)                                           │
│  PromptAsset/Version · SkillAsset/Version · McpServer…      │
│  LabelPointer · AvailabilityRecord                          │
│  S3: skill bundles (content-addressed)                      │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            v
┌─────────────────────────────────────────────────────────────┐
│  Catalog Resolver                                           │
│  input: Workflow Contract + overlays + env labels           │
│  output: ExactAssetSet + Effective Run Configuration slice  │
└───────────────────────────┬─────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              v                           v
┌──────────────────────────┐   ┌──────────────────────────────┐
│ Agent Profile Builder    │   │ Operation prep (Temporal)    │
│ -> Agents SDK Agent      │   │ materialize skills           │
│    instructions/tools/   │   │ connect MCP under filter     │
│    mcp_servers           │   │ write Operation Binding      │
└──────────────────────────┘   └──────────────────────────────┘
```

### Reachable data surfaces

| Surface | Audience | Capability |
| --- | --- | --- |
| REST/Admin API | Operators, CI | CRUD, label promote, search |
| Read API (scoped) | Backend workers | Resolve exact versions by id/slug+label |
| Internal MCP (optional) | Coordinator agents | *Read-only* catalog search under capability profile |
| Export/import | GitOps | YAML/JSON dump of versions for review PRs |
| Eval store join | Evaluation system | Join traces ↔ asset versions ↔ scores |

Coordinator “catalog MCP” must be read-only and allowlisted; write paths stay human/CI with authz.

## Composition Into Existing Contracts

### Workflow Agentic Configuration Contract (per Workflow Type version)

Declares:

- allowed prompt slugs (and whether floating labels permitted)
- allowed skill slugs / required skills for operation classes
- allowed MCP server slugs + max tool sets
- default Agent Profiles referencing those assets by slug+label or pinned version

### Agent Profile (versioned)

References catalogs rather than inlining blobs:

```text
base_prompt: { slug, label_or_version }
skills: [{ slug, label_or_version }]
mcp_servers: [{ slug, label_or_version, tool_policy_override? }]
dynamic_instruction_policy: ...
model_policy: ...
```

### Effective Run Configuration

At run admission:

1. Validate references ⊆ Workflow Type contract
2. Resolve labels → exact versions
3. Persist resolved set immutably
4. Subsequent operations bind from this set (or authorized Run Control Revision successor)

### Operation Execution Binding

Records actual used:

- prompt version + content hash + render fingerprint
- skill versions + materialization paths + bundle hashes
- MCP versions + tool names exposed + schema snapshot hashes
- model id / effort / fallback as already required

## Mongo Collection Sketch (Beanie)

Suggested collections (names illustrative):

| Collection | Notes |
| --- | --- |
| `catalog_assets` | Discriminated by `kind`; or split three collections if indexes diverge |
| `catalog_versions` | Immutable; unique `(asset_id, version)` |
| `catalog_labels` | Unique `(asset_id, label)`; `use_revision=True` for concurrent promotes |
| `catalog_availability` | Env / deployment channel gates |
| `catalog_audit_events` | Optional append-only promote/deprecate events |

Indexes:

- `(kind, slug)` unique on assets
- `(asset_id, version)` unique on versions
- `(asset_id, label)` unique on labels
- text index on `slug`, `display_name`, skill description, tags
- `(status, tags)` for operator browse

Blob storage:

- `s3://…/catalog/skills/{content_hash}.zip`
- optional mirror of prompt bodies if very large (normally inline in Mongo)

## Git + Runtime Hybrid (recommended)

| Layer | Role |
| --- | --- |
| Git (optional) | Authoring, PR review, seed data for bootstrap |
| Mongo catalog | System of record for labels and runtime resolution |
| Import job | CI publishes immutable versions from merged Git paths |
| Export job | Periodic dump for disaster recovery / offline audit |

This matches production prompt-management hybrids without making Git the live resolver (workers must not `git pull` mid-run for instructions).

## Implementation Phases

### Phase 0 — Vocabulary and contracts

- Add CONTEXT terms: Prompt Catalog Entry, Skill Catalog Entry, MCP Server Catalog Entry, Catalog Label, Catalog Resolver, Asset Usage Binding
- Confirm that Operation Execution Binding must include exact catalog versions

### Phase 1 — Beanie models + resolve API

- Implement Prompt + label resolve
- Wire one Agent Profile path to load instructions from catalog
- Record bindings in a probe Temporal workflow

### Phase 2 — Skills

- Bundle upload, hash verify, sandbox materialization
- Align frontmatter with agentskills.io validation
- Optional OpenAI hosted mirror for hosted-shell workflows

### Phase 3 — MCP registry

- Stdio + streamable HTTP recipes
- Static tool filters from catalog
- Health probe + schema snapshot
- Budget dimension hooks per MCP server/tool

### Phase 4 — Operator surfaces + eval joins

- Admin UI / CLI for promote
- Evaluation datasets keyed by asset version
- Optional Langfuse sync as non-authoritative mirror

## Explicit Non-Goals (for this proposal)

- Replacing Execution Capability Profiles with catalog metadata
- Letting Dynamic Instructions or SKILL.md grant MCP/tools
- Storing secrets in catalog documents
- Making OpenAI hosted Skills or Langfuse the source of truth
- Auto-installing arbitrary skills from the public web into production runs

## Open Questions for Grill

1. **Single `catalog_*` collection family vs three families?** Prefer three if skill manifests and MCP recipes diverge in indexing and retention.
2. **Semver vs monotonic int for versions?** Monotonic int is simpler for labels (Langfuse/OpenAI-like); semver is nicer for human Git tags. Could store both (`version_n`, `version_label`).
3. **Should coordinator agents get a read-only Catalog MCP?** Useful for discovery; risk of prompt-injection via catalog descriptions — mitigate with allowlisted fields and no raw secret/env templates in read views.
4. **Hosted OpenAI Skills mirror required for v1?** Likely no if sandbox/local shell is default; yes for container_auto paths.
5. **Prompt variable secrets:** compile-time redaction policy for bindings (store keys + hashes, not PHI/secrets in audit bodies).
6. **Cross-workflow reuse:** global catalog vs namespaced per product surface (`research.*`, `ingestion.*`) — recommend namespaced slugs with global uniqueness.
7. **Dynamic Agent Definition:** may reference only catalog assets already allowed by Delegation Ceiling, or may propose new draft assets that require human promotion before use?

## Acceptance Criteria (when this becomes a decision)

- [ ] Every model operation can point to exact prompt/skill/MCP catalog versions + content hashes
- [ ] Label moves never mutate historical Effective Run Configurations
- [ ] Workflow Type contracts can allowlist catalog assets without embedding full bodies
- [ ] Skills validate against agentskills.io rules before `active`
- [ ] MCP tools exposed to models are ⊆ catalog tool policy ∩ capability profile
- [ ] Resolver is the only supported path from slug/label to runtime SDK objects
- [ ] Eval and replay can re-fetch catalog payloads by hash (or archive) for any retained run

## References

- OpenAI Agents SDK — [MCP](https://openai.github.io/openai-agents-python/mcp/), [Agents overview](https://developers.openai.com/api/docs/guides/agents)
- OpenAI — [Skills](https://developers.openai.com/api/docs/guides/tools-skills), [MCP and Connectors](https://developers.openai.com/api/docs/guides/tools-connectors-mcp)
- Agent Skills — [Home](https://agentskills.io/home), [Specification](https://agentskills.io/specification)
- Langfuse — [Prompt Management](https://langfuse.com/docs/prompt-management/get-started)
- Beanie — Document settings, Link, revision/optimistic locking
- BellLabs checkpoints cited above for Agent Profile and authority intersection
