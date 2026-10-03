# Verifiability, Evaluators, Source Fidelity, and Evaluation Workflow Composition

Date: 2026-08-09

Status: Conversation synthesis and architectural working direction. This document records accepted principles, leading design hypotheses, the proposed experiment, and remaining questions. It is not yet an ADR or a finalized implementation contract.

## Purpose

This document preserves the BellLabs conversation about building a verifiable research and ingestion backend that combines deterministic software with probabilistic and agentic functionality.

The immediate design problem was how BellLabs should:

- represent deterministic validators, algorithmic evaluators, LLM graders, composite evaluators, and human review;
- compose those mechanisms into StageGraph, GoalDirected, Temporal, LangGraph, and Deep Agents workflows;
- distinguish an evaluator's observation from the authority to admit or reject an artifact;
- verify that extracted values and generated reports faithfully reflect immutable source material;
- grade source attribution without confusing source fidelity with source authority or scientific truth;
- prototype these ideas in an isolated OpenAI, Temporal, and LangGraph experiment before integrating them into the canonical backend.

The experiment discussed here is deliberately narrow. It asks whether BellLabs can prove that an agent faithfully extracted and attributed information from a synthetic product page and a synthetic case-study document. It does not attempt to prove that the product publisher's claims are scientifically true.

## Relationship to existing BellLabs architecture

This synthesis extends rather than replaces the existing architecture.

The accepted Provenance Spine remains:

```text
Source Origin
-> Source Work
-> Source Work Version
-> Source Representation
-> Source Snapshot
-> Derived Representation
-> Source Locator and/or Chunk Artifact
-> Assertion
-> Adjudication and Approved Knowledge
-> Curated Content or Component Data Binding
-> Rendered Experience
```

See:

- [Source Intelligence and the Provenance Spine checkpoint](../checkpoints/source_intelligence/2026-07-16-source-intelligence-and-provenance-spine-special-checkpoint.md)
- [Source workflows and provenance profiles checkpoint](../checkpoints/source_intelligence/2026-07-17-source-intelligence-source-workflows-and-provenance-profiles-special-checkpoint.md)
- [Assertion-centered temporal knowledge graph ADR](../adr/0002-assertion-centered-temporal-knowledge-graph.md)
- [System control plane and workflow execution configuration](../system-control-plane-and-workflow-execution-configuration.md)

The existing control-plane position also remains accepted:

> Completion is a typed policy decision, not a status string set by the worker that performed the work.

The new work deepens what an evaluator is, how evaluation findings compose, and how those findings affect completion, promotion, quarantine, repair, escalation, and knowledge admission.

## Foundational proposition: proposal versus authority

The emerging BellLabs rule is:

> Models may search, interpret, decompose, propose, compare, and explain. Canonical services capture, calculate, validate, reconcile, admit, version, and project according to explicit authority.

An LLM may propose:

- a claim boundary;
- a normalized value;
- an entity mapping;
- an entailment judgment;
- a source binding;
- a next search;
- a workflow definition;
- a repair action.

An LLM must not become the authority that:

- declares captured bytes authentic merely because it read them;
- validates a locator merely because it generated one;
- establishes that its own extraction is faithful;
- performs authoritative arithmetic in prose;
- accepts an entity identity without the applicable admission process;
- silently converts a source claim into BellLabs-approved knowledge;
- grades its own work and then promotes it solely on that grade;
- weakens a Workflow Type's invariants or evaluation obligations;
- declares its own workflow complete without an independent completion policy.

## Important distinctions

BellLabs must preserve the following differences:

| Concept | Question answered | What it does not establish |
|---|---|---|
| Citation | Which source is referenced? | Exact support, faithful extraction, source authority, or truth |
| Provenance | Which entities, activities, agents, and transformations produced this artifact? | Scientific validity or truth |
| Verification | Can a locator, extraction, transformation, or calculation be checked against declared inputs? | General applicability or evidence strength |
| Validation | Does the system reliably perform its intended use? | Truth of every source or output |
| Source fidelity | Did the output faithfully reflect what the source said? | Whether the source was correct |
| Attribution | Is the generated claim properly bound to the source and claimant that support it? | Independent corroboration or scientific acceptance |
| Evidence quality | How much reliance should be placed on the evidence? | Whether extraction and attribution were faithful |
| Adjudication | What governed conclusion does BellLabs draw from competing material? | Permanent truth |
| Reproducibility | Can the process be rerun from preserved inputs and methods? | That the reproduced result is correct |

