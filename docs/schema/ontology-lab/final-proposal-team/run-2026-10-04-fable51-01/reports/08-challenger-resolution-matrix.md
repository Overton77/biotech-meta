# 08 Challenger resolution matrix (Wave 5)

Run `run-2026-10-04-fable51-01`, 2026-10-04, Opus 5.5 worker for Fable. Inputs: the five Wave 5 Challenger reports in `validation/challengers/` (CH-W09W10-study-transfer, CH-W23-privacy, CH-W16-protocols, CH-W21W22-media, CH-W00-kernel). Outputs:

- `validation/fable-w5-validators.cypher`: 65 statements, V-F5-01 to V-F5-65, no gaps. Each statement is standalone and returns rows only on violations.
- `validation/fable-w5-params.json`: only the keys to add to `validation-params.json`. List keys are unioned; maps are added. Each key has a `_why_` sibling.
- `validation/query-shapes-privacy-corrected.cypher`: QS-5b, QS-6a and QS-8 in allow-list form (F-W5-11), plus the corrected Q04-1.

## How the tests were run

- **Instances.** All tests ran on embedded Neo4j 5.26.31 Community instances c3, c4 and c5 through bolt.
  - **c3:** final operations file, translated fixtures, W09 and W10 positives. For the privacy cases I loaded W23 `00-shared-base` and `04-uid-redirect` (26 nodes, every uid contains `w23`) and deleted them afterwards. c3 is back to 865 nodes and 1580 relationships.
  - **c4:** media group load.
  - **c5:** W16 fixture 08. I added W16 fixtures 02, 03, 06 and 10 (61 nodes) and left them loaded, because 02 and 08 share `hu:person:bryan-johnson`. c5 now has 92 nodes.
- **Parameters.** `merged-params.json` is the FINAL `validation-params.json` (re-read after the gen-params regeneration: 146 asserted and 42 derived types) unioned with `fable-w5-params.json`.
- **Mutations.** Every mutation ran inside one explicit transaction that was rolled back at the end. Inside it: the Challenger's mutation, then the validator, then the Challenger's undo, then the validator again. The instances therefore carry no residue.
  - Two undos (CH-S-01, CH-S-02) were given a typed relationship match in front of the Challenger's untyped one. Inside an open transaction the untyped `MATCH ()-[r]->() WHERE r.relationshipUid STARTS WITH …` missed rows.
- **Which graph each family ran on.** Study, privacy, media and W16 cases ran on the instances as loaded; their Challengers wrote them against pre-normalization uids. Kernel cases ran on c3 after `fixtures-final/99-normalize-live-ids.cypher` (the 03:31 version) was applied inside the same rolled-back transaction, as the kernel Challenger did.
- **The backfill fails on c3 as composed.** Its first statement violates the `StudyArm` id uniqueness constraint: `hu:study-arm:nct02678611-placebo` and `hu:arm:nct02678611-placebo` share an opaque id (CH-S-18). For the test I guarded the statement with `AND NOT EXISTS { MATCH (m) WHERE m.id = last(split(n.uid, ':')) }`. Fable's fixture fix for CH-S-18 removes the need for the guard.
- **Parameter regression check.** `validation/final-validation-suite.cypher` (184 statements) returned exactly the same rows on c3, c4 and c5 with the FINAL params and with the merged params.

## Counts

| | count |
|---|---|
| Objections in the five reports | 112 (CH-S 19, CH-P 18, CH-R 16, CH-M 17, CH-K 42) |
| Resolved (fully or partly) by a V-F5 validator, or detected by one | 84 |
| Validators written | 65 |
| Passed EXPLAIN on c3, c4 and c5 | 65 |
| Mutation-tested: fired on the replay and returned to the baseline after the undo | 64 |
| Tested as an observed defect, no mutation (V-F5-16, CH-S-17) | 1 |
| Left to Fable (SDL, OPS, FIXTURE or PARAMS) or to the corrected query shapes only | 15 |
| Held in the Challenger run, no action | 13 |
| Rows with a DEFERRED part (each states its reason) | 14 |

On the baseline, zero rows on every instance:
- **Without normalization:** 44 validators.
- **After the documented normalization step:** the same 44. V-F5-61 and V-F5-62 shrink to the D13 and D14 rows but stay non-zero on c3.

Every non-zero baseline row is accounted for below. It is either a fixture defect (D1 to D15) or an embedded negative of a worker fixture (E1 to E4). I tightened no validator to hide a row.

## Objection matrix

The tested column reads `rows before → after the mutation → after the undo`. A baseline of 1 or more is explained in the fixture-defect list.

