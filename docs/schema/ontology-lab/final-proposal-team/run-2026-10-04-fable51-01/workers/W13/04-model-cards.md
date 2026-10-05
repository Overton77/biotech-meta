# W13 model cards

## Conventions for every card

**Common fields.** Every node type below also carries the B2 skeleton fields, and they are not repeated in each card: `id`, `uid`, `name` (nullable, presentation only), `description`, `mongoResearchRunId` (internal operational lineage), `createdAt`, `updatedAt`, `privacyClass` (PUBLIC by default), `maturity`, `schemaVersion`, plus the archetype fields.

**Privacy.** Every W13 element is PUBLIC; agency records are public records. Nothing here is private-personal.

**Kind codes:**

| Code | Meaning |
|---|---|
| obs | observed from the source record |
| asr | asserted (through an Assertion) |
| der | derived (read-only projection) |
| op | operational |

**Temporal behaviour:**

- InformationArtifact fields are immutable after commit.
- VersionedState payloads are immutable (`payloadHash`). When a state held is carried by its attachment episode.
- Entity fields are current values. Anything that changes over time has been moved to a state or an assertion.

**Maturity:** PROVISIONAL (catalog module maturity) unless the card says CANDIDATE or NEW.

## Node types

### RegulatoryAgency

| Item | Value |
|---|---|
| Meaning | A public authority that runs programs and issues responses and statuses. It is not a jurisdiction. |
| Archetype, labels | Entity; `["RegulatoryAgency","Organization","Entity"]` |
| uid token | `org`, same as LegalEntity (W13-SR-02). Example: `hu:org:us-fda` |
| Identity keys | uid. Aliases: agency names, acronyms. Identifiers: none required |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | live type; round 0005 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `entityType` | String! | no | `REGULATORY_AGENCY` | op |
| `agencyCode` | String | yes | FDA, EC, FSA; display only, not identity | obs |
| `jurisdiction` | String | yes | home jurisdiction (W13-SR-01 convention) | obs |
| `overseesPathways` | → RegulatoryPathway | — | `OVERSEES`, structural, many | — |

### RegulatoryPathway

| Item | Value |
|---|---|
| Meaning | A regulatory program of one jurisdiction; stable across legal-basis changes |
| Archetype, labels | Entity; `["RegulatoryPathway","Entity"]` |
| uid token | `reg-pathway` (registered as a fixture alias; W13-SR-02 asks to register it for the primary label) |
| Identity keys | uid; natural key (`pathwayKind`, `jurisdiction`, program name). Not a URL |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | live; round 0005; S12–S14 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `pathwayKind` | PathwayKind! | no | program kind | obs |
| `jurisdiction` | String! | no | program jurisdiction | obs |
| `submissionCategory` | String | yes | live verbatim text | obs |
| `legalBasisCitation`, `effectiveFrom`, `effectiveTo` | String / DateTime | yes | **der** read-only projections of the current `HAS_PATHWAY_VERSION` episodes; null = unknown, never "ongoing" | der |

Edges:

| Field | Relationship | Class, cardinality | Target |
|---|---|---|---|
| `versions` | `HAS_PATHWAY_VERSION` | structural, StateEpisodeProperties | RegulatoryPathwayVersion |
| `hasSteps` | `HAS_REGULATORY_STEP` | structural, orderIndex | RegulatoryStep |
| `overseenBy` | `OVERSEES` (in) | structural | RegulatoryAgency |
| `legacyFollowedBy` | `FOLLOWS_PATHWAY` (in) | derived | Product |

### RegulatoryPathwayVersion (NEW)

