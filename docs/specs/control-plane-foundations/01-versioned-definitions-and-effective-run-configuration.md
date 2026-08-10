---
id: SPEC-CP-DEFINITIONS
title: Versioned definitions and effective run configuration
status: canonical
version: 1
governed_by: [ADR-0001, ADR-0003]
depends_on: []
sources:
  - path: ../pre-research/control-plane-foundations/01-versioned-workflow-definitions-and-effective-run-configuration.md
    sections: [all]
  - path: ../../../../biotech-research-ingestion-evaluation-system/docs/interview_and_research_result_documentation/TEMPORAL_LANGSMITH_DEEPAGENTS_BELLLABS_BACKEND_ARCHITECTURE_PROPOSAL.md
    sections: [5, 6, 8, 18, 20, 26]
supersedes:
  - ../pre-research/control-plane-foundations/01-versioned-workflow-definitions-and-effective-run-configuration.md
requirements:
  - REQ-CP-DEF-001
  - REQ-CP-DEF-002
  - REQ-CP-DEF-003
  - REQ-CP-DEF-004
  - REQ-CP-DEF-005
  - REQ-CP-DEF-006
  - REQ-CP-DEF-007
  - REQ-CP-DEF-008
  - REQ-CP-DEF-009
  - REQ-CP-DEF-010
contracts:
  - CON-CP-DEFINITION-REF-V1
  - CON-CP-ERC-V1
qualification_obligations:
  - QUAL-CP-DETERMINISTIC-COMPILATION
---

# Versioned definitions and effective run configuration

## Purpose

Define how BellLabs publishes immutable executable definitions and deterministically compiles one complete, content-addressed Effective Run Configuration (ERC) before a run can be admitted.

## Boundary and explicit non-ownership

This specification owns definition identity, publication immutability, alias resolution, typed overlays, deterministic compilation, authority and compatibility intersection, exact component selection, and ERC contents. It does not admit runs, schedule work, implement capability catalogs, or define StageGraph/GoalDirected semantics.

## Authority and persistence

MongoDB/Beanie owns immutable published definition revisions, mutable authoring heads, compiled ERC documents, compiler decisions, and exact document references. Large immutable subpayloads may be externalized to object storage by digest. PostgreSQL stores only the exact ERC identity/digest and transactional decisions that consume it. Temporal never compiles configuration or resolves aliases.

## Vocabulary and identities

- **Workflow Type Revision:** the immutable domain contract for inputs, invariants, obligations, outputs, allowed blueprint revisions, capability ceilings, linked-run slots, and workspace expectations.
- **Workflow Execution Blueprint Revision:** exactly one immutable `StageGraph` or `GoalDirected` topology/semantic definition.
- **Profile Revision:** an immutable reusable authored policy or capability component.
- **Exact Definition Reference:** logical identity, revision, schema version, and canonical digest.
- **Effective Run Configuration:** the complete immutable executable configuration for one proposed run.
- **Run Input Manifest:** immutable admitted-input candidates and content references supplied to compilation and later bound at admission.
- **Overlay Decision:** an immutable accepted, rejected, omitted, or degraded decision for a typed proposed override.

## Invariants

1. A published revision is never edited in place.
2. A run binds exactly one Workflow Type revision and one allowed blueprint revision.
3. Aliases, labels, environment availability, and authoring inheritance are resolved before pure compilation.
4. Caller authority, parent ceilings, and environment availability constrain configuration but never originate domain authority.
5. Execution consumes only the ERC or digest-verified immutable references contained by it.
6. Unknown, ambiguous, unauthorized, incompatible, or invariant-weakening overlays fail unless a published policy defines an exact degradation or omission.
7. Secret values never appear in definitions, ERCs, Temporal payloads, or digests; only validated secret references are permitted.
8. A parent freezes the constraints for linked-run slots but never embeds or overrides a future child's full ERC.

## State and lifecycle

Definitions move through `draft -> published -> retired`, where `published` and `retired` content are immutable. Retirement blocks future selection while preserving historical reads. Compilation is `requested -> resolved -> validated -> compiled | rejected`; a compiled ERC is immutable and never returns to a mutable state.

## Requirements

### REQ-CP-DEF-001 — Immutable executable revisions

The definition service MUST publish Workflow Types, blueprints, profiles, policies, and versioned contracts as immutable revisions identified by logical identity, schema version, revision, and canonical digest.

**Derived from:** ADR-0003 and pre-research foundation 01.
**Verification:** publish, attempt mutation, retire, and reload historical revisions against the real repository.

### REQ-CP-DEF-002 — Workflow Type owns admissible semantics

A Workflow Type Revision MUST declare its input contract, invariants, obligations, outputs, allowed blueprint revisions, capability ceilings, linked-run slots, workspace contract, and evaluation obligations; a profile or runtime MUST NOT invent them.

**Derived from:** ADR-0001 and pre-research foundation 01.
**Verification:** publication and compilation reject a profile that introduces undeclared topology or authority.

### REQ-CP-DEF-003 — One blueprint family per run

The compiler MUST bind exactly one exact `StageGraph` or `GoalDirected` blueprint revision already allowed by the Workflow Type.

**Derived from:** ADR-0003.
**Verification:** reject zero, multiple, disallowed, ambiguous, or structurally invalid blueprint bindings.

