# Bounded Guest Business Affiliation Summary Operation

## Problem Statement

An admitted transcript may identify a guest whose current and materially relevant historical business affiliations would make later research easier to start. A naive web lookup risks selecting the wrong person, inferring unsupported affiliations, flattening role and time, citing only result snippets, treating tool output as truth, or expanding into open-ended company and person research.

The operation must remain a bounded refinement aid. It needs explicit identity ambiguity, citation, temporal scope, source coverage, stopping, permission, and multidimensional budget contracts. It also requires exact governed capability bindings for Firecrawl, Tavily, and browser inspection so that similarly named public assets, runtime discovery, or prompt text cannot silently determine what executes.

## Solution

Add `GuestBusinessAffiliationSummaryOperation` as an optional or degradable operation within an admitted transcript artifact branch or GoalDirected iteration. The operation begins from an exact transcript guest mention and locator, constructs bounded identity variants, gathers complementary web observations, evaluates affiliation evidence and temporal scope, and emits a cited starter summary plus provisional Entity, Assertion, Evidence Question, and Source Lead seeds.

The operation never establishes canonical person or organization identity, never infers an affiliation without cited evidence, and never claims deep-research or systematic Source Discovery coverage. Admission requires all three exact capability requirements to resolve to one promoted immutable revision each: the Firecrawl Agent Skill for web discovery, extraction, and source capture; the Tavily Agent Skill for complementary search and research retrieval; and the Vercel `agent-browser` Skill for browser-based inspection of rendered or navigational pages. Exact versions, sources, digests, tool exposure, attachments, and runtime use are frozen in the Effective Run Configuration and Operation Execution Binding.

## User Stories

