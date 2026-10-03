# Competency Questions

Status: provisional (catalog 0.2.0 candidate). Integrated by the integration owner on 2026-10-03 from the lane fragments of rounds 0002 to 0009. The questions define what the BellLabs graph helps people know; every Essential and Foundational question carries a trace from informational desire to the failure the model must prevent, and binds to a query shape in [query-shapes.md](./query-shapes.md).

How to read this file:

- Section 1 is the requirements header and the priority scheme (Essential now, Foundational, Expansion, Research frontier), with the answerability code (A = answerable by the proposed model, Q = answerable with qualifications, X = needs information outside the graph) and the audience code (C consumer, R researcher, O operator, A agent).
- Section 2 classifies the 0.1.0 starter questions (`CQ-ID`, `CQ-EV`, `CQ-TM`, `CQ-RC`) and gives their traces.
- Sections 3 to 7 add the domain questions by prefix: `CQ-ST` and `CQ-MX` (studies and mechanisms, rounds 0002 and 0003), `CQ-DX`, `CQ-PF`, `CQ-MF`, `CQ-CM` (diagnostics, declared amounts, manufacturing and regulatory readiness, commerce, rounds 0004 and 0005), `CQ-CL`, `CQ-PV`, `CQ-EC` (claims, provenance, ecosystem, round 0006), `CQ-TM-06/07`, `CQ-RC-07`, `CQ-PC`, `CQ-PR` (time, private context, protocols, rounds 0007 and 0008), and `CQ-AX` (access, audience, query shapes, round 0009).
- Section 8 holds the minimal adversarial pairs. Pairs 1 to 8 are the 0.1.0 set; 9 to 21 come from round 0009, 22 to 29 from round 0006, 30 to 36 from rounds 0002 and 0003, and the remainder from rounds 0007 and 0008. Each pair must produce different graph deltas.
- Section 9 is the acceptance target.

Integration rulings on overlapping desires: `CQ-AX-18` and `CQ-AX-26` restate the desires owned by `CQ-CL-05` and `CQ-CL-01/02`; the `CQ-CL` identifiers are the owners and the `CQ-AX` entries are access-tier pointers to them. `CQ-EV-04` is extended by round 0002 (dimensions) and round 0008 (the use target is a non-personal `UseContextProfile`; personal applicability lives in the private store). Examples are synthetic unless they cite a registry or publication identifier.

# 1. Requirements header and priority scheme

## 1.0 Requirements specification header

