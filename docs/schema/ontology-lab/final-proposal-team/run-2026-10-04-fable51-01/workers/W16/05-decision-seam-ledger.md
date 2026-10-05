# W16 decision, objection and seam ledger

Status: **ACCEPTED-FOR-PROPOSAL** = W16 recommends it and the fragment implements it (Fable rules); **UNRESOLVED** = needs another owner or a ledger ruling. No consensus with other workers is claimed: none of their packets existed when this was written (W01, W02, W21 directories were empty).

## Decisions

| Id | Decision | Evidence | Alternatives (rejected) | Status |
|---|---|---|---|---|
| W16-D01 | Edition trigger is a change of canonical `payloadHash` (W16-CANON-1), not of raw bytes; `payloadCanonicalizationVersion` stored | W16-S02: 37 raw digests 2026-01-24..2026-10-02; W16-S01/S03: 4 real step changes | edition per capture digest (floods history); edition only when the source labels a version (misses silent changes) | ACCEPTED-FOR-PROPOSAL |
| W16-D02 | `changeProvenance` on the edition: SOURCE_VERSIONED or SNAPSHOT_DIFF; THIRD_PARTY_REPORTED only on Assertions/query rows (V-530p) | catalog forbidden implication; W16-S09 vs S01 conflicting doses | edition from a news report | ACCEPTED-FOR-PROPOSAL |
| W16-D03 | A byline that does not change with content is not a version label; recorded in `sourceVersionDateText`; may be a PUBLICATION_PROXY valid-from only for the first observed edition | Blueprint byline "01.23.2026" identical in S03 and S01 while doses changed | editionLabel = byline date | ACCEPTED-FOR-PROPOSAL |
| W16-D04 | D-004 implemented as `HAS_PROTOCOL_STEP` from the edition + derived, read-only `HAS_CURRENT_PROTOCOL_STEP` (`Protocol.currentSteps`, `@settable(false,false)`) | D-004, CL-013; B1 forbids `@cypher` | `@cypher` projection (forbidden); no projection (breaks live readers) | ACCEPTED-FOR-PROPOSAL; ruleOnly registration UNRESOLVED (W16-SR-06) |
| W16-D05 | Order on the HAS_PROTOCOL_STEP edge; steps shared across editions only with their dependency closure (copy-on-write, V-527p) | protocols.io V.1 step 1 = V.2 step 2 (S04/S05) | orderIndex on the step (forces a new node per reorder) | ACCEPTED-FOR-PROPOSAL |
| W16-D06 | Dependency DAG vs recurrence: ordering kinds acyclic per edition (V-528p); recurrence/cycles/repeat-until are step schedule data; lag range on DEPENDS_ON | NICE 1.10.15 "1 week after starting … weekly until … stable" (S06); HBOT "60 sessions, 5 per week" (S01) | self/cyclic DEPENDS_ON for repetition; banning all cycles without a repetition model | ACCEPTED-FOR-PROPOSAL |
| W16-D07 | Conditions in CNF on HAS_CONSTRAINT (`conditionGroup`, `negated`); HAS_CONSTRAINT domain extended to ProtocolAdjustmentRule (replaces REQUIRES_CONDITION) | "if over 40 or a family history" (S01); "every 6 months, or every 3 months for people in any of the following groups" (S06) | implicit AND (wrong for the MRI case); one constraint node per Boolean formula (non-reusable, unqueryable) | ACCEPTED-FOR-PROPOSAL |
| W16-D08 | Branches = CONDITIONAL steps + MUTUALLY_EXCLUSIVE_WITH; evaluation three-valued (UNKNOWN on missing fact) | Q-W16-04b/c/d executed | a single step with two cadences | ACCEPTED-FOR-PROPOSAL |
| W16-D09 | Bounded ranges for every schedule quantity (cadence, occurrences per period, totals, durations, cycles, lags, dose); verbatim texts always kept | "every 3 to 6 months", "3 to 5 per week", "500 to 600 mg", "at least 4 weeks, preferably up to 3 months" | midpoint; free text only | ACCEPTED-FOR-PROPOSAL |
| W16-D10 | `speechAct` (kernel enum) on ProtocolStep: practice vs recommendation | Blueprint "My sauna protocol: daily" vs "Aim for 3 to 5 sauna sessions per week" (S01) | infer recommendation from listing | ACCEPTED-FOR-PROPOSAL; forbidden-implication registration UNRESOLVED (W16-SR-14) |
| W16-D11 | Declared dose on USES with explicit `quantityBasis`; per-dose × occurrences is not rewritten into per-day; the page's own "400 mg daily" stays in verbatim text | "Acarbose 200 mg (Rx) (twice daily)" and "Acarbose 400 mg daily" (S01) | normalizing to PER_DAY silently | ACCEPTED-FOR-PROPOSAL |
| W16-D12 | Edition-binding rule: INCLUDES_PROTOCOL → ProtocolEdition = PINNED; HAS_SUBPROTOCOL → Protocol = FLOATING, resolved as-of and labelled; same rule for materials (USES → FormulationVersion pinned vs ProductVariant floating) | live alignment "needs a rule for which edition of a subprotocol is included"; Q-W16-13, Q-W16-08a | always pin (impossible when the source does not name a version); always float (loses stated versions) | ACCEPTED-FOR-PROPOSAL |
| W16-D13 | Authorship, performer roles and step evidence are kernel Assertions (no new edge types) | protocols.io V.2 adds AIDA to authors (S04); NICE shared-care prescriber role (S06) | `authorName` string; new role edges | ACCEPTED-FOR-PROPOSAL; predicate registration UNRESOLVED (W16-SR-02) |
| W16-D14 | Observation implements W07 `DiagnosticResult`; public and attributed only (V-532p); ABOUT_CONDITION asserted (V-536p) | round 0008 §7; CL-008 | private observations under RBAC | ACCEPTED-FOR-PROPOSAL; field types UNRESOLVED (W16-SR-03) |
| W16-D15 | ProtocolStep stays archetype Entity (catalog) with payloadHash and service-enforced immutability | catalog `protocols.nodes.ProtocolStep` | re-archetype as VersionedState (kernel change without failing case) | ACCEPTED-FOR-PROPOSAL |
| W16-D16 | Protocol-level schedule fields move from Protocol to ProtocolEdition (no mutable projection on Protocol) | an identity carrying a mutable schedule contradicts edition history | keep as current-edition projection (live alignment row) — rejected: stale-projection risk with no CQ benefit; `currentSteps` covers live readers | ACCEPTED-FOR-PROPOSAL (differs from live-alignment "keep (projection)"; Fable to rule) |
| W16-D17 | Retire `Target.comparedToRanges` (COMPARED_TO_REFERENCE → legacy ReferenceRange) and `ProtocolResult.supportedBy` | targets carry bounds; INV-404 (chunk not a locator) | keep legacy edges | ACCEPTED-FOR-PROPOSAL |
| W16-D18 | stepKey rule W16-STEPKEY-1 (model cards §6) with method version on the edition | OPEN-QUESTIONS P2 item 4; fixtures 01, 02, 08 | step number; display text | ACCEPTED-FOR-PROPOSAL (provisional until an extraction pilot over all 37 Blueprint captures) |
| W16-D19 | Repeat-until termination kept as `repeatUntilText` until REPEAT_UNTIL role is added | NICE 1.10.15 | invent a structured stop condition | UNRESOLVED (W16-SR-08) |
| W16-D20 | `CadenceUnit` YEAR/MINUTE requested; until ruled, "annually" = 12 MONTH with verbatim text | S01 Routine Measurement | silently approximating | UNRESOLVED (W16-SR-07) |

