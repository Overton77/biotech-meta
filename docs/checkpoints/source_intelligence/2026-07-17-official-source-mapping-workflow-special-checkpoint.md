# Official Source Mapping Workflow Special Checkpoint

Date: 2026-07-17

Status: Accepted architecture checkpoint

## Purpose

This checkpoint records the accepted domain architecture for `OfficialSourceMappingWorkflow`.

It defines inputs, mapping targets, verification semantics, temporal and claim-class scope, output authority, review, graph-promotion boundaries, evaluation, source-identity composition, and freshness.

It does not define implementation schemas, persistence technology, Temporal topology, agent SDK wiring, API routes, UI contracts, or exact policy thresholds.

## Accepted Purpose

`OfficialSourceMappingWorkflow` is an independently runnable Workflow Type that finds and verifies purpose-bound official-source relationships for provisional or canonical mapping subjects.

It supports subjects including:

- people
- organizations
- products and product variants
- formulations and labels
- trials
- publications
- regulatory records
- technologies
- repositories
- media channels

Official Source Mapping is specialized relationship and verification work. It does not silently absorb systematic Source Discovery, Source Corpus Build, canonical graph ingestion, or unrestricted source-identity reconciliation.

## Accepted Input Contract

The workflow accepts both provisional and canonical mapping subjects.

### Official Source Mapping Brief

The brief defines:

- mapping purpose
- requested relationship roles
- applicable claim classes
- temporal scope
- geographic or jurisdictional scope
- verification requirements
- exclusions

### Mapping Subject Manifest

The immutable manifest may contain exact versions of:

- Entity Seeds
- canonical graph Entities
- operator-provided referents
- prior mapping subjects

Supporting context may include:

- Seed Mentions
- Graph Match Candidates
- Starter Packages
- Knowledge Preflight Snapshots
- prior Official Source Mapping Results
- other governed source or identity evidence

Each subject preserves:

- authority level
- identity anchors
- provenance
- selected version
- supporting context references

### Input authority preservation

Input authority controls output authority.

- An unresolved Entity Seed may receive mapping candidates tied to that exact hypothesis.
- A canonical Entity may receive verified relationship outputs.
- Neither case grants automatic graph-mutation authority.
- Insufficient identity anchors produce unresolved outputs rather than fabricated identity.

The workflow does not require a canonical Entity before provisional mapping can begin.

## Accepted Mapping-Target Model

An Official Source Mapping Target is the most precise source referent supported by available evidence.

Permitted target layers include:

- Source Origin
- Source Work
- Source Work Version
- Source Representation
- mutable official record or page
- unresolved locator

The workflow does not fabricate a Source Work, Work Version, or Representation to complete a tidy provenance hierarchy.

Later source-identity work may refine a target while preserving:

- the original target
- the evidence available at the time
- the mapping candidate
- the verification decision
- refinement lineage

## Accepted Meaning of Official

There is no global `is_official` property.

Official standing is represented by a scoped, temporal `Official Source Relationship` between:

- an exact mapping subject
- an exact mapping target

The relationship preserves:

- relationship role
- purpose
- applicable claim classes
- jurisdiction or region
- validity or observation interval
- claimant
- verifier
- verification method and profile
- verification status
- supporting evidence
- opposing evidence

Relationship roles may include:

- owner
- issuer
- publisher
- manufacturer
- maintainer
- registry
- authorized distributor
- affiliate
- official media channel

These roles are not interchangeable.

Official standing does not establish general scientific truth. A source may be authoritative for identity, ownership, current labeling, self-description, or a regulatory record while remaining only a source of self-claims for efficacy or safety.

## Accepted Verification-Evidence Model

Official status is not established by self-assertion, link count, or a universal number of corroborating sources.

Official Relationship Verification Evidence is typed and attributable.

Evidence classes may include:

- demonstrated domain or account control
- reciprocal links
- registry identifiers
- regulatory identifiers
- trial identifiers
- publication identifiers
- product identifiers
- publisher or repository metadata
- authenticated platform relationships
- references from already verified channels
- certificates or signatures
- consistency across independent records
- evidence opposing the proposed relationship

The system distinguishes:

1. claimed by the source
2. externally supported
3. verified by BellLabs under a recorded method

### Verification requirement profiles

Each candidate is assessed under an exact Official Relationship Verification Requirement Profile.

The profile is:

- versioned
- purpose-specific
- relationship-specific
- evidence-class-aware
- risk-sensitive

One sufficiently strong registry or control proof may satisfy a profile. Many copied weak signals do not become independent evidence merely through repetition.

## Accepted Candidate, Decision, and Relationship Separation