| id | severity | disposition | tested |
|---|---|---|---|
| CH-S-01 | MAJOR | VALIDATOR V-F5-01 (V-201r verbatim) | yes @c3: V-F5-01 0→2→0 |
| CH-S-02 | MAJOR | VALIDATOR V-F5-01, V-F5-02 | yes @c3: V-F5-01 0→5→0; V-F5-02 0→1→0 |
| CH-S-03 | MAJOR | VALIDATOR V-F5-03 (SDL option asAdministeredFormulationVersionUid accepted by the rule; (b) GraphQL write acceptance stays DEFERRED: input-type rule needs SDL/service) | yes @c3: V-F5-03 0→1→0 |
| CH-S-04 | MAJOR | VALIDATOR V-F5-04 for (b); (a)/(c) detection already V-204; prevention (force PROPOSED at create) DEFERRED: service/SDL write rule, no validator can reject a write | yes @c3: V-F5-04 1→3→1 (baseline 1 = fixture defect D1) |
| CH-S-05 | MAJOR | VALIDATOR V-F5-05 (V-203r) | yes @c3: V-F5-05 0→1→0 |
| CH-S-06 | MAJOR | (a) VALIDATOR V-F5-06 (W10-V08r); (b) DEFERRED: needs a Claim outcome-class field (seam to W21 Claim) to compare input endpoint class with claim class; V-F5-17 review queue flags the case only incidentally | yes @c3: V-F5-06 0→1→0; V-F5-17 0→1→0 |
| CH-S-07 | MAJOR | DEFERRED: verdict-vs-inputs is a method judgement, not structural; review queue V-F5-17 (W10-V19) shipped | yes @c3: V-F5-17 0→1→0 (review) |
| CH-S-08 | MAJOR | VALIDATOR V-F5-07 (V-215r2) | yes @c3: V-F5-07 0→2→0 |
| CH-S-09 | MAJOR | VALIDATOR V-F5-08 (V-218r verbatim) | yes @c3: V-F5-08 0→3→0 |
| CH-S-10 | MAJOR | VALIDATOR V-F5-09 + FABLE-OPS (6a must become a one-shot migration stamping migrationRunId/migratedAt, otherwise every migrated live edge fires) | yes @c3: V-F5-09 0→3→0 |
| CH-S-11 | BLOCKING | VALIDATOR V-F5-10 (premise = rule predicate, inverse subject/object; REPORTS_SAFETY_SIGNAL branch) + PARAMS derivedTypes/derivedEdgePremises | yes @c3: V-F5-10 0→3→0 (11a, 11b, 11c) |
| CH-S-12a | MINOR | VALIDATOR V-F5-11 | yes @c3: V-F5-11 1→2→1 (baseline 1 = fixture defect D2) |
| CH-S-12b | BLOCKING | VALIDATOR V-F5-12 (all $episodeTypes) | yes @c3: V-F5-12 0→1→0 |
| CH-S-13 | MAJOR | VALIDATOR V-F5-13 | yes @c3: V-F5-13 0→1→0 |
| CH-S-14 | MAJOR | VALIDATOR V-F5-14 for (a)/(b); (c) API repair path DEFERRED to Fable SDL/service (supersedes not updatable, one atomic version-creation operation) | yes @c3: V-F5-14 1→3→1 (baseline 1 = fixture defect D3) |
| CH-S-15 | BLOCKING | VALIDATOR V-F5-15 (+ V-F5-63); SDL change recordedTo @settable(false,false) on EvidenceAssessment types recommended to Fable (not in its list) | yes @c3: V-F5-15 0→1→0 (GQL-10 replayed as Cypher SET) |
| CH-S-16 | BLOCKING | VALIDATOR V-F5-18 (+ V-F5-20); free-text name without a token/date pattern DEFERRED: needs coded descriptors (SDL) | yes @c3: V-F5-18 0→1→0 |
| CH-S-17 | MINOR | VALIDATOR V-F5-16 | yes (observed, no mutation): 5 rows on c3 = fixture defect D4 |
| CH-S-18 | MAJOR | FABLE-FIXTURE (uid tokens); V-F5-61 reports the 6 duplicate identities that the backfill cannot give an id | no (Fable) |
| CH-P-01 | BLOCKING | VALIDATOR V-F5-25 (graph half) + query shapes QS-5b/6a corrected; tier sub-schema / union pruning DEFERRED to Fable SDL build | yes @c3: V-F5-25 0→2→0 |
| CH-P-02 | BLOCKING | FABLE-SDL (privacyClass on Entity/ActorIdentity/SearchIndexable) + corrected QS-5b/6a/8 | QS: yes (see QS table) |
| CH-P-03 | BLOCKING | VALIDATOR V-F5-24 + PARAMS publicSearchFields | yes @c3: V-F5-24 0→2→0 |
| CH-P-04 | MAJOR | FABLE-SDL/OPS (vector indexes) + VALIDATOR V-F5-24 (embedding provenance) | yes @c3: V-F5-24 0→2→0 (chp-02 internal curator row) |
| CH-P-05 | BLOCKING | VALIDATOR V-F5-18 + V-F5-23 | yes @c3: V-F5-18 0→4→0; V-F5-23 0→4→0 |
| CH-P-06 | BLOCKING | VALIDATOR V-F5-23 | yes @c3: V-F5-23 0→4→0 |
| CH-P-07 | BLOCKING | VALIDATOR V-F5-18 (d, e), V-F5-19 (a, b, c), V-F5-20 (d key list) + PARAMS privateUidTokens | yes @c3: V-F5-19 0→3→0; V-F5-18 0→4→0 |
| CH-P-08 | MAJOR | VALIDATOR V-F5-28 (per-observation attribution); copy detection DEFERRED: needs the PCS contribution audit (cross-store) | yes @c3: V-F5-28 0→4→0 |
| CH-P-09 | MAJOR | VALIDATOR V-F5-22 | yes @c3: V-F5-22 0→1→0 |
| CH-P-10 | MAJOR | VALIDATOR V-F5-21 | yes @c3: V-F5-21 0→2→0 |
| CH-P-11 | MAJOR | VALIDATOR V-F5-27 + V-F5-18 (e-mail) | yes @c3: V-F5-27 0→1→0 |
| CH-P-12 | BLOCKING | FABLE-OPS (section 7) + VALIDATOR V-F5-26 (recognizer) + corrected QS | yes @c3: V-F5-26 2→3→2 |
| CH-P-13 | MAJOR | VALIDATOR V-F5-23 | yes @c3: V-F5-23 0→4→0 |
| CH-P-14 | MAJOR | VALIDATOR V-F5-23 (detection); prevention (no generated create mutation for AnswerRecord/PolicyVersion/DecisionCriterion) DEFERRED to Fable SDL | partly: same shape as CH-P-13/05 replayed in Cypher (GraphQL not run) |
| CH-P-15 | BLOCKING | QUERY SHAPES query-shapes-privacy-corrected.cypher (QS-5b, QS-6a, QS-8) | yes: see QS table |
| CH-P-16 | MAJOR | FABLE-FIXTURE | no (Fable) |
| CH-P-17 | MINOR | FABLE-SDL (DiagnosticResult label) / V-313r | no (Fable) |
| CH-P-18 | MINOR | FABLE-OPS (section 5b) | no (Fable) |
| CH-R-01 | MAJOR | VALIDATOR V-F5-29 + PARAMS implicationPairs (ADHERENT_TO, NON_ADHERENT_TO, DEVIATED_FROM) | yes @c5: V-F5-29 1→4→1 |
| CH-R-02 | MAJOR | VALIDATOR V-F5-30; Enterprise existence constraint on DEPENDS_ON.dependencyKind recommended to Fable | yes @c5: V-F5-30 1→7→1; control 02a 1→3→1 |
| CH-R-03 | MINOR | VALIDATOR V-F5-31 (review); shared tokenizer with the ingestion normalizer DEFERRED | yes @c5: V-F5-31 2→5→2 |
| CH-R-04 | MAJOR | FABLE-SDL (cadence anchor + 183-day text) | no (Fable) |
| CH-R-05 | BLOCKING | VALIDATOR V-F5-32 (V-530q) + FABLE-SDL (DERIVED_FROM_PROTOCOL) | yes @c5: V-F5-32 0→1→0 |
| CH-R-06 | BLOCKING | VALIDATOR V-F5-21 + V-F5-22 + PARAMS privateSourceUriPatterns; "no shared-graph credential for the private writer" DEFERRED: deployment rule | yes @c5: V-F5-22 0→2→0; V-F5-21 0→1→0 |
| CH-R-07 | BLOCKING | VALIDATOR V-F5-18 (DOB pattern) + V-F5-20 (keys) + PARAMS | yes @c5: V-F5-20 0→2→0; V-F5-18 0→2→0 |
| CH-R-08 | BLOCKING | VALIDATOR V-F5-33 (V-536q) + PARAMS implicationPairs | yes @c5: V-F5-33 0→1→0; 08a-c 0→2→0 |
| CH-R-09 | MAJOR | VALIDATOR V-F5-34 | yes @c5: V-F5-34 1→4→1 |
| CH-R-10 | MAJOR | VALIDATOR V-F5-35 | yes @c5: V-F5-35 0→2→0 |
| CH-R-11 | MAJOR | VALIDATOR V-F5-36; SDL orderIndex: Int! recommended | yes @c5: V-F5-36 10→12→10 (baseline 10 = fixture defect D11) |
| CH-R-12 | MAJOR | FABLE-SDL (DiagnosticResult label, a-c) + VALIDATOR V-F5-37 (d) | yes @c5: V-F5-37 0→1→0 |
| CH-R-13 | BLOCKING | FABLE-OPS/FABLE-FIXTURE (HAS_STEP) + VALIDATOR V-F5-38 (domain, V-544p) | yes @c5: V-F5-38 0→3→0 (baseline c3 6 = fixture defect D6) |
| CH-R-14 | MAJOR | VALIDATOR V-F5-39 (V-542q) | yes @c5: V-F5-39 0→1→0 |
| CH-R-15 | MAJOR | VALIDATOR V-F5-40 (V-545p) | yes @c5: V-F5-40 0→2→0 |
| CH-R-16 | MAJOR | PARAMS assertedTypes (already present in the FINAL validation-params.json) | yes: final suite unchanged with merged params (184/184, 0 row diffs) |
| CH-M-01 | BLOCKING | VALIDATOR V-F5-41 (+ V-F5-42); MEDIA-EV-1 job filter must use the same allow-list (W22 derivation code) | yes @c4: V-F5-41 1→2→1 |
| CH-M-02 | MAJOR | VALIDATOR V-F5-41 + PARAMS privateSourceUriPatterns | yes @c4: V-F5-41 1→2→1 |
| CH-M-03 | MINOR | VALIDATOR V-F5-42 (V-617 + bytes rule) | yes @c4: V-F5-42 1→3→1 |
| CH-M-04 | MINOR | VALIDATOR V-F5-43 (V-604r) | yes @c4: V-F5-43 1→2→1 |
| CH-M-05 | held | none (V-615 holds) | n/a |
| CH-M-06 | MAJOR | VALIDATOR V-F5-44 | yes @c4: V-F5-44 0→1→0 |
| CH-M-07 | MAJOR | VALIDATOR V-F5-45 (review) + corrected Q04-1 | yes @c4: V-F5-45 0→1→0; Q04-1 lines 1→1 |
| CH-M-08 | MAJOR | VALIDATOR V-F5-46 + corrected Q04-1 | yes @c4: V-F5-46 0→1→0; Q04-1 lines 1→1 |
| CH-M-09 | MAJOR | VALIDATOR V-F5-47 | yes @c4: V-F5-47 0→1→0 |
| CH-M-10 | MAJOR | VALIDATOR V-F5-47 | yes @c4: V-F5-47 0→1→0 |
| CH-M-11 | MAJOR | VALIDATOR V-F5-48 | yes @c4: V-F5-48 1→2→1 (baseline 1 = fixture defect D8) |
| CH-M-12 | MAJOR | VALIDATOR V-F5-49 (interim number-token form); ReanchorProperties.textChange SDL field DEFERRED to Fable/W21 | yes @c4: V-F5-49 0→1→0 |
| CH-M-13 | MAJOR | VALIDATOR V-F5-50 + PARAMS abstractOnlyUriPatterns | yes @c4: V-F5-50 0→1→0 |
| CH-M-14 | MAJOR | VALIDATOR V-F5-51; Q-MP4-1 three-valued gate fix belongs to the W22 query (not a validator) | yes @c4: V-F5-51 0→1→0 |
| CH-M-15 | MAJOR | VALIDATOR V-F5-52 (PolicyVersion.useClass absent: null read as COMMERCIAL) | yes @c4: V-F5-52 0→1→0 |
| CH-M-16 | MINOR | VALIDATOR V-F5-53 (W19 Q-03 promoted) | yes @c4: V-F5-53 0→1→0 |
| CH-M-17 | MINOR | VALIDATOR V-F5-47 replaces V-423/V-423r/V-W21-06 (V-423 RETIRED); legacy assertionUid kept as migration fallback reported by V-W00-02r | yes: V-F5-47 0 rows on the valid fx07 projection and the NightCue legacy edge (c3, c4) |
| CH-K-01a | MINOR | VALIDATOR V-F5-54 | yes @c3: V-F5-54 0→1→0 |
| CH-K-01b | held | none (V-504) | n/a (held/Fable) |
| CH-K-02a | held | none (V-504a; recordedAt backfill in 99-normalize) | n/a (held/Fable) |
| CH-K-02b | MAJOR | VALIDATOR V-F5-55 | yes @c3: V-F5-55 0→15→0 |
| CH-K-03a | MAJOR | VALIDATOR V-F5-56 | yes @c3: V-F5-56 0→1→0 |
| CH-K-03b | held | none (V-507b) | n/a (held/Fable) |
| CH-K-04 | MAJOR | VALIDATOR V-F5-57 (V-W00-06); kernelHash recomputation DEFERRED: no stored commit hash yet | yes @c3: V-F5-57 0→1→0 |
| CH-K-05a | held | none (V-502) | n/a (held/Fable) |
| CH-K-05b | BLOCKING | VALIDATOR V-F5-58 | yes @c3: V-F5-58 0→1→0 |
| CH-K-05c | BLOCKING | VALIDATOR V-F5-58 | yes @c3: V-F5-58 0→1→0 |
| CH-K-05d | BLOCKING | VALIDATOR V-F5-58 | yes @c3: V-F5-58 0→1→0 |
| CH-K-05e | BLOCKING | VALIDATOR V-F5-58 | yes @c3: V-F5-58 0→2→0 |
| CH-K-06 | BLOCKING | VALIDATOR V-F5-59 | yes @c3: V-F5-59 0→1→0 |
| CH-K-07a | held | none (V-402) | n/a (held/Fable) |
| CH-K-07b | MAJOR | VALIDATOR V-F5-60 | yes @c3: V-F5-60 1→2→1 |
| CH-K-07c | MAJOR | VALIDATOR V-F5-60 | yes @c3: V-F5-60 1→2→1 |
| CH-K-08a | BLOCKING | PARAMS (FABLE: gen-params.mjs regenerates assertedTypes/derivedTypes/episodeTypes from the SDL) | no (Fable) |
| CH-K-08b | held | none (V-004/V-112/V-112r) | n/a (held/Fable) |
| CH-K-09 | BLOCKING | PARAMS (FABLE gen-params.mjs) | no (Fable) |
| CH-K-10a | held | none (V-000b) | n/a (held/Fable) |
| CH-K-10b | BLOCKING | FABLE (generated-label-checks.cypher, V-F5-ARCH-1/2) | no (Fable) |
| CH-K-11a | held | none (V-117) | n/a (held/Fable) |
| CH-K-11b | MAJOR | VALIDATOR V-F5-61 (V-117r) | yes @c3: V-F5-61 6→7→6 |
| CH-K-11c | MAJOR | VALIDATOR V-F5-61 | yes @c3: V-F5-61 6→7→6 |
| CH-K-12a | held | none (V-W00-16) | n/a (held/Fable) |
| CH-K-12b | MINOR | VALIDATOR V-F5-62 (V-W00-16r) | yes @c3: V-F5-62 4→5→4 |
| CH-K-12c | MAJOR | VALIDATOR V-F5-62 + PARAMS uidAliasTokenLabels | yes @c3: V-F5-62 4→5→4 |
| CH-K-13 | MAJOR | FABLE (generated-label-checks.cypher) | no (Fable) |
| CH-K-14a | held | none (V-103) | n/a (held/Fable) |
| CH-K-14b | MAJOR | VALIDATOR V-F5-63 | yes @c3: V-F5-63 0→2→0 |
| CH-K-14c | MINOR | VALIDATOR V-F5-63 | yes @c3: V-F5-63 0→2→0 |
| CH-K-15 | BLOCKING | VALIDATOR V-F5-64 + PARAMS registeredPredicates (CANDIDATE-only-when-PROPOSED nuance DEFERRED: registry statuses are free text) | yes @c3: V-F5-64 0→1→0 |
| CH-K-16a | MAJOR | FABLE-OPS (section 5b) | no (Fable) |
| CH-K-16b | MAJOR | FABLE-OPS (section 5b) | no (Fable) |
| CH-K-17a | held | none (constraint) | n/a (held/Fable) |
| CH-K-17b | held | none (accepted) | n/a (held/Fable) |
| CH-K-17c | MINOR | VALIDATOR V-F5-65 (+ FABLE-OPS: constraint for every asserted/episode type) | yes @c3: V-F5-65 0→2→0 |
| CH-K-18a | MAJOR | FABLE-OPS (6a guard) | no (Fable) |
| CH-K-18b | MAJOR | FABLE-OPS (6a rewrite) + detection V-F5-38 | yes @c3: V-F5-38 6→7→6 |
| CH-K-18c | BLOCKING | FABLE-OPS (section 7, no 1970 sentinel; V-F5-58 detects epoch values) | no (Fable) |
| CH-K-18d | MAJOR | FABLE-OPS/FABLE-FIXTURE (HAS_STEP) + detection V-F5-38 | no (Fable) |
| CH-K-19 | BLOCKING | FABLE-FIXTURE (99-normalize G1-G5) | no (Fable) |
### DEFERRED items and why