1. As an operator, I want to request guest context only for an admitted transcript guest mention, so that the operation cannot search arbitrary unbound people.
2. As an operator, I want the exact transcript artifact, speaker segment, timestamp or text locator, observed guest name, and surrounding disambiguation context preserved, so that the lookup remains grounded.
3. As an operator, I want multiple guest identity variants and aliases recorded before searching, so that spelling, initials, titles, and name changes are handled transparently.
4. As an identity reviewer, I want identity anchors and conflicting attributes tracked separately, so that same-name people are not merged by convenience.
5. As an identity reviewer, I want consequential ambiguity preserved as alternative hypotheses, so that the summary does not fabricate a canonical guest identity.
6. As an operator, I want the operation to stop or emit a restricted unresolved result when identity ambiguity exceeds policy, so that more searching cannot silently turn uncertainty into confidence.
7. As a research planner, I want current business affiliations distinguished from material historical affiliations, so that later research receives temporal context.
8. As a research planner, I want each affiliation to identify organization name, role, relationship type, supported time range, and identity caveats, so that vague association language is avoided.
9. As a research planner, I want employment, board service, founding, ownership, investment, advisory, partnership, and other relationship types distinguished, so that different business ties are not collapsed.
10. As a research planner, I want unknown start or end boundaries represented explicitly, so that observation time is not mistaken for validity time.
11. As a research planner, I want former roles prevented from appearing as current solely because an old page remains online, so that temporal claims are honest.
12. As a citation reviewer, I want every included affiliation supported by at least one exact cited observation, so that unsupported inference cannot enter the summary.
13. As a citation reviewer, I want source URL, retrieval time, retrieval method, source identity state, quoted or extracted evidence, and an exact locator when available, so that support can be checked.
14. As a citation reviewer, I want search snippets treated as discovery observations rather than final affiliation evidence unless policy explicitly accepts their limited support, so that unstable snippets do not masquerade as captured proof.
15. As a citation reviewer, I want citations to distinguish self-claimed, organization-claimed, registry, platform, and independent evidence, so that evidence origin is visible.
16. As an evaluator, I want supporting and opposing evidence preserved for disputed affiliations, so that contradictions are not resolved by deleting one side.
17. As an evaluator, I want person identity confidence, organization identity confidence, role confidence, relationship confidence, and temporal confidence kept separate, so that one score does not hide the weak dimension.
18. As an operator, I want source coverage planned across complementary tactics rather than a single provider, so that one ranking system does not define the result.
19. As an operator, I want the operation to record searched identity variants, queries, providers, pages, exclusions, inaccessible surfaces, and unresolved leads, so that bounded non-discovery is explainable.
20. As an operator, I want coverage assessed separately for current affiliation, material historical affiliation, role, and temporal evidence, so that source count is not mistaken for completeness.
21. As an operator, I want a valid zero-affiliation result accepted only after required coverage and stopping evidence, so that empty search results do not imply absence.
22. As an operator, I want source-count, elapsed-time, currency, token, page, network, tool-call, and data-egress caps, so that the lookup remains bounded.
23. As an operator, I want provider-specific Firecrawl, Tavily, and browser limits tracked independently, so that excess use of one capability cannot borrow silently from another dimension.
24. As an operator, I want a soft-limit continuation choice and a hard-cap stop, so that bounded work cannot continue through agent discretion.
25. As a workflow owner, I want operation-boundary escalation when systematic procurement, broad identity resolution, or deep company research becomes necessary, so that substantial work becomes a linked workflow or future run.
26. As a workflow owner, I want the summary obligation class set explicitly as required, degradable, optional, or prohibited, so that capability failure has predictable run consequences.
27. As an operator, I want missing or ambiguous required capability resolution to block this operation, so that a similarly named asset is never selected silently.
28. As a security reviewer, I want all three declared capability attachments present before operation admission, so that the runtime shape is known even if a particular call is not needed.
29. As a security reviewer, I want capability attachment distinguished from invocation, so that merely mounting Firecrawl, Tavily, and browser Skills does not imply every tool was called.
30. As an auditor, I want each actual Firecrawl, Tavily, and browser invocation recorded with exact skill, MCP server or tool, source, revision, digest, parameters or redacted request digest, usage, and result references, so that execution is reproducible.
31. As a security reviewer, I want external content treated as untrusted input that cannot change scope, authority, budgets, tools, or completion, so that prompt injection cannot control the workflow.
32. As a compliance reviewer, I want Permission Assessments checked for external processing, reasoning, quotation, retention, and derivative creation, so that transcript and retrieved evidence uses remain lawful under policy.
33. As a compliance reviewer, I want data-egress policy applied to transcript context sent to external providers, so that only the minimum authorized disambiguation context leaves the system.
34. As a research planner, I want provisional Entity Seeds for the guest and organizations with unresolved identity preserved, so that later identity work has grounded starting points.
35. As a research planner, I want provisional Assertion Seeds for supported affiliation propositions, so that cited claims can be investigated later without becoming accepted facts.
36. As a research planner, I want Evidence Question Seeds for conflicts, weak temporal boundaries, and identity uncertainty, so that gaps are actionable.
37. As a research planner, I want Source Leads for useful pages or records, so that later Source Discovery can admit them under its own contract.
38. As a package consumer, I want operation findings and seeds admitted through normal refinement validation and consolidation, so that web results cannot bypass package rules.
39. As a package consumer, I want failure, truncation, unsupported pages, contradictory evidence, and coverage limitations reflected in readiness and the Decision Report, so that the summary's limits remain visible.
40. As an operator, I want late or expanded findings to require a successor run after package terminality, so that immutable package outputs are never revised in place.
41. As an evaluator, I want identity disambiguation, citation entailment, temporal qualification, source complementarity, coverage accuracy, ambiguity preservation, and budget compliance evaluated separately, so that summary quality is not one opaque score.
42. As a developer, I want the operation usable from either StageGraph or GoalDirected refinement through the same typed contract, so that blueprint choice does not change output meaning.

## Implementation Decisions