These distinctions are especially important for first-party product material. A source may faithfully establish:

```text
"NanoVi claims X."
```

without establishing:

```text
"X is scientifically true."
```

## Evaluators are not gates

The conversation established a critical separation:

- An **evaluator** examines a subject and emits typed findings.
- A **gate** applies a versioned policy to findings and makes a governed transition decision.
- An **adjudicator** resolves cases that policy cannot decide safely or automatically.

```text
Subject artifact
      |
      v
Evaluator executions
      |
      v
Typed Evaluation Findings
      |
      v
Deterministic policy gate
      |
      +-> pass
      +-> reject
      +-> quarantine
      +-> revise or repair
      +-> escalate
                |
                v
        Optional adjudication
```

An LLM entailment grader may report that a passage probably supports an assertion. That is an Evaluation Finding. It is not, by itself, authorization to admit the assertion into canonical knowledge.

## Determinism is multidimensional

The system should not model all evaluation mechanisms on one simple deterministic-to-probabilistic line.

Relevant dimensions include:

| Dimension | Example values |
|---|---|
| Execution mechanism | rules, code, parser, formula, statistical model, LLM, ensemble, human |
| Repeatability | exact, environment-dependent, provider-dependent, stochastic |
| Grounding | formal invariant, gold label, source evidence, heuristic, rubric judgment |
| Output form | boolean, measurement, category, ranked candidates, narrative finding |
| Authority | advisory, gate-eligible, escalation-only, adjudicative |
| Independence | self, separate invocation, separate model, separate provider, deterministic service, human |
| Risk | informational, workflow-critical, knowledge-admission-critical |
| Replayability | locally replayable, provider-replayable, approximately repeatable, non-replayable |
| Calibration state | unqualified, experimental, calibrated, approved, deprecated |

The key correction is:

> Determinism describes execution behavior. It does not establish correctness, scientific validity, or authority.

A deterministic parser can repeat the same error perfectly. A probabilistic semantic evaluator may be well calibrated for one narrow rubric. A human adjudication may possess high authority while still exhibiting inter-reviewer disagreement.

## Evaluator mechanism classes

The proposed initial classes are:

### 1. Invariant validator

Examples:

- JSON Schema or Pydantic validation;
- required-artifact checks;
- referential integrity;
- ontology identifier existence;
- relationship compatibility;
- graph constraints;
- authorization and capability checks;
- StageGraph acyclicity and dependency validation.

### 2. Replayable computation

Examples:

- unit conversion;
- arithmetic and formula execution;
- effect-size calculation;
- reconciliation identities;
- typed normalization;
- deterministic scoring from declared findings.

### 3. Deterministic extraction or comparison

Examples:

- hashing;
- exact quote matching;
- source-locator resolution;
- byte, offset, or table-cell comparison;
- identifier validation;
- numeric transcription checking.

### 4. Algorithmic heuristic

Examples:

- fuzzy string matching;
- anomaly detection;
- similarity scoring;
- statistical thresholds;
- candidate ranking.

### 5. Model-assisted structured evaluator

Examples:

- claim-to-source entailment;
- extraction-context completeness;
- faithful-paraphrase assessment;
- ontology candidate ranking;
- contradiction classification;
- evidence rubric assessment.

### 6. Multi-evaluator synthesis

Examples:

- independent grader comparison;
- provider-diverse or model-diverse assessment;
- deterministic disagreement analysis;
- calibrated ensemble results.

### 7. Human assessment or adjudication

Examples:

- ambiguous entity resolution;
- risk-of-bias assessment;
- unclear scientific scope;
- consequential knowledge admission;
- override or dispute resolution.

## Semi-deterministic evaluation is composition

"Semi-deterministic" is best treated as a property of a composite evaluation procedure rather than a standalone evaluator kind.

Example:

```text
deterministically validate the source locator
-> deterministically recover the exact passage
-> ask an LLM for a structured entailment judgment
-> deterministically validate the grader output
-> compare it with another independent evaluator
-> deterministically apply the disagreement policy
-> escalate material disagreement to human review
```

The probabilistic judgment is bounded by deterministic input preparation, output validation, policy, evidence requirements, and authority.

## Proposed evaluator domain model

### `EvaluatorDefinition`

The stable semantic identity of an evaluator.

It declares:

- the question it answers;
- supported subject contracts;
- required input evidence;
- its output contract;
- its permissible uses;
- its authority ceiling;
- what it must never decide.

Example identity:

```text
assertion-locator-entailment
```