- **CH-S-06b:** a CONFIRMATORY biomarker input to a clinical-outcome claim cannot be detected without a Claim outcome-class field (seam W21 Claim). V-F5-17 flags the case only when no input is favorable.
- **CH-S-07:** whether a verdict matches its inputs is a method judgement, not a structural property. V-F5-17 ships it as a review queue: a SUPPORTED verdict needs a favorable CONFIRMATORY or INDEPENDENT_REPLICATION input, and a STRENGTHENED trigger must itself be such an input.
- **Rules a post-hoc validator cannot enforce:**
  - CH-S-03b, CH-S-04a/c and CH-S-14c: the GraphQL write path. These need write guards in the service or the SDL.
  - CH-S-15: making `recordedTo` read-only is an SDL change.
  - CH-P-14: removing the generated mutations is an SDL change.
  - CH-R-06: the private writer must hold no shared-graph credential. This is a deployment rule.
- **CH-P-01:** the tier sub-schema and union pruning are an SDL build artifact. The graph half is V-F5-25.
- **CH-P-08:** detecting that a public Observation copies a private measurement needs the PCS contribution audit, which is cross-store. V-F5-28 enforces per-observation attribution.
- **CH-S-16 and CH-R-07a:** a bare personal name in free text is not structurally detectable. Private tokens, e-mail addresses and birth-date patterns are detected. The rest needs coded descriptors.
- **CH-R-03:** the shared range tokenizer belongs to the ingestion normalizer. V-F5-31 is the review form.
- **CH-M-12:** the `textChange` field. **CH-M-14:** the W22 Q-MP4-1 gate. **CH-M-01:** the MEDIA-EV-1 job filter. All three are code or SDL outside the validator file.
- **CH-K-04:** a kernel hash would need a stored commit hash. **CH-K-15:** the CANDIDATE-only-when-PROPOSED nuance is not checked, because registry status strings are free text.