| Item | Value |
|---|---|
| Meaning | One legal-basis regime of a pathway. The payload is the instrument; when it held is the episode. Two clocks are kept: legal effect (episode) and codified text |
| Archetype, labels | VersionedState; `["RegulatoryPathwayVersion","VersionedState"]` |
| uid token | `reg-pathway-version` (W13-SR-04) |
| Identity keys | uid; natural key (pathway uid, `legalBasisCitation`) |
| Derivation | The pathway projections are computed over current episodes |
| Module, maturity | regulatory_and_ip; NEW (PROVISIONAL once SR-04/SR-05 are ruled) |
| Sources | S12, S13, S14, S1 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `stateType` | String! | no | `REGULATORY_PATHWAY_VERSION` | op |
| `payloadHash` | String! | no | `sha256:` hash of the payload | op |
| `effectiveFrom` | DateTime | yes | legal-effect start as stated by the instrument (89 FR 37286: 2024-07-05) | obs |
| `effectiveTo` | DateTime | yes | only when the instrument states a sunset; a vacatur or repeal ends the **episode** instead | obs |
| `versionLabel` | String | yes | presentation | op |
| `legalBasisCitation` | String! | no | e.g. "21 CFR 809.3(a) as amended by 89 FR 37286" | obs |
| `instrumentCitations` | [String!] | yes | every opening and closing instrument (FR docs, court judgment) | obs |
| `codifiedTextFrom`, `codifiedTextTo` | DateTime | yes | CFR text clock (2025-09-19 reversion) | obs |
| `jurisdiction` | String! | no | | obs |
| `pathway` | `HAS_PATHWAY_VERSION` (in) | — | exactly one pathway | — |

### RegulatoryStep

| Item | Value |
|---|---|
| Meaning | A template step of a pathway definition; not an event |
| Archetype, labels | Entity; `["RegulatoryStep","Entity"]` |
| uid token | `reg-step` (W13-SR-04) |
| Module, maturity | regulatory_and_ip; PROVISIONAL (live type kept) |
| Sources | live |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `entityType` | String! | no | | op |
| `stepKind` | String | yes | free text | obs |
| `milestoneCode` | String | yes | agency milestone code | obs |
| `ofPathways` | `HAS_REGULATORY_STEP` (in) | — | | — |

### RegulatorySubmission

| Item | Value |
|---|---|
| Meaning | What was filed with an agency |
| Archetype, labels | InformationArtifact; `["RegulatorySubmission","InformationArtifact"]` |
| uid token | `reg-submission` (W13-SR-02) |
| Identity keys | uid; `Identifier` records (FDA_GRN, FDA_NDI, FDA_510K, FDA_DEN, FDA_NDA …) through `HAS_IDENTIFIER`; `identifier` is display only |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | S1–S4, S8–S11 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `artifactType` | String! | no | | op |
| `publishedAt`, `observedAt`, `contentHash` | | yes | archetype fields | |
| `submissionKind` | PathwayKind! | no | must equal the `UNDER_PATHWAY` target kind (V-W13-04) | obs |
| `submissionSubtype` | String | yes | ORIG-1, Traditional, Direct (verbatim) | obs |
| `identifier` | String | yes | verbatim number | obs |
| `jurisdiction` | String! | no | | obs |
| `submittedAt` | DateTime | yes | date on the filing | obs |
| `receivedAt` | DateTime | yes | agency receipt (NEW) | obs |
| `filingDate` | DateTime | yes | **asr** projection of the latest accepted filing-date assertion; an NDI reset is a superseding assertion | asr |
| `conditionsOfUseText` | String | yes | as proposed by the submitter | obs |

Edges:

| Field | Relationship | Class, cardinality |
|---|---|---|
| `underPathway` | `UNDER_PATHWAY` | structural, exactly_one |
| `underLegalBasisVersion` | `UNDER_LEGAL_BASIS_VERSION` | structural, zero_or_one (filing regime) |
| `submittedBy` | `SUBMITTED_BY` | asserted, one_or_more over time |
| `submissionAbout` | `SUBMISSION_ABOUT` | asserted, one_or_more |
| `supersedesSubmission` | `SUPERSEDES_SUBMISSION` | asserted, zero_or_one |
| `responses` | `SUBMISSION_HAS_RESPONSE` | structural, many |
| `identifiers` | `HAS_IDENTIFIER` | IdentifierLinkProperties (W00) |

### RegulatoryResponse