- This operation depends on specifications 1 and 2. Specification 3 is required only when the operation is invoked from a GoalDirected iteration.
- Invocation requires an exact admitted transcript Starter Artifact reference, a guest Seed Mention or equivalent typed guest mention with locator, authorized surrounding context, a Refinement Directive request for guest context, and an applicable obligation cell.
- The operation input freezes observed guest label, aliases already present in admitted content, identity anchors, transcript locator, temporal hints, geographic or industry hints, requested current/historical scope, exclusions, permission references, capability bindings, and budget.
- The output is a separately identifiable immutable operation result containing identity hypotheses, search observations, affiliation candidates, cited accepted summary entries, contradictions, unresolved questions, coverage assessment, stopping rationale, provisional seeds, findings, and execution bindings.
- Person identity remains provisional. The operation may decide only whether evidence is sufficient to attribute a summary entry to the transcript guest hypothesis for this bounded starter-summary purpose. It cannot issue canonical identity or merge records.
- Identity assessment keeps name match, biographical-anchor match, organization-context match, temporal consistency, geographic consistency, opposing evidence, and alternative people separate.
- Policy requires restricted output or escalation when a same-name alternative remains materially plausible, when transcript context conflicts with retrieved identity anchors, or when attribution would materially affect consequential downstream use.
- Affiliation relationship types use a controlled vocabulary with namespaced extension support. Initial types include founder or cofounder, employee or executive, board member, advisor, owner, investor, partner, contractor, spokesperson, and explicitly unresolved association.
- Each affiliation summary entry binds an exact guest identity hypothesis, organization referent, relationship type, role label, valid-time range or bounded unknowns, observation interval, current-versus-historical classification, supporting and opposing citations, confidence dimensions, and limitations.
- “Current” requires evidence current enough under the operation's freshness policy and no stronger evidence of termination. A page's retrieval time alone cannot prove the affiliation was valid at that time.
- Historical materiality is purpose-bound and must be stated in the directive or operation policy. The operation does not enumerate every job or company relationship in a person's history.
- Citation evidence preserves source URL, observation time, retrieval method, provider-native observation, exact quote or extracted evidence, locator, source-layer hypothesis, and immutable result or capture reference when created under allowed supporting-lookup rules.
- Provider-native retrieval observations are immutable. BellLabs identity, relevance, affiliation, temporal, and confidence assessments are separate records and never overwrite native ranks or snippets.
- Search snippets are normally discovery leads. Final summary entries require inspected page or record evidence unless a typed policy exception records that only snippet-level evidence was available and restricts the entry accordingly.
- The coverage matrix contains cells for guest identity variants, current affiliations, material historical affiliations, role support, temporal support, and contradiction checks across required source/evidence classes. Counts of URLs, domains, or providers are diagnostics only.
- A valid zero-affiliation output requires all required cells to satisfy stopping conditions and must distinguish likely absence from bounded non-discovery, inaccessible evidence, unresolved identity, and unsupported temporal scope.
- Default stopping occurs when required coverage cells are assessed, no unresolved high-value lead remains inside budget, and another tactic is unlikely to materially improve identity, role, or temporal support. Budget exhaustion alone is not sufficient stopping evidence for a valid zero result.
- The operation has explicit caps for currency, input tokens, output tokens, elapsed time, total tool calls, Firecrawl calls, Tavily calls, browser interactions, pages inspected, search results considered, network bytes, data egress, and semantic cycles.
- Soft thresholds create a Continuation Proposal under the parent refinement controls. Hard caps stop the affected operation. Remaining capacity in one dimension does not authorize exceeding another.
- The operation remains a Supporting Source Lookup. If it requires systematic procurement, broad cross-source identity resolution, reusable person research, open-ended company mapping, or coverage beyond declared ceilings, it emits an immutable Operation Boundary Escalation Proposal containing observed threshold conditions, evidence, alternatives, requested scope, budget effect, and recommended action. A proposal grants no authority and the operation stops or waits according to policy rather than continuing as hidden deep research.
- Only the authority declared by the Workflow Type's Operation Boundary Escalation Policy may accept an Operation Boundary Escalation Decision. The accepted Decision records deciding authority and rationale and selects one permitted consequence: request a distinct linked Workflow Run, apply an allowed Run Control Revision with explicit obligation and invalidation effects, require human intervention, or stop/degrade the operation. The agent that authored the proposal cannot self-authorize the Decision unless the published policy explicitly delegates that exact bounded class.
- The Agent Profile declares exactly three required attachment requirements:
  - Logical capability `firecrawl-web-discovery-extraction-capture`, asset kind Agent Skill, required capabilities web discovery, page extraction, and source capture, attached as agent instructions and sandbox Skill material.
  - Logical capability `tavily-complementary-search-research-retrieval`, asset kind Agent Skill, required capabilities complementary web search and research retrieval, attached as agent instructions and sandbox Skill material.
  - Logical capability `vercel-agent-browser-rendered-inspection`, asset kind Agent Skill, source identity Vercel `agent-browser`, required capabilities browser navigation, rendered-page inspection, and interaction, attached as sandbox Skill material with browser execution authority.