### `EvaluatorImplementationRevision`

The exact executable method used for one evaluation.

It should preserve:

- evaluator definition reference;
- implementation revision;
- mechanism class;
- code, package, or container reference and digest;
- prompt and rubric revision;
- model and provider reference;
- tool dependencies;
- parameters, thresholds, and sampling configuration;
- input and output contract revisions;
- qualification and calibration state.

Executable code should usually remain in deployable packages or containers. The evaluator registry stores immutable references and digests. Prompts and rubrics are first-class versioned artifacts rather than hidden strings in application code.

### `EvaluationPolicy`

The versioned composition and decision rules for a purpose.

It declares:

- required evaluation capabilities;
- applicability conditions;
- permitted implementation qualifications;
- independence requirements;
- thresholds;
- aggregation and reconciliation rules;
- fail-open or fail-closed behavior;
- escalation conditions;
- risk-specific requirements.

### `EvaluationRun`

An immutable execution record preserving:

- exact evaluator implementation revision;
- subject reference and digest;
- input and contextual artifact references;
- ontology, workflow, and policy revisions;
- runtime environment;
- model invocation details when applicable;
- seed and sampling parameters;
- timestamps, usage, and execution status;
- raw output artifact reference.

### `EvaluationFinding`

An atomic evaluator result preserving:

- criterion;
- verdict;
- measurement or score, when applicable;
- uncertainty;
- rationale;
- evidence bindings;
- failure codes;
- recommended disposition.

The proposed universal execution verdict vocabulary is:

```text
PASS
FAIL
INDETERMINATE
NOT_APPLICABLE
ERROR
```

Domain evaluators may add more specific classifications, such as `ENTAILED`, `CONTRADICTED`, or `UNSUPPORTED`, while mapping them explicitly to policy behavior.

### `GateDecision`

The governed consequence of findings under an exact policy revision.

It preserves:

- policy revision;
- finding references;
- decision outcome;
- authority used;
- reason codes;
- escalation destination;
- any authorized override.

Findings and decisions remain separate so a new policy can be evaluated over preserved findings without falsifying the historical decision.

## Evaluation Workflow Types

An individual evaluator answers one bounded question. An Evaluation Workflow Type describes the governed process for reaching a broader evaluation outcome.

```text
prepare evidence
-> execute one or more evaluators
-> validate findings
-> reconcile agreement or disagreement
-> request review when required
-> apply a gate policy
-> emit an Evaluation Decision Package
```

The proposed symmetry is:

```text
Workflow Type
  -> Workflow Implementation
  -> Operation bindings

Evaluation Workflow Type
  -> Evaluation Workflow Implementation
  -> Evaluator bindings
```

Candidate reusable composition primitives are:

| Primitive | Meaning |
|---|---|
| `evaluate` | Execute one evaluator |
| `sequence` | Run evaluations in dependency order |
| `parallel` | Run independent evaluations concurrently |
| `map` | Evaluate each member of a collection |
| `reduce` | Aggregate findings without granting admission authority |
| `condition` | Route based on typed findings |
| `fallback` | Use an approved alternative after typed failure or unavailability |
| `retry` | Repeat under explicit retry policy |
| `reconcile` | Compare findings and preserve disagreement |
| `human_review` | Request governed human assessment |
| `gate` | Apply a deterministic policy |
| `emit` | Produce the canonical decision artifact |

## Coordinator selection and composition

The Coordinator should normally select an evaluation capability or policy, not an arbitrary model or grader.

Example requirement:

```yaml
evaluation_requirement:
  capability: assertion.entailment
  subject_contract: AssertionCandidate@4
  risk_tier: high
  minimum_qualification: calibrated
  independence:
    must_not_share_producer: true
    minimum_independent_assessors: 2
  permitted_mechanisms:
    - model_assisted
    - human
  latency_class: interactive
  cost_class: standard
```

The evaluator registry resolves approved implementation candidates. The Coordinator may optimize among compatible implementations for:

- cost;
- latency;
- current availability;
- modality or language support;
- benchmark performance;
- provider diversity;
- data-residency constraints;
- expected information gain.

The Coordinator must not weaken:

- required capabilities;
- minimum qualification;
- independence requirements;
- human-review obligations;
- admission thresholds;
- authority ceilings.

The governing rule is:

> Policy determines what evaluation is required. The Coordinator chooses how to satisfy that requirement within approved constraints.

## Binding evaluation to ordinary workflows

Workflow Types should declare evaluation obligations at explicit hooks:

```text
operation precondition
operation postcondition
stage admission
stage completion
workflow completion
artifact promotion
knowledge admission
publication admission
```

Workflow Implementations may select or propose compatible evaluator implementations. They cannot remove the Workflow Type's mandatory evaluation obligations.

Authorized overlays may:

- add evaluation obligations;
- select a more qualified implementation;
- require more independence;
- lower an escalation threshold;
- add human review.

They must not silently weaken an invariant.

StageGraph and GoalDirected workflows may use different tactics, but equivalent artifacts must face the same domain admission policies. Workflow topology determines how work proceeds. Evaluation policy determines what has been established. Gate authority determines what may transition.

## Execution mapping: Temporal, LangGraph, and Deep Agents

The three technologies have different responsibilities.

```text
Temporal
durable cross-service and long-running orchestration
        |
        v
LangGraph
stateful conditional evaluation and bounded agentic reasoning
        |
        v
Deep Agent or other agent runtime
implementation harness for particular probabilistic evaluator nodes
```

### Temporal

Temporal should own:

- durable workflow identity;
- parent and child evaluation workflows;
- evaluator Activity scheduling;
- retries and timeouts;
- parallel fan-out;
- cancellation;
- long-running review waits;
- Signals, Updates, or equivalent governed review input;
- durable completion.

Network calls, LLM requests, database writes, and evaluator execution belong in Activities rather than deterministic Temporal Workflow code.

### LangGraph

A compiled LangGraph subgraph is appropriate when evaluation contains:

- model-driven investigation;
- iterative evidence preparation;
- conditional repair;
- disagreement resolution;
- bounded evaluator-agent loops;
- human interrupts.

LangGraph state should hold canonical artifact references rather than become the sole system of record for source data, findings, or decisions.

### Deep Agents or another agent harness

An agent harness may implement narrow evaluators such as:

- scientific entailment evaluator;
- evidence-context completeness evaluator;
- contradiction investigator;
- ontology candidate evaluator;
- risk-of-bias assistant;
- evaluation-repair agent.

Such an evaluator should receive:

- one narrow rubric;
- minimal tools;
- an exact subject and evidence package;
- an exact ontology slice when needed;
- a structured response contract;
- no canonical mutation tools;
- no authority to admit its own output.

The boundary remains:

```text
agent emits EvaluationFindingProposal
-> application validates the proposal
-> canonical EvaluationFinding is recorded
-> gate applies policy
```

### Avoid competing durability layers

The leading ownership hypothesis is:

- Temporal owns the canonical workflow lifecycle;
- LangGraph owns resumable internal agent state where needed;
- BellLabs persistence owns subjects, findings, and decisions;
- the agent harness owns no authoritative durable domain state.

Long human waits should be surfaced to the Temporal Evaluation Workflow. A Temporal Activity should not remain open indefinitely merely because an internal LangGraph node is waiting for human input.

## Evaluation composition modes

Not every check warrants a standalone workflow.

### Inline invariant

Use for cheap deterministic checks such as schema conformance, missing references, unit types, and authorization.

### Embedded evaluation subgraph

Use for bounded semantic evaluation inside a governing workflow, such as source-locator entailment during extraction.

### Durable evaluation child workflow

Use for expensive, parallel, human-reviewed, independently requested, reusable, or long-running evaluation.

### Asynchronous surveillance or re-evaluation workflow

Use when a new source version, correction, retraction, ontology revision, evaluator deprecation, or policy revision may affect already completed outputs.

## Proposed source-fidelity experiment

The isolated experiment should use:

- a synthetic product page;
- a synthetic case-study document;
- immutable captured representations;
- an OpenAI model for structured extraction and narrowly scoped semantic grading;
- LangGraph for the bounded extraction and evaluation graph;
- Temporal for durable execution and evaluation lifecycle;
- deterministic BellLabs code for hashing, locator resolution, typed parsing, comparison, and final gate policy.

The experiment's primary question is:

> Did the agent faithfully reproduce what the captured source said, and can every extracted or written claim be traced to the exact source region that supports it?

It deliberately does not ask whether the source's product or scientific claims are true.

## Three source-fidelity layers

### 1. Capture fidelity

Did BellLabs preserve the evaluated source exactly?

Potential checks:

- captured-byte digest;
- source-snapshot identity;
- acquisition time and method;
- representation type;
- transformation inputs and outputs.

### 2. Extraction fidelity

Did the agent correctly parse facts and claims contained in the source?