| Item | Value |
|---|---|
| Meaning | What the agency answered. Immutable; a later letter is a new node |
| Archetype, labels | InformationArtifact; `["RegulatoryResponse","InformationArtifact"]` |
| uid token | `reg-response` (W13-SR-02) |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | S1, S2, S3, S8–S11, S15 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `artifactType` | String! | no | | op |
| `publishedAt`, `observedAt`, `contentHash` | | yes | archetype fields | |
| `responseKind` | RegulatoryResponseKind! | no | closed per pathway (V-W13-03) | obs |
| `decisionTextVerbatim` | String | yes | SESE, DENG, "FDA has no questions" | obs |
| `issuedAt` | DateTime | yes | letter or decision date | obs |
| `jurisdiction` | String! | no | must equal the submission's | obs |
| `conditionsOfUseText` | String | yes | agency conditions, verbatim; null = not captured (V-331) | obs |
| `agencyDisclaimerText` | String | yes | all disclaimers verbatim, in letter order, " \| " separated | obs |

Edges:

| Field | Relationship | Class, cardinality |
|---|---|---|
| `issuedBy` | `ISSUED_BY` | structural, exactly_one |
| `submission` | `SUBMISSION_HAS_RESPONSE` (in) | exactly_one |
| `resultingStatuses` | `RESULTS_FROM_RESPONSE` (in) | many |

### RegulatoryStatus

| Item | Value |
|---|---|
| Meaning | The jurisdiction-specific standing of exactly one subject. Only APPROVAL is approval |
| Archetype, labels | VersionedState; `["RegulatoryStatus","VersionedState"]` |
| uid token | `regulatory-status` (catalog primary-label token; `reg-status` is the fixture alias) |
| Identity keys | uid; a natural key is not unique (two episodes of one standing may exist) |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | live; round 0005; S1–S11 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `stateType` | String! | no | | op |
| `payloadHash` | String! | no | | op |
| `effectiveFrom`, `effectiveTo` | DateTime | yes | source-stated payload | obs |
| `statusKind` | RegulatoryStatusKind! | no | closed | asr (agency) or inferred (BellLabs normalization, with assertion) |
| `jurisdiction` | String! | no | | obs |
| `scopeText` | String | yes | verbatim scope (indication, food categories) | obs |
| `productCode` | String | yes | SAF, QPN | obs |
| `pcccAuthorized` | Boolean | yes | null = not stated | obs |
| `legalBasisCitation` | String | yes | answer text | obs |
| `statusCodeVerbatim` | String | yes | live migration only | obs |

Edges:

| Field | Relationship | Class, cardinality |
|---|---|---|
| `statusOf` | `STATUS_OF` | asserted, exactly_one distinct subject (V-333r) |
| `resultsFromResponse` | `RESULTS_FROM_RESPONSE` | structural, zero_or_one; required for APPROVAL |
| `underLegalBasis` | `UNDER_LEGAL_BASIS` | structural, exactly_one |
| `underLegalBasisVersion` | `UNDER_LEGAL_BASIS_VERSION` | structural, zero_or_one; dependency semantics, V-334r |
| `issuedBy` | `ISSUED_BY` | structural, exactly_one |
| `legacyHeldBy` | `HAS_REGULATORY_STATUS` (in) | derived |

### OrphanDesignation

| Item | Value |
|---|---|
| Meaning | An orphan designation. `statusKind` is always DESIGNATION (V-321). Never approval |
| Archetype, labels | VersionedState; `["OrphanDesignation","RegulatoryStatus","VersionedState"]` |
| uid token | `regulatory-status` (W13-SR-02) |
| Fields | as RegulatoryStatus without `productCode`, `pcccAuthorized`, `statusCodeVerbatim`; plus `designationId`, `indication`, `designatedNameVerbatim` (obs) |
| Edges | `designationFor`, the GraphQL name for stored `STATUS_OF`; subject IngredientMaterial \| MaterialMixture \| StudyIntervention \| Product |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | S10 |

### DrugApproval

| Item | Value |
|---|---|
| Meaning | An NDA/BLA approval. `statusKind` is always APPROVAL (V-321) |
| Archetype, labels | VersionedState; `["DrugApproval","RegulatoryStatus","VersionedState"]` |
| uid token | `regulatory-status` |
| Fields | `applicationNumber`, `indication` (obs) |
| Edges | `approvalFor`, the GraphQL name for `STATUS_OF`; same subject range as OrphanDesignation; `resultsFromResponse` is required (V-336) |
| Module, maturity | regulatory_and_ip; PROVISIONAL |
| Sources | S11 |