- The logical names are governed catalog selectors, not executable floating dependencies. Publication resolves each requirement to exactly one promoted immutable revision using approved internal catalog, registry, or direct-source adapters.
- The resolution record freezes asset logical and revision identities, source repository or registry identity, source revision, full file manifest, content digest, inspection and evaluation decisions, compatibility, license, required secrets, runtime requirements, and attachment target.
- Where a resolved Skill uses an MCP server or project adapter, the Effective Run Configuration also freezes exact MCP server revision, exposed tool revisions, tool schema digests, filters, connection policy, and secret references. No unfiltered server exposure is allowed.
- Publication fails when a required selector is missing, ambiguous, unpromoted, unhealthy beyond policy, incompatible, or resolves to a digest different from the accepted revision. Runtime never substitutes a similarly named capability.
- All three capabilities must be attached when the operation is admitted. Task-directed policy chooses actual calls. Unused attached capabilities remain recorded as available-but-not-invoked.
- Actual use is captured in the Operation Execution Binding with exact prompt, Agent Profile, model, skill, MCP server/tool or browser adapter, workspace, authority, request digest, result references, usage, errors, and time.
- Firecrawl is the primary capability for web discovery, extraction, and allowed supporting evidence capture. Tavily supplies complementary search and research retrieval. Browser inspection is used when navigation, rendered content, interactive disclosure, or source verification cannot be completed through the retrieval capabilities.
- Provider roles are defaults, not evidence authority. The planner may omit an actual call when coverage is already satisfied, but it may not use a capability outside its frozen allowed methods.
- Retrieved content, tool descriptions, web instructions, and page scripts are untrusted. They cannot grant tools, request secrets, broaden search, change budgets, alter obligation status, or declare completion.
- External calls receive the minimum authorized guest context. Full transcript content is not sent when a bounded mention and disambiguation extract suffices.
- Discovered sources and evidence are registered under the normal supporting-lookup provenance contract. The operation does not create a Source Collection, Source Corpus, canonical entity, accepted Assertion, or graph write.
- Provisional seeds retain exact evidence and identity ambiguity. Assertion Seeds remain source-attributed propositions, not facts. Source Leads remain unselected referents.
- Operation results enter the Starter Package only through shared finding, seed, staleness, consolidation, package assembly, and readiness services.
- A required operation failure makes the required obligation unsatisfied. A degradable operation failure can produce `partially_completed`; optional omission has no degradation consequence; prohibited classification prevents admission.
- Dependency: specifications 1 and 2 define authority and execution. Specification 3 supplies iteration and verifier semantics when selected.

## Testing Decisions

