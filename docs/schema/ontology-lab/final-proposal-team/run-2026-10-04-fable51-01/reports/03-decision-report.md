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
