# 10 Kernel operations delta (W00 reconciliation pass)

What changes in the W00 operations recommendation (`07-operations.md`, `operations.cypher`, `operations-enterprise.cypher`)
because of the rulings in `09-kernel-reconciliation.md`. Executable statements: `operations-delta.cypher` (Neo4j 5.26
Community syntax, idempotent). Everything not listed here is unchanged.

## 1. Uniqueness constraints and indexes (operations-delta.cypher)

| Part | Statements | Why (ruling) |
|---|---|---|
| A | `<label>_uid` and `<label>_live_id` uniqueness for the 125 labels registered in this pass that are neither W00-owned nor refinement specializations (rule T2: a specialization is covered by its parent label's constraints). Live id property: `id`, or `documentId` / `documentTextVersionId` / `segmentationId` / `chunkId` per catalog liveIdProjection. | W00-R-01 (uid-token-registry.yaml). Global uniqueness across labels stays with the six archetype constraints of operations.cypher (V-000a). Owners may move these lines into their own files; the statement shape is fixed. |
| B | `relationshipUid` uniqueness plus `assertionUid` and `recordedFrom` indexes on HAS_PATHWAY_VERSION, HAS_CERTIFICATION_SCOPE, HAS_CAPABILITY_STATE, STATUS_OF, IP_STATUS_OF, STRAIN_OF, GOVERNED_BY_SPECIFICATION | W00-R-07, W00-R-37: these are episode or exclusive asserted types now in `$episodeTypes` / `$exclusiveTypes`; the write guard looks up the open episode by assertionUid. |
| B | `has_state_valid_from`, `has_state_valid_to` | W00-R-16: HAS_STATE now also carries Organization/Product/Listing state caches, read as of a valid time. The existing `has_state_relationship_uid`, `has_state_recorded_from`, `has_state_assertion_uid` stay. |
| B | none for LEGACY_EVALUATES | W00-R-17: legacy, read-only, no relationshipUid; nothing queries it by property. |
| B | none for MENTIONS_ENTITY, CHUNK_IN_SEGMENT | W00-R-19, W00-R-23: derived and regenerable (W20 owns retrieval indexes). |
| C | `equivalence_retired_uid`, `equivalence_kind_recorded` | W00-R-11: resolving a held uid looks up the redirect by retiredUid and orders by recordedAt. |
| C | `assertion_stated_as_of`, `assertion_predicate_class` | W00-R-13 point-in-time reads; W00-R-02 V-003r partitions by predicateClass. |
| C | `source_source_kind` | W00-R-08: V-W00-17 and V-324r filter Sources by kind. |
| - | `source_locator_quote_hash` (W20-SR-07) | already in operations.cypher; unchanged. |

Enterprise file (`operations-enterprise.cypher`): no new existence constraint is required by the rulings. If Fable adopts
existence constraints for new required fields, the candidates are `EquivalenceAssessment.survivingUid/retiredUid` (only for
SAME_IDENTITY_MERGED, so not expressible as an existence constraint; stays V-432r) and `Source.sourceKindNote` (conditional; V-W00-17).

## 2. Migrations (operations-delta.cypher part D; run once, batched, idempotent)

| Step | Legacy shape | Target | Ruling | Audit after the run |
|---|---|---|---|---|
| D1 | `(x)-[:HAS_SNAPSHOT]->(y)` where not Source -> SourceSnapshot | HAS_STATE with relationshipUid, recordedFrom, bases UNKNOWN | W00-R-16 | V-W00-15 zero rows; V-101r lists episodes awaiting authorizing assertions (back-fill queue) |
| D2 | `EVALUATES` not Adjudication -> Assertion | LEGACY_EVALUATES (properties copied) | W00-R-17 | V-W00-15 |
| D3 | `MENTIONS` not SourceLocator -> Mention | MENTIONS_ENTITY (derivationRule kept or `legacy-mentions-v0`) | W00-R-19 | V-W00-15; V-112r (ruleOnly) |
| D3b | `(:Chunk)-[:OCCURS_IN_SEGMENT]->()` | CHUNK_IN_SEGMENT (W21 keeps OCCURS_IN_SEGMENT for ClaimOccurrence -> EpisodeSegment) | W00-R-23 | V-W00-15 USE_CHUNK_IN_SEGMENT |
| D4 | `IDENTIFIED_BY` | HAS_IDENTIFIER (IdentifierLinkProperties) | W00-R-20 | V-W00-15; V-101r back-fill queue |
| D5 | privacyClass `public`, `internal`, `synthetic` | `PUBLIC`, `INTERNAL`, `INTERNAL` | W00-R-06 | V-521r zero rows except private-personal records, which are reported and removed from the shared graph by the privacy owner, never rewritten |
| D6 | Source with stored `name` and no `title` | `title` | W00-R-14 | V-W00-08 |
| - | uids whose token changed (OutcomeDefinition `outcome` -> `outcome-definition`; W11 `specification-criterion` -> `spec-criterion`; W12/W02 `spec-version` -> `specification-version`; W13 `mixture` -> `material`) | new uid + SAME_IDENTITY_MERGED redirect from the old uid (retired node kept, DEPRECATED) | W00-R-01, W00-R-11 | V-W00-16 (TOKEN_NOT_REGISTERED_FOR_LABEL rows listed in fixtures/results/validation-corrections-runs.md are this queue) |

## 3. Validation parameters (fixtures/validation-params-w00.json)

Base: `validation/validation-params.json` (catalog 0.2.0). Deltas:

- `$assertedTypes` + BOARD_MEMBER_OF, EMPLOYED_BY, ADVISES_ORGANIZATION, INVESTED_IN, HOLDS_EQUITY_IN, PARENT_OF, OWNS_BRAND,
  OPERATES_FACILITY, MARKETS_PRODUCT, MANUFACTURES_PRODUCT, DISTRIBUTES_PRODUCT, ENDORSES_PRODUCT (W01-SR-06); SPONSORS_CONTENT,
  OPERATES_CHANNEL, SERVES_ON_CHANNEL, ACCOMPANIES_TALK (W21-SR-16); LISTS_PROCEDURE, IMPLEMENTS_PANEL, AVAILABLE_IN (W15-SR-11);
  HAS_PATHWAY_VERSION (W13-SR-05); DEVELOPS_PLATFORM, USES_PLATFORM, USES_EQUIPMENT, IMPLEMENTS_PLATFORM, USES_MODALITY, HAS_SENSOR,
  EMBODIES_MODEL, RUNS_ON_DEVICE (W08-SR-06); TARGETS_CONDITION, USES_COMPONENT (W06-SR-12); EVALUATES_RISK_FACTOR (W09-SR-16);
  **minus IDENTIFIED_BY** (W00-R-20). UNDER_LEGAL_BASIS_VERSION is not added: W13 fixtures store it as a structural edge (the first
  run of this pass showed 4 V-101r rows when it was listed).
- `$derivedTypes` + RECOMMENDS, HAS_CHUNK, CHUNK_IN_SEGMENT, ABOUT, MENTIONS_ENTITY, SUPPORTED_BY_DOCUMENT, HAS_CURRENT_PROTOCOL_STEP, ACTS_IN.
- `$ruleOnlyDerivedTypes` + RESOLVES_TO_CHUNK, HAS_CHUNK, CHUNK_IN_SEGMENT, ABOUT, MENTIONS_ENTITY, HAS_CURRENT_PROTOCOL_STEP, COMPARED_TO.
- `$exclusiveTypes` + STRAIN_OF, HAS_PATHWAY_VERSION (HAS_CAPABILITY_STATE and GOVERNED_BY_SPECIFICATION are path-partitioned and stay out).
- `$implicationPairs` + 19 pairs (W12, W13, W14, W15, W22). Rule learned in this pass: a pair whose conclusion is a structural
  relationship type (`[DEPICTS, SUPPORTED_BY]`) is NOT a V-112 parameter; with it, V-112r reported every SUPPORTED_BY edge as
  NO_CITATION (first run). Such pairs stay in predicate-registry.yaml and are checked by their owner's validators (V-60x).
- New: `$episodeTypes` (V-503r), `$quantityPredicateClass` (V-003r), `$uidTypeTokens` and `$uidAliasTokens` (V-W00-16).

## 4. Runtime prerequisites

- APOC Core 5.26.31 with apoc-common 5.26.31 is a deployment prerequisite of @neo4j/graphql 7.6.3 whenever a DateTime field is
  read (`apoc.date.convertFormat`), on Community and Enterprise (W00-R-28; W00-SR-14, W12-SR-11, W13-SR-16, W15-SR-16). Unchanged
  from the first pass, now ruled.
- Scoped subquery syntax `CALL (x) { ... } IN TRANSACTIONS` used by the migrations needs Neo4j 5.23 or later (pinned 5.26.31).

## 5. Application-enforced rules that change

| Rule | Before | After | Ruling |
|---|---|---|---|
| uid minting | service mints uid for Cypher ingestion; API create allowed | every create of a uid-identified record goes through the ingestion service (uid = `hu:<token>:` + generated id); GraphQL create mutations are not exposed at deployment | W00-R-04 |
| uid token choice | label token or 0.2.0 alias | label-keyed registry; refinement specializations use the parent token; aliases only for 0.2.0 fixtures | W00-R-01 |
| opaque segment | UUID or ULID | also hex sha256 of the identity tuple for DocumentTextVersion, Segmentation, Chunk | W00-R-43 |
| literal xor object | all assertions | QUANTITY-class assertions may carry one object plus one numeric literal | W00-R-02 |
| asserted-edge qualifiers | edge only | stored on the authorizing Assertion and copied to the edge; covered by contentHash | W00-R-03 |
| point-in-time statements | date in verbatim text | statedAsOf + precision on the Assertion; bounds stay null | W00-R-13 |
| open-end witness | max(observedAt) | coalesce(publishedAt, observedAt) for PRESENT or null statedTense | W00-R-13 |
| cached captures | - | observedAt = cache time, retrievedAt = request time, cache state in the CAPTURE methodVersion | W00-R-31 |
| merges | not executed (W00-SR-05 open) | SAME_IDENTITY_MERGED redirect; retired node kept DEPRECATED; private records never rewritten; re-stated assertions SUPERSEDES {DUPLICATE_MERGE} | W00-R-11 |
| exclusive attachments with path partitions | - | HAS_CAPABILITY_STATE, GOVERNED_BY_SPECIFICATION checked in the write transaction against the partition path | W00-R-07 |
| privacy class spelling | catalog lower case | PUBLIC / INTERNAL only; field-level INTERNAL list (banner of the fragment) applied by the public projection | W00-R-06, W00-R-27 |
| sourceKind OTHER | - | requires sourceKindNote | W00-R-08 |
| canonicalUri | endpoint URI | post-redirect endpoint, never doi.org / identifiers.org / PubMed search resolvers | W00-R-15 |
| re-anchoring | - | no automatic SUPPORTED_BY join through REANCHORS; a CAPTURE_FIDELITY review adds it | W00-R-29 |
| offsets | "code points after normalization" | code points of DocumentTextVersion.text as stored; writers convert UTF-16 | W00-R-24 |
| image regions | IMG-REL-XYWH-1 (candidate) | IMG-PX1 (pixels after EXIF orientation); LIG-HY1 matching-only | W00-R-24 |
| jurisdiction strings | free | ISO 3166-1 / 3166-2, EU, GB-GBN (pending verification) | W00-R-42 |

## 6. Merge consequence for other owners

Adding `massBasis`/`amountReferent` to AssertionArchetype (W00-R-12) requires ContraindicationAssertion and InteractionAssertion
(W17) to declare the two nullable fields; the merged schema then builds (fragment-changelog.md). Union and relationship relabels
need the W04, W15 (tradeItemIdentifiers -> HAS_IDENTIFIER), W04 (Product.snapshots -> HAS_STATE), W09 (Study.evaluates ->
LEGACY_EVALUATES), W16/W20/W21 (mentions -> MENTIONS_ENTITY) and W23 (redirectKind -> equivalenceKind) fragment or fixture edits
named in seam-rulings.yaml. W20 renames its chunk-overlap edge CHUNK_IN_SEGMENT (W00-R-23).

## 7. Execution evidence

OPS_EVIDENCE_PLACEHOLDER