- Tests evaluate externally visible operation inputs, immutable observations, summary output, findings, seeds, coverage, budget ledger, package effects, and Decision Report references. They do not assert prompt wording or private provider-client calls.
- The primary identity fixture contains two plausible people with the same name, overlapping industries, and one transcript anchor that supports only one candidate. The output must preserve the alternative and explain the bounded attribution.
- A high-ambiguity fixture lacks sufficient anchors and must emit a restricted unresolved summary rather than selecting a person.
- Temporal tests include a current role, a clearly ended former role, an undated role page, and conflicting end dates. Current/historical classification and unknown boundaries must follow evidence.
- Citation-entailment tests verify that each summary entry is supported by quoted or extracted evidence and that the cited passage entails the person, organization, relationship, and temporal qualification claimed.
- Snippet tests prove that search snippets remain observations or restricted evidence and are not silently promoted to full citation support.
- Coverage tests prove complementary tactics, explicit inaccessible surfaces, unresolved leads, valid bounded non-discovery, and rejection of URL count as completion.
- Capability-resolution tests cover exact single resolution, missing Firecrawl, ambiguous Tavily matches, wrong `agent-browser` source identity, unpromoted revisions, digest mismatch, incompatible runtime, and forbidden silent substitution.
- Attachment tests prove all three Skills are present before admission while invocation logs accurately show which were actually used.
- Tool-binding tests verify exact Skill revisions, MCP server and tool revisions where applicable, schema digests, filters, secret references, and actual-call records in the Operation Execution Binding.
- Provider-adapter contract tests use deterministic fakes that preserve native ranks, snippets, extraction output, browser observations, errors, usage, and timestamps. Live-provider smoke tests are separate and cannot be the correctness suite.
- Budget tests independently exhaust Firecrawl calls, Tavily calls, browser interactions, elapsed time, pages, tokens, and data egress. No dimension may borrow silently from another.
- Boundary tests present an operation that requires broad person history and systematic company procurement; the operation must stop and emit a proposal, prove the proposal grants no capability, then exercise authorized linked-run, allowed-control-revision, human-intervention, and stop/degrade decisions with their recorded effects.
- Prompt-injection tests place malicious instructions in transcript and web content and prove they cannot change capability selection, call secrets, broaden scope, alter budgets, or bypass citation rules.
- Permission tests prove minimum-context egress, quote restrictions, external-processing denial, and conditional retention behavior.
- Seed tests verify exact locators, provisional identity, source-attributed Assertion Seeds, Evidence Question Seeds for conflict and time gaps, and Source Leads without selection status.
- Integration tests run the operation inside both StageGraph and GoalDirected refinement and assert the same immutable operation-result and package contracts.
- Failure tests prove required versus degradable consequences, preservation of partial observations, and Decision Report disclosure.
- Evaluation reports separate identity attribution, citation entailment, temporal accuracy, source complementarity, coverage accuracy, ambiguity preservation, and budget compliance.
- Prior art is the public refinement acceptance seam from specification 2 and the GoalDirected verifier harness from specification 3; provider fakes plug into project adapters without bypassing application commands.

## Out of Scope

- Canonical person or organization identity resolution.
- Exhaustive biography, full employment history, company diligence, ownership mapping, or deep research.
- Systematic Source Discovery, Source Collection construction, Source Corpus Build, or ongoing source monitoring.
- Raw artifact capture or arbitrary transcript ingestion.
- Scientific claim verification, evidence adjudication, recommendation generation, or graph mutation.
- Inferring an affiliation from co-occurrence, social proximity, appearance, title alone, or uncited model knowledge.
- Installing or trusting public Skills at runtime; promotion and exact resolution occur before operation admission.
- Guaranteeing all affiliations exist or proving absence beyond the assessed bounded scope.

## Further Notes

- Dependency order: specifications 1 and 2 are mandatory; specification 3 is conditional on GoalDirected invocation. This is the final specification in the dependency chain.
- The exact capability requirement names above are stable logical catalog identities. Executable versions and digests are intentionally resolved and frozen by publication rather than hard-coded as floating package versions.
- Firecrawl, Tavily, and browser access increase retrieval reach but do not increase identity, truth, permission, or workflow authority.