### Validators this file supersedes in `final-validation-suite.cypher`

Remove these when appending, or keep them as informational:

| superseded | replaced by |
|---|---|
| V-201 | V-F5-01 |
| V-218 | V-F5-08 |
| V-215r | V-F5-07 |
| V-104 and the V-502 sentinel branch | V-F5-58 |
| V-117 | V-F5-61 |
| V-W00-16 | V-F5-62 |
| **V-423 / V-423r: RETIRED** (fires on the valid fx07 projection; CL-016) | V-F5-47 |
| V-W21-06 | V-F5-47 |
| V-604 | V-F5-43 |
| V-605 | V-F5-41 + V-F5-42 |
| V-528p | V-F5-30 |
| V-536p | V-F5-33 |
| V-542p | V-F5-39 |
| W10-V08 | V-F5-06 |
| W10-V14 | V-F5-18 + V-F5-20 |
| V-121 | V-F5-23 |
| V-113, V-115, V-116 | V-F5-26 |

## Results table

Columns:
- **EXPLAIN** on c3, c4, c5.
- **Baseline rows** in four columns:
  - c3 as loaded
  - c3 after the final 99-normalize, in a rolled-back transaction
  - c4 as loaded
  - c5 as loaded

  After normalization, c4 and c5 return 0 for V-F5-61 and V-F5-62. The other columns are unchanged.
