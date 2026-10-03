# Starter Property Model

Status: candidate for the first recommendation vertical slice

This is a selection rule and initial property set, not permission to add every field to every label.

## Placement rule

Use a node property when the value is atomic, functionally dependent on that node, frequently filtered or sorted, and has no independent provenance or dispute lifecycle.

Use a relationship property when the value qualifies only one endpoint pair, is simple, and shares the relationship's lifecycle.

Use a first-class node—usually `Assertion`, `VersionedState`, `Occurrence`, or `EvidenceAssessment`—when the fact is n-ary, independently sourced, disputed, repeated, scored by multiple methods, or needs its own temporal or review lifecycle.

Do not keep a JSON blob merely because the concept is difficult. Blobs are acceptable for preserved raw payloads and vendor-specific extensions, not for facts needed by retrieval or validation.

## Shared identity properties

| Property | Required | Meaning |
|---|---:|---|
| `uid` | yes | BellLabs stable, opaque identity. |
| `entityType` | yes | Stable semantic kind within the catalog. |
| `canonicalName` | when named | Preferred display/search label, not the identity key. |
| `createdAt` | yes | System time at which the identity record was first committed. |
| `schemaVersion` | yes | Semantic catalog version used at creation. |
| `maturity` | for ontology-managed terms | Candidate, provisional, accepted, or deprecated. |

External identifiers should normally be `Identifier` records with `scheme`, `value`, `issuer`, `jurisdiction`, `validFrom`, and `validTo`. A directly indexed identifier such as `nctId`, `doi`, `pmid`, `unii`, or `chebiId` may be materialized on the identity node only when uniqueness and normalization rules are explicit.

Names, aliases, descriptions, websites, statuses, formulations, availability, and prices are not generally durable identity fields.

## Shared immutable state properties

| Property | Required | Meaning |
|---|---:|---|
| `uid` | yes | Stable state-record identifier. |
| `stateType` | yes | State payload kind. |
| `payloadHash` | yes | Hash of canonicalized semantic state fields. |
| `schemaVersion` | yes | Catalog version defining the payload. |
| `createdAt` | yes | System creation time of the immutable record. |
| `sourceSnapshotUid` | optional projection | Source snapshot that supplied the payload when exactly one applies. |

Domain validity is not inferred from `createdAt`. The same immutable state payload may be linked through more than one recorded-time episode if the system retracts and later reinstates it.

## `HAS_STATE` relationship properties

| Property | Required | Meaning |
|---|---:|---|
| `validFrom` | nullable | Inclusive beginning of domain validity. |
| `validTo` | nullable | Exclusive end of domain validity. |
| `recordedFrom` | yes | Inclusive beginning of system belief. |
| `recordedTo` | nullable | Exclusive end of system belief; `null` means currently recorded. |
| `validTimePrecision` | when imprecise | Instant, day, month, year, interval, or unknown. |
| `validTimeBasis` | yes | Explicit source, observation, publication proxy, inference, or unknown. |
| `assertionUid` | when source-derived | Assertion authorizing the attachment. |

Open intervals use `null`; a sentinel maximum date is forbidden. Unknown `validFrom` is different from “valid from ingestion.”

## Asserted temporal relationship properties

For a direct temporal projection such as `Organization-[:MARKETS_PRODUCT]->Product`:

- `relationshipUid` for stable audit reference;
- `validFrom`, `validTo`, `recordedFrom`, `recordedTo`;
- `assertionUid` or `projectionOfAssertionUid`;
- predicate-specific qualifiers such as `roleType`, `jurisdiction`, `dose`, or `unitCode` only when they have the same lifecycle as the pair.

Do not place generic evidence strength or truth confidence on these edges. Those belong to assessments with named methods. If several sources disagree, preserve separate Assertions rather than averaging edge properties.

## Assertion properties

| Property | Required | Meaning |
|---|---:|---|
| `uid` | yes | Stable proposition record. |
| `predicate` | yes | Controlled predicate identifier. |
| `polarity` | yes | Positive, negative, mixed, or unknown. |
| `status` | yes | Extracted, proposed, accepted, rejected, disputed, superseded, or unresolved. |
| `recordedAt` | yes | System time of assertion capture. |
| `validFrom`, `validTo` | nullable | Domain time claimed by the assertion. |
| typed literal fields | conditionally | Exactly one object or one typed literal value. |
| `extractionMethod`, `agentRunUid` | for machine extraction | Reproducible extraction lineage. |

Assertions link to exactly one subject, zero or one object, one or more source locators when source-derived, and zero or more adjudications. Confidence dimensions live on their respective assessments.

## First-slice domain properties

| Node | Identity properties | State or record properties |
|---|---|---|
| `ChemicalSubstance` | `uid`, authoritative IDs/materialized keys | preferred name, formula, structure descriptors only as authority-versioned state or sourced assertions |
| `IngredientMaterial` | `uid`, material kind, specification owner identity where identity-defining | display description, grade, supplier-facing name |
| `Product` | `uid`, product kind, owning brand link | display name and lifecycle status only if explicitly treated as materialized current projections |
| `ProductVariant` | `uid`, identity-defining dosage form/strength/flavor/jurisdiction dimensions | current presentation text |
| `FormulationVersion` | `uid`, version identifier if supplied | effective bounds via attachment; composition through `IngredientComponent` |
| `IngredientComponent` | `uid` | role, label order, declared quantity, unit, basis, verbatim declaration |
| `Study` | `uid`, registry identifiers | title/status projections; registration history in `RegistrationVersion` |
| `StudyResult` | `uid` | estimate, unit, interval, p-value, analysis population, timepoint |
| `EvidenceApplicability` | `uid`, method version | identity, dose, route, schedule, duration, population, comparator, outcome, and quality dimensions |

## Recommendation records

A recommendation is not `Product-[:RECOMMENDED_FOR]->Goal`. It is a replayable decision occurrence:

```text
(RecommendationDecision)-[:FOR_CONTEXT]->(DecisionContext)
(RecommendationDecision)-[:USED_POLICY]->(PolicyVersion)
(RecommendationDecision)-[:SELECTED]->(RecommendationCandidate)-[:ABOUT]->(ProductVariant)
(RecommendationCandidate)-[:BASED_ON]->(EvidenceApplicability)
(RecommendationDecision)-[:HAS_EXPLANATION]->(DecisionExplanation)
```

`RecommendationDecision` carries `uid`, `decidedAt`, `recordedAt`, `status`, and the valid/recorded temporal viewpoint used for retrieval. Candidate assessments carry criterion values and method versions. Hard safety constraints block eligibility; they are not blended into a convenience score. User-specific context must remain outside the shared research graph when it could contain PHI, with only governed references crossing the boundary.

## Current canonical-schema refactoring targets

The current Neo4j GraphQL schema should be migrated incrementally:

1. Move mutable `Product` fields toward immutable product state or clearly marked current materialized projections.
2. Put bitemporal attachment semantics on `HAS_STATE`; do not rely only on timestamps stored inside `ProductSnapshot`.
3. Split generic `confidence` into the confidence vector defined by the lab.
4. Give scientific propositions explicit subject, predicate, object/literal, source locator, and adjudication surfaces.
5. Treat `RelationshipAssertion` as a general semantic construct or retire its media-specific overlap with `Claim`.
6. Version trial registration/status fields rather than silently updating the durable `Study` identity.
7. Introduce decision-occurrence modeling before exposing recommendation APIs or MCP tools.
