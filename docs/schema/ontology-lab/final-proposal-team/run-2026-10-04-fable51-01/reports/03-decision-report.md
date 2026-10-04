# 03 Decision report (Fable 5.1 rulings) — DRAFT, completed at Wave 5/6

Scope: rulings that integrate the 24 worker packets into one schema. Every ruling names the request(s) it answers, the evidence (fixture, source or build fact) and the consequence for the final files. Workers' own packet-level decisions stay in their `05-decision-seam-ledger.md`; W00's kernel rulings are in `workers/W00/09-kernel-reconciliation.md` and are adopted here unless a row below says otherwise. Disagreements are preserved, not averaged.

## A. Frozen naming rulings (D-001..D-016) — status after research

| Id | Status | Evidence from packets |
|---|---|---|
| D-001 archetype labels stored | CONFIRMED | Every fragment builds with multi-label `@node`; W00 fixtures exercise V-000a/b. |
| D-002 ChemicalSubstance / ChemicalForm / IngredientMaterial | CONFIRMED, refined | W02: salts are their own ChemicalSubstance linked by HAS_ACTIVE_MOIETY (GSRS UNII 8XM2XT8VWI vs 0I8H2M0L7N); ChemicalForm kept for physical forms; NRPT is never a substance (fx-06). |
| D-003 StudyIntervention name, LegacyEvaluatedIntervention read-only | CONFIRMED | W09 fragment; W09-SR-13 adopted: the stored legacy relationship type becomes `LEGACY_EVALUATES` so `EVALUATES` keeps one meaning (Adjudication→Assertion). |
| D-004 HAS_PROTOCOL_STEP; HAS_STEP only for manufacturing | CONFIRMED | W16 (order on the edge; V-527p/V-528p); W11 keeps HAS_STEP. W16-D16 departure accepted: protocol-level schedule fields live on the edition; `Protocol` keeps read-only projections. |
| D-005 Source / Document / Publication / Episode | CONFIRMED with W19 R1–R5 | canonicalUri is the post-redirect endpoint, never doi.org; a DOI is an Identifier of the Publication; a slide deck is a Document container, never a rendition of the talk (W21 ACCOMPANIES_TALK); `Source.renditionCoverage` candidate. |
| D-006 Claim / ClaimOccurrence / RelationshipAssertion | CONFIRMED | W21; ExperienceReport retired into ClaimOccurrence (assertionBasis PERSONAL_EXPERIENCE). |
| D-007 catalog names for merged live types | CONFIRMED | W15 MerchantListing, W09 StudyPopulation/OutcomeDefinition/StudyResult; StudyOutcome, ListingSnapshot retired. |
| D-008 Material retired unless failing case | RULED: retired | W11 and W02 agree: every GRN 000635 process input is an IngredientMaterial or ChemicalSubstance; nicotinamide is both input and component under one uid. No ProcessMaterial. |
| D-009 one SpecificationVersion (W11) | CONFIRMED | W12 references it through `CRITERION_OF_SPECIFICATION` (W11-SR-03 / W12 D-W12-16 converge). |
| D-010 IMAGE_REGION locator + LOCATES_REGION | CONFIRMED | W00 V-W00-03; W22 MP5 crop fixture; coordinates live on the ORIGINAL MediaVariant. |
| D-011 assertionUid vs projectionOfAssertionUid | CONFIRMED; CL-016 resolved in D-011's favour | The derived `RECOMMENDS` projection carries `derivationRule` + `derivedFromAssertionUids` (W21 fx07); catalog V-423 is replaced by W21's V-W21-06. |
| D-012 no private-personal element | CONFIRMED | W23 grep and leak fixtures; three new leak checks (V-W23-04/05/09/10) adopted. |
| D-013 nullable `Entity.name` | CONFIRMED; extended to `ActorIdentity.name` | W01-SR-02 build failure otherwise. |
| D-014 provider-less `@vector` only with justification | CONFIRMED | No worker declared `@vector`; Fable adds none in the final file beyond the justified retrieval set listed in section D (candidate indexes are documented in the operations file as commented templates). |
| D-015 live `@fulltext` names kept; stored property names in operations | CONFIRMED | W20 alias round trip (title/url); generator emits stored names. |
| D-016 `sha256:<hex>` hashes; SYNTHETIC_FIXTURE basis | CONFIRMED | All packets. |