- **Replays**: `case@instance: validator before → after → after undo`.

| validator | EXPLAIN c3/c4/c5 | baseline c3 / c3-normalized / c4 / c5 | replays |
|---|---|---|---|
| V-F5-01 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-01@c3: 0→2→0; CH-S-02@c3: 0→5→0; CH-S-10@c3: 0→1→0 |
| V-F5-02 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-02@c3: 0→1→0 |
| V-F5-03 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-03@c3: 0→1→0 |
| V-F5-04 | ok / ok / ok | 1 / 1 / 1 / 0 | CH-S-04@c3: 1→3→1 |
| V-F5-05 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-05@c3: 0→1→0 |
| V-F5-06 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-06@c3: 0→1→0 |
| V-F5-07 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-08@c3: 0→2→0 |
| V-F5-08 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-09@c3: 0→3→0 |
| V-F5-09 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-10@c3: 0→3→0 |
| V-F5-10 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-11@c3: 0→3→0 |
| V-F5-11 | ok / ok / ok | 1 / 1 / 0 / 0 | CH-S-12a@c3: 1→2→1 |
| V-F5-12 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-12b@c3: 0→1→0 |
| V-F5-13 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-13@c3: 0→1→0 |
| V-F5-14 | ok / ok / ok | 1 / 1 / 1 / 0 | CH-S-07@c3: 1→1→1; CH-S-14@c3: 1→3→1 |
| V-F5-15 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-15 (GQL-10 replayed in Cypher)@c3: 0→1→0 |
| V-F5-16 | ok / ok / ok | 5 / 5 / 2 / 0 | — |
| V-F5-17 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-06@c3: 0→1→0; CH-S-07@c3: 0→1→0 |
| V-F5-18 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-16@c3: 0→1→0; CH-P-01..13,07c (attack block A)@c3: 0→4→0; CH-R-07@c5: 0→2→0 |
| V-F5-19 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→3→0 |
| V-F5-20 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→1→0; CH-R-07@c5: 0→2→0 |
| V-F5-21 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→2→0; CH-R-06@c5: 0→1→0 |
| V-F5-22 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→1→0; CH-R-06@c5: 0→2→0 |
| V-F5-23 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→4→0 |
| V-F5-24 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→2→0 |
| V-F5-25 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→2→0 |
| V-F5-26 | ok / ok / ok | 2 / 2 / 2 / 0 | CH-P-01..13,07c (attack block A)@c3: 2→3→2; CH-P-12 (block A + ops section 7 replay)@c3: 2→3→2 |
| V-F5-27 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→1→0 |
| V-F5-28 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-P-01..13,07c (attack block A)@c3: 0→4→0 |
| V-F5-29 | ok / ok / ok | 0 / 0 / 0 / 1 | CH-R-01@c5: 1→4→1 |
| V-F5-30 | ok / ok / ok | 0 / 0 / 0 / 1 | CH-R-02a@c5: 1→3→1; CH-R-02bc@c5: 1→7→1 |
| V-F5-31 | ok / ok / ok | 0 / 0 / 0 / 2 | CH-R-03@c5: 2→5→2 |
| V-F5-32 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-05@c5: 0→1→0 |
| V-F5-33 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-08abc@c5: 0→2→0; CH-R-08d@c5: 0→1→0 |
| V-F5-34 | ok / ok / ok | 0 / 0 / 0 / 1 | CH-R-09@c5: 1→4→1 |
| V-F5-35 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-10@c5: 0→2→0 |
| V-F5-36 | ok / ok / ok | 0 / 0 / 0 / 10 | CH-R-11@c5: 10→12→10; CH-R-13c@c5: 10→10→10 |
| V-F5-37 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-12d@c5: 0→1→0 |
| V-F5-38 | ok / ok / ok | 6 / 6 / 6 / 0 | CH-R-13ab@c5: 0→3→0; CH-K-18b@c3: 6→7→6 |
| V-F5-39 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-14@c5: 0→1→0 |
| V-F5-40 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-R-15@c5: 0→2→0 |
| V-F5-41 | ok / ok / ok | 0 / 0 / 1 / 0 | CH-M-01@c4: 1→2→1; CH-M-02@c4: 1→2→1 |
| V-F5-42 | ok / ok / ok | 0 / 0 / 1 / 0 | CH-M-01@c4: 1→2→1; CH-M-03@c4: 1→3→1 |
| V-F5-43 | ok / ok / ok | 0 / 0 / 1 / 0 | CH-M-04@c4: 1→2→1 |
| V-F5-44 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-06@c4: 0→1→0 |
| V-F5-45 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-07@c4: 0→1→0 |
| V-F5-46 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-08@c4: 0→1→0 |
| V-F5-47 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-09@c4: 0→1→0; CH-M-10@c4: 0→1→0 |
| V-F5-48 | ok / ok / ok | 0 / 0 / 1 / 0 | CH-M-11@c4: 1→2→1 |
| V-F5-49 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-12@c4: 0→1→0 |
| V-F5-50 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-13@c4: 0→1→0 |
| V-F5-51 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-14@c4: 0→1→0 |
| V-F5-52 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-15@c4: 0→1→0 |
| V-F5-53 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-M-16@c4: 0→1→0 |
| V-F5-54 | ok / ok / ok | 0 / 0 / 0 / 1 | CH-K-01a@c3: 0→1→0 |
| V-F5-55 | ok / ok / ok | 0 / 0 / 1 / 0 | CH-K-02b@c3: 0→15→0 |
| V-F5-56 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-K-03a@c3: 0→1→0 |
| V-F5-57 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-K-04@c3: 0→1→0 |
| V-F5-58 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-K-05b@c3: 0→1→0; CH-K-05c@c3: 0→1→0; CH-K-05d@c3: 0→1→0; CH-K-05e@c3: 0→2→0 |
| V-F5-59 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-K-06@c3: 0→1→0 |
| V-F5-60 | ok / ok / ok | 1 / 1 / 0 / 0 | CH-K-07b@c3: 1→2→1; CH-K-07c@c3: 1→2→1 |
| V-F5-61 | ok / ok / ok | 513 / 6 / 718 / 10 | CH-K-11b@c3: 6→7→6; CH-K-11c@c3: 6→7→6 |
| V-F5-62 | ok / ok / ok | 67 / 4 / 63 / 0 | CH-K-12b@c3: 4→5→4; CH-K-12c@c3: 4→5→4 |
| V-F5-63 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-S-15 (GQL-10 replayed in Cypher)@c3: 0→1→0; CH-K-14b@c3: 0→2→0; CH-K-14c@c3: 0→2→0 |
| V-F5-64 | ok / ok / ok | 0 / 0 / 4 / 1 | CH-K-15@c3: 0→1→0 |
| V-F5-65 | ok / ok / ok | 0 / 0 / 0 / 0 | CH-K-17c@c3: 0→2→0 |
### Query shapes (privacy-corrected), c3 with W23 base and the CH-P attack block plus the section 7 replay applied (rolled back)

