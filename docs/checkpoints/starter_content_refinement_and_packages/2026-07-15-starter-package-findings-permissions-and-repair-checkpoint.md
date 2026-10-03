# Starter Package Findings, Permissions, and Repair Checkpoint

Date: 2026-07-15

Status: Accepted domain direction; control configuration and execution design remain open

## Purpose

This checkpoint continues from [Starter Preflight and Mission Specification](2026-07-15-starter-preflight-and-mission-specification-checkpoint.md). It records the detailed domain decisions for Starter Package artifact references, findings, permissions, repairs, extracted seeds, Decision Reports, and partial outcomes.

## Package Artifact References

A Starter Package is a manifest over immutable artifacts rather than a copied content bundle.

Each **Package Artifact Reference** records package-specific intended use:

- one controlled primary role
- zero or more controlled secondary roles
- selection rationale
- ordering or grouping
- required or optional use

Artifact role is contextual. File type, media kind, origin, trust, permissions, and other intrinsic or acquisition metadata remain separate.

The initial versioned core **Artifact Role Vocabulary** is:

- `primary_subject`
- `supporting_context`
- `prior_work`
- `evidence_candidate`
- `source_lead`
- `instruction_reference`
- `comparison_reference`
- `output_reference`

Namespaced extensions may be preserved as metadata but cannot drive workflow behavior until the consuming Workflow Type explicitly supports them.

## Starter Findings

Integrity, permission, safety, ambiguity, and future finding classes use a shared **Starter Finding** audit envelope with typed detail schemas.

Every finding separates:

- subject and exact locator
- finding type
- type-specific details
- severity
- confidence and confidence basis
- review state
- evidence
- detector or reviewer identity
- method version
- recommended action
- downstream implications

The finding does not contain a universal block/warn decision. Consequence is evaluated by the proposed downstream Workflow Type's Input Admission Contract and policy.

### Finding severity

The impact scale is:

- `informational`
- `minor`
- `material`
- `major`
- `critical`

Severity does not encode confidence, urgency, review state, or downstream consequence.

### Finding confidence

Confidence uses:

- `low`
- `moderate`
- `high`

Each value includes its basis and method version. Numeric probability is optional and may drive probability-aware behavior only when produced by a calibrated method with recorded calibration context. Uncalibrated model percentages must not masquerade as probabilities.

### Finding review state

The review states are:

- `unreviewed`
- `confirmed`
- `disputed`
- `resolved`
- `dismissed`
- `superseded`

Proceeding despite a still-valid finding is a separate policy decision, not a finding state.

## Artifact Identity and Content Deduplication

A **Starter Artifact** is an immutable intake occurrence with its own:

- origin and acquisition path
- submitter or actor
- capture time
- declared metadata
- permissions context
- lineage
- referenced payload

A durably captured artifact remains an artifact even if its content is corrupt or unreadable. Integrity findings record that condition.

If intake fails before bytes and identity are durably captured, no Starter Artifact exists; that is an operational intake failure.

**Artifact Content** is the immutable content-addressed payload. Identical bytes may be stored once and referenced by multiple Starter Artifacts. Content deduplication must not merge provenance, permissions, acquisition identity, or lineage.

## Permission Assessments

Permissions are evaluated per acquisition path. Identical content from separate sources does not inherit, merge, union, or transfer rights.

A **Permission Assessment** is a method- and policy-versioned operational decision, not a claim of definitive legal truth. It preserves:

- acquisition and source identity
- applicable jurisdiction
- terms and license evidence
- assessor and method
- policy version
- conditions and expiration
- ambiguity and escalation
- review status
- a decision for each Permission Capability

Legal ambiguity remains explicit and may require human or legal review.

### Permission capabilities

Workflow Types compose atomic versioned capabilities into their requirements. The initial capability vocabulary is:

- `inspect`
- `send_to_external_processor`
- `retain`
- `transform`
- `index`
- `use_for_reasoning`
- `quote`
- `derive_knowledge`
- `create_derivative`
- `publish_derivative`
- `display_or_redistribute_media`
- `train_model`
- `include_in_evaluation_dataset`