Potential checks:

- exact text match;
- numeric transcription;
- units and currency;
- subject, predicate, and object binding;
- relevant qualifiers;
- claimant and modality;
- omissions against required gold facts.

### 3. Attribution fidelity

Does each generated claim point to source evidence that actually supports that claim as written?

Potential checks:

- locator validity;
- evidence exactness;
- claimant correctness;
- claim-to-passage entailment;
- scope preservation;
- citation coverage;
- citation precision;
- unsupported-claim rate.

## Example: product price

Synthetic source:

```text
Product XY
One-time purchase: $33.99
Subscription price: $28.99
Package contains 30 capsules.
```

The extraction should preserve both the literal source value and normalized meaning:

```json
{
  "assertion_kind": "source_fact",
  "subject": {
    "raw_text": "Product XY",
    "normalized_name": "Product XY"
  },
  "predicate": "has_offered_price",
  "object": {
    "raw_text": "$33.99",
    "value": "33.99",
    "currency": "USD"
  },
  "qualifiers": {
    "purchase_option": "one_time_purchase"
  },
  "claimant": {
    "type": "source_publisher",
    "name": "Synthetic Product Company"
  },
  "evidence": {
    "snapshot_ref": "snapshot:product-page-v1",
    "representation_ref": "representation:product-page-v1-dom",
    "locator": {
      "type": "dom_text",
      "node_ref": "product-price-one-time",
      "exact_text": "$33.99"
    }
  }
}
```

Deterministic validation can establish:

1. The snapshot digest matches the stored bytes.
2. The locator resolves in the declared representation.
3. The declared exact text matches the resolved text.
4. A canonical parser converts `$33.99` to decimal `33.99` and currency `USD`.
5. The independently parsed value equals the agent's normalized value.

Semantic or structural evaluation must also establish that the price is bound to:

- Product XY;
- the one-time purchase option;
- not the subscription option;
- not a crossed-out prior price;
- not another product variant;
- not the package quantity.

A number may be transcribed correctly but bound to the wrong entity or condition. Numeric equality alone is insufficient.

## Parsing provenance

Parsing should add lineage rather than replace the source:

```text
Synthetic Source Origin
-> immutable HTML or PDF Source Snapshot
-> Derived Representation
-> addressable DOM, page, text-block, or table-cell representation
-> agent extraction proposal
-> normalized Assertion Candidate
-> Evaluation Findings
-> Gate Decision
```

Each transformation should record:

- input artifact reference and digest;
- output artifact reference and digest;
- parser or transformer name and version;
- configuration;
- producing activity and actor;
- timestamp;
- warnings;
- missing or unreadable regions.

For HTML, a resilient locator may combine:

- snapshot identity;
- DOM or node identity;
- character offsets;
- exact text;
- prefix and suffix context;
- hashed excerpt.

For PDF, a locator may combine:

- snapshot identity;
- page number;
- bounding box;
- parsed block identity;
- exact text;
- table, figure, caption, or footnote identity when applicable.

## Source attribution and claim decomposition

Generated paragraphs must be decomposed into atomic claims before attribution is graded.

Example:

```text
NanoVi claims its technology structures water into exclusion-zone-like
domains, improving cellular repair and increasing cellular energy.
```

Possible atomic claims:

```text
C1: NanoVi makes a claim about its technology.
C2: NanoVi claims the technology structures water.
C3: NanoVi describes the structures as exclusion-zone-like.
C4: NanoVi claims the process improves cellular repair.
C5: NanoVi claims the process increases cellular energy.
```

One source may support C1 through C3, another may support C4, and neither may support C5. A paragraph-level score would conceal this mixed support.

Each claim-source relationship should preserve:

- the atomic claim;
- claimant;
- exact source and locator;
- source passage;
- which claim components the source supports;
- relationship type such as supports, contradicts, mentions, or background;
- whether individual or joint source support is required.

For a multiple-citation claim, BellLabs should evaluate:

```text
Does Source 1 support the claim?
Does Source 2 support the claim?
Do Source 1 and Source 2 jointly support the complete claim?
```

An irrelevant extra citation must not improve the result. Citation dumping should reduce citation precision rather than create an appearance of stronger support.

## The semantic-comparison standard

There is no single universally accepted gold metric for comparing a source with a generated report.

The leading standard for BellLabs is:

> Human-adjudicated atomic claim-to-evidence alignment against immutable source material, supplemented by deterministic checks for exact values, quotations, qualifiers, and locators.