The ontology requirements specification practice (the NeOn methodology's ORSD, built on Grüninger and Fox competency questions) asks a requirements document to state purpose, scope, implementation language, intended users, intended uses, and requirements, with functional requirements written as competency questions ([SRC-NEON-ORSD-2012], [SRC-USCHOLD-GRUNINGER-1996]). This header is that record for the BellLabs catalog.

| ORSD field | BellLabs value |
|---|---|
| Purpose | Let people and agents ask what is known, from whom, as of when, and with what applicability, about supplements, studies, diagnostics, devices, and the claims made about them, without turning a source's statement or a name match into a fact. |
| Scope | Shared world model (public, sourced). Private user context is out of the shared model and is reached only by uid reference (Lane 5). |
| Implementation language | Neo4j 5 property graph, catalog `uid` identity, projected to the live Neo4j GraphQL API. Questions are restated as Cypher shapes in `query-shapes.md`. |
| Intended users | Consumer (C), Researcher (R), Operator (O), Agent (A). |
| Intended uses | Public answer with trace; operator audit; agent projection. Owner-private use is Lane 5. |
| Non-functional requirements | Every answer traceable to a source locator and an adjudication; reproducible as of a recorded date; no private data in shared answers; deterministic projection for identical requests. |
| Pre-glossary | assertion, source locator, snapshot, adjudication, applicability, recorded time, valid time, projection (as defined in `architecture.md` and `README.md`). |

Grüninger and Fox state that competency questions "do not generate ontological commitments; rather, they are used to evaluate the ontological commitments that have been made" ([SRC-GRUNINGER-FOX-1995], quoted at snippet level). That is why a question here earns a node, relationship, or property only through its trace, and why an informal question must be restated in query form before it counts as answered.

## 1.1 Scheme

### 1.1 Priority classes

Every question carries exactly one class.

**Essential now.** Needed for the first BellLabs decision trail: one public, traceable answer to "does this evidence apply to this product for this stated goal, and what is unknown", over the first fixture set (two products, two formulation versions, one trial, one case report, one conflicting marketing claim, one late-arriving correction), plus the access boundaries that keep that answer safe. Test: without it, the first trail is either impossible or silently wrong. A question whose wrong answer is a safety or privacy harm is never ranked below Foundational.

**Foundational.** Not needed to render the first trail, but absent at write time it makes later history unrecoverable or meaning ambiguous. Test: "could this be added later without re-reading sources or rewriting committed history?" If the answer is no, the question is Foundational. Typical members: recording a locator, keeping valid and recorded time apart, keeping identity separate from name, storing the viewpoint of a published answer.

**Expansion.** Valuable, with a clear additive extension path. It can be added later as new nodes or predicates and back-filled from stored sources and committed assertions, so deferring it loses nothing. Test: "can it be added later by new records alone?"

**Research frontier.** Limited today by evidence, methods, or consent. Even a perfect model would need data or methods that do not exist or are not permitted. The model records the seam and the honest "cannot answer" state, and nothing more.

### 1.2 Answerability

| Code | Meaning |
|---|---|
| A | Answerable by the proposed model. |
| Q | Answerable with qualifications. The qualification is stated, and it is part of the answer. |
| X | Needs information outside the graph. The missing information is named. |

### 1.3 Audience and access tier

| Tag | Who asks | Access tier | What the tier returns |
|---|---|---|---|
| C | Consumer | `PUBLIC_ANSWER` | Public answer with trace: assertion, locator, snapshot time, adjudication, qualification block (weakest applicability dimension, unresolved facts, time basis). Public identifiers only. No private context. |
| R | Researcher | `PUBLIC_ANSWER` | Same, plus reproducibility parameters (recorded-as-of, valid-at, schema digest, query shape). |
| O | Operator | `OPERATOR_AUDIT` | Internal: reviewer identity and type, extraction method, agent run lineage (`agentRunUid`, live `mongoResearchRunId`), status history, open resolution hypotheses, trace gaps. Private user content is excluded. Only counts and uids of private records may appear. |
| A | Agent | `AGENT_PROJECTION` | Schema slice and data slice for an intent, within budgets, through typed intents that a compiler turns into Cypher or GraphQL. No direct query access. Private content excluded unless Lane 5 delegates it per owner. |

A fourth tier, `OWNER_PRIVATE`, belongs to Lane 5 and is not defined here.

### 1.4 Trace format

Each Essential or Foundational question carries seven lines in this order, matching the mission file:

1. **Desire** (the informational desire)
2. **Example answer**
3. **Distinctions** (necessary distinctions)
4. **Evidence** (evidence requirements)
5. **Model** (nodes, relationships, properties)
6. **Query** (pattern; a `QS-n` id from `query-shapes.md`)
7. **Prevents** (the failure the model must prevent)

Expansion and Research frontier questions carry the desire, the answerability and the extension path or limit.

---

# 2. Classification of the existing questions

| ID | Question (unchanged) | Priority | Answerability |
|---|---|---|---|
| CQ-ID-01 | Is the marketed product in a study the same enduring product, variant, formulation version, or merely a similarly named product? | Essential now | Q |
| CQ-ID-02 | Which label or formulation was effective when a study intervention was administered? | Essential now | Q |
| CQ-ID-03 | Does a label declare a chemical substance, a material that realizes it, or a constituent the material is said to provide? | Foundational | A |
| CQ-ID-04 | Which external identifiers support a substance match, and at what authority/version? | Foundational | Q |
| CQ-ID-05 | Did a packaging-only change, formulation change, supplier/specification change, or product-identity change occur? | Foundational | Q |
| CQ-EV-01 | What exact proposition does a source make, and which span supports it? | Essential now | A |
| CQ-EV-02 | Is the proposition a source assertion, a BellLabs adjudication, or a derived retrieval shortcut? | Essential now | A |
| CQ-EV-03 | Which trials, case reports, observational studies, or marketing testimonials support or contradict the proposition? | Foundational | Q |
| CQ-EV-04 | Does evidence apply to the current formulation, dose, route, schedule, duration, population, comparator, and outcome? | Essential now | Q |
| CQ-EV-05 | Has a result been corrected, retracted, superseded, or contradicted without deleting the historical assertion? | Foundational | Q |
| CQ-TM-01 | What did BellLabs believe on recorded date `R` about facts valid on domain date `V`? | Essential now | A |
| CQ-TM-02 | When a late historical source arrives, can the system add past valid time without pretending BellLabs knew it earlier? | Essential now | A |
| CQ-TM-03 | Can the system distinguish publication time, observation time, study time, effective time, and ingestion time? | Foundational | A |
| CQ-TM-04 | Are unknown temporal bounds preserved as unknown rather than replaced with the current time? | Foundational | A |
| CQ-TM-05 | Can two nonexclusive assertions overlap while mutually exclusive states are rejected for overlapping intervals? | Foundational | Q |
| CQ-RC-01 | Why was one product preferred over another for a stated goal and decision context? | Essential now | Q |
| CQ-RC-02 | Which evidence, applicability assessments, constraints, price/availability observations, and policy version affected the decision? | Foundational | Q |
| CQ-RC-03 | Which missing or disputed facts could change the ranking? | Essential now | Q |
| CQ-RC-04 | Can a decision be replayed as of both its domain-time and system-time viewpoint? | Foundational | Q |
| CQ-RC-05 | Can the system distinguish "evidence favors," "BellLabs recommends," "a source recommends," and "a user selected"? | Essential now | A |
| CQ-RC-06 | Can contraindications or interaction uncertainty block a recommendation rather than merely lower a score? | Foundational | Q |

The first-slice acceptance target in the existing file listed CQ-ID-01, CQ-ID-02, CQ-EV-01, CQ-EV-04, CQ-TM-01, CQ-TM-02, CQ-RC-01 and CQ-RC-03. This scheme keeps all eight Essential and adds CQ-EV-02 (a trail that cannot say whether a sentence is a source's or BellLabs' is unsafe), CQ-RC-05 (the same reasoning for recommendations), and the access questions CQ-AX-01, CQ-AX-02, CQ-AX-07, CQ-AX-12, CQ-AX-13, CQ-AX-14 and CQ-AX-24.

Why CQ-RC-02, CQ-RC-04, CQ-RC-06 are Foundational and not Essential: the first trail is a public comparison for a stated goal. The personal decision, its replay and its safety block live in the private record (Lane 5, rounds 0007 and 0008) and the candidate safety module. They must be modeled now because a decision stored without its viewpoint and policy version cannot be replayed afterwards.

### Traces for the existing questions

#### CQ-ID-01 (Essential now, Q)
1. **Desire:** Know whether the product a study tested is the thing I can buy.
2. **Example answer (synthetic):** "Study S names Product P in its intervention text (assertion A1, locator L1). That is a mention. The historical label is not recovered, so the match to any `FormulationVersion` is unknown. The current label (observed 2026-07-10) declares formulation F2."
3. **Distinctions:** name continuity, enduring `Product`, `ProductVariant`, `FormulationVersion`; mention versus identity; formulation continuity versus evidence applicability (round 0001).
4. **Evidence:** the publication's intervention text; any historical label snapshot with `observedAt`; the current label snapshot; an adjudication of the match.
5. **Model:** `StudyIntervention`, `InterventionComponent`, `USES_INTERVENTION_MATERIAL`; `ProductVariant`, `HAS_FORMULATION_VERSION` (asserted edge with `validFrom/validTo`, `recordedFrom/recordedTo`, `assertionUid`); `ResolutionHypothesis` with `PROPOSES_MATCH` and `COMPETES_WITH`; `EvidenceApplicability.identityMatch`.
6. **Query:** QS-2b + QS-3a + QS-1a (`USES_INTERVENTION_MATERIAL`, `PROPOSES_MATCH`).
7. **Prevents:** linking a trial to the current formulation by default; treating a name match as identity.

#### CQ-ID-02 (Essential now, Q)
1. **Desire:** Know which label or formulation applied when the intervention was given.
2. **Example answer:** "Administration ran 2016-03 to 2016-09 (registry, `SOURCE_STATED`). Formulation versions believed on 2026-10-03 that overlap: none with a known start before 2019. The earlier formulation is unknown."
3. **Distinctions:** administration time versus publication time versus label retrieval time; unknown start versus no formulation.
4. **Evidence:** study dates with locator; label snapshots with `observedAt`; a source that dates a formulation.
5. **Model:** `Study`/`StudyIntervention` dates (valid time of the administration); `HAS_FORMULATION_VERSION` bitemporal attachment; `validTimeBasis`.
6. **Query:** QS-2b-interval; an empty result is read with QS-7.
7. **Prevents:** using the label "retrieved today" as the label effective in the past; using ingestion time as valid time.

#### CQ-ID-03 (Foundational, A)
1. **Desire:** See whether a label names a substance, a material, or a constituent a material provides.
2. **Example answer:** "The label declares the text 'X Blend (provides compound C)'. The declaration identifies material M (assertion, `PROPOSED`). Material M `PROVIDES_CONSTITUENT` C. No assertion states a measured amount of C."
3. **Distinctions:** `DECLARATION_IDENTIFIES_MATERIAL`, `REALIZES_SUBSTANCE`, `PROVIDES_CONSTITUENT`, `QUANTITATIVELY_CONTAINS` are four predicates, not one.
4. **Evidence:** verbatim label declaration with locator; a specification or analysis if a quantity is claimed.
5. **Model:** `LabelDeclaration`, `IngredientMaterial`, `ChemicalSubstance`, `Constituent`; `QUANTITATIVELY_CONTAINS` requires `quantity`, `unitCode`, `basis`.
6. **Query:** QS-1a with `$predicates` listing all four.
7. **Prevents:** reading "provides" as "contains N mg of"; collapsing label and measurement (INV-006).

#### CQ-ID-04 (Foundational, Q)
1. **Desire:** Know which external identifiers support a substance match, from which authority and release.
2. **Example answer:** "Substance S carries identifier (scheme UNII, value U, issuer FDA) asserted from authority snapshot T (retrieved 2026-09-01) and identifier (scheme CAS, value N) from snapshot T2. The name match to the paper's compound is a hypothesis with status `PROPOSED`."
3. **Distinctions:** identifier versus name; authority release version lives on the authority's `SourceSnapshot`, not on the identifier; materialized key versus `Identifier` record.
4. **Evidence:** authority record snapshot with content hash; resolution evidence for the mention.
5. **Model:** `Identifier` (scheme, value, issuer, jurisdiction, validFrom, validTo), `HAS_IDENTIFIER` (asserted; proposed name), `ResolutionHypothesis`.
6. **Query:** QS-8 to find candidates, then QS-1a on the `HAS_IDENTIFIER` assertion.
7. **Prevents:** merging two substances on a shared name or on a stale identifier; losing which authority release supplied an id.
Qualification: coverage depends on which authorities are ingested.

#### CQ-ID-05 (Foundational, Q)
1. **Desire:** Know what kind of change occurred between two points.
2. **Example answer:** "Between V1 and V2 the formulation changed (component C1 amount 250 mg to 300 mg), the package count did not. A supplier specification version also changed. Whether this also creates a new variant is open (Candidate B)."
3. **Distinctions:** `PackageConfiguration` change, `FormulationVersion` change, `SpecificationVersion` change, `ProductVariant` change.
4. **Evidence:** label or specification snapshots at both times.
5. **Model:** the four node types and their attachments; classification is a derived diff, not a stored fact (store it as an `Adjudication` only if a reviewer decides).
6. **Query:** QS-2b at two V values plus a component diff.
7. **Prevents:** treating a packaging change as a formulation change, or the reverse. Qualified because the variant-versus-formulation rule is open (`OPEN-QUESTIONS.md`, Priority 0, item 1).

#### CQ-EV-01 (Essential now, A)
1. **Desire:** Read exactly what a source asserts and where.
2. **Example answer:** "The page states 'supports healthy sleep' (assertion A, polarity positive, modality: marketing claim), locator: section 'Benefits', quote hash Q, snapshot observed 2026-07-10, content hash H."
3. **Distinctions:** the sentence versus its normalized proposition; negation, hedge, quantification; the source's reading versus BellLabs'.
4. **Evidence:** snapshot with content hash and `retrievedAt`; locator with selector or page and `quoteHash`.
5. **Model:** `Assertion` (`predicate`, `polarity`, `status`), `SUPPORTED_BY`, `SourceLocator`, `SourceSnapshot`, `Source`.
6. **Query:** QS-1a.
7. **Prevents:** a paraphrase with no span; a dropped qualification; a locator that cannot be reproduced.

#### CQ-EV-02 (Essential now, A)
1. **Desire:** Know whose statement a sentence is.
2. **Example answer:** "Sentence 1 is a source assertion (company page). Sentence 2 is a BellLabs adjudication (verdict `PARTIALLY_SUPPORTED`, reviewer type human, reviewed 2026-09-12). Sentence 3 is a derived shortcut (edge `CONTAINS` regenerated by rule R from assertions A3, A4)."
3. **Distinctions:** `Assertion`, `Adjudication`, derived edge (`class: derived`).
4. **Evidence:** the record kind and, for a derived edge, its derivation rule and source assertions.
5. **Model:** archetypes `Assertion` and `EvidenceAssessment`; derived edges carry `projectionOfAssertionUid` or `derivationRule` plus `derivedFromAssertionUids`.
6. **Query:** QS-1a (record kinds) and QS-4a.
7. **Prevents:** presenting a derived `CONTAINS` as something a source said, or an adjudicated verdict as a source's claim.

#### CQ-EV-03 (Foundational, Q)
1. **Desire:** See what supports and what contradicts a proposition, by evidence type.
2. **Example answer:** "For proposition P: one randomized trial supports for outcome O in population G (assertion A5, adjudicated `SUPPORTED`); a case report is consistent but is not comparable; a manufacturer testimonial supports and is not independent evidence; one observational study contradicts for a different dose."
3. **Distinctions:** support versus contradiction versus not comparable; evidence type; a restated or retold result is not a second line of evidence (CQ-AX-05).
4. **Evidence:** study design from the registry or paper, each with locator.
5. **Model:** `SUPPORTED_BY`, `CONTRADICTED_BY` on assertions and adjudications; `Study.studyKind`; `Publication REPORTS_ON Study`.
6. **Query:** QS-1a grouped by study kind.
7. **Prevents:** counting any edge as support. Qualified: "supports" needs the same proposition frame (predicate, population, outcome), which is a Lane 2 question (CQ-ST).

#### CQ-EV-04 (Essential now, Q)
1. **Desire:** Know whether study evidence transfers to my target product.
2. **Example answer:** "Weakest dimension: identity, `UNKNOWN` (no historical formulation). Also unresolved: dose, `PARTIAL` (studied 500 mg, label 250 mg). Population and outcome: `MATCH` for adults, `PARTIAL` for the outcome (surrogate). Missing facts: no `FormulationVersion` recorded for the study period."
3. **Distinctions:** formulation continuity is not applicability; each dimension is separate; `NOT_ASSESSED` differs from `UNKNOWN`.
4. **Evidence:** study intervention and arm facts; label or specification facts; an adjudicated assessment with method version.
5. **Model:** `EvidenceApplicability` (dimensions, `methodVersion`), `ASSESSES_APPLICABILITY_TO`, `BASED_ON_EVIDENCE`.
6. **Query:** QS-3a and QS-3b.
7. **Prevents:** a single score that hides the weakest dimension (INV-008); inheriting evidence from a shared ingredient or name.
Qualification: dimension values and the method belong to Lane 2 round 0002.

#### CQ-EV-05 (Foundational, Q)
1. **Desire:** See that a result changed without losing what it said before.
2. **Example answer:** "The 2026-01-10 assertion said start 2025-06-01. On 2026-06-20 a corrected label superseded it (new assertion, start 2025-09-01). Both remain. A reader asking as of 2026-03-01 sees the first."
3. **Distinctions:** correction (new recorded episode) versus change in the world versus retraction versus contradiction by another source.
4. **Evidence:** the new snapshot or retraction notice, itself a source with a locator.
5. **Model:** `Assertion`, `SUPERSEDES` (proposed, K-4), `Adjudication`, a retraction notice as a `Source` whose assertion refers to the publication (predicate to be named by Lane 2 or 4).
6. **Query:** QS-2a at R before and after; QS-2c.
7. **Prevents:** overwriting `status` or deleting the old assertion.
Qualification: retraction status needs an external feed; it is in the graph only if ingested.

#### CQ-TM-01 (Essential now, A)
1. **Desire:** Ask what was believed on R about V.
2. **Example answer:** see the worked example in `query-shapes.md` QS-2: the same V gives formulation F1 on R=2026-03-01 and F0 on R=2026-08-01.
3. **Distinctions:** valid time versus recorded time; `recordedAt` on assertions, `recordedFrom/recordedTo` on states and asserted edges.
4. **Evidence:** the recorded timestamps themselves, set by the system, never by a source.
5. **Model:** the four time properties; supersession encoded as a record.
6. **Query:** QS-2a, QS-2b.
7. **Prevents:** answering with the current belief and calling it historical.

#### CQ-TM-02 (Essential now, A)
1. **Desire:** Add a late historical fact without rewriting what the system knew.
2. **Example answer:** "On 2026-07-02 a source added formulation F0 valid 2024-01-01 to 2025-09-01. Asked as of 2026-03-01, F0 is not visible. Asked as of 2026-08-01, it is."
3. **Distinctions:** late arrival (recorded-time) versus change in the world (valid-time).
4. **Evidence:** the source's own dates (`publishedAt`, or the date the source states).
5. **Model:** new edge with a later `recordedFrom` and an earlier `validFrom`; no edit of existing rows.
6. **Query:** QS-2c.
7. **Prevents:** back-dating `recordedFrom`; moving existing valid time to fit.

#### CQ-TM-03 (Foundational, A)
1. **Desire:** Keep the five clocks apart.
2. **Example answer:** "Paper published 2019-05 (`publishedAt`); study ran 2016 (valid time of the administration); label observed 2026-07-10 (`observedAt`); label effective from 2025-09 (`effectiveFrom`); ingested 2026-10-01 (`recordedAt`)."
3. **Distinctions:** `publishedAt`, `observedAt`, valid time, `effectiveFrom/effectiveTo`, `recordedAt`.
4. **Evidence:** each from its own kind of source.
5. **Model:** one property family per clock on the right archetype.
6. **Query:** QS-2a return columns.
7. **Prevents:** one `date` field standing for several clocks.

#### CQ-TM-04 (Foundational, A)
1. **Desire:** Know when a time bound is unknown.
2. **Example answer:** "validFrom unknown; last confirmed 2026-07-10 (open end unverified)."
3. **Distinctions:** unknown start, open end, stale open end.
4. **Evidence:** the supporting snapshots' `observedAt`.
5. **Model:** null bounds; `validTimeBasis`; no sentinel dates.
6. **Query:** QS-2a, QS-2b classes (`UNKNOWN_START`, `OPEN_END_STALE`); V-104, V-105.
7. **Prevents:** replacing a null with the current time or a far-future sentinel.

#### CQ-TM-05 (Foundational, Q)
1. **Desire:** Allow overlapping non-exclusive facts, reject conflicting exclusive ones.
2. **Example answer:** "Two organizations both market Product P in 2026 (allowed). Two different current formulations of one variant in one jurisdiction at one time (rejected, flagged for review)."
3. **Distinctions:** exclusive versus non-exclusive predicates; scope (jurisdiction); overlap judged conservatively when bounds are unknown.
4. **Evidence:** the predicate registry; the intervals.
5. **Model:** predicate attribute `exclusivity` and scope keys (K-6).
6. **Query:** V-108.
7. **Prevents:** silently keeping two incompatible current states. Qualified: Neo4j cannot enforce interval overlap, so the rule is service-enforced.

#### CQ-RC-01 (Essential now, Q)
1. **Desire:** Understand why one product was preferred for a stated goal.
2. **Example answer (public tier):** "For goal G in adults, Product P1 is ranked above P2 under policy v3 because P1's evidence has fewer unresolved dimensions (QS-3 results attached). This is a comparison, not advice to a person."
3. **Distinctions:** a decision is an occurrence, not a `Product-[:RECOMMENDED_FOR]->Goal` edge.
4. **Evidence:** the criteria, applicability assessments, constraints, observations, policy version.
5. **Model:** `RecommendationDecision`, `RecommendationCandidate`, `DecisionCriterion`, `PolicyVersion` (candidate module; personal instances are private, Lane 5).
6. **Query:** QS-1a on the explanation, QS-3a, QS-6a.
7. **Prevents:** a timeless recommendation edge; a public answer that reads as personal advice.
Qualification: personal decisions live in the private store.

#### CQ-RC-02 (Foundational, Q)
1. **Desire:** List what influenced a decision.
2. **Example answer:** "Evidence versions E1, E2; applicability assessments AP1, AP2 (method m2); constraint set C; price observation 2026-09-30; availability observed 2026-10-01; policy v3."
3. **Distinctions:** each influence is a versioned record, referenced, not copied.
4. **Evidence:** the referenced records and their times.
5. **Model:** `RecommendationCandidate BASED_ON EvidenceApplicability`; offer and price observations as `Occurrence`; `USED_POLICY`.
6. **Query:** QS-1a + QS-3a + QS-2b (offers).
7. **Prevents:** a decision that cites "current" data and cannot show which version.
Qualification: price and availability depend on what was observed and when.

#### CQ-RC-03 (Essential now, Q)
1. **Desire:** Know which unknowns could change the ranking.
2. **Example answer:** "P1 over P2 would reverse if the historical formulation matches P2's tested dose (identity `UNKNOWN`) or if assertion A9 (disputed) is accepted."
3. **Distinctions:** missing versus disputed versus conflicting.
4. **Evidence:** the unresolved dimensions and disputed assertions.
5. **Model:** `EvidenceApplicability` dimensions with `missingFacts`; competing assertions and SUPPORT adjudication verdicts (an assertion's `status` is capture fidelity and never carries the dispute about truth); missing-fact codes.
6. **Query:** QS-3a, QS-3b.
7. **Prevents:** a ranking presented as settled.
Qualification: the reversal test is computed by the decision service, which re-ranks under counterfactual values. The graph supplies the unknowns.

#### CQ-RC-04 (Foundational, Q)
1. **Desire:** Replay a decision as it was.
2. **Example answer:** "Re-running with R=2026-09-20 and V=2026-09-20 under schema digest D reproduces candidate list L."
3. **Distinctions:** domain-time and system-time viewpoints stored with the decision.
4. **Evidence:** the stored viewpoints and the algorithm or policy version.
5. **Model:** the decision stores `recordedAsOf`, `validAt`, `schemaDigest`, `policyVersion`.
6. **Query:** QS-2 with the stored parameters.
7. **Prevents:** a decision whose inputs are lost.
Qualification: the algorithm code is outside the graph.

#### CQ-RC-05 (Essential now, A)
1. **Desire:** Keep four stances apart.
2. **Example answer:** "Evidence favors P1 for outcome O (`EvidenceAssessment`). BellLabs' policy v3 ranks P1 first (decision record). A named speaker recommends P2 (assertion from episode E, span S). A user selected P2 (private record)."
3. **Distinctions:** assessment, decision, source recommendation, user choice.
4. **Evidence:** four different record types.
5. **Model:** `EvidenceAssessment`; `RecommendationDecision`; `Assertion` with predicate `RECOMMENDS` and `ASSERTED_BY`; private selection (Lane 5). The live `Person.recommends` edge with `RecommendationMetadata.strength` is a source stance only.
6. **Query:** QS-1a with the record kind; QS-6a.
7. **Prevents:** reading a speaker's recommendation as BellLabs' recommendation.

#### CQ-RC-06 (Foundational, Q)
1. **Desire:** Let a safety constraint block, not just reduce a score.
2. **Example answer:** "Candidate P3 is `BLOCKED` for use with condition K (constraint assertion C7, locator, adjudicated). Interaction data for medication M is missing, which also blocks under policy v3."
3. **Distinctions:** hard constraint versus score; missing interaction data versus no interaction.
4. **Evidence:** contraindication or interaction assertions with locators.
5. **Model:** `UseConstraint`, `ContraindicationAssertion`, `InteractionAssertion` (candidate module `safety_and_constraints`).
6. **Query:** QS-1a over constraint assertions (illustrative; module is candidate).
7. **Prevents:** a blend that scores a contraindicated product as acceptable.
Qualification: the person's conditions and medications are private; the shared graph is queried with public condition and substance uids only.

---



# 3. Studies and mechanisms (CQ-ST, CQ-MX; extensions to CQ-EV and CQ-ID) from rounds 0002 and 0003

## Catalog entries

### Evidence and claims (extensions)

| ID | Question | Priority | Answerability |
|---|---|---|---|
| `CQ-EV-04` (extended) | Does evidence apply to the current formulation, dose, route, schedule, duration, population, comparator, and outcome, dimension by dimension, and which dimensions are unknown? | Essential now | Q: dimensions answerable; verdict thresholds are method-versioned and uncalibrated |
| `CQ-EV-05` (extended) | Has a result or publication been corrected, retracted, or superseded, and which assertions, applicability assessments, and syntheses rely on it? | Foundational | Q: needs Lane 4 Publication-to-Source alignment and Lane 5 correction events |
| `CQ-EV-06` (new) | For an applicability assessment, which dimensions are `UNKNOWN`, and which specific missing fact would resolve each? | Essential now | A |

### Identity (extension)

| ID | Question | Priority | Answerability |
|---|---|---|---|
| `CQ-ID-06` (new) | Which material (branded material, chemical form, supplier, specification) did a study administer, and is it the same material as a current product's component, or only the same substance? | Essential now | Q: often UNRESOLVED; the model represents competing hypotheses, sources rarely settle lot-level supply |

### Studies (`CQ-ST`)

| ID | Question | Priority | Answerability |
|---|---|---|---|
| `CQ-ST-01` | For each arm, what was administered: material, chemical form, amount with quantity and mass basis, dosage form, route, schedule, duration; and who provided the investigational product? | Essential now | A |
| `CQ-ST-02` | Which commercial products share a substance or material with a study intervention, and through what path (same lot, formulation, branded material, substance only)? | Essential now | A |
| `CQ-ST-03` | Which outcomes are biomarkers, surrogate endpoints (in which context of use and at what validation level), intermediate clinical endpoints, or clinical outcomes, and who classified them? | Essential now | Q: classification is a BellLabs assessment; validation levels exist for regulatory contexts only |
| `CQ-ST-04` | What were the registered primary outcomes in the earliest registration version, and does any publication relabel priority? | Foundational | Q: needs registry history (not retrievable in this session) |
| `CQ-ST-05` | When the primary result is null, which favorable findings are secondary, subgroup, within-arm, or post hoc, and does any synthesis or claim rely on them as confirmatory? | Essential now | A |
| `CQ-ST-06` | Which adverse events were systematically collected and reported per arm, which were not reported, and how do safety findings compare across studies of different materials and doses? | Foundational | Q: cross-study comparison needs applicability on both sides |
| `CQ-ST-07` | Which publications share a study population or dataset, and so are not independent evidence? | Foundational | Q: shared datasets are often undisclosed; the model records only declared reuse |
| `CQ-ST-08` | As of an observation date, what does the registry establish (status, enrollment actual or estimated, results posted), and where do registry and publication disagree? | Foundational | A for observed versions; O for unobserved history |
| `CQ-ST-09` | Which findings published, or recorded by BellLabs, in a stated period changed a claim-level synthesis, by which criteria, with what effect, and with which provenance? | Essential now | A |
| `CQ-ST-10` | Is a result "clinically meaningful" according to the authors, according to a BellLabs criterion (threshold and its source), or neither? | Expansion | Q: MCID sources are outcome- and population-specific and often absent |

### Mechanisms (`CQ-MX`)

| ID | Question | Priority | Answerability |
|---|---|---|---|
| `CQ-MX-01` | For a mechanism story, which steps were directly measured, inferred, cited, or hypothesized, and by which source? | Essential now | A (requires KCR-3a) |
| `CQ-MX-02` | For each measured step: species and model, tissue, cell or compartment, setting, tested material, exposure amount, unit, basis, route, duration? | Essential now | Q: preclinical doses frequently need full-text extraction |
| `CQ-MX-03` | Has a step measured in one species or compartment been measured in humans, with what direction (including null)? | Foundational | A |
| `CQ-MX-04` | Does a commercial formulation plausibly deliver the exposure under which an ingredient-level effect was observed (dose ratio on matched bases, human exposure data for the target material and form)? | Essential now | Q: human PK for a specific commercial form is usually missing; answer is often UNKNOWN with listed missing facts |
| `CQ-MX-05` | Which mechanism shortcuts in the live graph rest on hypotheses, citations, or retracted sources rather than measurements? | Foundational | A |
| `CQ-MX-06` | Where does an effect reverse direction with dose, and over what tested range? | Expansion | Q: depends on multi-dose contexts per source |

## Traces (Essential now and Foundational)

Format: Informational desire -> example answer -> necessary distinctions -> evidence requirements -> nodes, relationships, properties -> query pattern -> failure the model must prevent.

### CQ-EV-04 (extended) and CQ-EV-06

- **Desire:** "Does the NRPT trial support the Basis I can buy, and what is missing?"
- **Example answer:** "Partially. Same two declared actives and the same nominal 250 mg NR + 50 mg PT, oral capsules. Unknown: which NR material the 2016 trial used (Elysium provided the capsules; ChromaDex says it supplied Elysium's NR until mid-2016; current label names Elysium NR-E), whether '250 mg NR' is salt or cation mass, label servings per day. Evidence is an 8-week whole-blood NAD+ biomarker in healthy 60 to 80 year olds."
- **Distinctions:** naming vs identity; substance vs material vs formulation; quantity basis vs mass basis; UNKNOWN vs NOT_ASSESSED; categorical vs continuous vs explanation-only dimensions.
- **Evidence requirements:** paper Methods locator; correction locator; label snapshot locator; resolution hypotheses for trial material.
- **Model:** `EvidenceApplicability` -`HAS_EVIDENCE_TARGET`-> `StudyIntervention`; -`ASSESSES_APPLICABILITY_TO`-> `FormulationVersion`; -`HAS_DIMENSION`-> `ApplicabilityDimension {dimension, dimensionClass, verdict, identityLevel, evidenceValue, targetValue, *QuantityBasis, *MassBasis, ratio, missingFacts, rationale}` -`SUPPORTED_BY`-> `SourceLocator`.
- **Query pattern (illustrative):**
  ```cypher
  MATCH (ea:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(:FormulationVersion {uid: $formulationUid}),
        (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
  OPTIONAL MATCH (d)-[:SUPPORTED_BY]->(loc:SourceLocator)
  RETURN ea.uid, d.dimension, d.verdict, d.missingFacts, collect(loc.uri) AS sources
  ORDER BY CASE d.verdict WHEN 'MISMATCH' THEN 0 WHEN 'UNKNOWN' THEN 1 WHEN 'PARTIAL' THEN 2 ELSE 3 END;
  ```
- **Failure prevented:** a direct `Study -EVALUATES-> Product` edge or a single unexplained score that hides the unresolved material.

### CQ-EV-05 (extended)

- **Desire:** "Was the NRPT paper corrected, and does that change anything we rely on?"
- **Example answer:** "Yes, an Author Correction (PMID 30155270, 2018-08-20) replaced a citation and added that Elysium provided the investigational product. It changes the material-identity provenance, not the results."
- **Distinctions:** correction vs retraction vs expression of concern; correction as new recorded episode vs change of valid time.
- **Evidence requirements:** PubMed publication type, correction text locator.
- **Model:** `Publication {publicationKind}` -`CORRECTS|RETRACTS`-> `Publication`; dependent `Assertion`s via `SUPPORTED_BY` locators; `EvidenceSynthesis -TRIGGERED_BY {criterionCode: CORRECTION_OR_RETRACTION}`.
- **Query pattern:** V-235 (illustrative) plus `MATCH (c:Publication)-[:CORRECTS|RETRACTS]->(p:Publication {pmid: $pmid}) RETURN c`.
- **Failure prevented:** deleting or silently editing assertions from a retracted or corrected source.

### CQ-ID-06

- **Desire:** "Was the NR in the 2016 Basis trial the same material as the NR in today's Basis?"
- **Example answer:** "Unresolved. Two competing hypotheses: ChromaDex NIAGEN (supported only by ChromaDex's attributed statement in C&EN) and Elysium NR-E (supported only by the current label naming). No lot-level source."
- **Distinctions:** provided-the-product vs supplied-the-material; branded material vs chemical form vs substance.
- **Evidence requirements:** correction text, trade-press statement attributed to its speaker, current label.
- **Model:** `IngredientMaterial {materialKind: UNRESOLVED_MATERIAL}`; `ResolutionHypothesis -PROPOSES_MATCH->` x2, `COMPETES_WITH`; `PROVIDES_INVESTIGATIONAL_PRODUCT` assertion; `SUPPLIES_INGREDIENT_MATERIAL` assertion `ASSERTED_BY` ChromaDex, status `ACCEPTED` (an accurate record of what ChromaDex said) while its truth is contested through the competing `ResolutionHypothesis` records and any SUPPORT adjudication.
- **Query pattern:** `MATCH (h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(:IngredientMaterial {uid: $trialMaterial}) MATCH (h)-[:PROPOSES_MATCH]->(c) WHERE c.uid <> $trialMaterial RETURN h.resolutionStatus, c.name, h.rationale`.
- **Failure prevented:** merging trial material with a current branded material by name.

### CQ-ST-01

- **Desire:** "Exactly what did each arm take?"
- **Example answer:** "NRPT 1X: two capsules of 125 mg NR + 25 mg PT plus two placebo capsules once daily at breakfast for 8 weeks (250 mg NR + 50 mg PT per day; mass basis unspecified); capsules provided by Elysium Health."
- **Distinctions:** per-capsule vs per-day; dosage form on intervention vs on material; provider vs supplier.
- **Evidence requirements:** Methods "Intervention" locator; correction locator.
- **Model:** `StudyArm -ASSIGNS_INTERVENTION-> StudyIntervention {route, dosageForm, schedule, dosesPerDay, durationIso} -HAS_INTERVENTION_COMPONENT-> InterventionComponent {quantity, unitCode, quantityBasis, massBasis, verbatimDoseText} -USES_INTERVENTION_MATERIAL-> IngredientMaterial`.
- **Query pattern:** `MATCH (:Study {uid: $s})-[:HAS_ARM]->(a)-[:ASSIGNS_INTERVENTION]->(si)-[:HAS_INTERVENTION_COMPONENT]->(ic)-[:USES_INTERVENTION_MATERIAL]->(m) RETURN a.name, si.dosageForm, si.durationIso, ic.quantity, ic.unitCode, ic.massBasis, m.name`.
- **Failure prevented:** live `InterventionArmMetadata.doseText` as the only dose record; dose without basis.

### CQ-ST-02

- **Desire:** "Which products on the market relate to this trial's intervention, and how closely?"
- **Example answer:** "Tru Niagen 300 mg uses the same branded material (NIAGEN) as the 300 mg arm of NCT02712593 (spec version unknown); Basis shares only the substance and adds pterostilbene."
- **Distinctions:** path type determines identity level.
- **Evidence requirements:** intervention material and formulation components, both asserted with locators.
- **Model:** paths through `USES_INTERVENTION_MATERIAL`, `USES_MATERIAL`, `REALIZES_SUBSTANCE`, `HAS_CHEMICAL_FORM`, `FORM_OF_SUBSTANCE`.
- **Query pattern (illustrative):**
  ```cypher
  MATCH (si:StudyIntervention {uid: $si})-[:HAS_INTERVENTION_COMPONENT]->(:InterventionComponent)-[:USES_INTERVENTION_MATERIAL]->(m:IngredientMaterial)
  MATCH (f:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(m2:IngredientMaterial)
  WHERE m2 = m OR EXISTS { MATCH (m)-[:REALIZES_SUBSTANCE]->(s:ChemicalSubstance)<-[:REALIZES_SUBSTANCE]-(m2) }
  RETURN f.uid, CASE WHEN m2 = m THEN 'SAME_MATERIAL' ELSE 'SAME_SUBSTANCE_ONLY' END AS path;
  ```
- **Failure prevented:** substance-level match reported as product evidence (INV-008).

### CQ-ST-03

- **Desire:** "Is the NAD+ result a surrogate for anything I care about? Is the LDL-C change?"
- **Example answer:** "Whole-blood NAD+ is a pharmacodynamic biomarker with no established surrogate context. LDL-C is a safety biomarker in this trial; FDA lists serum LDL-C as a surrogate for traditional approval of lipid-lowering drugs in hypercholesterolemia, a context that does not match."
- **Distinctions:** measured kind vs endpoint role vs surrogate context of use vs personal importance.
- **Evidence requirements:** FDA surrogate table row; BEST definitions; study outcome definitions.
- **Model:** `OutcomeDefinition {measureKind} -MEASURES_BIOMARKER-> Biomarker`; `EndpointClassification -CLASSIFIES_OUTCOME|CLASSIFIES_BIOMARKER->`, `-COMPARED_WITH_CONTEXT->`.
- **Query pattern:** `MATCH (ec:EndpointClassification)-[:CLASSIFIES_OUTCOME]->(od:OutcomeDefinition {uid: $od}) OPTIONAL MATCH (ec)-[:COMPARED_WITH_CONTEXT]->(ctx) RETURN ec.endpointClass, ec.biomarkerCategory, ec.contextMatch, ctx.contextDiseaseOrUse, ctx.surrogateValidationLevel`.
- **Failure prevented:** surrogate status as a biomarker attribute transferring across contexts.

### CQ-ST-04

- **Desire:** "Did the paper headline the registered primary outcome?"
- **Example answer:** "No. Registry primary outcomes are blood pressure, safety blood parameters, and heart rate; blood NAD+ is registered as secondary. The Discussion calls NAD+ 'the major efficacy endpoint'. Registry history was not available, so we cannot say whether the registered outcomes changed."
- **Distinctions:** registered vs published priority; observed registry version vs history.
- **Evidence requirements:** `RegistrationVersion` with `versionDate`; publication locators.
- **Model:** `DECLARES_OUTCOME_PRIORITY` assertions per source; `OutcomeDefinition -DEFINED_IN-> RegistrationVersion|Publication`.
- **Query pattern:** V-223.
- **Failure prevented:** a single `isPrimary` boolean that takes whichever source was ingested last.

### CQ-ST-05

- **Desire:** "The product page says strength rose 12%. Was that the trial's main result?"
- **Example answer:** "No. In ATLAS (NCT03464500) the registered and reported primary endpoint, peak power output, was not significant; ~12% strength was a secondary outcome. In ENERGIZE (NCT03283462) both primary endpoints (6MWD, ATPmax) were not significant; endurance was secondary."
- **Distinctions:** analysisKind; comparisonKind; not-significant vs no-effect.
- **Evidence requirements:** registry primary outcomes; paper abstracts.
- **Model:** `StudyResult {analysisKind, comparisonKind, statisticalConclusion}`; `ResultInterpretation`; `EvidenceSynthesis -INCLUDES_RESULT {inputRole}->`.
- **Query pattern:** V-215 and `MATCH (s:Study)-[:DEFINES_OUTCOME]->(od)<-[:RESULT_FOR]-(r:StudyResult) RETURN od.name, r.analysisKind, r.comparisonKind, r.statisticalConclusion`.
- **Failure prevented:** secondary or within-arm findings presented as the confirmatory result.

### CQ-ST-06

- **Desire:** "Were there safety concerns, and do other NR trials agree?"
- **Example answer:** "NRPT trial: 66 AEs in 45 participants, similar across arms, no serious AEs reported, systematic collection; small within-group LDL-C increases confounded by baseline imbalance. Conze (NIAGEN, different material, no pterostilbene, younger overweight adults) reported no LDL elevation. These differ on material, co-ingredient, and population, so they are not a direct contradiction."
- **Distinctions:** reported zero vs not reported; per-arm counts vs between-arm tests; cross-study comparison requires applicability.
- **Evidence requirements:** AE section locators; lipid section locators.
- **Model:** `AdverseEventResult`; `EvidenceSynthesis {inputRole: SAFETY}`.
- **Query pattern:** `MATCH (ae:AdverseEventResult)-[:RESULT_FOR_ARM]->(a:StudyArm)<-[:HAS_ARM]-(:Study {uid: $s}) RETURN a.name, ae.eventTerm, ae.seriousness, ae.participantsAffected, ae.collectionMethod`.
- **Failure prevented:** "no AEs reported" stored as "no AEs occurred"; cross-material safety merged.

### CQ-ST-07

- **Desire:** "Are these two papers independent confirmations?"
- **Example answer:** "Not if they analyze the same trial or dataset. For NCT02678611 only one results article and its correction exist in the packet; data are available on request."
- **Distinctions:** study vs dataset vs publication; declared vs undeclared reuse.
- **Model:** `PRODUCED_DATASET`, `ANALYZES_DATASET {analysisRole}`, `REPORTS_ON`.
- **Query pattern:** `MATCH (p1:Publication)-[:REPORTS_ON|ANALYZES_DATASET]->(x)<-[:REPORTS_ON|ANALYZES_DATASET]-(p2:Publication) WHERE p1.uid < p2.uid RETURN p1.pmid, p2.pmid, labels(x)`.
- **Failure prevented:** double counting (V-218).

### CQ-ST-08

- **Desire:** "What can the registry tell me, and what can't it?"
- **Example answer:** "As observed 2026-10-03: completed, enrollment 120, one Canadian site, no results posted. The paper reports results and three sites (Canada and US). The registry cannot tell us whether results were published or which material was used."
- **Distinctions:** observedAt vs versionDate; resultsPosted vs published; estimated vs actual enrollment.
- **Model:** `TrialRegistration -HAS_REGISTRATION_VERSION-> RegistrationVersion {observedAt, versionDate, overallStatus, enrollmentCount, enrollmentCountType, resultsPosted, siteCountries, ...}`.
- **Query pattern:** V-212.
- **Failure prevented:** live `Study.hasResults = false` read as unpublished; status overwritten on resync.

### CQ-ST-09

- **Desire:** "What changed our view on NR and muscle mitochondria in 2019, and why?"
- **Example answer:** "On 2019-09-15 the synthesis was superseded after Elhassan et al. (published 2019-08-13) measured unchanged mitochondrial respiration, citrate synthase, and mtDNA in aged human muscle at 1 g/day for 21 days. Criterion HUMAN_DIRECT_MEASUREMENT_NULL; effect WEAKENED; verdict label remained INSUFFICIENT."
- **Distinctions:** publication date vs BellLabs recorded date; verdict change vs strength change.
- **Model:** `EvidenceSynthesis {verdict, evidenceCutoff, recordedAt, methodVersion} -SUPERSEDES->`, `-TRIGGERED_BY {criterionCode, effectOnVerdict}->`.
- **Query pattern (illustrative):**
  ```cypher
  MATCH (v:EvidenceSynthesis)-[t:TRIGGERED_BY]->(x)
  WHERE t.evidencePublishedAt >= date($from) AND t.evidencePublishedAt < date($to)   // or v.recordedAt in range
  MATCH (v)-[:SUPERSEDES]->(prev:EvidenceSynthesis)
  RETURN v.claimText, prev.verdict, v.verdict, t.criterionCode, t.effectOnVerdict, x.uid, v.recordedAt;
  ```
- **Failure prevented:** overwriting assessments so that change and its reason are lost.

### CQ-MX-01, CQ-MX-02, CQ-MX-03

- **Desire:** "NR is said to boost NAD+, activate sirtuins, and improve mitochondria. Which of that was shown in people, where, and at what dose?"
- **Example answer:** see the table in round 0003 (blood NAD+ measured in humans at 250 to 1000 mg/day; muscle NAD+ metabolome measured in 12 aged men at 1 g/day for 21 days; sirtuin activity hypothesized in the Basis paper and measured-null by an acetylation proxy in human muscle; mitochondrial function improved in mice, unchanged in human muscle).
- **Distinctions:** basisKind; compartment-specific measurand; species; exposure basis.
- **Model:** `Assertion {basisKind, polarity}` -`OBSERVED_IN_CONTEXT`-> `MechanismEvidenceContext` -`IN_SPECIES|MEASURED_IN|EXPOSED_TO|IN_STUDY_ARM`->.
- **Query pattern (illustrative):**
  ```cypher
  MATCH (a:Assertion {predicateClass: 'MECHANISM'})-[:HAS_OBJECT]->(o)
  WHERE o.uid IN $stepObjects
  OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c)-[:IN_SPECIES]->(sp)
  OPTIONAL MATCH (c)-[:MEASURED_IN]->(site)
  RETURN o.name, a.predicate, a.basisKind, a.polarity, sp.scientificName, site.name, c.exposureAmount, c.exposureUnit, c.exposureDurationIso;
  ```
- **Failure prevented:** hypotheses and mouse results returned as human measured facts; blood results joined to tissue steps.

### CQ-MX-04

- **Desire:** "Does the product dose get me what the study saw?"
- **Example answer:** "Unknown for Basis vs the Elhassan muscle finding: 1 g/day (basis unspecified) vs 250 mg NR chloride per serving, no human muscle data for Basis's material and dose."
- **Model:** `EvidenceApplicability -HAS_EVIDENCE_TARGET-> Assertion`, `ApplicabilityDimension {dimension: EXPOSURE}`, `BASED_ON_EVIDENCE -> StudyResult` (human exposure).
- **Query pattern:** V-237 and the CQ-EV-04 pattern filtered to `EXPOSURE`.
- **Failure prevented:** ingredient mechanism transferred to a product without exposure evidence (FI-303).

### CQ-MX-05

- **Desire:** "Which mechanism links in our graph are only hypotheses?"
- **Example answer:** lists of live `AFFECTS_MECHANISM` / `MODULATES` edges without a projected `DIRECT_MEASUREMENT` assertion.
- **Model:** derived edges with `projectionOfAssertionUid`.
- **Query pattern:** V-233, V-234, V-235.
- **Failure prevented:** shortcut edges becoming the only record of a mechanism claim.


# 4. Diagnostics, declared amounts, manufacturing and regulatory readiness, commerce (CQ-DX, CQ-PF, CQ-MF, CQ-CM) from rounds 0004 and 0005

## Diagnostics and devices

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-DX-01` | What does a test measure (measurand, specimen type, method principle, instrument), as distinct from what it infers? | Essential now | A | 0004 |
| `CQ-DX-02` | Is a result measured, calculated from measured values, or inferred by a model, and which assay version or algorithm version produced it? | Essential now | A | 0004 |
| `CQ-DX-03` | Can two similarly named tests, or one lab's test before and after a method change, share a trend axis, and with which conversion rule? | Essential now | Q (depends on labs publishing assay detail) | 0004 |
| `CQ-DX-04` | Which algorithm or model version produced a score, and is the version stated by the source, inferred from a publication, or unknown? | Essential now | A | 0004 |
| `CQ-DX-05` | Is a difference between two scores within one algorithm version larger than the documented technical noise for that version? | Foundational | Q (needs a reliability source per version; research frontier for most vendor pipelines) | 0004 |
| `CQ-DX-06` | Which reference interval applied when the result was reported (kind, partition, derivation, version), and is it a reference interval or a decision limit? | Foundational | A | 0004 |
| `CQ-DX-07` | What can a model-derived feature service establish about its cohort, feature definition, unit, and model version, and what can it not? | Foundational | A | 0004 |
| `CQ-DX-08` | Is a diagnostic result synthetic, public aggregate, or private personal, and can a query over public evidence return a private result? | Foundational | Q (placement owned by Lane 5; see CQ-PC) | 0004 |
| `CQ-DX-09` | Which device firmware or app version produced a wearable metric? | Expansion | O today (consumer_devices stays future) | 0004 |

## Products and formulations (declared amounts)

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-PF-01` | Is a declared amount the listed ingredient as named, a nutrient (not its source), a blend total, an extract mass, or a marker constituent, and which calculated amounts (active moiety, nutrient equivalent) follow from it with which rule? | Essential now | A for US Supplement Facts; Q elsewhere | 0005 |
| `CQ-PF-02` | Does an amount shown in a listing title or marketing claim match the label declaration observed for the same variant? | Foundational | Q (needs a label snapshot) | 0005 |
| `CQ-PF-03` | Does a certification, lot test summary, or regulatory status attach to a product, a variant, a lot, a listed product ID, or a facility? | Essential now | A | 0005 |
| `CQ-PF-04` | Do the conditions of use in a notification response (dose, food category, level) cover the material form and dose in a given formulation? | Foundational | Q (condition text is preserved; matching is an applicability assessment) | 0005 |

## Manufacturing and regulatory readiness

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-MF-01` | Who manufactures, supplies, contract-manufactures, or only markets a material or product, according to which source and when? | Essential now | A | 0005 |
| `CQ-MF-02` | What regulatory status does X have in jurisdiction J at time T, which submission and response produced it, and is it approval, clearance, De Novo authorization, designation, notification on file, establishment registration, or enforcement discretion? | Essential now | A | 0005 |
| `CQ-MF-03` | Does a company's characterization of an agency action (wording, conditions, scope) match the agency record? | Essential now | A | 0005 |
| `CQ-MF-04` | Which manufacturing capabilities are operating, piloting, planned, suspended, or discontinued, asserted by whom, over which valid time? | Foundational | Q (filings rarely give capacity) | 0005 |
| `CQ-MF-05` | What did a specific filing disclose versus what the same company promoted elsewhere in the same period? | Foundational | A | 0005 |
| `CQ-MF-06` | Does a facility registration, a cGMP claim, a GMP certification, or an inspection outcome support a quality conclusion, for which facility and period? | Foundational | Q (inspections are expansion) | 0005 |

## Commerce

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-CM-01` | Who hosts the listing, who placed the offer, who is seller of record, who fulfills, and who earns affiliate compensation, as observed when? | Essential now | A | 0005 |
| `CQ-CM-02` | Which offers existed for a product variant on date D, and is the listing-to-variant identity resolved or only proposed? | Foundational | Q (OPEN-QUESTIONS quality and commerce item 3) | 0005 |
| `CQ-CM-03` | What price and availability were observed, of which price kind (list, one-time, subscription, coupon-adjusted, per unit), at what time? | Essential now | A | 0005 |
| `CQ-CM-04` | Which media recommendations carry an affiliate link to which offer? | Expansion | Q (Lane 4 owns speaker attribution) | 0005 |
| `CQ-CM-05` | When an offer is no longer observed, did it end, or did observation stop? | Foundational | A (unknown end stays null) | 0005 |

## Traces (Essential now and Foundational)

### CQ-DX-01
- Desire: know what a test actually measures before reasoning about it.
- Example answer: "Lab A 'Hemoglobin A1c' measures LOINC 4548-4 (HbA1c/Hb total, mass fraction, whole blood) by cation-exchange HPLC on Tosoh G8 software 5.24 until 2025-06-01, then by immunoassay on cobas c513."
- Distinctions: biological referent versus measurand versus orderable test versus assay version versus method principle; specimen type versus specimen instance.
- Evidence: LOINC part model (SRC-LOINC-4548-4); lab method notices; NGSP lists.
- Model: `Biomarker`, `Metric` (+ `Identifier` LOINC), `LabTest`, `AssayVersion`, `MeasurementMethod`, `ToolOrInstrument`, `Specimen`; `MEASURES_METRIC`, `PERFORMED_WITH_ASSAY_VERSION`, `USES_METHOD`, `RUNS_ON_INSTRUMENT`, `ACCEPTS_SPECIMEN_TYPE`.
- Query (illustrative): `MATCH (t:LabTest {uid:$t})-[e:PERFORMED_WITH_ASSAY_VERSION]->(a)-[:USES_METHOD]->(m) WHERE e.recordedTo IS NULL RETURN a, m, e.validFrom, e.validTo`.
- Failure prevented: treating a LOINC code as an assay, or a local test name as a measurand.

### CQ-DX-02
- Desire: never present an estimate as a measurement.
- Example answer: "52.0 years is an INFERRED GrimAge v1 output; 5.4 % is a MEASURED HbA1c."
- Distinctions: measured, calculated, inferred; assay version versus algorithm version.
- Evidence: report text; algorithm publications (PMID 30669119).
- Model: `DiagnosticResult.resultKind`, `PRODUCED_BY_ASSAY_VERSION`, `COMPUTED_BY_ALGORITHM_VERSION`; V-303.
- Query: `MATCH (r:DiagnosticResult {uid:$r}) OPTIONAL MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v) OPTIONAL MATCH (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a) RETURN r.resultKind, v, a`.
- Failure prevented: "your biological age was measured at 52".

### CQ-DX-03
- Desire: show a trend only when values are on one scale.
- Example answer: "Lab A Jan 2025 (5.4 %) and Lab B Jan 2025 (36 mmol/mol) are comparable with conversion NGSP = 0.09148 * IFCC + 2.152; Lab A Jan and Sep 2025 used different assay versions and have no assessment, so they are shown as separate series."
- Distinctions: same measurand versus same assay version versus assessed comparability; unit conversion versus identity.
- Evidence: NGSP master equation; NGSP interference table by instrument and software version; lab notices with method-change dates.
- Model: `AssayVersion`, `ComparabilityAssessment` (`COMPARES` exactly two), derived `COMPARED_TO`; INV-L3-01; V-302.
- Query: see `examples/diagnostic-comparison.cypher` V-302.
- Failure prevented: a false improvement or deterioration caused by an analyzer change.

### CQ-DX-04
- Desire: name the algorithm version behind any score.
- Example answer: "Score A: GrimAge v1 (publication version, PMID 30669119). Score B: GrimAge2 (PMID 36516495). Vendor score C: version unresolved between v1 and v2."
- Distinctions: algorithm family versus version; vendor reimplementation versus publication; stated versus presumed version.
- Evidence: publications; vendor documentation; service help text.
- Model: `Algorithm`, `AlgorithmVersion` (`versionLabel`, `versionBasis`), `VERSION_OF_ALGORITHM`, `DERIVED_FROM_ALGORITHM_VERSION`; UNRESOLVED Assertions plus competing `ResolutionHypothesis`; V-308.
- Query: `MATCH (r:DiagnosticResult {uid:$r})-[:COMPUTED_BY_ALGORITHM_VERSION]->(v)-[:VERSION_OF_ALGORITHM]->(al) RETURN al.name, v.versionLabel, v.versionBasis`.
- Failure prevented: defaulting an unversioned "GrimAge" to the latest version.

### CQ-DX-05
- Desire: know whether a change is signal.
- Example answer: "Both scores are GrimAge2 from one assay version; the 2-year change is within the replicate deviation reported for prominent clocks (up to 9 years, PMID 36277076); not established as a change."
- Distinctions: within-version difference (calculated) versus established biological change (assessment).
- Evidence: reliability studies per version.
- Model: `ComparabilityAssessment.replicateNoiseBasis`; forbidden `[WITHIN_VERSION_SCORE_DIFFERENCE, MEASURED_BIOLOGICAL_CHANGE]`.
- Query: illustrative only; requires assessment nodes.
- Failure prevented: labeling noise as improvement.

### CQ-DX-06
- Desire: interpret a value against the interval actually used.
- Example answer: "Reported against Lab A interval 4.1 to 5.6 % (transferred, adults, effective from 2025-06-01, assay cobas c513); not a diagnostic threshold."
- Distinctions: reference interval versus decision limit versus guideline target; established versus transferred versus verified; partition.
- Evidence: CLSI EP28-A3c summary; Ozarda 2016; lab report.
- Model: `ReferenceIntervalVersion`, `FOR_ASSAY_VERSION`, `INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION`; V-305b, V-306, V-309.
- Query: `MATCH (r:DiagnosticResult {uid:$r})-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri) RETURN ri`.
- Failure prevented: reinterpreting old results with today's interval; "outside range" read as a diagnosis.

### CQ-DX-07
- Desire: know what a model service can support.
- Example answer: "Owkin Pathology Explorer exposes 26 TCGA cohorts, 6 quantifiable cell types, and `density_lymphocytes_in_tumor` (TCGA_BRCA median 277.1; 85 nulls of 1038); the model version and the area unit are not reported."
- Distinctions: feature definition versus value; versioned versus unversioned endpoint; unit not reported versus unitless.
- Evidence: MCP tool outputs; arXiv 2508.09926 (v3 current).
- Model: `AlgorithmVersion.versionBasis = SERVICE_ENDPOINT_UNVERSIONED`, `Metric.unitStatus = NOT_REPORTED`; V-312.
- Query: `MATCH (v:AlgorithmVersion {versionBasis:'SERVICE_ENDPOINT_UNVERSIONED'})-[:OUTPUTS_METRIC]->(m) RETURN v, m.unitStatus`.
- Failure prevented: trending an unversioned model output; inventing a unit.

### CQ-DX-08
- Desire: diagnostics never leaks private results into public answers.
- Example answer: "This query returns only results with privacyClass public or synthetic."
- Distinctions: synthetic, public aggregate, private personal.
- Evidence: placement policy (Lane 5).
- Model: `DiagnosticResult.privacyClass` (interface contract only).
- Query: placement-dependent; Lane 5.
- Failure prevented: a public evidence query returning a person's HbA1c.

### CQ-PF-01
- Desire: know what a label amount refers to.
- Example answer: "'Nicotinamide Riboside Chloride 250 mg' is LISTED_INGREDIENT_AS_LISTED (the salt). The NR cation amount (about 219.5 mg) is a CALCULATED assertion from molecular weights, not declared."
- Distinctions: nutrient versus source compound; listed ingredient versus component; blend total; extract versus marker; declared versus calculated versus measured.
- Evidence: 21 CFR 101.36(b)(2)(ii), (b)(3)(ii), proprietary blend paragraph; label snapshot; molecular weight source.
- Model: `QuantityDeclaration.amountReferent`, `IngredientComponent.amountReferent`; calculated Assertion (KCR-L3-001); V-330.
- Query: `MATCH (:LabelSnapshot {uid:$l})-[:HAS_DECLARATION]->(d)-[:HAS_QUANTITY_DECLARATION]->(q) RETURN d.verbatimText, q.value, q.unitCode, q.amountReferent`.
- Failure prevented: comparing 250 mg of a salt with 250 mg of a free base or cation as if equal.

### CQ-PF-02
- Desire: catch listing text that disagrees with the label.
- Example answer: "Listing title says 'Nicotinamide Riboside 300mg'; the label snapshot is not captured, so the comparison is unknown."
- Distinctions: listing title assertion versus label declaration.
- Evidence: listing snapshot; label snapshot.
- Model: listing title as Assertion on `MerchantListing`; forbidden `[LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]`.
- Query: illustrative join of listing assertion and label declaration by variant.
- Failure prevented: using a marketplace title as the declared amount.

### CQ-PF-03
- Desire: know what a certification or status actually covers.
- Example answer: "NSF Certified for Sport listing (observed 2026-10-03) covers Basis Product IDs 231202; 24150; ...; it does not name the lot in hand."
- Distinctions: product, variant, lot, listed product ID, facility.
- Evidence: NSF listing; NSF 455-2 versus 173 explainer.
- Model: `CertificationScope.COVERS` range adds `Facility`, `TradeItemIdentifier`; derived `CERTIFIED_UNDER` (V-332).
- Query: `MATCH (l:CertificationListing)-[:HAS_CERTIFICATION_SCOPE]->(s)-[:COVERS]->(x) RETURN labels(x), x.uid`.
- Failure prevented: a facility GMP certificate shown as a product certification.

### CQ-PF-04
- Desire: check whether a regulatory response covers this use.
- Example answer: "GRN 000635 covers listed food categories at up to 0.0057 % by weight; the company states 180 mg/day; a 300 mg/day capsule is outside the GRAS notice's stated uses; NDI 1062 (company-reported 300 mg/day) is the relevant notification, unverified at FDA."
- Distinctions: agency conditions versus company restatement; food use versus supplement use.
- Evidence: FDA response letter; company page.
- Model: `RegulatoryResponse.conditionsOfUseText`; `CHARACTERIZES_REGULATORY_RESPONSE` + `Adjudication`; applicability is an `EvidenceAssessment` (Lane 2 owns its dimensions).
- Query: illustrative.
- Failure prevented: extending a notification's conditions to a different dose or product form.

### CQ-MF-01
- Desire: know who makes what.
- Example answer: "Per the FY2025 10-K, W.R. Grace supplies NRC to Niagen Bioscience as single supplier (effective 2025-04-01 agreement); the company's 'we make' marketing is not established as manufacturing."
- Distinctions: manufacture, contract manufacture, supply, market, distribute.
- Evidence: securities filings; supply agreements; court records.
- Model: asserted predicates `MANUFACTURES_PRODUCT`, `CONTRACT_MANUFACTURES_FOR`, `SUPPLIES_INGREDIENT_MATERIAL`; forbidden `[SUPPLIES_INGREDIENT_MATERIAL, MANUFACTURES_PRODUCT]`.
- Query: `MATCH (a:Assertion)-[:HAS_OBJECT]->(:IngredientMaterial {uid:$m}) WHERE a.predicate IN ['SUPPLIES_INGREDIENT_MATERIAL','MANUFACTURES_PRODUCT'] MATCH (a)-[:ASSERTED_BY]->(who) RETURN a, who`.
- Failure prevented: "brand X manufactures its ingredient" from marketing alone.

### CQ-MF-02
- Desire: say exactly what kind of regulatory standing something has.
- Example answer: "NRC: GRAS notice on file (GRN 000635, FDA no questions, food uses only). Not approved. Paige Prostate: De Novo authorization DEN200080 (2021-09-21, no PCCP)."
- Distinctions: submission, response, status; approval versus clearance versus De Novo versus designation versus notification on file versus registration versus enforcement discretion.
- Evidence: agency databases and letters; eCFR 807.39/807.97; FDA consumer page.
- Model: `RegulatorySubmission`, `RegulatoryResponse`, `RegulatoryStatus{statusKind}`, `RegulatoryPathway`; V-320a/b, V-321, V-323.
- Query: `MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(:IngredientMaterial {uid:$m}) OPTIONAL MATCH (s)-[:RESULTS_FROM_RESPONSE]->(r) RETURN s.statusKind, s.jurisdiction, r.responseKind, r.conditionsOfUseText`.
- Failure prevented: "FDA approved" for a notification, registration, or clearance.

### CQ-MF-03
- Desire: test a company's regulatory claim against the agency record.
- Example answer: "The company calls GRN 635 'GRAS no objection ... 180 mg/day'; FDA wrote 'no questions' for food uses at 0.0057 % and made no own determination: partially supported."
- Distinctions: agency text versus company characterization; enforcement discretion versus authorization.
- Evidence: FDA letters; company pages; filings.
- Model: `CHARACTERIZES_REGULATORY_RESPONSE`/`STATUS` assertions; `Adjudication`; V-335.
- Query: `MATCH (a:Assertion {predicate:'CHARACTERIZES_REGULATORY_RESPONSE'})-[:HAS_SUBJECT]->(r:RegulatoryResponse) OPTIONAL MATCH (j:Adjudication)-[:EVALUATES]->(a) RETURN a.valueString, r.conditionsOfUseText, j.verdict`.
- Failure prevented: repeating marketing paraphrase as the agency's position.

### CQ-MF-04
- Desire: track readiness over time.
- Example answer: "Facility F: PLANNED (2024 filing, target 2025); OPERATING from 2025-09 (2025 10-K). Company Y: promoted only; no state attached."
- Distinctions: stage versus source context; planned target date versus valid time.
- Evidence: filings, press releases, audits.
- Model: `ManufacturingCapability`, bitemporal `HAS_CAPABILITY_STATE`; V-324, V-325.
- Query: `MATCH (o {uid:$o})-[h:HAS_CAPABILITY_STATE]->(c) WHERE h.recordedTo IS NULL RETURN c.stage, h.validFrom, h.validTo, h.assertionUid ORDER BY h.validFrom`.
- Failure prevented: a promoted or planned capability shown as operating.

### CQ-MF-05
- Desire: see disclosure and promotion side by side.
- Example answer: "10-K FY2025: relies on Grace and contract manufacturers. Home page: 'Every ingredient we make'. Adjudication: INSUFFICIENT."
- Distinctions: source kind (securities filing versus marketing page); same issuer.
- Evidence: filing; marketing snapshot captured in the same period.
- Model: `Source.sourceKind`, `ASSERTED_BY`, `Adjudication`.
- Query: `MATCH (a:Assertion)-[:ASSERTED_BY]->(:Organization {uid:$o}) MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) RETURN s.sourceKind, a.predicate, a.status`.
- Failure prevented: merging a filing and a promotion into one "company says" claim.

### CQ-MF-06
- Desire: know what quality signals actually say.
- Example answer: "Plant P is FDA food-facility registered (not approval, not CGMP evidence); no NSF 455-2 listing captured; no inspection record captured."
- Distinctions: registration, cGMP claim, GMP certification, inspection outcome.
- Evidence: FDA DS Q&A; 21 CFR 807.39; NSF listings.
- Model: `RegulatoryStatus{ESTABLISHMENT_REGISTRATION}` on `Facility`; `CLAIMS_CGMP_COMPLIANCE` assertion; `CertificationListing` COVERS `Facility`; inspection deferred.
- Query: illustrative.
- Failure prevented: "FDA-registered" read as "FDA-approved" or "cGMP-compliant".

### CQ-CM-01
- Desire: know who is actually selling.
- Example answer: "Amazon B0FS82B35K on 2026-10-03: hosted by Amazon, ships from Amazon, sold by 'TRU NIAGEN' (seller account; legal entity unresolved)."
- Distinctions: host, lister, seller of record, fulfiller, affiliate.
- Evidence: listing snapshot.
- Model: `HOSTS_LISTING`, `LISTS_OFFER`, `SELLER_OF_RECORD_FOR`, `FULFILLS_OFFER`, `AFFILIATE_FOR_OFFER`; derived `SELLS_PRODUCT`; V-326a/b.
- Query: `MATCH (ml:MerchantListing {uid:$l})-[:HAS_OFFER]->(off) OPTIONAL MATCH (s)-[:SELLER_OF_RECORD_FOR]->(off) OPTIONAL MATCH (f)-[:FULFILLS_OFFER]->(off) RETURN off, s.name, f.name`.
- Failure prevented: "Amazon sells X".

### CQ-CM-02
- Desire: list offers for a variant at a date.
- Example answer: "On 2026-10-03, one observed Amazon offer; listing-to-variant link is PROPOSED."
- Distinctions: listing identity versus variant identity; observed versus inferred availability.
- Evidence: listing snapshots; identifiers (ASIN, GTIN).
- Model: `LISTING_FOR` (asserted), `TradeItemIdentifier`, `CommerceMatch`.
- Query: illustrative.
- Failure prevented: merging two variants through a shared listing title.

### CQ-CM-03
- Desire: show a price that can be trusted for its time and kind.
- Example answer: "$49.00 one-time (2026-10-03); $41.65 coupon-adjusted on the brand store (same day)."
- Distinctions: price kinds; observation time.
- Evidence: listing snapshots.
- Model: `PriceObservation{priceKind}`; V-328.
- Query: `MATCH (:Offer {uid:$o})-[:HAS_PRICE_OBSERVATION]->(p) RETURN p.amount, p.currency, p.priceKind, p.observedAt ORDER BY p.observedAt`.
- Failure prevented: averaging coupon and list prices; stale price as current.

### CQ-CM-05
- Desire: distinguish an ended offer from an observation gap.
- Example answer: "Last observed 2026-10-03; no later observation; end unknown."
- Distinctions: validTo unknown versus validTo observed.
- Evidence: observation schedule.
- Model: Offer valid time null when unknown; `PriceObservation` occurrences.
- Query: illustrative.
- Failure prevented: claiming a product was discontinued because crawling stopped.


# 5. Claims, provenance, ecosystem (CQ-CL, CQ-PV, CQ-EC) from round 0006

## Merge notes (no duplicated desires)

- CQ-CL-01 extends **CQ-EV-01** (what proposition, which span) with who said it, in which container and rendition. It does not replace CQ-EV-01.
- **CQ-AX-26** (Lane 1, "what a named person actually said, in context") is the access-tier expression of CQ-CL-01 plus CQ-CL-02. Recommendation to the coordinator: keep CQ-CL-01/02 as the model owners and keep CQ-AX-26 as a pointer row, or drop CQ-AX-26.
- **CQ-AX-18** (Lane 1, "whether a speaker had a stake when speaking") is the time-overlap part of CQ-CL-05. Same recommendation.
- **CQ-AX-05** (Lane 1, independence counting) depends on CQ-CL-06 (retelling chain and asserter unity).
- Correction of a spoken quantity (Lifespan #4 spermidine case) is a case of existing **CQ-EV-05**; no new ID. CQ-PV-04 covers the conversion-error desire, which is distinct.
- **CQ-RC-05** ("a source recommends" versus others) depends on CQ-CL-02's `speechAct`.

## Summary table

| ID | Question | Priority | Answerability | Audience |
|---|---|---|---|---|
| CQ-CL-01 | What did named speaker S say in container E, in which rendition, and at which exact span? | Essential now | A | C, R, A |
| CQ-CL-02 | On what basis was it presented (personal experience, manufacturer claim, mechanism reasoning, study result, expert opinion, anecdote) and as what speech act (statement, practice report, recommendation, caution)? | Essential now | Q | C, R, A |
| CQ-CL-03 | Which qualifications did the speaker attach, where, and of what kind? | Essential now | Q | C, R |
| CQ-CL-04 | Did a later retelling drop a qualification, change the speech act or basis, broaden the scope, change the amount or attribution, or ignore a correction? | Essential now | Q | C, R, O |
| CQ-CL-05 | Which financial relationships (sponsorship, affiliate, investment, equity, board, advisory, employment, founding, IP, compensation) did the speaker or the channel have, valid at the time of the statement, that are relevant to this statement, and where were they disclosed? | Essential now | Q | C, R |
| CQ-CL-06 | Which assertions by different asserters instantiate the same proposition, and how many are independent rather than retellings? | Foundational | Q | R, O |
| CQ-CL-07 | Who is the speaker when only a handle or no identity is known, and what links (if any) are hypotheses rather than identities? | Expansion | Q | R, O |
| CQ-CL-08 | Was a statement part of a sponsor read or of editorial conversation, and who read it? | Essential now | A | C, R |
| CQ-CL-09 | Which experience reports (live `ExperienceReport`) describe an outcome for an intervention, by whom, and with what basis? | Expansion | Q | R |
| CQ-PV-01 | For each assertion in an answer, show the five provenance states: who said it, which captured span supports it, which assessment (if any) warrants a broader conclusion, which agent activity used it, and which policy allowed this use. | Essential now | Q | C, R, O |
| CQ-PV-02 | Can the cited span be found again after the page, transcript, or media rendition changed, and which captured version was used? | Foundational | A | R, O |
| CQ-PV-03 | Which capture, transcription, segmentation, and extraction activities (and agent versions) produced this assertion, and which research run? | Foundational | A | O |
| CQ-PV-04 | Could a conversion, transcription, unit, quantity-basis, or attribution error change the conclusion? | Essential now | Q | C, R, O |
| CQ-PV-05 | Is this source the primary source of the statement or a retelling or aggregator? | Foundational | Q | R |
| CQ-PV-06 | Which downstream uses of a source (quote, summarize, use as recommendation evidence, share) does policy version P allow? | Foundational | X | O, A |
| CQ-EC-01 | Which organizations, people, funders, suppliers, patents, and studies form the neighbourhood of X, valid at V and as recorded at R? | Foundational | Q | R |
| CQ-EC-02 | Where does similar work appear under different names (brand versus legal entity, ingredient trade names, programme names), without merging identities? | Foundational | Q | R, O |
| CQ-EC-03 | Through which time-bounded asserted ties is a speaker connected to the organizations, products, or substances in a statement's neighbourhood? | Essential now | Q | C, R |
| CQ-EC-04 | Which studies have authors affiliated with organizations that sell the studied ingredient, and is that affiliation distinct from funding or sponsorship? | Expansion | Q | R |

## Traces (Essential now and Foundational)

#### CQ-CL-01 (Essential now, A)
1. **Desire:** Know exactly what a named person said, where, and in which version of the recording or page.
2. **Example answer:** "In Huberman Lab episode 52 (published 2021-12-27 per Apple Podcasts), guest David A. Sinclair said: 'My 82 -year-old father, we take a gram of NMN every day.' Span from the publisher transcript page as captured 2026-10-03 (page notes the transcript is under human review); quote hash sha256:96fe6eb5..."
3. **Distinctions:** speaker versus asserter versus host; container (work) versus rendition (page, video, audio feed); captured version versus current page; utterance versus proposition.
4. **Evidence:** a captured rendition with content hash; a quote anchor; speaker label; container publication time.
5. **Model:** `(:Assertion:ClaimOccurrence)` with `ASSERTED_BY`, `OCCURS_IN` Episode; `SUPPORTED_BY` `SourceLocator` (`selectorKind`, `exact`, `prefix`, `suffix`, `quoteHash`, `normalizationVersion`) `<-HAS_LOCATOR-` `SourceSnapshot` `<-HAS_SNAPSHOT-` `Source` `-RENDITION_OF->` Episode; `APPEARS_IN {roleType}`.
6. **Query:** Lane 1 QS-1a after alignment; fixture pattern `MATCH (a:ClaimOccurrence)-[:ASSERTED_BY]->(:Person {uid:$p}) MATCH (a)-[:OCCURS_IN]->(:Episode {uid:$e}) MATCH (a)-[:SUPPORTED_BY]->(l)<-[:HAS_LOCATOR]-(s)` (illustrative).
7. **Prevents:** attributing a host's sponsor read to the guest; citing a page that has since changed with no record of which version was read.

#### CQ-CL-02 (Essential now, Q)
1. **Desire:** Know whether a statement was a personal report, a relayed manufacturer claim, mechanism reasoning, a study result, or advice.
2. **Example answer:** "Personal-experience practice report (`assertionBasis` PERSONAL_EXPERIENCE, `speechAct` REPORTS_PRACTICE). Not a recommendation. No study was cited in the span."
3. **Distinctions:** basis (how the speaker supports it) versus topic (`ClaimType` on `Claim`); practice report versus recommendation; relayed manufacturer claim versus a statement by a person who holds a role at the manufacturer.
4. **Evidence:** the span and its surrounding turns; extraction guideline with examples.
5. **Model:** `Assertion.assertionBasis`, `Assertion.speechAct`, `Assertion.reportedSpeechAct`; live `Claim.claimType` unchanged.
6. **Query:** filter on `assertionBasis` and `speechAct` (indexes `assertion_basis`, `assertion_speech_act`).
7. **Prevents:** a `Person-[:RECOMMENDS]->` edge projected from a practice report (V-423).
Qualification: the classification is an extraction judgment; its extraction confidence and activity are shown.

#### CQ-CL-03 (Essential now, Q)
1. **Desire:** See the caveats the speaker attached.
2. **Example answer:** "Qualified two turns later: 'I'm not the same as everybody else. I have different microbiome, age, sex.' (INDIVIDUAL_VARIATION)."
3. **Distinctions:** qualifier in the same sentence versus a later utterance; kinds of qualification (individual variation, population, species or model, quantity basis, uncertainty interval, needs confirmation, hedge, time scope, conditional use, consult a professional).
4. **Evidence:** the qualifier's own span.
5. **Model:** `QUALIFIED_BY {qualificationKind}` between two occurrences in one container (V-416).
6. **Query:** `MATCH (a)-[q:QUALIFIED_BY]->(b)-[:SUPPORTED_BY]->(l)` (illustrative).
7. **Prevents:** presenting a qualified statement as unqualified.
Qualification: qualifiers outside the captured excerpt are not found; capture completeness is shown.

#### CQ-CL-04 (Essential now, Q)
1. **Desire:** Know whether a later retelling changed what was said.
2. **Example answer:** "Synthetic Longevity Digest (fixture) says Sinclair 'recommends taking a gram of NMN every morning to slow aging'. Compared with episode 52: qualification lost (INDIVIDUAL_VARIATION), speech act changed (REPORTS_PRACTICE to RECOMMENDS), scope broadened (adds 'to slow aging'), amount unchanged. Link basis: BellLabs match (the digest cites nothing)."
3. **Distinctions:** retelling versus original (distinct assertions); verbatim quote versus paraphrase; explicit citation versus BellLabs match; asserter of the retelling versus the party it credits.
4. **Evidence:** both spans; the qualifier span; any correction notice for the original.
5. **Model:** `RETELLS {retellingMode, linkBasis, hypothesisUid | citationLocatorUid}`, `ATTRIBUTES_TO`, `RetellingFidelityAssessment` with `ASSESSES_RETELLING`, `AGAINST_ORIGINAL`, `IDENTIFIES_LOST_QUALIFICATION`.
6. **Query:** `MATCH (f:RetellingFidelityAssessment)-[:ASSESSES_RETELLING]->(r), (f)-[:AGAINST_ORIGINAL]->(o)` (illustrative).
7. **Prevents:** merging a retelling into the original (V-410, V-411, V-412); storing loss as a flag on one assertion (V-414).
Qualification: when no citation exists the link is a hypothesis.

#### CQ-CL-05 (Essential now, Q)
1. **Desire:** Know which money ties matter for this statement, whether they were in force at the time, and where they were disclosed.
2. **Example answer:** "For the guest's mention 'InsideTracker is one of them': DIRECT. Self-disclosure page lists investor, advisor and IP interest from 2011 (open as observed 2026-10-03) and board 2011 to 2017; the guest said on air he was a board member and is 'still their scientific lead guy'; the host read an InsideTracker sponsor message in this episode. For the NMN statement: InsideTracker sponsorship not relevant; EdenRoc group equity with MetroBiotech ('NAD boosters') indirectly relevant, group-level codes, disclosure not found in the partial capture. None of this changes whether the statement is true."
3. **Distinctions:** sponsorship of content versus personal financial interest; investor versus equity; group versus member company; valid at statement time versus valid now; disclosed in container versus elsewhere versus not found in a partial capture versus not disclosed; relevance versus truth.
4. **Evidence:** role assertions with bounds from each source; sponsor-read span; container publication time; capture completeness.
5. **Model:** FINANCIAL_INTEREST predicates as Assertions and projected edges with `validFrom`, `validTo`, `validTimePrecision`, `validTimeBasis`, `assertionUid`; `ConflictRelevanceAssessment` (`relevanceLevel`, `relevanceBasis`, `temporalOverlap`, `disclosureFinding`) with `FOR_OCCURRENCE`, `ASSESSES_INTEREST`.
6. **Query:** Lane 1 QS-2a at V = container `publishedAt`, joined to the occurrence; relevance read from the assessment.
7. **Prevents:** treating a disclosed sponsorship as falsity or an unfound one as truth (V-424); concluding "not disclosed" from a partial capture (V-426); pushing a group role to a member company (V-434); using today's roles for a past statement (V-427).
Qualification: relevance paths through substance classes ("NAD boosters" to NMN) need the class assertion, which may be missing.

#### CQ-CL-06 (Foundational, Q)
1. **Desire:** Count how many independent asserters say the same thing.
2. **Example answer:** "Claim 'NMN 1 g/day slows aging': 1 assertion (a retelling, which RETELLS a practice report that does not make this claim). Independent first-hand assertions: 0."
3. **Distinctions:** proposition identity versus assertion instance; retelling versus independent assertion.
4. **Evidence:** `INSTANCE_OF` resolutions; `RETELLS` chains.
5. **Model:** `Claim`, `INSTANCE_OF` (derived, rule or hypothesis), `RETELLS`, one `ASSERTED_BY` per Assertion.
6. **Query:** count Assertions on a Claim that have no outgoing `RETELLS` (illustrative).
7. **Prevents:** echo inflation.
Qualification: proposition identity is a resolution judgment; unlinked retellings are counted as independent until matched.

#### CQ-CL-08 (Essential now, A)
1. **Desire:** Tell advertising from conversation.
2. **Example answer:** "At [4:47] in the YouTube rendition the host read: 'Today's episode is also brought to us by InsideTracker.' (sponsor read). The guest's later mention of InsideTracker is editorial."
3. **Distinctions:** sponsor read versus editorial; host versus guest; rendition-specific timing.
4. **Evidence:** rendition transcript cue and chapter list.
5. **Model:** `SPONSORS_CONTENT` Assertion asserted by the host with `segmentKind` SPONSOR_READ (or an `EpisodeSegment {segmentType: SPONSOR_READ}`), `MEDIA_TIME` locator.
6. **Query:** `MATCH (a:ClaimOccurrence {predicate:'SPONSORS_CONTENT'})-[:OCCURS_IN]->(:Episode {uid:$e})` (illustrative).
7. **Prevents:** `ENDORSES_PRODUCT` from a sponsor read or an editorial mention (V-422).

#### CQ-PV-01 (Essential now, Q)
1. **Desire:** For any assertion in an answer, see the five provenance states separately.
2. **Example answer:** "Said: yes, by Sinclair in episode 52 (capture accepted). Supported span: locator L, snapshot S (2026-10-03, partial). Broader conclusion: none assessed. Used by: answer-composition activity A1 (agent B). Allowed by: policy v0, use QUOTE_IN_ANSWER."
3. **Distinctions:** the five states; capture status versus truth verdict.
4. **Evidence:** Assertion, locator chain, assessments, activity records, policy reference.
5. **Model:** Assertion, `SUPPORTED_BY` SourceLocator, EvidenceAssessment/Adjudication, Activity (`USED`, `WAS_GENERATED_BY`, `WAS_ASSOCIATED_WITH`), `AUTHORIZED_BY` PolicyVersion.
6. **Query:** Lane 1 QS-1a extended by activity and policy hops.
7. **Prevents:** showing a said-it record as evidence (state 1 as state 3), and using a source without a permission record (V-429).
Qualification: state 5 depends on Lane 5's PolicyVersion contents.

#### CQ-PV-02 (Foundational, A)
1. **Desire:** Re-find the cited passage later.
2. **Example answer:** "Snapshot 2026-10-03 hash sha256:9cadaee8... (stored excerpt). Quote anchor re-found in the 2026-11 snapshot with FUZZY match ('82-year-old')."
3. **Distinctions:** snapshot versus source; text version versus snapshot; quote anchor versus positions; rendition timeline versus work.
4. **Evidence:** stored capture, quote, normalization.
5. **Model:** `SourceLocator` typed fields; `DocumentTextVersion` `TEXT_OF_SNAPSHOT`; `REANCHORS {anchorMatch}`.
6. **Query:** V-401.
7. **Prevents:** a locator that cannot be resolved once the page changes.

#### CQ-PV-03 (Foundational, A)
1. **Desire:** Know which runs and tools produced an assertion, so a faulty run can be found and redone.
2. **Example answer:** "Extracted by activity hu:activity:..., method lane4-manual-curation-v0.1; capture by Tavily extract (tool version unknown)."
3. **Distinctions:** agent (who or what) versus activity (a run); last writer versus generator.
4. **Evidence:** activity records.
5. **Model:** `Activity` (`externalRunSystem`, `externalRunId`, `methodVersion`), `Agent` (`agentKind`, `toolVersion`).
6. **Query:** V-430 and a reverse lookup by `externalRunId`.
7. **Prevents:** losing the creating run when a later run edits a node.

#### CQ-PV-04 (Essential now, Q)
1. **Desire:** Know whether a mistake in units, basis, transcription or attribution could flip the conclusion.
2. **Example answer:** "Lifespan #4: speaker said 'about a gram' of spermidine; the publisher's correction says the active ingredient is 1 to 2 mg. The spoken amount has `quantityBasis` UNSPECIFIED; a 1000-fold difference depends on basis. Any answer using this amount is flagged."
3. **Distinctions:** what was said versus what is true; quantity basis (product mass, active ingredient); transcription confidence; speaker attribution confidence.
4. **Evidence:** correction notice; quantity basis; extraction activity.
5. **Model:** `Assertion.quantityBasis`, correction notice assertion (`CORRECTS_SOURCE`, mechanics in Lane 5 round 0007), `extractionConfidence` with activity.
6. **Query:** answers list assertions whose `quantityBasis` is UNSPECIFIED or that have an incoming correction (illustrative).
7. **Prevents:** treating a corrected spoken amount as a measured dose, or the correction as the fact ending.

#### CQ-PV-05 (Foundational, Q)
1. **Desire:** Know whether I am reading the original or a retelling.
2. **Example answer:** "The digest is a retelling (aggregator); primary source: episode 52 rendition."
3. **Distinctions:** primary versus aggregator (Biolink); retelling versus original.
4. **Evidence:** `RETELLS` chain.
5. **Model:** derived from absence or presence of outgoing `RETELLS`; replaces live `Document.isPrimarySource` as a per-assertion fact.
6. **Query:** `NOT (a)-[:RETELLS]->()` (illustrative).
7. **Prevents:** a document-level "primary" flag applied to every claim in it.

#### CQ-PV-06 (Foundational, X)
1. **Desire:** Know whether a use of a source is allowed.
2. **Example answer:** "Quoting allowed under policy v0; sharing externally not covered."
3. **Distinctions:** use versus permission; use kinds.
4. **Evidence:** license or terms of the source; BellLabs policy (outside the graph today).
5. **Model:** `AUTHORIZED_BY {useKind}` to `PolicyVersion` (Lane 5).
6. **Query:** V-429.
7. **Prevents:** an answer that quotes without a permission record.
Needs outside the graph: source licenses and terms; policy contents.

#### CQ-EC-01 (Foundational, Q)
1. **Desire:** See who is connected to an organization or person, as of a date.
2. **Example answer:** "As of 2021-12-27 (recorded 2026-10-03): Sinclair to InsideTracker (investor, advisor, IP interest; board ended in 2017); Sinclair to EdenRoc group (equity, group-level); MetroBiotech affiliated with EdenRoc (from 2015)."
3. **Distinctions:** asserted role versus name co-occurrence; valid time versus recorded time; group versus member.
4. **Evidence:** role assertions with bounds.
5. **Model:** FINANCIAL_INTEREST and organization predicates as asserted edges with `assertionUid`.
6. **Query:** Lane 1 QS-2a over the predicate family.
7. **Prevents:** neighbourhoods inflated by name matches or expired roles.

#### CQ-EC-02 (Foundational, Q)
1. **Desire:** Find the same or similar work under other names without merging.
2. **Example answer:** "'InsideTracker (Segterra)': brand and legal entity kept apart; `OWNS_BRAND` PROPOSED."
3. **Distinctions:** identity hypothesis versus similarity assessment; brand versus legal entity.
4. **Evidence:** the juxtaposition; registry records (not ingested).
5. **Model:** `ResolutionHypothesis` for identity; `EquivalenceAssessment {equivalenceKind}` `COMPARES` two nodes.
6. **Query:** V-432, V-433.
7. **Prevents:** merged identities.

#### CQ-EC-03 (Essential now, Q)
1. **Desire:** Trace the money path from a speaker to the subject of a statement.
2. **Example answer:** "Speaker to EdenRoc (equity) to MetroBiotech (affiliated) to 'NAD boosters' to NMN (class membership not asserted in the graph): INDIRECT, path incomplete."
3. **Distinctions:** direct versus indirect; asserted path versus inferred class membership.
4. **Evidence:** role and product-class assertions.
5. **Model:** same as CQ-CL-05; `relevanceBasis` names the path kind.
6. **Query:** bounded traversal over FINANCIAL_INTEREST and `AFFILIATED_WITH` (illustrative).
7. **Prevents:** relevance claimed through unasserted hops.

## Expansion

- **CQ-CL-07 (Expansion, Q).** Pseudonymous and anonymous speakers. Extension: `PseudonymousActor`/`AnonymousActor` in `ASSERTED_BY` range (KCR-4.3); live `LINKS_TO` becomes a `ResolutionHypothesis`.
- **CQ-CL-09 (Expansion, Q).** Experience reports. Extension: live `ExperienceReport` is a ClaimOccurrence with `assertionBasis` PERSONAL_EXPERIENCE; `CohortParticipant` reports touch private context (Lane 5 placement).
- **CQ-EC-04 (Expansion, Q).** Author affiliation versus funding. Example: PMID 38241160 lists an author affiliated with Elysium Health Inc.; that is not `FUNDS_STUDY`. Extension: author-affiliation assertions per publication.


# 6. Time, recommendation, private context, protocols (CQ-TM, CQ-RC, CQ-PC, CQ-PR) from rounds 0007 and 0008

## Time

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-TM-01` | What did BellLabs believe on recorded date `R` about facts valid on domain date `V`? | Essential now | A | 0007 |
| `CQ-TM-02` | When a late historical source arrives, can the system add past valid time without pretending BellLabs knew it earlier? | Essential now | A | 0007 |
| `CQ-TM-03` | Can the system distinguish publication time, observation time, retrieval time, study time, effective time, and ingestion time? (extended: retrieval time added) | Foundational | A | 0007 |
| `CQ-TM-04` | Are unknown temporal bounds preserved as unknown rather than replaced with the current time, and are the precision and basis of known bounds preserved? (extended) | Foundational | A | 0007 |
| `CQ-TM-05` | Can two nonexclusive assertions overlap while mutually exclusive states are rejected for overlapping intervals? | Foundational | Q (definite overlaps rejected; possible overlaps queued) | 0007 |
| `CQ-TM-06` | (new) Which assertions, adjudications, and recommendation snapshots relied on a source version that was later corrected, retracted, or superseded, and when did BellLabs learn of the revision? | Foundational | A | 0007 |
| `CQ-TM-07` | (new) Did a change mean the fact ended in the world, or that BellLabs corrected its record of a fact that never held? | Essential now | A | 0007 |

## Recommendation and choice

(Priority class and answerability for `CQ-RC-01` to `CQ-RC-06` follow the canonical classification in section 2; the integration owner aligned this table to it on 2026-10-03.)

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-RC-01` | Why was one option preferred over another for a stated goal and decision context, and which options were rejected or blocked, for which reason? (extended) | Essential now | Q | 0008 |
| `CQ-RC-02` | Which evidence, applicability assessments, constraints, price/availability observations, and policy version affected the decision? | Foundational | Q | 0008 |
| `CQ-RC-03` | Which missing or disputed facts could change the ranking? | Essential now | Q (only facts named in `missingFactKeys` and disputed assertions; unnamed unknowns are not enumerable) | 0008 |
| `CQ-RC-04` | Can a decision be replayed as of both its domain-time and system-time viewpoint? | Foundational | Q | 0007, 0008 |
| `CQ-RC-05` | Can the system distinguish "evidence favors", "BellLabs recommends", "a source recommends", and "a user selected"? | Essential now | A | 0008 |
| `CQ-RC-06` | Can contraindications or interaction uncertainty block a recommendation rather than merely lower a score? | Foundational | Q (as record shape); policy content is outside this lane | 0008 |
| `CQ-RC-07` | (new) Which past recommendations relied on evidence or context that has since been corrected, superseded, re-adjudicated, or extended by new measurements, and would the decision differ now? | Foundational | Q (detection is A; "would it differ" requires re-running the policy, a counterfactual that is Research frontier for policies without stored criteria) | 0007, 0008 |

## Private context

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-PC-01` | (new) What was the person trying to improve at time `T`, as recorded then? | Essential now | A | 0008 |
| `CQ-PC-02` | (new) Which personal-context version (goals, measurements, declared conditions and intake, preferences) was in force for a given decision, and what changed since? | Essential now | A | 0008 |
| `CQ-PC-03` | (new) What is the person waiting on (lab result, delivery, protocol period end, evidence update, clinician input), since when, until when expected, and what will resolve it? | Foundational | A | 0008 |
| `CQ-PC-04` | (new) What may be shared, with whom, for what purpose, and until when, and what was actually disclosed under which grant? | Essential now | A | 0008 |
| `CQ-PC-05` | (new) After an erasure request or a grant revocation, which private records, derived projections, and shared contributions must be deleted or withdrawn, and has propagation completed? | Foundational | Q (the PCS can track propagation it controls; third-party copies are O) | 0008 |
| `CQ-PC-06` | (new) Which of a person's measurements are comparable over time (same `Metric`, `LabTest` or method, unit, and reference-range basis)? | Expansion | Q (depends on Lane 3 assay comparability, round 0004) | 0008 |
| `CQ-PC-07` | (new) What is the purchase and use lifecycle of a chosen option (intended, ordered, delivered, started, stopped), and which lot did the person receive? | Expansion | Q (lot only when the person records it) | 0008 |
| `CQ-PC-08` | (new) Can any public query, API, or agent traversal reach private-personal data? | Essential now | A (no private data in the shared graph; F-V6, F-V7, V-520 to V-522) | 0008 |

## Protocols

| ID | Question | Priority | Answerability | Round |
|---|---|---|---|---|
| `CQ-PR-01` | (new) What changed between two versions of a public protocol, and is each change source-versioned, inferred from a snapshot diff, or reported by a third party? | Foundational | Q (changes between unobserved states are unknown) | 0008 |
| `CQ-PR-02` | (new) Which steps are essential, conditional (on what), optional, or not stated, and which steps depend on others and how? | Foundational | A for source-stated levels; BellLabs judgments of essentiality are Expansion | 0008 |
| `CQ-PR-03` | (new) What is missing before a person can evaluate the protocol: unreported step details, missing measurement plans or stop rules, missing baseline measurements, undeclared constraint facts? | Expansion | Q | 0008 |
| `CQ-PR-04` | (new) Which observations or measurements should trigger review, pausing, stopping, or clinician contact under the adopted edition? | Expansion | A for source-stated triggers; policy triggers depend on PolicyVersion content | 0008 |
| `CQ-PR-05` | (new) Which public protocol edition did a person adopt, with which deviations, during which interval? | Foundational | A | 0008 |
| `CQ-PR-06` | (new) What evidence supports each step of a protocol, as opposed to the protocol as a whole? | Research frontier | Q (step-level attribution is rarely stated by sources) | 0008 |

## Traces for Essential now and Foundational questions

Format: Informational desire -> example answer -> necessary distinctions -> evidence requirements -> nodes, relationships, properties -> query pattern -> failure the model must prevent.

### CQ-TM-01
- Desire: reconstruct BellLabs' belief at a past system time about a past or present domain time.
- Example answer: "On 2026-04-10 BellLabs held that SleepWell US capsules had formulation fv-a1 (200 mg elemental Mg declared), valid from November 2025 (month precision, stated by the label), supported by the 2026-03-02 label snapshot, adjudicated SUPPORTED by policy on 2026-03-02."
- Distinctions: valid vs recorded time; current projection vs historical status; known vs possible validity.
- Evidence: assertion `recordedAt`/`recordedTo`; time-stamped adjudications; attachment episodes.
- Model: `Assertion {recordedAt, recordedTo, validFrom, validTo, *Precision, *Basis}`, `Adjudication {recordedAt}`, `SUPERSEDES`, `HAS_FORMULATION_VERSION` episodes.
- Query: round 0007 section 11 (statically-checked); fixture Q-1.
- Failure prevented: replay showing a later correction or a later-learned end as if known at `R`.

### CQ-TM-02
- Desire: add history learned late without rewriting what was known earlier.
- Example answer: "The 2019 label (archive capture 2019-05-10) was recorded on 2026-08-01; decisions before that date did not see it."
- Distinctions: `observedAt` vs `retrievedAt` vs `recordedAt`; stated vs inferred bounds.
- Evidence: archive capture time, fetch time.
- Model: `SourceSnapshot {observedAt, retrievedAt}`, assertion `recordedAt`, edge `recordedFrom` service-assigned.
- Query: fixture Q-1 excludes fv-a0; F-V5 no-backdating check.
- Failure prevented: backdated `recordedFrom` changing past replays.

### CQ-TM-03
- Desire: keep every clock distinct.
- Example answer: "Notice published 2010-02-06; PubMed record observed 2026-10-03; BellLabs recorded the revision 2026-10-03."
- Distinctions: publication, observation, retrieval, valid, effective (payload), recorded, created.
- Evidence: source metadata, capture logs.
- Model: round 0007 clock table.
- Query: property reads on `SourceSnapshot` and `SourceRevisionEvent`.
- Failure prevented: ingestion time used as valid time.

### CQ-TM-04
- Desire: never fabricate certainty about dates.
- Example answer: "Launched in March 2026 (month precision): on 2026-03-15 validity is POSSIBLE; from 2026-04-01 KNOWN."
- Distinctions: null (unknown) vs stated; precision per bound; basis per bound.
- Evidence: source wording.
- Model: `validFromPrecision`, `validToPrecision`, `validFromBasis`, `validToBasis`.
- Query: as-of query reports `boundState`; V-503 forbids non-null bounds with `OBSERVATION_ONLY`.
- Failure prevented: "available as of March" stored as a start date.

### CQ-TM-05
- Desire: reject contradictory exclusive states while allowing parallel roles.
- Example answer: "Two formulation versions for one US variant overlap on [2026-06-10, 2026-07-01) in current belief: commit refused."
- Distinctions: exclusive vs nonexclusive types; definite vs possible overlap; valid vs recorded overlap.
- Evidence: bounds and precision.
- Model: catalog `temporalCardinality`, `exclusivityPartition`.
- Query: F-V9 / V-508 (definite), V-509 (possible).
- Failure prevented: two "current" formulations for one variant.

### CQ-TM-06
- Desire: impact of a source revision.
- Example answer: "PMID 9500320 was linked to retraction notice PMID 20137807; 3 assertions and 1 adjudication relied on the prior record; a new adjudication supersedes it; 2 snapshots flagged."
- Distinctions: retraction vs erratum vs silent change; assertion content vs adjudication.
- Evidence: PubMed publication types and linking; captured snapshots.
- Model: `SourceRevisionEvent {revisionKind}`, `REVISES_SOURCE`, `PRIOR_SNAPSHOT`, `RESULTING_SNAPSHOT`, `ANNOUNCED_IN`; adjudication `SUPERSEDES`.
- Query: `MATCH (ev:SourceRevisionEvent)-[:PRIOR_SNAPSHOT]->(sn)-[:HAS_LOCATOR]->(l)<-[:SUPPORTED_BY]-(a:Assertion)` (illustrative in validation fragment Q-505).
- Failure prevented: editing historical adjudications or deleting assertions from retracted sources.

### CQ-TM-07
- Desire: tell a correction from a fact ending.
- Example answer: "SleepWell: correction (the 200 mg value never held; 120 mg since November 2025). CalmRoot: fact ended (3 g formulation held until 2026-06-10)."
- Distinctions: `SOURCE_CORRECTION` vs `VALIDITY_BOUNDED`; current attachment of the old state.
- Evidence: source statement of error vs effective date of change.
- Model: `SUPERSEDES.supersessionKind`, attachment episodes.
- Query: fixture Q-2.
- Failure prevented: a correction treated as a historical change (evidence about the "old" formulation wrongly retained) or the reverse.

### CQ-RC-01
- Desire: explain the choice and the alternatives.
- Example answer: "SleepWell selected (rank 1); CalmRoot rejected for insufficient dose applicability; NightCue rejected by stated preference."
- Distinctions: selected, alternative, rejected, blocked.
- Evidence: option records, criterion values.
- Model: `RecommendationOption {disposition, rank, rejectionReason, blockingConstraintUids}`.
- Query: `MATCH (rs:RecommendationSnapshot {uid:$u})-[:HAS_OPTION]->(o) RETURN o ORDER BY o.rank` (PCS).
- Failure prevented: only the winner being recorded.

### CQ-RC-02
- Desire: name every input version.
- Example answer: "Policy v3, ranker-2026.04.1, assertion A1, adjudication adj-A1, applicability ea-A, context version v1, viewpoint 2026-04-10T09:00Z."
- Distinctions: evidence versions vs current evidence; policy vs algorithm build.
- Evidence: snapshot fields.
- Model: snapshot `policyVersionUid`, `algorithmVersion`, `evidenceRecordedAt`, option uid lists.
- Query: snapshot read plus uid resolution.
- Failure prevented: explanations citing current evidence.

### CQ-RC-03
- Desire: know what could flip the ranking.
- Example answer: "Baseline serum magnesium and current intake were not known."
- Distinctions: named missing facts vs disputed facts vs unknown unknowns.
- Evidence: policy-declared required facts.
- Model: `missingFactKeys`; disputed assertions in evidence lists.
- Query: snapshot read; join to assertion status as of viewpoint.
- Failure prevented: false confidence.

### CQ-RC-04
- Desire: replay exactly.
- Example answer: "Replay at R = 2026-04-10T09:00Z reproduces fv-a1, fv-b1, fv-c1."
- Distinctions: viewpoint R and V stored.
- Evidence: append-only shared history.
- Model: snapshot viewpoint fields; round 0007 episodes.
- Query: fixture Q-1; F-V2.
- Failure prevented: replay drifting with later corrections.

### CQ-RC-05
- Desire: never conflate who recommended.
- Example answer: "The host recommends NightCue (source); BellLabs selected SleepWell; the person chose SleepWell."
- Distinctions: source recommendation, policy selection, user decision, evidence assessment.
- Evidence: source assertion; snapshot; user decision.
- Model: `RECOMMENDS {assertionUid}`, `RecommendationOption.disposition`, `UserDecision`.
- Query: F-V8 (source `RECOMMENDS` without assertion); pair queries.
- Failure prevented: a host's recommendation presented as BellLabs'.

### CQ-RC-06
- Desire: hard blocks.
- Example answer: "Option D blocked by constraint hu:constraint:... ; not ranked."
- Distinctions: block vs penalty.
- Evidence: safety constraints and declared context.
- Model: `disposition: BLOCKED`, `blockingConstraintUids`, `rank` null.
- Query: F-V11.
- Failure prevented: a contraindicated option ranked low but still shown as recommended.

### CQ-RC-07
- Desire: know which past decisions need review.
- Example answer: "Snapshot s1 used A1, superseded by a source correction on 2026-06-15; context gained a lab value on 2026-05-22."
- Distinctions: correction vs bounded validity vs new context.
- Evidence: change feed, supersession records, context versions.
- Model: `SUPERSEDES.recordedAt` vs `evidenceRecordedAt`; `PendingItem {pendingKind: EVIDENCE_REVIEW | REVIEW_SUGGESTED}`.
- Query: fixture Q-3.
- Failure prevented: silently editing old decisions or never revisiting them.

### CQ-PC-01
- Desire: the person's goal as recorded then.
- Example answer: "On 2026-04-10 the goal was shorter sleep onset (priority 1)."
- Distinctions: goal concept (public) vs the person's goal version (private).
- Evidence: user input with time.
- Model: `UserGoalVersion {functionalGoalUid, priority, recordedAt}` in PCS.
- Query: PCS as-of over goal versions referenced by the context version.
- Failure prevented: today's goals used to explain old decisions.

### CQ-PC-02
- Desire: which context version was used and what changed.
- Example answer: "Decision used v1; v2 (2026-05-22) added a serum magnesium result."
- Distinctions: context version vs measurement; insert-only.
- Evidence: PCS records.
- Model: `UserContextVersion`, `HAS_CONTEXT_VERSION` episodes, `PersonalMeasurement`.
- Query: F-V1; PCS diff of measurement uid lists.
- Failure prevented: new measurements rewriting the decision.

### CQ-PC-03
- Desire: what the person is waiting on.
- Example answer: "Evidence review open since 2026-06-15; baseline lab resolved 2026-05-22."
- Distinctions: pending kind; planned `expectedBy` vs actual `resolvedAt`.
- Evidence: PCS events.
- Model: `PendingItem`.
- Query: PCS `WHERE resolvedAt IS NULL`.
- Failure prevented: forgotten follow-ups.

### CQ-PC-04
- Desire: sharing permissions and disclosures.
- Example answer: "Coach may VIEW recommendation snapshots and protocol-in-use for coaching review from 2026-04-12 to 2026-07-12; one disclosure on 2026-04-20."
- Distinctions: view vs export vs contribute; grant validity vs recorded time; revocation not backdated.
- Evidence: user consent actions.
- Model: `SharingGrant`, `HAS_SHARING_GRANT` episodes, `DisclosureEvent`.
- Query: F-V10.
- Failure prevented: disclosure without an active grant; retroactive revocation erasing disclosure history.

### CQ-PC-05
- Desire: erasure completeness.
- Example answer: "Erased 2026-09-01; 4 projections purged; 1 contribution withdrawn; backups crypto-shredded."
- Distinctions: delete vs tombstone; projection vs record; contribution token.
- Evidence: propagation acknowledgements.
- Model: `ErasureTombstone {propagationStatus}`, `contributionToken`.
- Query: PCS tombstones with incomplete propagation.
- Failure prevented: orphan copies after erasure.

### CQ-PC-08
- Desire: assurance that public surfaces cannot reach private data.
- Example answer: "Zero private nodes and zero private uid values in the shared graph."
- Distinctions: placement vs access control.
- Evidence: validation runs.
- Model: `privacyClass`; private uid prefix `hu:private-`.
- Query: V-520 to V-522; fixture F-V6, F-V7.
- Failure prevented: leaks through traversal, search indexes, or mislabeled nodes.

### CQ-PR-01
- Desire: what changed between protocol versions.
- Example answer: "Edition 2 added baseline serum magnesium, made the magnesium step conditional on it, and dropped the screen-free hour (snapshot diff); a third party reports rapamycin was stopped in 2024 (third-party report)."
- Distinctions: source-versioned vs snapshot diff vs third-party report; unobserved gaps.
- Evidence: snapshots per observed state; versioned sources (protocols.io).
- Model: `ProtocolEdition`, `HAS_PROTOCOL_EDITION`, `ProtocolStep {stepKey, payloadHash}`.
- Query: round 0008 CQ-PR-01 query; fixture Q-4.
- Failure prevented: inventing a change history between unobserved states; treating a news report as the owner's version.

### CQ-PR-02
- Desire: essential, conditional, dependent steps.
- Example answer: "Magnesium step CONDITIONAL, applies when baseline is within range, REQUIRES_RESULT_OF the baseline step."
- Distinctions: source-stated vs editorial inference; constraint role; dependency kind.
- Evidence: protocol text.
- Model: `requirementLevel`, `requirementBasis`, `HAS_CONSTRAINT {constraintRole}`, `DEPENDS_ON {dependencyKind}`.
- Query: `MATCH (e:ProtocolEdition {uid:$e})-[:HAS_STEP]->(s) OPTIONAL MATCH (s)-[c:HAS_CONSTRAINT]->(k) OPTIONAL MATCH (s)-[d:DEPENDS_ON]->(t) RETURN s.stepKey, s.requirementLevel, collect(DISTINCT [c.constraintRole, k.uid]), collect(DISTINCT [d.dependencyKind, t.stepKey])` (illustrative).
- Failure prevented: `isOptional: false` read as "essential".

### CQ-PR-05
- Desire: what the person actually adopted.
- Example answer: "Edition 2 since 2026-04-15, with modified bedtime timing."
- Distinctions: public edition vs private adoption; deviation kinds.
- Evidence: user input.
- Model: `ProtocolInUse`, `ProtocolAdoptionVersion {adoptedEditionUid, deviations}`, `HAS_ADOPTION_VERSION`.
- Query: PCS as-of over adoption episodes.
- Failure prevented: assuming adherence to every step; public protocol node gaining personal edges.


# 7. Access, audience and query shapes (CQ-AX) from round 0009

The existing questions say what the graph must know. These say who asks, in what form the answer leaves the graph, and what each audience may see.

### 3.1 Public answer with trace (C, R)

| ID | Question | Tier | Priority | Ans. |
|---|---|---|---|---|
| CQ-AX-01 | For each factual sentence in a public answer, which assertion, locator and adjudication stands behind it, and which sentences have none? | PUBLIC | Essential now | A |
| CQ-AX-02 | Does the answer state the scope of the evidence (population, dose, outcome, jurisdiction, time) and avoid turning public evidence into a personal medical conclusion? | PUBLIC | Essential now | Q |
| CQ-AX-03 | Can a published answer be reproduced later from its recorded-as-of date, valid-at date, schema digest and query shape? | PUBLIC | Foundational | Q |
| CQ-AX-04 | When the graph returns nothing, is that unknown to BellLabs, not reported by a source, measured absent, or out of scope? | all | Foundational | A |
| CQ-AX-05 | How many independent evidence lines support a claim, once shared datasets, common sponsors or authors, and retellings are accounted for? | PUBLIC | Foundational | Q |
| CQ-AX-06 | For a current-state question (price, availability, label, status), when was it last observed, and is the open end verified? | PUBLIC | Foundational | A |

### 3.2 Operator audit (O)

| ID | Question | Tier | Priority | Ans. |
|---|---|---|---|---|
| CQ-AX-07 | Which accepted assertions lack a locator, a reproducible snapshot, or an adjudication? | AUDIT | Essential now | A |
| CQ-AX-08 | Which derived edges cannot be regenerated, or cite a withdrawn or mismatched assertion? | AUDIT | Foundational | A |
| CQ-AX-09 | Who or what produced each assertion, status change and adjudication, under which method and run? | AUDIT | Foundational | Q |
| CQ-AX-10 | Which adjudications predate a newer snapshot or correction of their source and need re-review? | AUDIT | Expansion | Q |
| CQ-AX-11 | Which published answers depend on assertion A, so a correction's reach can be assessed? | AUDIT | Expansion | Q |
| CQ-AX-12 | Can any shared-graph path, index or answer reach private user context? | AUDIT | Essential now | A |

### 3.3 Agent projection (A)

| ID | Question | Tier | Priority | Ans. |
|---|---|---|---|---|
| CQ-AX-13 | For an intent, which schema elements and data may an agent read and write, within what budgets, with private context excluded? | AGENT | Essential now | Q |
| CQ-AX-14 | For free text, which candidate identities match, and is the choice kept as a hypothesis instead of resolved silently? | AGENT | Essential now | A |
| CQ-AX-15 | Can an agent tell its own uncommitted candidates from committed assertions, and are candidates kept out of answers? | AGENT | Foundational | A |
| CQ-AX-16 | Does a proposed write pass the forbidden-implication and citation guard before commit? | AGENT | Foundational | A |

### 3.4 Cross-domain (two or more modules)

| ID | Question | Modules | Tier | Priority | Ans. |
|---|---|---|---|---|---|
| CQ-AX-17 | Can I buy, today and in my jurisdiction, the product that was studied, at the studied amount per serving? | products, studies, commerce, regulatory, time | PUBLIC | Foundational | Q |
| CQ-AX-18 | Was the speaker's relationship with the manufacturer in force on the date of the statement? | claims, organizations, time | PUBLIC | Foundational | Q |
| CQ-AX-19 | For the lot I bought, what do independent measurements say compared with its label? | labels, quality, commerce | PUBLIC | Expansion | Q |
| CQ-AX-20 | Given a described mechanism for an ingredient, does it follow that the commercial formulation delivers the exposure that mechanism needs? | mechanisms, formulations, quality | PUBLIC | Research frontier | X |
| CQ-AX-21 | Can the shared graph say whether two assay methods are comparable without receiving the person's results? | diagnostics, time, private context | PUBLIC | Expansion | Q |
| CQ-AX-22 | Is the public protocol version I follow the one a published result used, without the shared graph learning my own deviations? | protocols, time, private context | PUBLIC | Expansion | Q |

### 3.5 Misleading simplification (a naive graph answers wrongly)

| ID | Question | Naive graph answer that is wrong | Tier | Priority | Ans. |
|---|---|---|---|---|---|
| CQ-AX-23 | Is product or ingredient X approved or cleared? | Any link to a regulatory node means approved. | PUBLIC | Foundational | A |
| CQ-AX-24 | How strong is the evidence for claim C? | Read a stored `evidenceStrength` attribute. | all | Essential now | A |
| CQ-AX-25 | Which products contain compound C? | Follow a `contains` edge, ignoring declared versus measured, form and time. | PUBLIC | Foundational | Q |
| CQ-AX-26 | What did a named speaker say about X? | Follow a `Person-[:RECOMMENDS]->Product` edge. | PUBLIC | Foundational | A |
| CQ-AX-27 | Which papers did this person write? | Match on name. | PUBLIC | Expansion | Q |
| CQ-AX-28 | What works for people like me? | Aggregate over other users' private histories. | PUBLIC | Research frontier | X |

### Traces for CQ-AX questions

#### CQ-AX-01 (Essential now, A)
1. **Desire:** Trust that no factual sentence in an answer is unsupported.
2. **Example answer:** "Sentence 1 -> A1 (locator L1, snapshot 2026-07-10, adjudication `SUPPORTED`). Sentence 2 -> A2 (no adjudication; flagged `NO_ADJUDICATION_AS_OF_R`). Sentence 3 -> BellLabs inference by rule R2 from A3, A4."
3. **Distinctions:** supported, unsupported, inferred; a sentence may rest on several assertions.
4. **Evidence:** the per-sentence citation list produced when the answer is composed.
5. **Model:** `Assertion`, `SourceLocator`, `Adjudication`; answer text is outside the graph, citations are uids.
6. **Query:** QS-1a, gaps column.
7. **Prevents:** an answer with fluent but untraceable sentences.

#### CQ-AX-02 (Essential now, Q)
1. **Desire:** Know the limits of the evidence and not be handed a diagnosis.
2. **Example answer:** "This evidence concerns adults 18 to 65, 250 mg/day for 12 weeks, outcome sleep latency (self-reported), in the US. It does not address your situation. Weakest dimension: population for children, `MISMATCH`."
3. **Distinctions:** evidence scope versus a person's situation; a public answer versus a recommendation occurrence.
4. **Evidence:** the applicability dimensions and the studied scope.
5. **Model:** `EvidenceApplicability` dimensions; the answer is computed from shared records only; no private record is read or written.
6. **Query:** QS-3a + QS-6a; QS-5 with `privateContext: EXCLUDED`.
7. **Prevents:** "this will work for you" from public evidence; storing the asker's context in the shared graph.
Qualification: scope text is composed by the answering service; the graph supplies its inputs.

#### CQ-AX-03 (Foundational, Q)
1. **Desire:** Re-run a published answer and get the same trace.
2. **Example answer:** "Answer record AR1: recordedAsOf 2026-10-03, validAt 2026-07-10, schema digest D, query shape QS-3a, cites assertions A1 to A4."
3. **Distinctions:** a published (shared) answer versus an ad hoc answer to one person. The second is behavior data and belongs in the private store (Lane 5). The record never holds the asker's identity or question text.
4. **Evidence:** the viewpoint parameters and cited uids.
5. **Model:** candidate `AnswerRecord` occurrence (K-7) with `recordedAsOf`, `validAt`, `schemaDigest`, `queryShapeId`, `accessTier`.
6. **Query:** QS-2 using the stored parameters; V-121.
7. **Prevents:** a published answer that cannot be reproduced because its viewpoint was never stored.
Qualification: reproducing assumes no destructive edit of history, and the query-shape version is under change control.

#### CQ-AX-04 (Foundational, A)
1. **Desire:** Tell "we don't know" from "it isn't there".
2. **Example answer:** "Variant V: ingredient M `NOT_DECLARED_IN_COVERING_SOURCE` (a label snapshot from 2026-07-10 exists and does not list it). No measurement exists, so absence is not established."
3. **Distinctions:** unknown, unmeasured, not reported, below detection, absent, false (INV-007), plus out of scope.
4. **Evidence:** a negative-polarity assertion for absence; a covering snapshot for non-declaration.
5. **Model:** `Assertion.polarity`; covering snapshot via `LABEL_FOR`.
6. **Query:** QS-7.
7. **Prevents:** reading an empty result as a negative.

#### CQ-AX-05 (Foundational, Q)
1. **Desire:** Count independent support, not repetitions.
2. **Example answer:** "Five papers support C. They reduce to two independent lines: three report one dataset, and two repeat a conference abstract's result. Sponsor is the same company for both lines."
3. **Distinctions:** shared dataset, shared authors or sponsor, retelling versus replication. Sponsorship does not mean execution.
4. **Evidence:** `Dataset` links, authorship, sponsor and funder roles, the retelling chain.
5. **Model:** cross-module: studies (`HAS_DATASET`), organizations (`SPONSORS_STUDY`, `FUNDS_STUDY`), documents (retelling provenance, Lane 4).
6. **Query:** QS-1a over supporting assertions, then grouped by dataset and sponsor (a derived grouping, not a stored count).
7. **Prevents:** "five studies agree" when they are one.
Qualification: dataset sharing is often not declared; the count is a lower bound on dependence, and the answer says so.

#### CQ-AX-06 (Foundational, A)
1. **Desire:** Know how fresh a price, label or status is.
2. **Example answer:** "Label for variant V last observed 2026-07-10; open end unverified after that date."
3. **Distinctions:** observed time versus effective time versus retrieval time.
4. **Evidence:** snapshot `observedAt` and `retrievedAt`.
5. **Model:** `SourceSnapshot` times; `OPEN_END_STALE` class; `Offer` and `PriceObservation` as observations.
6. **Query:** QS-2a, QS-2b.
7. **Prevents:** "current" meaning "most recently scraped".

#### CQ-AX-07 (Essential now, A)
1. **Desire:** Find accepted facts with weak backing.
2. **Example answer:** "12 accepted assertions have no adjudication; 3 cite a locator whose snapshot has no content hash."
3. **Distinctions:** no locator, no snapshot, non-reproducible snapshot, no adjudication.
4. **Evidence:** the graph itself.
5. **Model:** V-110, V-111; INV-002.
6. **Query:** QS-1a gaps; V-110, V-111.
7. **Prevents:** accepted state resting on nothing.

#### CQ-AX-08 (Foundational, A)
1. **Desire:** Catch projection drift.
2. **Example answer:** "Edge `CONTAINS` P to M cites assertion A7, which was superseded; edge `ENDORSES_PRODUCT` cites an `ADVISES_ORGANIZATION` assertion."
3. **Distinctions:** projection of one assertion versus multi-hop derivation; live versus superseded citation.
4. **Evidence:** edge citation properties.
5. **Model:** `projectionOfAssertionUid`, `derivationRule`, `derivedFromAssertionUids` (K-2).
6. **Query:** QS-4a; V-112.
7. **Prevents:** a regenerable shortcut becoming the only record.

#### CQ-AX-09 (Foundational, Q)
1. **Desire:** Know who or what made a fact.
2. **Example answer:** "Assertion A created by extraction run R1 (model M, prompt version P3), reviewed by a human reviewer on 2026-09-12."
3. **Distinctions:** operational lineage (live `mongoResearchRunId`, `agentRunUid`) versus semantic provenance (`SUPPORTED_BY` chain). Run id says who produced, not what supports it.
4. **Evidence:** `extractionMethod`, `agentRunUid`, `Adjudication.reviewerType`, `reviewedAt`.
5. **Model:** catalog fields as named; live `mongoResearchRunId` maps to `agentRunUid` (see `live-schema-decisions.md`).
6. **Query:** QS-1a (operator tier columns).
7. **Prevents:** using a run id as if it were provenance. Qualified: edges created through the live API carry a run id only if the writer set it.

#### CQ-AX-12 (Essential now, A)
1. **Desire:** Be sure nothing public can reach private data.
2. **Example answer:** "0 shared-to-private edges; 0 private nodes under shared indexes; 2,114 private-to-shared reference edges, all of allowed types."
3. **Distinctions:** property hiding versus path existence; incoming edges from private nodes onto shared nodes; derived search text.
4. **Evidence:** the graph and the index metadata.
5. **Model:** private records recognised by the `hu:private-` uid prefix and `privacyClass` and kept in the private context store (K-5 revised by round 0008; no marker label in the shared graph); no governed reference edges cross the boundary, references are uid properties.
6. **Query:** QS-6a, QS-6b; V-113 to V-116.
7. **Prevents:** a co-interest inference through a private bridge node; a shared embedding built from private text.

#### CQ-AX-13 (Essential now, Q)
1. **Desire:** Give an agent only what its task needs.
2. **Example answer:** "Request req-ax-trail-0001 resolves to 6 modules, 41 node and relationship definitions, depth 3, no private labels."
3. **Distinctions:** schema slice versus data slice; typed intent versus raw query.
4. **Evidence:** the projection contract and its closure trace.
5. **Model:** `projection-contract.yaml` plus `accessTier`, `privateContext`, `traceDepth` (K-3).
6. **Query:** QS-5a, QS-5b.
7. **Prevents:** an agent receiving the whole ontology or writing outside its slice.
Qualification: node and relationship budgets are service-enforced.

#### CQ-AX-14 (Essential now, A)
1. **Desire:** Turn words into candidates without deciding for the agent.
2. **Example answer:** "'NR' matches 3 substances and 1 material by index `CompoundSearch` (lexical scores only). One open hypothesis proposes substance S (status `PROPOSED`)."
3. **Distinctions:** lexical hit, semantic hit, resolved identity.
4. **Evidence:** search results, identifier assertions, hypotheses.
5. **Model:** live `@fulltext` and `@vector` surfaces; `ResolutionHypothesis`.
6. **Query:** QS-8.
7. **Prevents:** treating a search hit or a high similarity as identity.

#### CQ-AX-15 (Foundational, A)
1. **Desire:** Keep candidates apart from committed facts.
2. **Example answer:** "Agent run R2 produced 14 candidates (status `EXTRACTED` or `PROPOSED`); none is visible to the public tier."
3. **Distinctions:** `GraphCandidate` in the runtime versus committed assertion; `PROPOSED` versus `ACCEPTED`.
4. **Evidence:** status and run id.
5. **Model:** `Assertion.status`, `agentRunUid`.
6. **Query:** QS-1a with an allowed-status parameter.
7. **Prevents:** a public answer built on unreviewed extraction.

#### CQ-AX-16 (Foundational, A)
1. **Desire:** Refuse bad writes before commit.
2. **Example answer:** "Write refused: `ENDORSES_PRODUCT` P to X cites an `ADVISES_ORGANIZATION` assertion (`NO_LIVE_MATCHING_ASSERTION`)."
3. **Distinctions:** the catalog's forbidden implications.
4. **Evidence:** the cited assertion.
5. **Model:** edge citation properties; `forbiddenImplications` list.
6. **Query:** QS-4b.
7. **Prevents:** reintroducing a forbidden implication through an agent write.

#### CQ-AX-17 (Foundational, Q)
1. **Desire:** Know whether the tested thing is buyable here and now.
2. **Example answer:** "Studied: 500 mg/day of material M (study intervention). Current US label (observed 2026-07-10) declares 250 mg per serving, two servings per day gives 500 mg declared. Listed by merchant X (offer observed 2026-10-01). Availability is a merchant statement, not a sale. Identity of M to the studied material is `UNKNOWN`."
3. **Distinctions:** studied versus labeled amount; per-serving versus per-day; label versus measured; listed versus sold; jurisdiction.
4. **Evidence:** study intervention, label snapshot, offer observation, regulatory status by jurisdiction.
5. **Model:** `InterventionComponent`, `IngredientComponent` with `quantityBasis`, `Offer`, jurisdiction-specific regulatory records.
6. **Query:** QS-3a + QS-2b + QS-1a.
7. **Prevents:** equating "product available" with "tested dose obtainable".

#### CQ-AX-18 (Foundational, Q)
1. **Desire:** Know whether a speaker had a stake when speaking.
2. **Example answer:** "On the episode date (2026-03-04) the speaker held an advisory role with the manufacturer (valid 2025-01 to unknown end, source-stated). The relationship does not, by itself, mean endorsement."
3. **Distinctions:** valid time of the role versus the date of the statement; advising is not endorsing.
4. **Evidence:** the role assertion and the episode's `publishedAt` or utterance time.
5. **Model:** `ADVISES_ORGANIZATION`, `EMPLOYED_BY` with valid time; claim occurrence time (Lane 4).
6. **Query:** QS-2a at V = statement date, joined to QS-1a of the claim occurrence.
7. **Prevents:** using today's relationship for a past statement, or inferring endorsement from advising.
Qualification: the full relevance of a financial relationship is Lane 4's CQ-CL.

#### CQ-AX-23 (Foundational, A)
1. **Desire:** Read regulatory status exactly.
2. **Example answer:** "Establishment registered with FDA (registration number R). Device listed. Premarket clearance: no record found in the ingested sources. Registration and listing do not denote approval or clearance."
3. **Distinctions:** registration, listing, notification, designation, clearance, approval, authorization; each is jurisdiction-specific.
4. **Evidence:** the agency record; for the registration case, 21 CFR 807.39 ([SRC-FDA-807-39]).
5. **Model:** `RegulatorySubmission`, `RegulatoryResponse`, `OrphanDesignation`, `DrugApproval` (catalog); registration and listing records (Lane 3 to add); forbidden implications extended by one: registration or listing does not imply clearance or approval.
6. **Query:** QS-4a with the extended pair list; QS-7 for "no record found".
7. **Prevents:** "FDA registered" displayed as "FDA approved". Owned by Lane 3 (CQ-MF); listed here as the access-layer expression.

#### CQ-AX-24 (Essential now, A)
1. **Desire:** See how strong the evidence is, by what criteria.
2. **Example answer:** "Assessment E1 (method evidence-grading v1, reviewer type human, 2026-09-12): design randomized, applicability dimensions as in QS-3, result `PARTIALLY_SUPPORTED`. The extractor's initial 'MODERATE' label on the claim is retained as an extraction hint, not as strength."
3. **Distinctions:** an extraction-time hint versus an assessment with criteria, method version and provenance.
4. **Evidence:** the assessment's inputs.
5. **Model:** `EvidenceAssessment` with `methodVersion`. The live `Claim.evidenceStrength`, `AssociationMetadata.evidenceStrength`, `TreatmentTargetMetadata.evidenceStrength` and `SafetyMetadata.evidenceStrength` are refined to hints (see `live-schema-decisions.md`).
6. **Query:** QS-1a; QS-1b exposes the live attribute under a hint label.
7. **Prevents:** "well-supported" as a node attribute.

#### CQ-AX-25 (Foundational, Q)
1. **Desire:** List products by what they declare, as of a date.
2. **Example answer:** "Variants whose formulation valid on 2026-07-10 (as recorded 2026-10-03) declares at least 200 mg of substance C per serving: V1 (declared as the chloride salt, basis salt mass). Blends that 'provide' C are listed separately with no amount."
3. **Distinctions:** declared versus measured; salt mass versus active moiety; per serving versus per container; `PROVIDES_CONSTITUENT` versus `QUANTITATIVELY_CONTAINS`; formulation at V.
4. **Evidence:** label declarations and, if present, measurements.
5. **Model:** `FormulationVersion`, `IngredientComponent` (`quantity`, `unitCode`, `quantityBasis`, `declaredAs`); the derived `CONTAINS` shortcut is regenerable and never filtered on alone.
6. **Query:** QS-2b (formulation as of R and V) joined to component predicates; QS-4a for the shortcut.
7. **Prevents:** answering from a flat `contains` edge. The live `CONTAINS_COMPOUND_FORM` with `DoseMetadata` has no time and no declared-versus-measured basis.
Qualification: normalization of salt versus moiety amounts is an open question (`OPEN-QUESTIONS.md`, Priority 1).

#### CQ-AX-26 (Foundational, A)
1. **Desire:** Know what a named person actually said, in context.
2. **Example answer:** "In episode E at segment S (span L), the speaker read a sponsor script stating X. The speaker's own view is not asserted. A separate occurrence, minute 41, states a personal experience."
3. **Distinctions:** personal experience, manufacturer claim read aloud, quoted study result, hypothetical; speaker versus asserter.
4. **Evidence:** transcript span with segment and `textVersionHash`.
5. **Model:** live `ClaimOccurrence` (`UTTERED_BY`, `OCCURS_IN`, `SUPPORTED_BY` with `quoteSpan`) aligned by Lane 4 to catalog `Assertion` with `ASSERTED_BY`.
6. **Query:** QS-1b now; QS-1a after alignment.
7. **Prevents:** a `Person-[:RECOMMENDS]->Product` edge standing for a sponsor read. Owned by Lane 4 (CQ-CL).

#### Expansion and Research frontier questions

- **CQ-AX-10 (Expansion, Q).** Stale adjudication queue. Extension path: compare `Adjudication.reviewedAt` with newer `SourceSnapshot.retrievedAt` of the cited source. Needs no new records beyond QS-1a data. Qualified because a content change that does not alter the cited span should not trigger review.
- **CQ-AX-11 (Expansion, Q).** Impact of a correction. Extension path: `AnswerRecord` to `Assertion` citation edges (K-7) make the reverse lookup a one-hop query. Without them it can only be approximated from recorded parameters.
- **CQ-AX-19 (Expansion, Q).** Declared versus measured for a lot: needs `ProductLot`, `MeasuredResult`, certificate data. Extension path: `quality` module, already in the catalog.
- **CQ-AX-20 (Research frontier, X).** Mechanism-to-product exposure. Needs pharmacokinetic or bioavailability data for the actual formulation. The graph can hold what a source measured, and the inference "exposure follows" is recorded only as an adjudicated, scoped assessment. Limit: such data is rarely public.
- **CQ-AX-21 (Expansion, Q).** Assay comparability. The comparability assessment is shared (Lane 3, round 0004). The person's values stay private. The access pattern is fixed now: the private store sends only assay identifier uids to the shared graph (QS-6).
- **CQ-AX-22 (Expansion, Q).** Protocol version versus protocol in use. Public protocol versions are shared; deviations are private (Lane 5).
- **CQ-AX-27 (Expansion, Q).** Same person. Needs `Identifier` records (ORCID) and `ResolutionHypothesis` for authors. The live `Person.LINKS_TO PseudonymousActor` edge is an identity claim and moves to a hypothesis (see `live-schema-decisions.md`).
- **CQ-AX-28 (Research frontier, X).** "People like me." Needs consented, de-identified cohort data and a re-identification risk method. Neither is permitted nor available. The shared graph never aggregates over private histories; the question stays out of the graph.

---


# 8. Minimal adversarial pairs

Each pair must produce different graph deltas. Rounds that introduced a pair are named in the section headers.

## 8.1 Starter pairs (0.1.0)

Each pair must produce different graph deltas.

1. “Product X contains 250 mg of compound C” versus “Product X’s blend provides compound C.”
2. “The trial evaluated Product X” versus “The trial evaluated the same compound sold in Product X.”
3. “The company says X improves sleep” versus “A randomized trial found X improved sleep.”
4. “No adverse events were reported” versus “No adverse events occurred.”
5. “Available as of March” versus “launched in March.”
6. “Current label retrieved today” versus “label effective today.”
7. “Evidence is insufficient” versus “evidence shows no effect.”
8. “The source was corrected in June” versus “the underlying fact ceased to be true in June.”

## 8.2 Pairs 9 to 21 (round 0009)

Pairs 1 to 8 are in the existing file. Each pair below must produce different graph deltas. "Evidence needed" names what a source must supply to justify the choice.

| # | Area | Statement A | Statement B | Delta A | Delta B | Evidence needed |
|---|---|---|---|---|---|---|
| 9 | Claims | "Speaker S says X improves sleep." | "Speaker S read a sponsor's script saying X improves sleep." | `ClaimOccurrence` `ASSERTED_BY` S with `assertionBasis` PERSONAL_EXPERIENCE or EXPERT_OPINION and `speechAct` STATES. | `ClaimOccurrence` `ASSERTED_BY` S (one asserter, KCR-4.3) with `assertionBasis` MANUFACTURER_CLAIM, `segmentKind` SPONSOR_READ, located in an `EpisodeSegment` of type SPONSOR_READ, a `SPONSORS_CONTENT` assertion by the sponsor, and no `RECOMMENDS` edge from S. (Restated at integration: the original delta gave the occurrence two asserters.) | Transcript span with surrounding segment, sponsor disclosure. |
| 10 | Mechanisms | "Compound C raised NAD+ in mouse liver at 400 mg/kg." | "Product X raises NAD+." | Assertion with subject `ChemicalSubstance` C, qualifiers species, tissue, dose, and a result status "measured". | Assertion with subject `ProductVariant` X and no species or tissue. It is not entailed by A; the link between them is an `EvidenceApplicability` with identity `UNKNOWN`. | Paper methods and results with locator; label for X. |
| 11 | Diagnostics | "Ferritin 45 ng/mL by assay A." | "Ferritin 45 ng/mL by assay B." | `MeasuredResult` `PRODUCED_RESULT` by an execution using method A. | Same number, execution using method B. No equivalence edge; a comparability assessment has dimension `UNKNOWN` until one is made. | Method identifiers (for example LOINC method part), reference intervals, manufacturer calibration statements. |
| 12 | Regulatory | "Establishment registered and device listed with FDA." | "Device cleared by FDA." | `RegulatorySubmission` kind registration and listing, no `RegulatoryResponse` of kind clearance. | A clearance record with a number, a decision date and the cleared indication. | FDA registration database note and 21 CFR 807.39 for A ([SRC-FDA-807-39]); a clearance decision record for B. |
| 13 | Protocols | "Protocol v2 changed the stated dose." | "A person changed their own dose within protocol v1." | New shared `ProtocolVersion` with a changed step; v1 unchanged. | Private protocol-in-use deviation record referencing v1 by uid; no shared edit. | The published protocol versions; the person's own record (private). |
| 14 | Time | "A 2023 label was ingested in 2026." | "The formulation changed in 2026." | New assertion with `validFrom` 2023 (source-stated), `recordedAt` 2026; existing rows' recorded episodes unchanged. | New formulation version valid from 2026; the 2023 attachment closed in valid time. | The label's own date; whether the 2026 label differs. |
| 15 | Time | "The study was published in 2019." | "The study ran in 2019." | `Publication.publishedAt` 2019; study valid time unknown. | Study administration valid time 2019; publication later or unknown. | Registry dates; publication date. |
| 16 | Private context | "The March recommendation used the March lab value." | "Given the June lab value, the March recommendation is outdated." | Snapshot carries the context version used in March; no change. | A new decision occurrence cites the June value; the March snapshot is not edited. | The private measurement history (private). |
| 17 | Studies | "Biomarker B rose in the trial." | "Participants' symptom S improved." | `OutcomeDefinition` kind surrogate; `outcomeMatch` for a symptom goal is `PARTIAL`. | `OutcomeDefinition` kind clinical or patient-reported; `outcomeMatch` `MATCH`. | Registry outcome measures and the paper's outcome definitions. |
| 18 | Quality | "The page says 'third-party tested'." | "Lot L has a certificate of analysis from lab Z." | `LotTestSummary` or a bare assertion; no lab, method or values. | `CertificateOfAnalysis` `CERTIFIES_RESULTS_FOR` lot L, with `TestExecution`, `TestMethod`, lab and results. | The certificate itself with signer and method. |
| 19 | Access | "Evidence for outcome O in adults, from the shared graph." | "You should take X, based on your history." | Public answer: only shared records read; optional `AnswerRecord` if published. | Private recommendation occurrence referencing shared uids; nothing written to the shared graph. | For B, the person's private context and consent (private). |
| 20 | Time | "The product page shows 'In stock' as observed 2026-10-01." | "The product has been available since 2026-10-01." | `Offer` observation with `observedAt` 2026-10-01 and `OPEN_END_STALE` after. | Offer or availability state with `validFrom` 2026-10-01 stated by the source. | The page snapshot; a source that dates availability. |
| 21 | Search | "Search 'NR' returned compound C." | "'NR' is compound C." | A candidate in the result; no edge. | `ResolutionHypothesis` `PROPOSES_MATCH` C, `PROPOSED`; accepted only after adjudication. | Authority identifiers; context of the mention. |

Pairs 20 and 21 repeat the structure of existing pairs 5 and 6 in the commerce and search domains, because the live schema has a current-state surface (`Product.currentAsOf`, `Listing.availabilityStatus`) and a search surface that invite exactly these errors.

## 8.3 Pairs 22 to 29 (round 0006)

22. "I take a gram of NMN every day" versus "Take a gram of NMN every day." (practice report versus recommendation)
23. "The episode is sponsored by X" versus "The guest endorses X."
24. "Investor (I)" versus "Equity (E)" on a disclosure page.
25. "Codes for a corporate group" versus "codes for each member company".
26. "No disclosure found in our captured excerpt" versus "No disclosure was made."
27. "The publisher corrected the amount" versus "The speaker stopped taking that amount."
28. "A newsletter repeats the claim" versus "A second person independently makes the claim."
29. "Segment at 4:47 in the video" versus "segment at 4:47 in the audio feed" (dynamic ad insertion).

## 8.4 Pairs 30 to 36 (rounds 0002 and 0003)

Each pair must produce different graph deltas.

30. "Study X evaluated NRPT, commercially known as Basis" vs "Study X evaluated the current Basis formulation" (naming assertion vs applicability with `MATERIAL_IDENTITY = UNKNOWN`).
31. "NIAGEN 300 mg trial applies to Tru Niagen 300 mg" vs "applies to Basis" (`SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED` vs `SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL` plus `ACTIVE_COMPOSITION` subset).
32. "Whole-blood NAD+ increased" vs "muscle sirtuin activity increased" (measured human blood vs hypothesis, and measured-null muscle proxy).
33. "LDL-C is a validated surrogate" vs "LDL-C rose in a supplement trial" (context-of-use bound classification vs safety biomarker).
34. "Primary endpoint not met" vs "no effect" (`NOT_SIGNIFICANT` + `INCONCLUSIVE` vs `EVIDENCE_OF_NO_MEANINGFUL_EFFECT` with margin).
35. "Registry shows no results" vs "results unpublished" (`resultsPosted: false` vs absence of results publication).
36. "Elysium provided the investigational product" vs "Elysium supplied the NR" (`PROVIDES_INVESTIGATIONAL_PRODUCT` vs `SUPPLIES_INGREDIENT_MATERIAL`).

## 8.5 Pairs 37 to 42 (rounds 0007 and 0008)

37. "BellLabs selected option A" versus "the person chose option A" (`RecommendationOption.disposition = SELECTED` versus `UserDecision.decisionKind = CHOSE`).
38. "A podcast host recommends product X" versus "BellLabs recommends product X to this person" (`Person -[:RECOMMENDS {assertionUid}]->` versus a private `RecommendationSnapshot`).
39. "The person adopted protocol edition 2" versus "the person follows every step of edition 2" (`ProtocolAdoptionVersion` with deviations).
40. "Shared with the coach for 90 days" versus "published" (`SharingGrant.permittedActions` `VIEW` versus `CONTRIBUTE_DEIDENTIFIED`).
41. "The paper was retracted" versus "the paper never reported the finding" (new adjudication versus superseded assertion).
42. "The archive shows the 2019 label" versus "BellLabs knew the 2019 label in 2019" (`observedAt` 2019, `retrievedAt` and `recordedAt` 2026).


# 9. Acceptance target

## 9.1 Initial acceptance target (0.1.0)

The first vertical slice should answer `CQ-ID-01`, `CQ-ID-02`, `CQ-EV-01`, `CQ-EV-04`, `CQ-TM-01`, `CQ-TM-02`, `CQ-RC-01`, and `CQ-RC-03` over a small fixture set containing two products, two formulation versions, one trial, one case report, one conflicting marketing claim, and one late-arriving correction.

## 9.2 Amendment accepted for 0.2.0 (round 0009)

The first vertical slice should answer, over the fixture set already named: CQ-ID-01, CQ-ID-02, CQ-EV-01, CQ-EV-02, CQ-EV-04, CQ-TM-01, CQ-TM-02, CQ-RC-01, CQ-RC-03, CQ-RC-05, and the access questions CQ-AX-01, CQ-AX-02, CQ-AX-07, CQ-AX-12, CQ-AX-13, CQ-AX-14, CQ-AX-24. Each must be answered by a shape in `query-shapes.md`. A failing minimal pair from section 4 for any Essential question is a release blocker.

Source keys in square brackets refer to entries in `../sources/source-registry.yaml`. "Lane N" names the specialist lane that drafted a section; the rounds each lane produced are listed in `proposal-index.md`.