This vocabulary may split or expand through later versions when real workflow contracts require finer distinctions.

### Permission outcomes

Each assessed capability receives one of:

- `allowed`
- `allowed_with_conditions`
- `requires_review`
- `unknown`
- `prohibited`

Unknown is not permission. Each downstream policy explicitly decides whether uncertainty is admissible.

## Repair Semantics

Generating a repair and accepting it are separate decisions.

A **Repair Artifact** is an immutable candidate replacement or companion with full derivation and method provenance.

A **Repair Decision** chooses whether to:

- activate it as a superseding package selection
- retain it as a companion
- reject it

Generation does not imply acceptance or activation. Low-risk deterministic repairs may be auto-accepted under policy; semantic or material repairs may require review.

When a required Repair Decision is pending, refinement pauses durably. A configured timeout or fallback may later emit a restricted package or fail the run.

The original artifact is never destroyed or mutated.

### Repair versus reconstruction

A Repair Artifact may reconstruct content from identified source evidence while preserving locators and uncertainty.

When sufficient source evidence does not exist, model-inferred missing content is a **Reconstruction Hypothesis**. It may support investigation but cannot silently fill the gap or supersede the original as faithful recovered content.

## Extracted Seeds

A **Seed Mention** preserves:

- exact artifact and locator
- observed text or media region
- extraction actor and method
- method version

An **Extracted Seed** provisionally groups one or more mentions. It carries:

- one preferred candidate type
- optional alternative types
- confidence basis for each type
- provisional labels and aliases
- mention references

Seed grouping and typing may later split, merge, or change. Extracted Seeds are not authoritative graph knowledge.

Knowledge Preflight may attach zero or more **Graph Match Candidates** to a seed. Every candidate preserves:

- match category
- confidence basis
- evidence
- query context
- observed graph version
- target graph identity

Multiple candidates coexist until an identity-resolving workflow adjudicates them. A Graph Match Candidate is distinct from the ingestion-oriented Graph Candidate.

## Decision Report Boundary

The Starter Package and Refinement Decision Report are separate immutable artifacts linked to the same Workflow Run and to each other.

The Starter Package contains reusable domain output:

- artifact references
- findings
- seeds
- preflight references
- repairs and repair decisions
- readiness assessment
- Mission Direction Proposal

The Decision Report explains the process:

- accepted and rejected alternatives
- rationale
- tool behavior
- uncertainty narrative
- failures
- output-quality reasoning
- improvement candidates

The report does not replace the structured Starter Package and is not embedded wholesale inside it.

## Package Emission and Workflow Outcome

A valid Starter Package requires:

- at least one captured artifact reference
- a valid package identity and version
- complete Run Input Manifest lineage
- internally valid artifact and derivation references
- a Starter Readiness Assessment

Captured artifacts may all be corrupt, unreadable, or otherwise unusable. Refinement may still complete successfully by accurately producing a restricted package.

If no captured artifact or prior package exists, refinement does not emit an empty Starter Package. Artifact-free intent proceeds through the Intake Brief or Mission Specification path.

Workflow execution outcome is separate from package readiness:

- `completed`: required execution obligations finished, even if severe findings make the package unusable
- `partially_completed`: valid outputs exist but one or more declared degradable operations in the accepted execution contract failed
- `failed`: a required execution obligation was not met

If preflight was deliberately omitted under the accepted plan, refinement may complete. If preflight was included, attempted, exhausted retries, and degraded under policy while a valid package was emitted, refinement is partially completed.

## Next Interview Target

Define `StarterContentRefinementWorkflow` execution and control contracts:

- exact input variants and admission rules
- stage boundaries and required versus degradable work
- deterministic checks versus agent judgment
- tool, model, budget, and capability profiles
- approval and repair wait policies
- retry, timeout, cancellation, resume, and fork semantics
- Decision Report effort and structure
- application event contract and dashboard observability
- provisional OpenAI Agents SDK and Temporal mapping