Automated NLI, question-answering, or LLM graders approximate that reference process. They do not replace the gold process until calibrated against it for the exact task.

Relevant external methods include:

- [FActScore](https://aclanthology.org/2023.emnlp-main.741/): atomic-fact support and factual precision;
- [Attributable to Identified Sources](https://aclanthology.org/2023.cl-4.2/): human attribution evaluation against identified sources;
- [ALCE](https://aclanthology.org/2023.emnlp-main.398/): answer correctness and citation quality, including citation support and completeness;
- [QAFactEval](https://aclanthology.org/2022.naacl-main.187/): question-answering-based factual consistency, complementary to entailment-based methods.

## Semantic comparison is directional

### Report to source

Question:

```text
Does every generated report claim have adequate source support?
```

Measures include:

- atomic faithfulness;
- unsupported-claim rate;
- contradiction rate;
- citation precision;
- attribution correctness.

### Source to report

Question:

```text
Did the report include the source information it was required to include?
```

Measures include:

- required-fact recall;
- omission rate;
- qualifier preservation;
- scoped completeness.

A report can be faithful but incomplete. It can also be comprehensive but unfaithful. These axes must remain separate.

## Structured semantic comparison

Each atomic report claim and gold source assertion should be decomposable into comparable fields:

```text
subject
predicate
object
polarity
modality
claimant
attribution mode
population
intervention or product identity
quantity, denominator, unit, and uncertainty
temporality
evidence type
other material qualifiers
```

This catches failures that embedding similarity may miss.

Example source:

```text
In a company-sponsored case study, 12 of 18 participants reported
improved sleep after six weeks.
```

Unfaithful report:

```text
A clinical trial showed that the technology improves sleep.
```

The report changed or omitted:

- company-sponsored case study -> clinical trial;
- participant report -> objective result;
- 12 of 18 -> no denominator;
- six weeks -> no duration;
- bounded observation -> generalized efficacy conclusion.

The passages may appear semantically similar while differing materially. Embedding similarity or ROUGE-style overlap is therefore not an admission-grade evaluator.

## Semantic support vocabulary

Proposed claim-level judgments:

```text
ENTAILED
PARTIALLY_ENTAILED
CONTRADICTED
UNSUPPORTED
INDETERMINATE
```

### `ENTAILED`

The source evidence supports the complete claim, including material qualifiers.

### `PARTIALLY_ENTAILED`

Some components are supported, but at least one material component is missing, added, or overstated. The finding should identify supported components, unsupported components, and missing qualifiers.

### `CONTRADICTED`

The source contains incompatible information.

### `UNSUPPORTED`

The source does not establish the claim but does not explicitly contradict it.

### `INDETERMINATE`

The source, representation, claim boundary, or context is insufficient for a reliable decision. This should trigger declared review or additional-evidence behavior rather than be converted silently into a middling score.

## Gold package for the synthetic experiment

The product page and case-study document should have a hidden, manually authored gold package created before report generation.

It should contain:

- atomic source assertions;
- expected normalized values;
- exact evidence locators;
- required qualifiers;
- allowed faithful paraphrases where useful;
- required report facts;
- optional facts;
- known contradictions;
- forbidden or unsupported interpretations;
- seeded negative cases.

The extraction agent sees the source material and extraction instructions. It does not see the gold package.

The experiment should avoid asking one model invocation to create the source, author the gold answer, perform the extraction, and grade itself. Synthetic fixtures and gold expectations should be fixed and reviewed independently of the evaluated extraction call.

For a larger benchmark, the strongest process would use two trained reviewers and adjudicate disagreements. Reviewer agreement should be measured before adjudication because high disagreement indicates an ambiguous rubric, claim boundary, or source context.

## Deliberate experiment traps

The synthetic product page should include:

- one-time and subscription prices;
- an old or crossed-out price;
- multiple product variants;
- package quantity;
- disclaimer text;
- manufacturer marketing claims;
- a footnote limiting a claim.

The synthetic case study should include:

- company sponsorship;
- a small sample size;
- self-reported outcomes;
- percentages with denominators;
- an adverse or neutral result;
- a limitation section;
- associative rather than causal language;
- a fact in a table but not prose;
- at least one fact that complicates an implication on the product page.

Seeded failure cases should include:

- wrong price;
- correct price attached to the wrong variant or purchase option;
- correct quote attached to the wrong source;
- correct source with a stale or invalid locator;
- faithful fact missing a material qualifier;
- manufacturer marketing rewritten as scientific fact;
- multiple citations dumped after a paragraph without atomic bindings;
- a citation that mentions the topic but does not support the claim;
- a report that changes association into causation;
- a report that omits a required limitation or denominator.

## Proposed metrics

Metrics should remain multidimensional.

### Atomic faithfulness

```text
fully supported report claims / all report claims
```

Partial entailment should be reported separately rather than silently counted as full support.

### Critical unsupported-claim rate

```text
unsupported or contradicted critical claims / all critical claims
```

### Required-fact recall

```text
required gold facts faithfully represented / all required gold facts
```

Only facts designated as required belong in this denominator. Concise reports should not be penalized for omitting every minor detail.

### Citation precision

```text
claim-source bindings that support the claim / all claim-source bindings
```

### Citation coverage

```text
claims requiring attribution with valid bindings / all claims requiring attribution
```

### Qualifier preservation

Track preservation of:

- claimant;
- source or evidence type;
- population;
- intervention or product identity;
- dose;
- duration;
- denominator;
- uncertainty;
- modality;
- causality;
- limitations.

### Numerical fidelity

Prefer deterministic comparison of:

- value;
- sign;
- unit;
- currency;
- denominator;
- range;
- confidence interval;
- decimal precision where meaningful;
- associated entity;
- associated condition or purchase option.

## Do not collapse evaluation into one trust score

A profile may include:

```json
{
  "atomic_faithfulness": 0.94,
  "required_fact_recall": 0.88,
  "citation_precision": 1.0,
  "citation_coverage": 0.96,
  "numeric_fidelity": 1.0,
  "qualifier_preservation": 0.79,
  "contradicted_critical_claims": 0,
  "unsupported_critical_claims": 0,
  "indeterminate_claims": 2
}
```

The Gate Decision should apply explicit policy rather than average these dimensions into one reassuring number.

Candidate experiment policy:

```text
no contradicted critical claims
no unsupported critical claims
100% snapshot and locator validity
100% numeric fidelity for reported values
100% citation coverage for externally verifiable claims
required-fact recall at or above the workflow-specific threshold
all indeterminate critical claims escalated
```

Exact thresholds remain open until the fixture and error taxonomy are built.

## Candidate Workflow Type

Candidate name:

```text
source-fidelity-evaluation
```

Candidate semantic purpose:

> Evaluate whether structured extractions and synthesized claims faithfully reflect, preserve, and attribute information contained in immutable source snapshots.

Candidate topology:

```text
capture synthetic sources
-> derive addressable representations
-> generate structured extraction with OpenAI
-> validate output contracts
-> resolve all source locators
-> verify exact quotations and typed values
-> generate a report from the captured sources
-> decompose the report into atomic claims
-> evaluate claim-to-source support and attribution
-> compare extraction and report against the hidden gold package
-> reconcile deterministic and model findings
-> request human adjudication for declared cases
-> apply source-fidelity gate
-> emit Evaluation Decision Package
```

Candidate inputs:

- immutable source snapshot bundle;
- derived representation references;
- extraction or report artifact;
- exact Evaluation Policy revision;
- gold package reference for benchmark mode;
- risk and intended-use profile.

Candidate outputs:

- atomic extraction candidates;
- atomic report claims;
- claim-source bindings;
- deterministic validation findings;
- semantic evaluation findings;
- disagreement and adjudication records;
- multidimensional fidelity profile;
- Gate Decision;
- human-readable evaluation report;
- machine-readable Evaluation Decision Package.

## Candidate logical storage boundaries

- **Evaluator registry or control-plane database:** definitions, implementation revisions, policies, qualifications, findings, decisions, and lineage metadata.
- **Artifact store:** source snapshots, derived representations, raw evaluator outputs, prompt renderings, evidence packages, traces, and benchmark datasets.
- **Deployment and code system:** executable validator and evaluator packages or containers.
- **Knowledge graph:** semantic projections of evaluation and provenance relationships, not the only replay-critical system of record.
- **Audit or event log:** evaluator qualification, promotion, deprecation, policy changes, review, override, repair, and re-evaluation events.

## Relationship to LLM fine-tuning

The conversation also established that evaluator and workflow architecture should precede fine-tuning.

Fine-tuning may eventually improve recurring behavior such as:

- tool selection;
- ontology-shaped reasoning;
- Workflow Type reuse;
- StageGraph versus GoalDirected routing;
- schema-valid proposals;
- source-claim versus BellLabs-adjudication distinctions;
- provenance-obligation completeness;
- appropriate escalation.

Fine-tuning should not become the storage mechanism for:

- the live BellLabs ontology;
- current evaluator policies;
- permissions or authority;
- current Workflow Type contracts;
- exact tool schemas;
- changing source or scientific knowledge.

The governing rule remains:

> Put stable behavioral tendencies in weights. Put changing knowledge, schemas, permissions, policies, and authority in inspectable external systems.

## Decisions and strong working conclusions

1. Evaluators and gates are distinct.
2. Evaluation Findings are observations; Gate Decisions are governed consequences.
3. Determinism is multidimensional and does not imply correctness.
4. Semi-deterministic evaluation is best modeled as composition around probabilistic judgments.
5. Individual evaluators need stable definitions and exact versioned implementations.
6. Prompts and rubrics are first-class versioned evaluator artifacts.
7. Evaluation policies declare required capabilities, thresholds, independence, and escalation.
8. Coordinator agents select capabilities or policies and resolve approved implementations within constraints.
9. Workflow Types declare evaluation obligations that implementations and overlays cannot silently weaken.
10. Equivalent artifacts face equivalent domain admission gates regardless of whether StageGraph or GoalDirected produced them.
11. Temporal should own durable evaluation lifecycle; LangGraph may own bounded internal agentic state; BellLabs persistence owns canonical subjects, findings, and decisions.
12. Agent-based graders emit proposals or findings and do not possess admission authority merely because they are graders.
13. Source fidelity, source authority, evidence quality, and scientific truth are different questions.
14. Exact values, locators, quotations, units, and other structured fields should be checked deterministically wherever possible.
15. Generated reports should be decomposed into atomic claims before attribution is graded.
16. Semantic comparison is directional: report-to-source faithfulness and source-to-report completeness are separate.
17. Citation correctness and citation coverage are separate.
18. Multiple citations require individual and joint-support evaluation.
19. No single trust score should conceal critical unsupported or contradicted claims.
20. The gold standard for the prototype is a manually authored atomic gold package with exact source evidence, supplemented by deterministic checks and calibrated semantic evaluators.
21. The proposed `source-fidelity-evaluation` experiment is an appropriate isolated proof before canonical backend integration.

## Open questions

1. Which evaluator concepts belong in the existing BellLabs ubiquitous language and which require new formal terms?
2. Is `EvaluationWorkflowType` a specialized Workflow Type family or a separate catalog abstraction with a shared compiler?
3. Which evaluation operations use a dual inline/standalone execution model?
4. What is the exact evaluator qualification lifecycle from experimental to approved?
5. How are independence groups represented across model, prompt, provider, evidence context, and producing agent?
6. Which findings are sufficiently stable to replay under a new policy without rerunning the evaluator?
7. When must a model or prompt revision trigger re-evaluation of prior artifacts?
8. How should Temporal and LangGraph execution identifiers map to canonical Evaluation Runs and Attempts?
9. What are the exact source-locator contracts for HTML, PDF, tables, figures, and transformed text?
10. How should the system validate claim decomposition itself?
11. Which semantic comparison cases require two model graders, a different provider, or human adjudication?
12. What thresholds should the initial source-fidelity gate enforce?
13. Which metrics are benchmark-only because they require a hidden gold package, and which are available during ordinary production evaluation?
14. How should evaluation findings trigger repair, re-extraction, re-research, re-adjudication, or downstream invalidation?
15. Where should the isolated experiment live, and what exact promotion evidence is required before integrating it into the canonical backend?

## Recommended next step after the documentation refactor

Create the isolated `source-fidelity-evaluation` experiment with fixed synthetic fixtures and deliberately seeded failures.

The first successful proof should demonstrate that BellLabs can:

1. capture exact HTML and PDF source artifacts;
2. derive addressable representations with transformation provenance;
3. use OpenAI to produce structured extraction and a short attributed report;
4. validate exact values, units, quotes, and locators deterministically;
5. decompose the report into atomic claims;
6. grade claim-source attribution with a narrow structured semantic evaluator;
7. compare the results with a hidden, manually authored gold package;
8. preserve disagreement and indeterminate findings;
9. apply a separate deterministic fidelity gate;
10. execute the complete experiment through Temporal and LangGraph;
11. emit both a human-readable report and a machine-readable Evaluation Decision Package;
12. show exactly why each seeded good or bad output passed, failed, or escalated.

The experiment succeeds only if plausible-looking but unfaithful outputs are rejected for the correct reasons. A fluent report with citations is not enough.