## Objections recorded against my own proposal

| Objection | Response | Residual |
|---|---|---|
| CNF on edges is more than the catalog has | Two real sources fail without it; it is three nullable edge properties; evaluation semantics executed | evaluator lives in the private store (W23) |
| `speechAct` on steps duplicates Assertion speech acts | Steps are edition payload, not Assertions; classifying the text span is needed to answer "what does it recommend" | classification is editorial (requirementBasis-like); method version needed |
| Many schedule fields | Each is a live field split into min/max or a source-forced addition; a Schedule node was considered | GraphQL surface grows; ingestion normalizer required |
| ADDED_OR_NOT_CAPTURED weakens diffs | It is honest for partial captures (V.1 excerpt) | complete captures remove the qualifier |

## Kernel-change requests

None. W16 uses the kernel unchanged (archetypes, Assertion, asserted_edge profile, predicateExclusivity, privacy). Registration requests (tokens, predicates, ruleOnly, validators) are seam requests, not kernel changes.

## Unresolved dependencies and closure criteria

| Seam | Owner | Closure criterion |
|---|---|---|
| W16-SR-01 tokens | W00 | tokens in `conventions.uidTypeTokens` |
| W16-SR-02 predicates and subject/object ranges | W00 | predicates registered; AssertionSubjectTarget includes Protocol/ProtocolEdition/ProtocolStep |
| W16-SR-03 DiagnosticResult types | W07 | W07 fragment builds together with W16 fragment |
| W16-SR-04 privacyClass casing | W00 | one stored casing; validators updated |
| W16-SR-05 Person fields | W01 | W01 fragment carries the two fields |
| W16-SR-06 ruleOnly derived edge | W00 | catalog entry ruleOnly: true |
| W16-SR-07/08 enum values | Fable | ledger ruling |
| W16-SR-09 route vocabulary | W00/W09 | shared enum named |
| W16-SR-10 CL-007 | W09 | W09 confirms study scope |
| W16-SR-11 private contract | W23 | W23 contract cites edition uid + stepKey + CNF semantics |
| W16-SR-12 substance classes | W02 | class identity or explicit "text only" ruling |
| W16-SR-13 applicability for steps | W10 | union members + forbidden implication |
| W16-SR-14 validators | Fable | ids assigned |
| W16-SR-15..20 | W08, W05, W04, W00/W20, W17, W10 | owners confirm boundaries/members |