| shape | probe | shipped shape: rows / non-PUBLIC nodes returned | corrected: rows / non-PUBLIC nodes |
|---|---|---|---|
| QS-5b | root = INTERNAL assertion chp-06 | 2 / 1 (the INTERNAL root) | 0 / 0 |
| QS-5b | root = laundered `PRIVATE-PERSONAL` product chp-12 | 0 paths (root admitted, CH-P-15c) | 0 / 0 (root refused) |
| QS-5b | root = PUBLIC assertion A2 | 3 / 0 | 4 / 0 |
| QS-6a | SleepWell variant, 2 hops | 34 / 9+ INTERNAL (AnswerRecords, Activities, ranking policy v3, chp-06) | 22 / 0 |
| QS-8 | PersonSearch "night shift" | 3 / 2 (INTERNAL, null class) | 1 / 0 |
| QS-8 | ProductSearch "pregnant" | 1 / 0 | 1 / 0 |
| Q04-1 (c4) | NMN claim, before vs after CH-M-07 + CH-M-08 | shipped: firstHand 2 → 3, asserters 2 → 3 (per the Challenger) | lines 1 → 1; live 2 → 4, second-hand 1 → 2 |

**Reading the QS results:**

- **QS-5b on A2 returns one more path than the shipped shape.** The shipped shape compares `r.recordedFrom <= $recordedAsOf`, where the parameter is a string in `validation-params.json`. That comparison evaluates to null, which silently drops every edge that has a recorded time. The corrected shape uses `datetime($recordedAsOf)`.
- **QS-8 still returns two records that are PUBLIC but should not be in the graph.** No query-level filter can refuse them, because the data claims PUBLIC; the data validators catch both.
  - "night shift" returns the PUBLIC, unsourced person chp-10. V-F5-21 catches it.
  - "pregnant" returns product chp-03, whose PUBLIC searchText was derived from private fields. V-F5-24 catches it.