### REQ-CP-DEF-004 — Pure deterministic compilation

The compiler MUST be a pure function of exact definition inputs, explicit actor/time context, caller and parent authority, environment availability, Run Input Manifest reference, and typed overlay, producing byte-stable canonical output for the same compiler version and semantic inputs.

**Derived from:** governing invariant.
**Verification:** QUAL-CP-DETERMINISTIC-COMPILATION.

### REQ-CP-DEF-005 — Complete effective configuration

The ERC MUST freeze the compiler/schema versions, source refs and digests, selected blueprint, resolved workflow configuration, operation assemblies, Deep Agent profile and placement refs, capability attachment plan, workspace and evaluation bindings, authority intersections, budget/concurrency ceilings, linked-run constraints, Run Input Manifest, and every overlay decision.

**Derived from:** 2026-08-09 foundation interview.
**Verification:** the tracer vertical executes without reading an alias, authoring head, or mutable runtime default.

### REQ-CP-DEF-006 — Resolve authoring composition before admission

The compiler MUST resolve profile composition and exact component references, detect collisions and incompatible combinations deterministically, and emit flattened executable bindings with no runtime inheritance.

**Derived from:** Decision 5 of the 2026-08-09 interview.
**Verification:** composition tests cover ordering, collisions, compatible reuse, and stable flattening.

### REQ-CP-DEF-007 — Typed overlay governance

Every overlayable, fixed, or strengthen-only field MUST be declared by schema; unknown fields and authority-expanding or invariant-weakening values MUST be rejected and recorded.

**Derived from:** pre-research foundation 01.
**Verification:** API/service tests assert exact decisions for accepted, rejected, omitted, and degraded fields.

### REQ-CP-DEF-008 — Capability selection is exact and fail-closed

Required and optional capability requirements MUST resolve through authority, maturity, compatibility, availability, and conflict rules to exact revisions and attachment targets; missing or incompatible required capabilities MUST fail compilation without similarly named substitution.

**Derived from:** control-plane capability boundary decision.
**Verification:** MCP, Skill, sandbox, model, middleware, and tool selection fixtures cover fail, omit, and authored degradation.

### REQ-CP-DEF-009 — Independent child compilation

Each linked child Run Request MUST compile its own ERC from its Workflow Type and exact definitions under the frozen parent slot constraints, without inheriting the parent's executable configuration or credentials.

**Derived from:** ADR-0003.
**Verification:** two child requests under one slot compile independently and remain within the same parent ceiling.

### REQ-CP-DEF-010 — Secrets remain references

Definition publication and compilation MUST reject secret values and accept only typed secret references whose resolution is deferred to an authorized operation worker.

**Derived from:** ADR-0003 security boundary.
**Verification:** schema, serialization, logging, and Temporal payload tests prove secret-value absence.

## Contracts

### CON-CP-DEFINITION-REF-V1

Every executable reference carries `kind`, logical identity, schema version, revision, canonical digest, lifecycle status, and optional content-addressed payload reference. Storage-generated IDs are not semantic identity.

### CON-CP-ERC-V1

The ERC is a versioned discriminated contract containing the complete executable payload or digest-verified immutable subpayload references. Its digest covers all execution-affecting values and preserves semantically ordered collections.

## Failure, retry, cancellation, and recovery

Compilation is side-effect-free. Resolution/application-service retries reuse the request identity. Conflicting request fingerprints are rejected. Failed compilation creates a durable decision but no run. Recovery reloads exact published revisions and never resolves through current aliases.

## Security, tenancy, redaction, and secrets

All compilation inputs are tenant-scoped and authority-checked. Prompt text, catalog descriptions, retrieved content, installed packages, runtime availability, and framework defaults are untrusted inputs. Secret references and sensitive-data classifications are frozen; values are excluded.

## Dependencies and compatible implementations

This specification is implemented before transactional admission. It is compatible with provider-neutral operation adapters, but the first required cognitive adapter is Deep Agents `0.7.5` under `SPEC-CP-DEEP-AGENT-RUNTIME`.

## Qualification and evidence

`QUAL-CP-DETERMINISTIC-COMPILATION` must show byte-stable compilation, alias independence, immutable historical reads, collision rejection, capability failure/degradation, independent child compilation, and digest verification.

## Open decisions

- Exact collection names and retention durations.

## Initial canonical serialization decision

Canonical bytes are UTF-8 JSON produced after strict schema validation and JSON-mode normalization,
with lexicographically sorted object keys, compact separators, Unicode preserved, non-finite numbers
rejected, and array order preserved as semantic. Digests are lowercase `sha256:<hex>` over those
bytes. Any externalized subpayload is canonicalized independently and represented in the parent by
its exact schema identity, digest, media type, size, and immutable object reference. The
externalization size threshold is deployment configuration and cannot change either digest.

## Non-goals

- Capability catalog ingestion or promotion.
- Run admission and lifecycle mutation.
- Temporal scheduling or family semantics.
- Runtime materialization of Deep Agents.

## Source lineage and supersession

This document extracts and supersedes pre-research foundation 01. It removes the OpenAI Agents SDK as an assumed connected runtime and adds the accepted Deep Agent profile/materialization references.
