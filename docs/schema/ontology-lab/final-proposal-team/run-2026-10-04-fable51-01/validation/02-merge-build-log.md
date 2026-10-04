# Merge build log (Fable, Wave 5 preparation)

| Time (UTC) | Fragments merged | Definitions | Dups | Undefined refs | Result under `@neo4j/graphql` 7.6.3 |
|---|---|---|---|---|---|
| 01:50 | 17 complete + drafts on disk | 471 | 0 | 4 (retired `Association`, `ExperienceReport`, `FoodProduct`, `MediaSource` still named in unions) | FAILED: 41 errors, 7 classes (4 retired-type references, 1 interface relationship not implemented) |
| 01:53 | same, after `prune-unions.mjs` (21 member changes in 5 unions: 4 undefined members, 17 specialization overlaps) | 471 | 0 | 0 | FAILED: 1 error (`Observation` implements `DiagnosticResult` with plural field names) |
| 01:56 | same, plus `Observation` field alignment (`producedByAssayVersion`, `computedByAlgorithmVersion`, `interpretedWithReferenceIntervalVersion`; `resultKind: DiagnosticResultKind!`; `valueStatus: ResultQualifier`) | 471 | 0 | 0 | **BUILD OK** in 36.7 s: 41,894 generated types, 475 queries, 530 mutations, 52.46 MB printed SDL |

Merge rulings these steps encode (carried into the final assembly and the decision report):

- MR-01 A union never lists a type together with a type whose stored labels include that type's primary label (W05-SR-09, W00-SR-11, W23 finding). The parent member stays; the specialization resolves through it.
- MR-02 Union members naming retired types (`Association`, `ExperienceReport`, `FoodProduct`, `MediaSource`) are dropped; the migration table records their successors (W03, W21, W05, W22 packets).
- MR-03 An implementer of a GraphQL interface with `@declareRelationship` fields uses the interface's exact field names and types (`Observation` aligned to W07's `DiagnosticResult`).