## Fixture defects found (baseline rows on clean data)

**D1.** `fixtures-final/recommendation-snapshot.cypher`: applicability `synthetic-mg-glycinate-evidence-to-sleepwell-fv-a1` has `doseMatch = MATCH`, but its EXPOSURE dimension is UNKNOWN. The fixture's own comment says the flat fields are projections of the dimension nodes. (V-F5-04; c3, c4)

**D2.** Composition of W09 fixture 01 with the translated set: `ctgov-nct02678611` has two current, open-ended HAS_REGISTRATION_VERSION episodes (`observed-2026-10-03` and `observed-2026-10-04`); the older one was never re-bounded. This is the same family as CH-S-18. (V-F5-11; c3)

**D3.** `fixtures-final/study-vs-product-mismatch.cypher`: `nr-muscle-mito-function-older-humans-v2` SUPERSEDES v1, but v1 stays ACCEPTED with `recordedTo` null. (V-F5-14; c3, c4)

**D4.** Five EvidenceSyntheses have no ASSESSES_CLAIM (V-F5-16; c3 5 rows, c4 2 rows):
- W09 fixtures 02 and 03 (3).
- The inherited v1 and v2 from D3 (2).

**D5.** `fixtures-final/diagnostic-comparison.cypher`: six DiagnosticResults are stored with `privacyClass 'synthetic'`. That value is neither PUBLIC nor INTERNAL, so the node counts as private and two PUBLIC assertions point at it. (V-F5-26 2 rows; also V-313r/V-521r; c3, c4)

