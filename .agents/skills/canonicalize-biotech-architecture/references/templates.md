# Traceability and canonical-document templates

## Contents

1. Document registry entry
2. Decision packet
3. ADR
4. Canonical specification
5. Atomic requirement
6. Contract record
7. Work package
8. GitHub or local issue body
9. Qualification and evidence record
10. Traceability projection

Use only the fields that carry information. Keep identifiers stable after publication.

## 1. Document registry entry

```yaml
- id: DOC-<stable-slug>
  path: <repository-relative-path>
  title: <title>
  recorded_at: <date-or-null>
  declared_status: <verbatim-status-or-missing>
  authority: accepted | proposed | research_evidence | implementation_observation | historical
  framework_assumptions: [temporal, openai-agents-sdk, langgraph, deep-agents, agent-server]
  topics: []
  content_sha256: <digest>
  inbound_references: []
  disposition: promote | keep_update | split | merge | rewrite | supersede_archive | delete_verified_duplicate
  extraction_state: not_started | partial | complete | verified
  extracted_to: []
  superseded_by: []
  notes: <brief>
```

## 2. Decision packet

```markdown
# Decision packet: <cluster>

## Immediate implementation consequence
## Sources read
## Current understanding
## Durable decisions supported by evidence
## Conflicts and supersession candidates
## Proposed canonical destinations
## Proposed requirements
## Owner questions
## Recommended source dispositions
## Decisions that may safely remain deferred
```

Limit owner questions to those that change architecture, scope, authority, or the next implementation frontier.

## 3. ADR

```yaml
---
id: ADR-<number-or-domain-key>
title: <decision>
status: proposed | accepted | superseded
recorded_at: <date>
supersedes: []
superseded_by: []
source_documents:
  - path: <path>
    sections: []
affects_specs: []
---
```

```markdown
## Context
## Decision
## Consequences
## Rejected alternatives
## Compatibility and migration impact
## Revisit triggers
```

## 4. Canonical specification

```yaml
---
id: SPEC-<domain-key>
title: <bounded owner>
status: draft | canonical | superseded
version: 1
governed_by: []
depends_on: []
sources:
  - path: <path>
    sections: []
supersedes: []
requirements: []
contracts: []
qualification_obligations: []
---
```

```markdown
## Purpose
## Boundary and explicit non-ownership
## Authority and persistence
## Vocabulary and identities
## Invariants
## State and lifecycle
## Requirements
## Contracts
## Failure, retry, cancellation, and recovery
## Security, tenancy, redaction, and secrets
## Dependencies and compatible implementations
## Qualification and evidence
## Open decisions
## Non-goals
## Source lineage and supersession
```

## 5. Atomic requirement

```markdown
### REQ-<domain>-<key> — <short normative title>

<Actor or component> MUST|MUST NOT <observable behavior> when <condition>.

**Rationale:** <why the requirement exists>

**Derived from:** <source anchors and ADRs>

**Verification:** <test seam or QUAL identifier>
```

One requirement expresses one independently verifiable obligation. Put configurable values in a referenced policy or contract instead of baking environment values into the requirement.

## 6. Contract record

```yaml
id: CON-<domain>-<key>
owner: SPEC-<domain-key>
version: <semantic-version-or-schema-version>
kind: schema | envelope | protocol | state_machine | identity_grammar | policy
requirements: []
compatibility: <rules>
artifact_path: <path-or-planned-path>
```

Create a `CON-*` only for a concrete versioned compatibility surface.

## 7. Work package

```yaml
---
id: WP-<domain>-<key>
title: <implementable outcome>
status: draft | ready | in_progress | blocked | complete
implements: []
governed_by: []
contracts: []
blocked_by: []
github_issue: null
evidence: []
---
```

```markdown
## Outcome
## Current implementation baseline
## Requirements implemented
## Architectural seams affected
## Compatibility and migrations
## Acceptance criteria
## Qualification and evidence
## Failure and rollback posture
## Documentation and traceability updates
## Non-goals
## Drift guards
```

Keep one work package within one fresh implementation context unless it is an explicitly named aggregate gate.

## 8. GitHub or local issue body

```markdown
## Work package

`WP-<domain>-<key>`

## What to build

<One end-to-end outcome.>

## Implements

- `REQ-...`

## Governed by

- `ADR-...`
- `SPEC-...`
- `CON-...`

## Acceptance criteria

- [ ] <observable criterion>

## Required evidence

- <test, migration proof, trace, replay fixture, or QUAL identifier>

## Blocked by

- <WP or issue reference, or None>

## Non-goals

- <excluded work>

## Documentation updates

- <specification and traceability projections>
```

## 9. Qualification and evidence record

```yaml
id: QUAL-<domain>-<key>
requirements: []
method: <replay, failure injection, hours-long run, migration rehearsal, security test, etc.>
environment: <sanitized exact environment>
pass_condition: <objective condition>
evidence_id: EVD-<domain>-<key>
evidence_path: <planned-or-actual-path>
status: planned | running | passed | failed | accepted
```

An evidence package records exact revisions, commands, configurations, artifacts, sanitized outputs, failures, and gate disposition.

## 10. Traceability projection

```markdown
| Requirement | Source anchors | ADR | Canonical spec | Contract | Work package | GitHub/local issue | Test/qualification | Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
```

Generate or mechanically validate this projection from canonical metadata. Do not author new requirements inside the matrix.