## B. Merge rulings (MR)

| Id | Ruling | Requests answered |
|---|---|---|
| MR-01 | A union (or interface relationship target) never lists a type together with a type whose stored labels include that type's primary label; the parent stays, the specialization resolves through it. Enforced by `prune-unions.mjs` at assembly and by the merge checker. | W05-SR-09, W00-SR-11, W23 finding; 21 member removals recorded in `validation/02-merge-build-log.md` |
| MR-02 | Retired types (`Association`, `ExperienceReport`, `FoodProduct`, `MediaSource`, `Material`, `Compound`, `CompoundForm`, `Listing`, `ListingSnapshot`, `Population`, `OutcomeMeasure`, `OutcomeResult`, `StudyOutcome`, `PhysicalLocation`, `Ingredient`) never appear as members; the migration table names each successor. | W03, W21, W05, W22, W11, W02, W15, W09, W01 packets |
| MR-03 | Interface implementers use the interface's exact field names and types (`Observation` ↔ `DiagnosticResult`). | build fact |
| MR-04 | `HAS_SNAPSHOT` keeps one meaning (Source→SourceSnapshot). Entity→state caches (Organization/Product→*Snapshot) use `HAS_STATE` with `StateEpisodeProperties`. | W01-SR-03, W04-SR-06, W20-SR-11, W00 finding 7 |
| MR-05 | `EVALUATES` keeps one meaning (Adjudication→Assertion); the legacy study edge is stored as `LEGACY_EVALUATES`, read-only. | W09-SR-13 |
| MR-06 | `MENTIONS` keeps the kernel meaning (SourceLocator→Mention). Retrieval mention edges from Chunk/Episode/ProtocolResult are named per W00's reconciliation ruling (default `MENTIONS_SUBJECT`, derived, `RetrievalEdgeProperties`). | W20-SR-13, W21-SR-10, W16-SR-18 |
| MR-07 | `HAS_VARIANT` is the product edge; media uses `HAS_MEDIA_VARIANT`. `INVOLVES` is the event edge; exposure uses `HAS_EXPOSURE_AGENT`. `FOR_METRIC` is shared by W07 (ReferenceIntervalVersion→Metric) and W16 (Target→Metric) as one structural type. `MEASURED_IN` is W03's; `Metric.measuredInOrgans` is retired. | CL-014, W05, W07-SR-05, W03-SR-06 |
| MR-08 | `IDENTIFIED_BY` (commerce trade identifiers) is folded into `HAS_IDENTIFIER` with `IdentifierLinkProperties`; `TradeItemIdentifier` keeps its specialization labels. | W00 finding 7 |
| MR-09 | `ResultQualifier` is one shared enum owned by W07 (catalog `resultQualifier` values plus W12's BELOW_REPORTING_LIMIT, QUALITATIVE_ABSENT, QUALITATIVE_PRESENT); `ReportedStatus` stays kernel. | W07-SR-03, W12 request, W23 finding |
| MR-10 | `privacyClass` is stored exactly as the GraphQL enum (`PUBLIC`, `INTERNAL`); validators compare against those spellings; lowercase values in 0.2.0 fixtures are migrated (`SET n.privacyClass = toUpper(...)` statement in the operations file, section 8). | W16-SR-04, W07-SR-15, W23 finding, W00-SR-13 |
| MR-11 | `@declareRelationship` (interface fields only) and `@deprecated` are added to the allowed directive list of contract B1. | W07-SR-01, W20-SR-24 |
| MR-12 | APOC Core 5.26.x is a declared runtime prerequisite of the API layer (DateTime projection). | W00-SR-14, W09-SR-17, W11, W12, W13-SR-16, W23-SR-16 |

## C. Registry admissions (Fable-addressed)

Accepted as sole-writer additions to `02-ownership-registry.md` (recorded there at Wave 6): W06 enums `TreatmentComponentRole`, `TreatmentIntentKind`, `TreatmentIntentBasis` and `TreatmentTargetProperties`; W08 `EquipmentModelTarget` and candidate `FirmwareVersion`; W09 enums listed in W09-SR-01 plus `PublicationRevisionProperties`, `LegacyInterventionArmProperties`, candidates `USES_INTERVENTION_DEVICE` and `FOLLOWS_INTERVENTION_DEFINITION` (promoted to the fragment with W06/W05 targets); W13 `RegulatoryPathwayVersion`, `HAS_PATHWAY_VERSION`, candidate `RegulatoryInspection`; W14 candidate `IpRightStatus` + `IP_STATUS_OF`; W20 `DocumentAuthorTarget`, `RetrievalEdgeProperties`; W21 `IN_RENDITION`, `DELIMITED_BY`, `DISTRIBUTES_RENDITION`, `ACCOMPANIES_TALK`, and ownership of `RecommendableTarget`; W22 `MediaSuitabilityAssessment`, `MediaRightsRecord`; W23 candidates `DECLARES_CRITERION`, `PolicyKind`; W19 candidates `SourceAuthorityAssessment`, `SourceCoverageRequirement`, `SourceDiscoveryRecord`, `AuthorityScope`, `DiscoveryOutcome`. Enum value additions accepted with their failing cases: `CadenceUnit` YEAR, MINUTE and `ConstraintRole` REPEAT_UNTIL (W16-SR-07/08); `OrganizationType` CORPORATE_GROUP (W01-SR-09); `ProcessKind` values (W11-SR-01); `ReferenceIntervalDerivation` ADOPTED_FROM_GUIDELINE (W07-SR-06); `RoleType` HOST, CO_HOST, GUEST, MODERATOR (W21-SR-09); `RegulatoryResponseKind` NDI_FILING_ACKNOWLEDGED (W13-SR-06). Kernel enum value additions (SourceKind, ActivityKind, UseKind DISPLAY_MEDIA, RelevanceBasis) follow W00's reconciliation rulings.

Deferred (no failing case or user input needed): W21-SR-19 `EXCERPTS_FROM`; W21-SR-24 asserter of multi-author publications; W22 operator-captured photos with structural DEPICTS; W13 EU AUTHORIZATION status kind and GB/NI jurisdiction codes; W22-SR-10 capture from sites whose terms ban crawlers (user policy input).

## D. Fixture repairs accepted for the run's translated fixture set (0.2.0 files patched only where the Wave 6 report says so)

- `elysium-basis.cypher`: pin assertion `recordedAt` to fixed instants no later than the policy adjudication's `reviewedAt` (W02-SR-17, W04-SR-12, Fable baseline rehearsal).
- `claim-retelling-provenance.cypher`: Document nodes written with GraphQL names (`documentType`, no `documentId`, no `url`) must be written with stored names (W20-SR-23, W00-SR-03); "B (2011-2017)" board role stored as validTo 2018-01-01 YEAR contradicts the bound rule and targets a brand (W01-SR-05); add the SPONSOR_READ segment (W21-SR-17).
- `study-vs-product-mismatch.cypher`: `collectionMethod: SYSTEMATIC` unsupported by the paper's text → NOT_DESCRIBED (W09).
- Validation suite: the revised validators collected in `workers/W00/validation-corrections.cypher` plus worker-proposed checks (V-W01…V-W23 families) are compiled into the final suite at Wave 6 with final numbers; the original queries stay in `docs/schema/neo4j/validation.cypher` unchanged until a catalog release adopts them.

## E. Items for the user (nonblocking, unchanged from the handoff plus new)

Fable 5.1 availability: verified for this run. New user-dependent items: whether EU/UK authorisations are a new `AUTHORIZATION` status kind; crawler-term capture policy for media; the k-anonymity threshold; PostgreSQL 18 for `WITHOUT OVERLAPS` in the private store; deployment edition for existence/type constraints; vector index dimensions and embedding source.

## F. Wave 5 synthesis rulings (Fable, at assembly)

Mechanics: `validation/harness/assemble-final.mjs` with `assembly-rulings.json` (header, 24 domain banners, field renames, field type fixes, text replacements) and the seam-closure files (`field-injections.json`, `union-additions.json`, `enum-additions.json`, `extra-definitions.graphql`; ledger `04-seam-closure-ledger.md`). Output `docs/schema/final_biotech_schema_proposal.graphql` builds with `@neo4j/graphql` 7.6.3 (BUILD OK, 34 s).

| Id | Ruling | Why | Effect |
|---|---|---|---|
| F-W5-01 | `HAS_ANALYTE` admitted as a W07 candidate structural relationship on `Biomarker` → `ChemicalSubstance` / `MolecularEntity` (W03-SR-03, W02-SR-08). | A measurand must name its analyte for CQ-DX comparability and the W02 salt/moiety cases; no owner objected, W07 did not answer. | Two injected fields; registry row at Wave 6. |
| F-W5-02 | `AssayVersion.runsOnInstrument` retyped to `[EquipmentModelTarget!]!` (W08-SR-01); the stop-gap `runsOnDevices` injection dropped. | One field for one relationship; the union already exists (W08). | fieldTypeFix. |
| F-W5-03 | `SUPPORTED_BY` is property-less everywhere; W12's four fields lose `StructuralEdgeProperties`. | One relationship type, one property shape; the kernel declaration wins. | text replacement (4 occurrences). |
| F-W5-04 | `AFFECTS_MECHANISM` and `MODULATES` carry `AssociationProjectionProperties` on both ends (W02's outgoing fields switched from `DerivedEdgeProperties`). | W03 owns both relationship types; its property type is a superset of `DerivedEdgeProperties`, so nothing W02 wrote is lost. | text replacement (13 occurrences). |
| F-W5-05 | Seam-ledger enum additions without an explicit prior admission are ACCEPTED: `MaterialKind.FOOD` (W05-SR-02), `PathwayKind.NOVEL_FOOD_AUTHORISATION` and `RegulatoryResponseKind.NOVEL_FOOD_AUTHORISED` (W13-SR-03, EU 2020/16), `RegulatoryStatusKind.DESIGNATION_ENDED_UNSPECIFIED` (W06-SR-05, OOPD 465514). | Each has a stated failing case with a real identifier; the alternative (null kind + text) hides the case from queries. | kept in enum-additions. |
| F-W5-06 | Section 5 text replacements of the seam ledger applied: Product `HAS_SNAPSHOT`→`HAS_STATE`, `EVALUATES`→`LEGACY_EVALUATES` on `Study.evaluates`, `IDENTIFIED_BY`→`HAS_IDENTIFIER` (3), retrieval `MENTIONS`→`MENTIONS_ENTITY` with `RetrievalEdgeProperties` (3, W00-R-19 name wins over the MR-06 default). | MR-04..MR-08 as reconciled by W00. | stored types in the final file. |
| F-W5-07 | `Observation.comparedTo` (derived `COMPARED_TO`, `DerivedEdgeProperties`, read-only) injected; W16 omitted the field W07's model card places on `Observation`. | CQ-DX-03 comparability queries need the field on the implementer. | injection. |
| F-W5-08 | Remaining `HAS_VARIANT` (Product→ProductVariant, W04), `HAS_STEP` (ManufacturingProcess→ManufacturingStep, W11), `EVALUATES` (Adjudication→Assertion, kernel) and `HAS_SNAPSHOT` (Source/Document→SourceSnapshot) stay: each is a distinct catalog relationship with disjoint endpoints from the renamed one. | MR-04/MR-05/CL-014/D-004 renamed the colliding uses only. | none. |
| F-W5-09 | Union pruning at assembly (MR-01/MR-02): 14 members removed (retired types `FoodProduct`, `ExperienceReport`, `Association`; specializations beside their parent in `RegulatorySubjectTarget`, `StepSubstanceTarget`, `MediaSubjectTarget`, `MediaVisualizableRelationshipTarget`). | A union never lists a type and its specialization; labels make the specialization reachable through the parent. | listed in the assembly log. |

Deferred from the seam ledger (owner decided otherwise, or a removal): W04-SR-05/-07 endpoint widenings (W22/W01 keep their rules), retired-field requests (W21 AUTHORS/REPORTS, W06 Treatment.evaluatedInStudies, W20 chunk-support shortcuts), removal requests to owners, and new enums nobody defined (`DosageForm`, `AdministrationRoute`, `EpisodeType`, `CommerceMatch*`); each stays a controlled String until a packet owner defines the enum with failing cases.

## G. Challenger objections (Wave 5) and resolutions

Five Opus 5.5 Challengers attacked the assembled artifacts on isolated embedded instances (brief `validation/03-wave5-challenger-brief.md`; reports `validation/challengers/CH-*.md` with replayable `.cypher`). 112 objections in all: kernel 42 (CH-K), privacy 18 (CH-P), study transfer 19 (CH-S), media 17 (CH-M), protocols 16 (CH-R). Per-objection dispositions, with rows before and after each replayed mutation, are in `reports/08-challenger-resolution-matrix.md`. Summary of what Fable did:

| Disposition | Count | Where |
|---|---|---|
| Validator written and mutation-tested (V-F5-01..65) | 84 objections (65 statements) | `validation/fable-w5-validators.cypher`, compiled into `validation/final-validation-suite.cypher` |
| SDL change by Fable | CH-P-02 (interface `privacyClass`, F-W5-11), CH-P-04 (`@vector`, F-W5-12), CH-P-17/CH-R-12 (`DiagnosticResult` label, F-W5-10), CH-R-04 (cadence anchor, F-W5-13), CH-R-05 (`DERIVED_FROM_PROTOCOL`, F-W5-14), CH-S-15 (assessment `recordedTo` read-only, F-W5-15), CH-R-11 (`orderIndex: Int!`, F-W5-16) | `final_biotech_schema_proposal.graphql` |
| Operations change by Fable | CH-P-12 (privacyClass respelling limited to the two classes), CH-P-18 / CH-K-16 (packet constraints, section 5b), CH-K-18a–d / CH-R-13 (6a: UTTERED_BY guard, legacy `ProtocolEdition` for `HAS_STEP`, migration stamps; 7: alias-aware id backfill, no sentinel timestamps, edge basis backfill), CH-K-08a/09 (SDL-derived `assertedTypes`/`derivedTypes`), CH-K-10b/13 (generated label checks) | `final_biotech_schema_operations.cypher`, `validation/validation-params.json`, `validation/generated-label-checks.cypher` |
| Translated-fixture repair (section D) | CH-S-18 (arm/intervention tokens), CH-P-16 (PolicyVersion rows), CH-K-19 (relationshipUid, recordedAt, FINAL status, payloadHash), CH-R-13 (`HAS_PROTOCOL_STEP`), matrix defects D1, D3, D5 | `validation/harness/translate-fixtures.py`, `validation/fixtures-final/99-normalize-live-ids.cypher` |
| Query-shape correction | CH-P-15 / CH-P-06 (QS-5b, QS-6a, QS-8 allow-list; QS-5b string-vs-datetime comparison), CH-M-07/08 (Q04-1 distinct asserters) | `validation/query-shapes-privacy-corrected.cypher` |
| Held in the Challenger run | 13 | matrix |
| Deferred with reason | 14 parts: PUBLIC_ANSWER derived sub-schema (CH-P-01; OQ new item 1), cross-store copy audit (CH-P-08, CH-R-06; OQ item 3), GraphQL write paths that only a service layer can gate (CH-S-03b/04a/04c/14c, CH-P-14), verdict-versus-inputs (CH-S-07, review queue V-F5-17), bare personal names in free text (CH-S-16, CH-R-07a), shared range tokenizer (CH-R-03), `textChange` field (CH-M-12), Q-MP4-1 gate and MEDIA-EV-1 job filter (CH-M-14, CH-M-01: the validators V-F5-41/42/45 catch the result), stored kernel hash (CH-K-04), CANDIDATE-only-when-PROPOSED (CH-K-15), Claim outcome-class field (CH-S-06b) | matrix section "DEFERRED" |

Blocking findings and their closure: every privacy-tier case (CH-P-01..07, 12, 15) is closed either by a schema/operations change above, by a validator (V-F5-18..29), or by the corrected query shapes, except the derived public sub-schema itself, which is a deployment artifact outside this proposal and is recorded as the first new open question. Kernel blocking cases (sentinel dates, second asserter, unregistered predicate, archetype-less uid carrier, resolver-URI sources) are closed by V-F5-56..65 and the generated label checks; study-transfer blocking cases (CH-S-11, 12b, 15, 16) by V-F5-09/10/12/18 and F-W5-15; protocol blocking cases (CH-R-05..08, 13) by F-W5-14, V-F5-31..34 and the fixture/migration repairs; the media blocking case (CH-M-01) by V-F5-41/42.

Validators retired by this round (superseded, kept only as comments in the base file): V-104, V-113, V-115, V-116, V-117, V-121, V-201, V-215r, V-218, V-423, V-423r, V-W00-16, V-W21-06 (and worker-local V-604, V-605, V-528p, V-536p, V-542p, W10-V08, W10-V14 inside their packets).