**D6.** `fixtures-final/recommendation-snapshot.cypher`: six `ProtocolEdition -[:HAS_STEP]->` edges. This is CH-R-13, which Fable is fixing. (V-F5-38; c3, c4)

**D7.** Composition: snapshot `hu:snapshot:pmc5701244-2026-10-04` hangs from two Sources. The translated study-vs-product-mismatch fixture attaches it to `hu:source:doi-10.1038-s41514-017-0016-9`; W09 fixtures 05 and 06 attach it to `hu:source:pmc5701244`. (V-F5-60; c3)

**D8.** `fixtures-final/claim-retelling-provenance.cypher`: occurrence `hl52-host-read-insidetracker-sponsors-episode` has `segmentKind SPONSOR_READ` and lies at 287 s inside the 210–465 s YouTube sponsor block. It has no OCCURS_IN_SEGMENT, so V-W21-02 also sees it. (V-F5-48; c4)

**D9.** W21 `fx02b`: the translated occurrence `hl52-sinclair-self-reported-nmn-1g-daily` (recordedAt 2026-10-03T12:00Z) is WAS_GENERATED_BY `w21-extraction-2026-10-04`, which started 2026-10-04T01:00Z. The record predates the activity that generated it. (V-F5-55; c4)

**D10.** Unregistered predicates (V-F5-64):
- c4: W21 placeholder predicates `FORECASTS_COMMERCIAL_OPPORTUNITY` (fx06, 2 rows) and `REPORTS_LIFESPAN_EFFECT` (fx06, 2 rows). W21-SR routed them to their owners.
- c5: W16 fixture 02 `STEP_OCCURRENCES_PER_WEEK`. W16-SR-02 routed it to W00, but it never reached `predicate-registry.yaml`.

**D11.** W16 fixture 02: the Blueprint editions give one orderIndex to several steps (four steps at index 1 in edition 2026-10-04) without CONCURRENT_WITH. `hbot-course` appears at indexes 1 and 2. (V-F5-36, 10 rows; c5)

**D12.** W16 fixture 03: the NICE CG185 HAS_PROTOCOL_EDITION edge and its assertion are recorded at 2026-10-04T01:00Z, but the supporting snapshot was retrieved at 01:02Z. (V-F5-54; c5)

**D13.** c3 composition: `99-normalize-live-ids.cypher` aborts on the `StudyArm` id uniqueness constraint because of the CH-S-18 duplicate identities. With the guard, six translated arm and intervention nodes are left without a live id. (V-F5-61, 6 rows on c3-normalized)

**D14.** W10 fixtures: two ResultInterpretation and two EvidenceStrengthAssessment nodes are minted with the parent token `assessment`. The registered tokens are `result-interpretation` and `strength-assessment`; this is not a T2 refinement. (V-F5-62, 4 rows on c3-normalized)

**D15.** The instances were loaded with an earlier backfill (raw baselines: 513, 718 and 10 nodes without a live id; 67 and 63 token rows). The 03:31 `99-normalize` removes all of these except D13 and D14. The Wave 6 load order must run the current backfill.

**Embedded negatives (expected rows, not defects):**
- **E1.** c4, W22 mp3: hand-written EVIDENCES from the GENERATED mtDNA illustration (V-F5-41, V-F5-42, V-F5-43; also V-604/V-605).
- **E2.** c5, W16 06: an adherence property and an OMITTED_STEP edge on the negative step (V-F5-29, V-F5-34; also V-534p).
- **E3.** c5, W16 03: `nice-cg185-neg-loop` (V-F5-30; also V-528p).
- **E4.** c5, W16 10: two collapsed ranges (V-F5-31; also V-529b).
