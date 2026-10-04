# Validation rehearsal on the 0.2.0 baseline (before any final-schema change)

Purpose: prove the harness reproduces the recorded 2026-10-03 execution before it is used on the final proposal. Target: embedded Neo4j 5.26.31 Community (fresh instance), `@neo4j/graphql` 7.6.3 not involved in this step.

| Step | Command (harness) | Result |
|---|---|---|
| Constraints | `run-cypher.mjs <bolt> docs/schema/neo4j/constraints.cypher` | 57 statements: 45 applied, 12 rejected as Enterprise-only (property existence/type). Identical to the recorded result. `baseline-constraints.json`. |
| Six fixtures, loaded together in file order | `run-cypher.mjs` per fixture | elysium-basis 24/24, study-vs-product-mismatch 44/44, diagnostic-comparison 107/107, filing-vs-capability 81/81, claim-retelling-provenance 79/79, recommendation-snapshot 110/110 statements OK; 536 nodes, 962 relationships. |
| Validation suite | `run-cypher.mjs ... validation.cypher --params validation-params.json` | 174 statements, 174 OK after the parameter file was completed (`$implicationPairs` as `[premise, conclusion]` lists, `$exclusivePredicates`, `$catalogV020CutoverAt`, `$revisionEventUid`). Rows: **V-110: 3**, V-111b 7, V-212 2, V-223 1, V-331 1, V-401b 1, V-514b 1, V-522 100 (capped). |

The seven informational counts match `proposal-index.md` section 9 exactly. The one difference is **V-110 (3 rows)**, all three from `examples/elysium-basis.cypher`:

- The fixture sets `recordedAt = datetime()` (the load instant) on its assertions (lines 53, 62, 83 …) while its CAPTURE_FIDELITY policy adjudication carries a fixed `reviewedAt = datetime('2026-10-04T00:00:00Z')` (line 146). V-110 requires `reviewedAt >= recordedAt`. On 2026-10-03 the load instant preceded the fixed review instant and the query returned zero rows; from 2026-10-04T00:00Z onward every load fails it.
- Classification: **fixture reproducibility defect**, not a model or rule defect. The rule (INV-103) is correct; the fixture violates the kernel's own principle that recorded time is never a load-time artefact in a reproducible fixture.
- Disposition for this run: the translated fixture used for the final-schema execution pins `recordedAt` to fixed instants no later than the adjudication's `reviewedAt`; the original 0.2.0 file is left as-is unless the Wave 6 report decides to patch it (a one-line change per assertion), recorded in CHANGELOG under "Fixed".

Parameters generated from the catalog (`validation-params.json`): 68 asserted relationship types, 14 derived, 1 ruleOnly (`INSTANCE_OF`), 5 exclusive attachment types, 72 forbidden-implication pairs. `$sharedIndexedLabels` lists the `knowledge_names` fulltext labels; the live `@fulltext` label set is added when the final operations file creates those indexes.