### RegulatoryInspection (CANDIDATE)

| Item | Value |
|---|---|
| Meaning | An agency inspection of one facility over an interval |
| Archetype, labels | Occurrence; `["RegulatoryInspection","Occurrence"]` |
| uid token | `regulatory-inspection` (W13-SR-04) |
| Identity keys | uid; natural key (agency, facility, start date). Two letters that describe it resolve to one node; conflicting statements stay as assertions |
| Not carried | Classification: it is per project area, so it is an assertion `INSPECTION_CLASSIFIED_AS` (candidate predicate). Findings: assertions `INSPECTION_FOUND_VIOLATION` with locators in the warning letter (a Source). |
| Module, maturity | regulatory_and_ip; CANDIDATE (CQ-MF-C01) |
| Sources | S17–S19 |

Properties:

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| `occurrenceType` | String! | no | | op |
| `startedAt` | DateTime | yes | resolved from accepted assertions | der |
| `endedAt` | DateTime | yes | null while sources conflict | der |
| `jurisdiction` | String! | no | | obs |
| `inspectionScopeText` | String | yes | | obs |
| `form483Issued` | Boolean | yes | null = not stated, never false by default | obs |
| `form483IssuedAt` | DateTime | yes | | obs |

Edges:

| Field | Relationship | Class, cardinality |
|---|---|---|
| `inspectedFacility` | `INSPECTED_FACILITY` | asserted, exactly_one |
| `conductedBy` | `CONDUCTED_BY` | structural, exactly_one |

## Relationship types (all owned by W13)

No relationship-property type is owned by W13. The W00 types are reused by name.

| Type | Domain → range | Class | Cardinality | Properties | Notes |
|---|---|---|---|---|---|
| `UNDER_PATHWAY` | RegulatorySubmission → RegulatoryPathway | structural | exactly_one | none | V-W13-04 |
| `UNDER_LEGAL_BASIS_VERSION` (NEW) | RegulatorySubmission \| RegulatoryStatus → RegulatoryPathwayVersion | structural | zero_or_one | none | On a status: dependency (V-334r). On a submission: filing regime. V-W13-05 |
| `SUBMITTED_BY` | RegulatorySubmission → Organization | asserted | one_or_more over time | AssertedEdgeProperties | A consultant who files on behalf of a notifier is not the submitter |
| `SUBMISSION_ABOUT` | RegulatorySubmission → RegulatorySubjectTarget | asserted | one_or_more | AssertedEdgeProperties | V-W13-01 |
| `SUPERSEDES_SUBMISSION` | RegulatorySubmission → RegulatorySubmission | asserted | zero_or_one | AssertedEdgeProperties | Resubmission chains |
| `SUBMISSION_HAS_RESPONSE` | RegulatorySubmission → RegulatoryResponse | structural | many / response exactly_one | none | V-W13-09 |
| `ISSUED_BY` | RegulatoryResponse \| RegulatoryStatus → RegulatoryAgency | structural | exactly_one | none | Live RoleMetadata dropped |
| `STATUS_OF` | RegulatoryStatus (incl. specializations) → RegulatorySubjectTarget | asserted | exactly one distinct subject; one current episode | AssertedEdgeProperties | INV-304, V-323, V-333r; GraphQL names `statusOf` / `designationFor` / `approvalFor` |
| `RESULTS_FROM_RESPONSE` | RegulatoryStatus → RegulatoryResponse | structural | zero_or_one | none | V-320a, V-336 |
| `UNDER_LEGAL_BASIS` | RegulatoryStatus → RegulatoryPathway | structural | exactly_one | none | V-320b |
| `HAS_PATHWAY_VERSION` (NEW) | RegulatoryPathway → RegulatoryPathwayVersion | structural, bitemporal_attachment | many; EXCLUSIVE per pathway (W13-SR-05) | StateEpisodeProperties; `assertionUid` expected | V-W13-06 |
| `HAS_REGULATORY_STEP` | RegulatoryPathway → RegulatoryStep | structural | many | StructuralEdgeProperties (`orderIndex`) | live OrderingMetadata replaced |
| `OVERSEES` | RegulatoryAgency → RegulatoryPathway | structural | many | StructuralEdgeProperties | live RoleMetadata replaced |
| `INSPECTED_FACILITY` (CANDIDATE) | RegulatoryInspection → Facility | asserted | exactly_one | AssertedEdgeProperties | V-W13-07, V-W13-11 |
| `CONDUCTED_BY` (CANDIDATE) | RegulatoryInspection → RegulatoryAgency | structural | exactly_one | none | V-W13-11 |
| `HAS_REGULATORY_STATUS` (legacy) | Product → RegulatoryStatus | derived | many | DerivedEdgeProperties; `derivationRule: W13-DR-01` + `derivedFromAssertionUids` (the STATUS_OF assertions); never `projectionOfAssertionUid` (QS-4a would flag a predicate mismatch) | V-W13-08; read-only |
| `FOLLOWS_PATHWAY` (legacy) | Product → RegulatoryPathway | derived | many | DerivedEdgeProperties; `W13-DR-02` from SUBMISSION_ABOUT assertions | V-W13-08; read-only; never evidence of a favourable response |
| ~~`DESIGNATION_FOR`~~, ~~`APPROVAL_FOR`~~ | — | — | — | — | Not stored types. They are field names over `STATUS_OF` (W13-D05) |

