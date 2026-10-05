# CH-W00 kernel Challenger: time, provenance, identity (Wave 5)

Challenger: W00 role (Opus 5.5), run-2026-10-04-fable51-01, 2026-10-04.
Mutations, each followed by its undo: `CH-W00-kernel.cypher` (same directory). Every block is labelled `// CH-K-nn MUTATION` or `// CH-K-nn UNDO`.

## How the cases were run

- **Database.** Isolated Neo4j 5.26.31 Community embedded with APOC core (instance `c1`). It held the final operations file and the six translated fixtures in `validation/fixtures-final/`.
  - When I took the instance over, 533 of the 536 uid-bearing nodes had no live `id`, so the backfill had not run.
  - I ran `99-normalize-live-ids.cypher` (the plan's load step) and then took the baseline.
- **Validators.** The compiled suite is `docs/schema/neo4j/validation.cypher` with `validation-params.json`, plus `workers/W00/validation-corrections.cypher` with `validation-params-w00.json`.
  - Both validator files and both params files changed while I was working (V-504a was added at 02:50Z).
  - I therefore ran every case against copies frozen at 02:53Z. The live files match those copies; the final re-run on live files reproduced the frozen baseline.
  - The W00 packet file `workers/W00/fixtures/validation-w00.cypher` was also run, for reference. Section 4 of `reports/03-decision-report.md` names only the V-W01…V-W23 families for compilation, so I do not count a packet validator as part of the suite.
- **Baseline rows.**
  - The suite returned informational rows only.
  - The corrections file already returned rows for V-W00-02r 1, V-313r 6, V-503r 48, V-505r 1, V-505i 1, V-521r 6, V-504a 1, V-W00-15 1, V-W00-16 11 and V-W00-19 7.
  - Only changes against this baseline are attributed to a case.
- **Per-case sequence.** For each case I ran the mutation, then all three suites, then the undo, then all three suites again. Every undo returned the baseline exactly: no residual rows, 536 nodes and 962 relationships, no `chk-` uids left.
- **GraphQL probes.** I used `harness/roundtrip.mjs` (`@neo4j/graphql` 7.6.3) against `docs/schema/final_biotech_schema_proposal.graphql`.
- **What "Observed" means in the table:**
  - *caught by constraint* — the database rejected the write.
  - *caught: V-x* — a validator in the compiled suite returned the row.
  - *NOT caught* — the database accepted the write and no compiled validator flagged it. The table adds "(packet V-x)" where only an uncompiled W00 packet validator fires.

## A. Objections

Severity rule: **BLOCKING** means a frozen shared-contract rule (`01-shared-contract.md` §A/§B) is broken by the loaded fixtures, or by an accepted mutation, and the compiled suite does not catch it. **MAJOR** means a catalog invariant or contract consequence goes uncaught, or the operations file itself produces a violation. **MINOR** is hygiene.

| id | attack (mutation in .cypher) | violated rule | expected catcher | observed | severity | proposed fix |
|---|---|---|---|---|---|---|
| CH-K-01a | BOARD_MEMBER_OF edge `recordedFrom` set to 2026-10-02, before its assertion (2026-10-03T12Z) and before snapshot retrievedAt 2026-10-03 | INV-502; asserted_edge rule `recordedFrom >= assertion.recordedAt` | V-504 | **caught: V-505r** (RECORDED_BEFORE_ASSERTION). Suite V-504 is silent because it only reads 5 episode types (packet V-504 fires). | MINOR | Replace V-504's first branch with the packet form `MATCH ()-[h]->() WHERE h.assertionUid IS NOT NULL ...`, or retire it in favour of V-505r and record that in the suite header. |
| CH-K-01b | Assertion `recordedAt` and edge `recordedFrom` both backdated before retrieval | INV-502 | V-504 | **caught: V-504** ASSERTION_BEFORE_RETRIEVAL | held | — |
| CH-K-02a | ApplicabilityDimension `recordedAt` set to 2026-01-01; its locators are on snapshots retrieved 2026-07-10 and 2026-10-03 | INV-502 (W00-R-51) | V-504a | **caught: V-504a** | held | It holds only when `recordedAt` is non-null. 42 ApplicabilityDimensions in the fixtures have none (see CH-K-19). |
| CH-K-02b | Activity `curation-2026-10-03-lane4` startedAt moved to 2026-10-04T06Z; all of its assertions (recordedAt 2026-10-03T12Z) now predate the activity that generated them | PROV-O generation inside the activity; A.6 "recorded time service-assigned, never backdated" | none exists | **NOT caught** | MAJOR | New check V-504b: `MATCH (x)-[:WAS_GENERATED_BY]->(act:Activity) WHERE coalesce(x.recordedAt, x.recordedFrom) < act.startedAt OR (act.endedAt IS NOT NULL AND coalesce(x.recordedAt, x.recordedFrom) < act.startedAt)`. Rows are violations. |
| CH-K-03a | A fact ending recorded as `SUPERSEDES {SOURCE_CORRECTION}`: same subject, object and validFrom; newer only closes an open validTo; no `sourceRevisionEventUid`. The old record is silently declared an error. | A.6 "a correction is SOURCE_CORRECTION, a fact ending VALIDITY_BOUNDED" | none (V-507b only reads VALIDITY_BOUNDED) | **NOT caught** | MAJOR | New V-507c: a SOURCE_CORRECTION or SOURCE_REVISION supersession must name `sourceRevisionEventUid` resolving to a SourceRevisionEvent of a supporting source, and must not have the VALIDITY_BOUNDED shape (same object, same validFrom, older.validTo null, newer.validTo non-null) unless it does. |
| CH-K-03b | A correction (start year 2011 → 2012) recorded as VALIDITY_BOUNDED | A.6 | V-507b | **caught: V-507b** | held | — |
| CH-K-04 | Correction applied in place: validTo 2018 → 2017 edited on the Assertion and its edge together; updatedAt bumped | INV-501 (valid time immutable), INV-504 | V-505r | **NOT caught** (packet V-W00-06 fires on updatedAt > createdAt). V-505r only compares edge with assertion, so a consistent edit is invisible. | MAJOR | Compile V-W00-06. Also add a fidelity check that recomputes the assertion's kernel hash, e.g. `apoc.util.sha256([predicate, subjectUid, objectUid or literal, toString(validFrom), toString(validTo), precisions, bases])` against a stored `kernelHash` written at commit. APOC core is already a runtime prerequisite (W00-R-28). |
| CH-K-05a | Assertion validTo = 9999-12-31 | A.6 / INV-102 no sentinel dates | V-502 | **caught: V-502** | held | — |
| CH-K-05b | Assertion validTo = 9000-12-31 | A.6 / INV-102 | V-502 / V-104 | **NOT caught.** V-502 tests year ≥ 9999 on assertions; V-104 tests ≥ 9000 on edges only (packet V-103 fires). | **BLOCKING** | One sentinel validator over every temporal property of every node and edge: `[k IN keys(x) WHERE k IN ['validFrom','validTo','recordedAt','recordedFrom','recordedTo','effectiveFrom','effectiveTo','startedAt','endedAt','observedAt','retrievedAt','publishedAt','reviewedAt','createdAt','updatedAt'] AND (x[k].year >= 9000 OR x[k].year <= 1 OR x[k] = datetime({epochMillis: 0}))]`, run on `MATCH (x)` and `MATCH ()-[x]->()`. |
| CH-K-05c | Assertion validFrom = 0001-01-01 used for an unknown start | A.6 / INV-102 | V-104 | **NOT caught** (V-104's `year <= 1` is edge-only; packet V-103 fires) | **BLOCKING** | Same validator as CH-K-05b. |
| CH-K-05d | Assertion validFrom = 1970-01-01T00:00Z (epoch) used for an unknown start | A.6 / INV-102 | none | **NOT caught** anywhere, packet included | **BLOCKING** | Same validator as CH-K-05b, which includes the epoch test. |
| CH-K-05e | EvidenceApplicability recordedTo = 9999-12-31; AssayVersion effectiveTo = 9999-12-31 | A.6 / INV-102 | V-502 | **NOT caught.** V-502 reads only Assertion and 5 episode types. | **BLOCKING** | Same validator as CH-K-05b. |
| CH-K-06 | Second `ASSERTED_BY` (Huberman) added to a generic Assertion | A.3 / INV-003 "at most one asserter" | V-410 | **NOT caught.** V-410 is ClaimOccurrence-only; packet V-W00-01 fires. | **BLOCKING** | Compile V-W00-01 under a final id. Cardinality "zero_or_one" in the SDL field description is not enforced by anything else. |
| CH-K-07a | SourceLocator with no HAS_LOCATOR | A.8 | V-402 | **caught: V-402** | held | — |
| CH-K-07b | Snapshot attached to no Source (no HAS_SNAPSHOT, so no canonicalUri) holds a complete TEXT_QUOTE locator that is the only support of an ACCEPTED assertion | A.8 Source → SourceSnapshot → SourceLocator; INV-002 "reproducible" | V-401 / V-111 | **NOT caught.** V-401 and V-111 only check contentHash and retrievedAt. | MAJOR | New V-402b: every SourceSnapshot has exactly one incoming `HAS_SNAPSHOT` from a `Source` with non-null `canonicalUri`. Add the Source hop to V-401's EXISTS pattern. |
| CH-K-07c | One snapshot claimed by two Sources (YouTube rendition and the affiliations page) | A.8 "Source (one canonicalUri)" | none | **NOT caught** | MAJOR | Same V-402b (exactly one Source). |
| CH-K-08a | `Study -[:SPONSORED_BY]-> Organization` with no projectionOfAssertionUid, no derivationRule, no derivedFrom* | A.5 / INV-004 / INV-104; FI SPONSORS_STUDY → EXECUTES_STUDY area | V-112 / V-112r | **NOT caught.** SPONSORED_BY is `class: derived` in the SDL but is absent from `$derivedTypes` and from the implication targets. | **BLOCKING** | Generate `$derivedTypes` and `$assertedTypes` from the final SDL description strings, not by hand. 19 SDL-derived types are missing: ABOUT_PRODUCT, ASSOCIATED_WITH_CONDITION, ASSOCIATED_WITH_OUTCOME, FOLLOWED_BY, FOLLOWS_PATHWAY, HAS_REGULATORY_STATUS, INCLUDES_BIOMARKER, INCLUDES_SUBJECT, INCREASES_RISK_FOR, INDICATES, INVESTIGATED_BY, MEASURES, MEDIATES_RISK_THROUGH, OCCURS_IN_SEGMENT, OPERATED_BY, REPORTED_IN, REPORTS_SAFETY_SIGNAL, RESOLVES_TO_CONSTRAINT, SPONSORED_BY. Add a suite self-check that fails when an SDL relationship class is absent from the params. |
| CH-K-08b | Uncited CONTAINS (a type that is in `$derivedTypes`) | INV-004 | V-004, V-112 | **caught: V-004, V-112, V-112r** (NO_CITATION) | held | — |
| CH-K-09 | `Person -[:AFFILIATED_WITH]-> Organization` with no assertionUid, recordedFrom or relationshipUid | A.5 "asserted edges are projections of exactly one Assertion"; INV-101 | V-101 / V-505r | **NOT caught.** 47 SDL-asserted types are missing from `$assertedTypes`, among them AFFILIATED_WITH, HAS_IP_INTEREST_IN, RECEIVES_COMPENSATION_FROM, FOUNDED_ORGANIZATION, CONTRACT_MANUFACTURES_FOR, AUTHORED_BY and SUPPLIES_INGREDIENT_MATERIAL. V-505r only reads edges that already carry assertionUid. | **BLOCKING** | Same parameter regeneration as CH-K-08a. Make V-101 also require `relationshipUid` (the profile requires it; see CH-K-19). |
| CH-K-10a | Person gains `:InformationArtifact` | A.1 / INV-001 | V-000b | **caught: V-000b** | held | — |
| CH-K-10b | Shadow `:LegalEntity` with uid `hu:org:edenroc-sciences` and no `:Organization`/`:Entity` label. The uid now names two nodes. | A.1 exactly one archetype per node; A.2 / INV-001 one stable uid | entity_uid_unique, V-000a/b | **NOT caught.** No uniqueness constraint applies (labels absent). V-000a/b only scan archetype-labelled nodes. V-W00-16 accepts `org` (registry T2). Only the informational V-118 count moves. | **BLOCKING** | (1) New V-000c: every node with a `uid`, or with any label from the uid-token registry, carries exactly one archetype label and every `@node` label set of its type: `MATCH (n) WHERE n.uid IS NOT NULL AND size([l IN labels(n) WHERE l IN $archetypes]) <> 1`. (2) V-000a should group over all nodes with a uid, not only archetype-labelled ones. |
| CH-K-11a | Person `id` ≠ opaque uid segment | A.2 / INV-106 | V-117 | **caught: V-117** | held | — |
| CH-K-11b | Document `documentId` (its live id alias) drifted while a stray `id` equals the opaque segment. Operations §7 writes exactly that `id` onto every Document. | A.2, B2 alias, INV-106 | V-117 | **NOT caught.** V-117 reads `coalesce(n.id, n.documentId, …)`, so `id` masks the alias. | MAJOR | In V-117, choose the property by label: `CASE WHEN n:Document THEN n.documentId WHEN n:DocumentTextVersion THEN n.documentTextVersionId WHEN n:Segmentation THEN n.segmentationId WHEN n:Chunk THEN n.chunkId ELSE n.id END`. Also flag a Document carrying a plain `id` that differs from its alias. Restrict the §7 backfill to `NOT n:Document` (as 99-normalize does). |
| CH-K-11c | Live `id` removed from an Assertion. When I took the instance over, 533/536 uid nodes had no `id` and the suite returned zero violation rows. | A.2, B2 `id: ID!` | V-117 | **NOT caught.** V-117 skips a null live id. Packet V-W00-08 fires. | MAJOR | V-117: add `OR liveId IS NULL` for labels that are GraphQL node types. Compile V-W00-08. |
| CH-K-12a | Person with uid token `widget` | A.2, registry T1 | V-W00-16 | **caught: V-W00-16** TOKEN_NOT_REGISTERED_FOR_LABEL | held | — |
| CH-K-12b | Well-formed ClaimOccurrence minted `hu:assertion:…` | registry T1/T3: ClaimOccurrence token is `claim-occurrence` | V-W00-16 | **NOT caught.** V-W00-16 accepts the token of any label the node carries. | MINOR | V-W00-16: compare against the token of the primary label (first label of the type's `@node` list). Accept a parent-label token only for the T2 refinement list. |
| CH-K-12c | Person minted `hu:offer:…` (a 0.2.0 alias token of another type) | registry T1/T4 (aliases valid for 0.2.0 fixtures only) | V-W00-16 | **Downgraded.** The row is classified FIXTURE_ALIAS_TOKEN, a migration item, because the CASE tests the alias list before the label. | MAJOR | Reorder the CASE: an alias token is FIXTURE_ALIAS_TOKEN only when the alias map sends it to one of the node's labels (`$uidAliasTokens` as a map alias → label). Otherwise it is TOKEN_NOT_REGISTERED_FOR_LABEL. |
| CH-K-13 | Sinclair node gains `:Organization` (Person+Organization; both are Entity, so V-000b passes) | A.1 "multiple domain labels never add a second archetype" holds, but union discrimination fails; A.3 at most one asserter | none | **NOT caught.** GraphQL probe: `assertions{assertedBy}` over ONE `ASSERTED_BY` edge returns two asserters, `[{__typename: Person}, {__typename: Organization}]`, with the same uid. The node also appears in both `people` and `organizations`. | MAJOR | New V-000d: a node's domain labels equal exactly one `@node(labels:)` list of the final SDL (parameter `$nodeLabelSets` generated from the SDL). Reject a node carrying two primary labels from disjoint types. |
| CH-K-14a | Assertion validFrom == validTo | A.6 half-open | V-103 | **caught: V-103** | held | — |
| CH-K-14b | Assertion superseded at the instant it was recorded (recordedAt == recordedTo) through a well-formed VALIDITY_BOUNDED ending | A.6 half-open recorded intervals; INV-101 `recordedFrom < recordedTo` | V-506 / V-507 / V-109 | **NOT caught.** All three compare with `<` or `=` and accept equality, leaving an empty recorded interval. | MAJOR | V-506: add `OR older.recordedTo <= older.recordedAt`. V-507: use `x.recordedAt <= y.recordedAt` (newer must be strictly later). |
| CH-K-14c | AssayVersion effectiveFrom == effectiveTo; Activity endedAt before startedAt | A.6 half-open | none | **NOT caught** | MINOR | Generic interval validator over the pairs (effectiveFrom, effectiveTo), (startedAt, endedAt), (validFrom, validTo), (recordedAt, recordedTo), on nodes and edges, with `>=` as the violation. |
| CH-K-15 | Assertion predicate set to `ENDORSES_EVERYTHING_IT_FUNDS` | A.3 "predicate is a controlled string registered in the catalog" | none | **NOT caught.** No validator reads `predicate-registry.yaml`. | **BLOCKING** | Add `$registeredPredicates` (catalog relationship names ∪ assertedPredicates with status REGISTERED or CANDIDATE) to params, and new V-514c: `MATCH (a:Assertion) WHERE NOT a.predicate IN $registeredPredicates`. CANDIDATE predicates are allowed only with status PROPOSED (registry conventions). |
| CH-K-16a | Second Source with the same canonicalUri as `hu:source:youtube-n9IxomBusuw` | A.8 "Source (one canonicalUri)" | `source_canonical_uri` (W00 operations.cypher) | **NOT caught.** The constraint was dropped from the final operations file; no validator exists. | MAJOR | Restore `CREATE CONSTRAINT source_canonical_uri IF NOT EXISTS FOR (n:Source) REQUIRE n.canonicalUri IS UNIQUE` (Community-capable). Also restore `activity_external_run_unique` and `trade_item_identifier_identity`, which were dropped the same way. |
| CH-K-16b | Second Identifier (LOINC, Regenstrief Institute, 4548-4) | A.2 Identifier records; W00 fixture 08 relies on the rejection | `identifier_scheme_issuer_value` | **NOT caught.** The constraint was dropped from final ops. The wave-6 plan step "08-identifier-across-issuers (statement F08-dup rejected by identifier_scheme_issuer_value)" will no longer see the rejection. | MAJOR | Restore `CREATE CONSTRAINT identifier_scheme_issuer_value IF NOT EXISTS FOR (n:Identifier) REQUIRE (n.scheme, n.issuer, n.value) IS UNIQUE`. |
| CH-K-17a | Second BOARD_MEMBER_OF episode reusing the first episode's relationshipUid | asserted_edge "one relationship per episode" | rel_board_member_of_relationship_uid | **caught by constraint** (`Relationship(108) already exists …`) | held | — |
| CH-K-17b | Legitimate second recorded-time episode with a fresh relationshipUid | — | must be accepted | accepted | held | The per-type uniqueness does not block a legitimate second episode. |
| CH-K-17c | (1) Audit id `hu:rel:board-member-of-…` reused on an ADVISES_ORGANIZATION edge. (2) Duplicate relationshipUid on MEASURES_METRIC. | relationshipUid is a stable audit id (SDL "MERGE key") | rel_*_relationship_uid | **NOT caught.** Constraints are per type, and MEASURES_METRIC has none: mixed structural/asserted class in the SDL, so the generator skipped it. Same for APPROVAL_FOR, DESIGNATION_FOR, EVALUATES_RISK_FACTOR. | MINOR | gen-operations: emit the constraint for every type in `$assertedTypes ∪ $episodeTypes`. Add validator V-101b `MATCH ()-[r]->() WHERE r.relationshipUid IS NOT NULL WITH r.relationshipUid AS u, count(*) AS c WHERE c > 1`. |
| CH-K-18a | Operations §6a "UTTERED_BY → ASSERTED_BY" run verbatim on a ClaimOccurrence that already has ASSERTED_BY | INV-402 / A.3 | the migration itself | **The migration creates the violation.** V-410 catches it afterwards (asserters = 2). | MAJOR | Guard the statement with `WHERE NOT (a)-[:ASSERTED_BY]->()`. Export conflicting pairs to ResolutionHypothesis review, as already done for LINKS_TO. |
| CH-K-18b | Operations §6a "HAS_STEP → HAS_PROTOCOL_STEP" run verbatim on `Protocol -[:HAS_STEP]-> ProtocolStep` | D-004: HAS_PROTOCOL_STEP is ProtocolEdition → ProtocolStep | none | **NOT caught.** The statement writes Protocol → ProtocolStep, a domain the SDL does not declare. No validator checks the domain. | MAJOR | Match `(a:ProtocolEdition)-[r:HAS_STEP]->(b:ProtocolStep)`. A Protocol-level HAS_STEP needs an edition first (export to review). Add a domain check for HAS_PROTOCOL_STEP. |
| CH-K-18c | Operations §7 run verbatim after a Cypher write of an Organization and an Assertion without id or timestamps | A.6 no sentinel dates; B2 `id: ID!` | none | **NOT caught.** createdAt is set to 1970-01-01 (epoch sentinel). The Assertion gets no `id` because the backfill is `:Entity`-only. The same statement wrote `id` onto 3 Documents, which enables CH-K-11b. | **BLOCKING** | Replace §7 with the 99-normalize-live-ids statements (all uid-bearing nodes; Document-family aliases excluded). Use the commit transaction time (`datetime.transaction()`) or leave the field null for review. Never use `epochMillis: 0`. |
| CH-K-18d | §6a HAS_STEP statement on the loaded fixtures (6 ProtocolEdition -[:HAS_STEP]-> ProtocolStep edges written by translated `recommendation-snapshot`), then duplicate stepKey `fixed-bedtime` inside edition e1 | D-004; V-525 stepKey unique within an edition | V-525 / V-525r | The migration converts nothing (0 updates). **Frozen V-525 catches the duplicate; its replacement V-525r does not**, because V-525r and V-526r read only HAS_PROTOCOL_STEP, which no final fixture contains. | MAJOR | Fix the §6a match (CH-K-18b) and translate the fixture to HAS_PROTOCOL_STEP. Until both land, V-525r/V-526r should read `HAS_PROTOCOL_STEP|HAS_STEP` from ProtocolEdition. |
| CH-K-19 | PROBE, no mutation: the loaded final fixtures already contain kernel records the frozen API cannot read: 3 asserted edges without relationshipUid; 54 EvidenceAssessments without recordedAt; 46 VersionedStates without payloadHash; EvidenceApplicability.status `FINAL` | B3 (`recordedAt: DateTime!`, `payloadHash: String!`, AssessmentStatus enum), B4 (`relationshipUid: String!`), asserted_edge required fields | V-101, V-514; Enterprise existence constraints (rejected on Community) | **NOT caught** by the compiled suite. GraphQL probes G1–G5 all fail (section C). | **BLOCKING** | (1) Archetype-field validator V-514r over all six archetypes: Assertion (predicate, status, recordedAt), EvidenceAssessment (assessmentType, methodVersion, status ∈ AssessmentStatus, recordedAt), VersionedState (stateType, payloadHash), InformationArtifact (artifactType), Occurrence (occurrenceType), Entity (entityType). This is the generalized packet V-W00-08/09. (2) V-101: require relationshipUid. (3) Fix the translated fixtures, or record them as known failures before admission. |

**Counts.** 42 rows: 41 mutations plus 1 probe (CH-K-19).

| Severity | Rows |
|---|---|
| BLOCKING | 11 rows, 7 distinct fixes — CH-K-05b, 05c, 05d, 05e (one sentinel validator), 06, 08a + 09 (one parameter regeneration), 10b, 15, 18c, 19 |
| MAJOR | 15 — CH-K-02b, 03a, 04, 07b, 07c, 11b, 11c, 12c, 13, 14b, 16a, 16b, 18a, 18b, 18d |
| MINOR | 4 — CH-K-01a, 12b, 14c, 17c |
| held | 12 — CH-K-01b, 02a, 03b, 05a, 07a, 08b, 10a, 11a, 12a, 14a, 17a, 17b |

## B. Operations file (`final_biotech_schema_operations.cypher`)

- **Constraint and index names.**
  - There is no duplicate name inside the file or across the file and its Enterprise companion.
  - No name in either file collides with a worker operations file under a different definition.
  - `adjudication_verdict_exists` is the same definition with a different variable name. Harmless.
- **Relationship uniqueness.**
  - The 142 per-type `relationshipUid` constraints do not block a legitimate second episode (CH-K-17b).
  - They do reject reuse of an episode id (CH-K-17a).
  - Gaps: MEASURES_METRIC, APPROVAL_FOR, DESIGNATION_FOR and EVALUATES_RISK_FACTOR have no constraint, and an audit id can be reused across types (CH-K-17c).
- **Natural keys dropped.** Four Community-capable uniqueness constraints from W00 `operations.cypher` are absent from the final file: `source_canonical_uri`, `identifier_scheme_issuer_value`, `trade_item_identifier_identity`, `activity_external_run_unique` (CH-K-16).
- **Sections 6–7.**
  - On a fresh database every statement is a MATCH that finds nothing, so they are no-ops. This is by inspection: I was not permitted to start a fresh database.
  - On the loaded fixtures, §6 matches no legacy label. The §6a HAS_STEP statement misses the 6 legacy edges because of its wrong domain (CH-K-18d).
  - Harm shows only when the file is re-run on data, which the file header says is safe:
    - §7 writes the epoch sentinel and a Document `id` (CH-K-18c, CH-K-11b).
    - §6a can manufacture second asserters (CH-K-18a) and misplace HAS_PROTOCOL_STEP (CH-K-18b).
  - The header says §6 must run *before* §§1–5, but the file places it after them. On a live database a relabel that creates a uid duplicate fails mid-file instead of before the constraints exist. This is MINOR: split migration into its own file.

## C. GraphQL probes (final SDL, `@neo4j/graphql` 7.6.3, instance c1)

| probe | query (abridged) | result |
|---|---|---|
| G1 | `organizations(uid seller-account-amazon-tru-niagen){sellerOfRecordForConnection{edges{properties{relationshipUid}}}}` | ERR: Cannot return null for non-nullable field AssertedEdgeProperties.relationshipUid |
| G2 | `organizations(uid w-r-grace…){suppliesIngredientMaterialsConnection{… relationshipUid}}` | ERR: … RoleEdgeProperties.relationshipUid |
| G3 | `applicabilityDimensions(uid …material_identity){recordedAt}` | ERR: … ApplicabilityDimension.recordedAt |
| G4 | `evidenceApplicabilities(uid synthetic-mg-glycinate…){status}` | ERR: Enum "AssessmentStatus" cannot represent value: "FINAL" |
| G5 | `assayVersions(uid …cobas-c513){payloadHash}` | ERR: … AssayVersion.payloadHash |
| G13 (with CH-K-13 applied) | `assertions(uid A_BOARD){assertedBy{__typename …}}` | OK, but returns two asserters (Person and Organization, same uid) over one `ASSERTED_BY` edge |

## D. What held

- **Archetype labels.** A second archetype label is caught by V-000b (10a).
- **Locators.** A locator without a snapshot is caught by V-402 (07a).
- **Backdating.** Consistent backdating of an assertion before retrieval is caught by V-504 (01b). Edge-only backdating is caught by V-505r (01a). Backdated assessments with a recordedAt are caught by the new V-504a (02a).
- **Correction vs ending.** A correction mislabelled VALIDITY_BOUNDED is caught by V-507b (03b).
- **Sentinels and intervals.** The 9999 sentinel on an assertion is caught by V-502 (05a). An empty valid interval on an assertion is caught by V-103 (14a); on edges, by V-102.
- **Derived edges.** Uncited derived edges of listed types are caught by V-004, V-112 and V-112r (08b).
- **Identity.** id drift on ordinary types is caught by V-117 (11a). An unregistered uid token is caught by V-W00-16 (12a).
- **Episodes.** Episode-id reuse within a type is rejected by constraint (17a). A legitimate second episode is accepted (17b).
- **Migration fallout.** The second asserter that §6a manufactures is at least visible afterwards through V-410 (18a).
- **Restoration.** Every undo restored the baseline exactly.

## E. Not tested

- Enterprise existence and type constraints (Community rejects them). My claim that they would catch CH-K-19 rests on the companion file's text.
- Sections 6–7 on a truly fresh database (no database start or stop was permitted).
- Vector indexes (§5 is empty in the final file).