The workflow preserves three distinct layers.

### Official Source Mapping Candidate

An immutable proposal that a subject and target may have a particular:

- relationship role
- purpose
- claim-class scope
- jurisdictional scope
- temporal scope

Multiple candidates may coexist.

Candidates are competing only when their roles, scopes, and validity intervals are mutually exclusive.

### Official Source Verification Decision

An immutable assessment of one candidate under:

- an exact requirement profile
- an exact evidence set
- a recorded verification method
- a recorded verifier or decision authority

Accepted decision outcomes are:

- `verified`
- `provisionally_supported`
- `disputed`
- `rejected`
- `unresolved`

Rejected and unresolved candidates remain durable Source Intelligence. They do not disappear from a winner-only result.

### Official Source Relationship

Only a candidate satisfying the applicable verification threshold yields a verified Official Source Relationship.

Multiple verified relationships may be valid simultaneously, including a manufacturer site, regional storefront, authorized distributor, regulator-hosted label, and official media account.

The workflow does not reduce these relationships to one best official source.

## Accepted Confidence Model

There is no universal officialness score.

The Official Mapping Confidence Profile keeps separate:

- mapping-subject identity confidence
- target identity confidence
- relationship-role confidence
- temporal-scope confidence
- jurisdictional or regional confidence where applicable
- evidence-sufficiency confidence

Candidate ranking does not substitute for verification.

## Accepted Output Contract

The immutable Official Source Mapping Result binds:

- Official Source Mapping Brief
- Mapping Subject Manifest
- Official Source Mapping Targets
- Official Source Mapping Candidates
- Official Relationship Verification Evidence
- Official Mapping Confidence Profiles
- Official Source Verification Decisions
- verified Official Source Relationships
- registered Source Candidates
- unresolved and disputed mappings
- Official Source Mapping Coverage Assessment
- stopping rationale
- Decision Report

The workflow does not implicitly emit a Source Collection Snapshot.

## Accepted Coverage and Completion Model

Coverage is assessed across the requested matrix of:

- mapping subjects
- relationship roles
- claim classes
- jurisdictions or regions
- time scopes

The Official Source Mapping Coverage Assessment identifies:

- examined cells
- verified mappings
- provisionally supported mappings
- disputed mappings
- rejected mappings
- unresolved mappings
- unexamined cells
- failed or unsupported methods
- stopping rationale

A valid zero-mapping result is possible only when the required search and verification obligations were sufficiently attempted and assessed.

An empty result does not prove that no official source exists.

URL count is not mapping coverage.

## Accepted Relationship to Source Discovery

Official Source Mapping and Source Discovery remain separate Workflow Types.

Official Source Mapping:

- specializes in official relationship identity and verification
- registers sources it actually discovers
- emits Source Candidates and verified relationship context
- assesses mapping obligations

Source Discovery:

- performs systematic purpose-bound source procurement
- expands coverage across official and independent source classes
- ranks and adjudicates collection membership
- emits Source Collection Snapshots

When systematic procurement or collection construction is required, `SourceDiscoveryWorkflow` consumes Official Source Mapping outputs or runs as a linked Workflow Run.

Official Source Mapping does not claim systematic source coverage merely because it found verified official targets.

## Accepted Source-Identity Resolution Boundary

Official Source Mapping includes bounded Source Identity Resolution Operations required for its own mapping purpose.

Examples include:

- normalized identifier checks
- redirect inspection
- exact checksum comparison
- explicit representation metadata
- narrowly scoped alias checks

Substantial, reusable, independently requested, or cross-workflow source reconciliation uses the independently runnable `SourceIdentityResolutionWorkflow`.

This Workflow Type determines whether source referents represent the same or different:

- Source Origins
- Source Works
- Source Work Versions
- Source Representations
- immutable captures

### Decision rationale

The alternative of containing all source-identity resolution inside Official Source Mapping was considered.

It was rejected after examining a corpus-migration scenario containing publisher HTML and PDF, PubMed and PMC records, preprints, mirrors, corrected articles, redirects, and duplicate captures. That task requires work/version/representation reconciliation without any meaningful official-source mapping subject or official-relationship question.

Therefore:

- bounded purpose-local identity work remains internal
- independent reconciliation crosses the Source Identity Resolution Workflow boundary
- identity results refine later targets through lineage
- prior targets and verification decisions are not rewritten

## Accepted Verification Authority Policy

There is no universal human-review gate.

There is also no unrestricted mapper self-approval.

The Official Mapping Verification Authority Policy determines who may issue each decision based on:

- evidence strength
- evidence independence
- relationship type
- ambiguity
- conflict
- ownership or control consequence
- temporal complexity
- downstream risk

Strong deterministic evidence may permit narrow automated verification when policy explicitly allows it.

Independent or human review may be required for:

- ambiguous subject identity
- ambiguous target identity
- ownership changes
- historical relationships
- conflicting evidence
- reseller or affiliate status
- disputed account control
- other consequential mappings

An actor cannot satisfy an independence requirement by reviewing its own proposal.

Provisional and unresolved outputs may still guide Source Discovery while review is pending.

## Accepted Storage and Graph-Promotion Boundary

Official Source Mapping candidates, evidence, decisions, relationships, and results are durable Source Intelligence.

They are not ephemeral merely because they have not entered the canonical knowledge graph.

Durable Source Intelligence storage and canonical knowledge-graph promotion are separate acts.

Selected Source Intelligence enters canonical graph knowledge only through:

1. `IngestionPlanWorkflow`
2. applicable review or policy approval
3. `IngestionExecutionWorkflow`

Policy may automatically approve narrowly defined low-risk promotion, but it cannot bypass the distinct ingestion contracts or create a hidden graph-write path.

Official Source Mapping does not mutate canonical graph knowledge directly.

## Accepted Freshness and Monitoring Boundary

A completed mapping result is an immutable observation, not a permanently current truth.

It records:

- observation time
- evidence time
- supported validity interval where known
- verification method and profile

An Official Mapping Freshness Policy decides whether the result remains current enough for a proposed use.

The policy may consider:

- age
- ownership changes
- control changes
- redirects
- new evidence
- relationship risk
- downstream consequence

An outdated mapping remains historical evidence.

Bounded freshness checks may remain operations inside a consuming Workflow Run.

Continuous or portfolio-scale monitoring uses the independently runnable `SourceMonitoringWorkflow`, including change detection for:

- source availability
- identity
- ownership
- control
- redirects
- content
- official relationships
- downstream impact

Changed evidence creates linked observations, candidates, and decisions. It does not overwrite history.

## Accepted Evaluation Model

There is no aggregate officialness or mapping-quality score.

The method-versioned Official Source Mapping Evaluation Profile keeps separate:

- mapping-subject identity correctness
- target identity correctness
- source-layer precision
- relationship-role classification
- claim-class scope correctness
- jurisdictional scope correctness
- temporal-scope correctness
- evidence sufficiency
- evidence independence
- candidate-discovery false positives
- candidate-discovery false negatives
- confidence calibration
- coverage-assessment accuracy
- preservation of conflict and unresolved ambiguity
- downstream usefulness

Evaluation evidence types remain distinguishable:

- deterministic validation
- labeled benchmark comparison
- sampled independent review
- temporal rechecks
- downstream outcome evidence

The Decision Report summarizes decisions, alternatives, uncertainty, failures, tool usage, coverage, and evaluation references. It does not replace structured outputs or evaluation records.

## Explicit Non-Authority Rules

`OfficialSourceMappingWorkflow` does not:

- make a source globally official
- make official self-claims scientifically true
- fabricate missing source identity layers
- force one winner among simultaneously valid relationships
- establish systematic source procurement
- implicitly create a Source Collection
- silently resolve substantial cross-workflow source identity
- erase rejected or unresolved candidates
- overwrite historical mappings
- remain current without freshness assessment
- write canonical graph knowledge
- grant authority through prompts, tools, MCP access, or sandbox state

## Newly Accepted Standalone Workflow Types

This checkpoint accepts:

- `SourceIdentityResolutionWorkflow`
- `SourceMonitoringWorkflow`

Both retain bounded-operation equivalents inside consuming Workflow Runs for narrow purpose-local work.

## Deferred Details

The following remain intentionally open:

- exact relationship-role taxonomy
- exact claim-class taxonomy
- exact verification requirement profiles
- exact evidence-strength rules
- exact automated-verification risk classes
- exact freshness profiles
- exact monitoring schedules
- exact source-identity resolution output contract
- exact Source Monitoring output contract
- exact operation and stage decomposition
- exact schemas and event contracts
- exact persistence model
- exact Temporal and agent topology
- exact API, UI, SDK, MCP, and WebSocket bindings

## Next Interview Boundary

The next architecture interview should finish `SourceDiscoveryWorkflow`:

1. discovery input and requirement contracts
2. required source classes and diversity
3. provider-native rank and BellLabs reranking
4. collection membership decision semantics
5. coverage measurement
6. unresolved gaps
7. stopping and continuation
8. review and evaluation
9. relationship to Official Source Mapping and Research Execution