### Derivation rules

- **W13-DR-01.** For each accepted `STATUS_OF` Assertion `a` with subject `s:RegulatoryStatus` and object `p:Product`, where `s.statusKind <> 'ESTABLISHMENT_REGISTRATION'`: write `(p)-[:HAS_REGULATORY_STATUS {derivationRule:'W13-DR-01', derivedFromAssertionUids:[a.uid], derivedAt}]->(s)`. Regenerate whenever `a` is superseded.
- **W13-DR-02.** For each accepted `SUBMISSION_ABOUT` Assertion `a` with subject `sub` (`UNDER_PATHWAY` `w`) and object `p:Product`: write `(p)-[:FOLLOWS_PATHWAY {derivationRule:'W13-DR-02', derivedFromAssertionUids:[a.uid]}]->(w)`.
- **Pathway projections.**
  - `legalBasisCitation` comes from the version whose current episode (`recordedTo IS NULL`) covers now.
  - `effectiveFrom` = min `validFrom` over current episodes.
  - `effectiveTo` = `validTo` of the latest current episode when every current episode is closed; otherwise null.

## Enums (owned; values frozen at the catalog)

| Enum | Values | Owner note |
|---|---|---|
| `RegulatoryStatusKind` | APPROVAL, CLEARANCE, DE_NOVO_AUTHORIZATION, DESIGNATION, ESTABLISHMENT_REGISTRATION, NOTIFICATION_ON_FILE, ENFORCEMENT_DISCRETION, WITHDRAWN, REVOKED | Only APPROVAL is approval. The open question about an EU authorisation kind is W13-SR-03. |
| `RegulatoryResponseKind` | 22 catalog values (per-pathway lists in the SDL description) | Proposed additions: NDI_FILING_ACKNOWLEDGED (SR-06), NOVEL_FOOD_AUTHORISED (SR-03) |
| `PathwayKind` | NDI_NOTIFICATION, GRAS_NOTICE, PREMARKET_NOTIFICATION_510K, DE_NOVO, PMA, NDA, BLA, ORPHAN_DESIGNATION, FOOD_FACILITY_REGISTRATION, DEVICE_ESTABLISHMENT_REGISTRATION, COMPOUNDING_503B_BULKS_POLICY, LDT_POLICY | Proposed addition: NOVEL_FOOD_AUTHORISATION (SR-03) |

## Union

`RegulatorySubjectTarget = Product | ProductVariant | IngredientMaterial | AlgorithmVersion | AssayVersion | Facility | MaterialMixture | StudyIntervention`.

The members come from W04, W02, W07, W01 and W09. The per-edge restrictions are in the SDL description and enforced by V-W13-01. A union with AssertedEdgeProperties builds under 7.6.3, and its `…Connection.edges.properties` resolve against the fixture database (verified).
