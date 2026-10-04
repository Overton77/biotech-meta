# W14 model cards

Conventions. Every node card carries the contract B2 base fields (`id`, `uid`, `name`, `description`, `mongoResearchRunId`, `createdAt`, `updatedAt`, `privacyClass`, `maturity`, `schemaVersion`) and is not repeated below. Privacy is PUBLIC for every W14 element: office and court records and filed agreements are public. A license whose terms came only from a confidential source would be INTERNAL, but no such case exists in scope. "Kind" is asserted (A), observed (O), calculated (C), inferred (I) or operational (Op). uid tokens are **proposed** (W14-SR-01). Temporal behaviour: InformationArtifacts are immutable once captured. VersionedStates are immutable payloads; their validity comes from asserted episodes (`asserted_edge` profile: one edge per recorded-time episode, closed by a single write of `recordedTo`).

---

## PatentFamily

- **Meaning:** a patent family **under one stated family definition**. Not a right, not a status holder, and membership never implies coverage or assignment.
- **Archetype / labels / token:** Entity; `["PatentFamily","Entity"]`; `hu:patent-family:<opaque>`.
- **Module / maturity:** regulatory_and_ip; PROVISIONAL.
- **Identity keys:** uid. Where public, the family `Identifier` (scheme `DOCDB_FAMILY_ID` issuer EPO, or `INPADOC_FAMILY_ID`) with `familyIdentifier` as its materialized key. Uniqueness (`familyDefinition`, `familyIdentifier`) when the latter is non-null (07-operations.md). Two definitions give two nodes, compared by `EquivalenceAssessment {OVERLAPPING_SCOPE}`.

| Property | Type | Null | Meaning / value-state | Kind |
|---|---|---|---|---|
| entityType | String! | no | 'PatentFamily' | Op |
| familyDefinition | String! (candidate enum PatentFamilyDefinition: DOCDB_SIMPLE, INPADOC_EXTENDED, SOURCE_DISPLAYED, CURATED) | no | membership rule | A |
| familyIdentifier | String | yes = no public id for this definition | materialized key | A |
| title | String | yes | presentation | O |

| Edge | Dir | Range | Class | Card. | Props |
|---|---|---|---|---|---|
| FAMILY_HAS_APPLICATION | OUT | PatentApplication | structural | one_or_more | StructuralEdgeProperties (`orderIndex`, `notes`) |
| HAS_IDENTIFIER | OUT | Identifier | asserted | many | IdentifierLinkProperties |
| ASSIGNED_PATENT | IN | Organization | asserted | many | AssertedEdgeProperties |
| LICENSE_COVERS | IN | PatentLicense | asserted | many | AssertedEdgeProperties |

Sources: S1 (SOURCE_DISPLAYED family). CQs: C05, C02, EC-01.

---

## PatentApplication

- **Meaning:** one application at one office (national, regional, PCT, provisional), as filed or published. Immutable. Its claims as filed or published are separate `PatentClaim` nodes. Status lives in `IpRightStatus`.
- **Archetype / labels / token:** InformationArtifact; `["PatentApplication","InformationArtifact"]`; `hu:patent-application:<opaque>`.
- **Identity:** uid; `officeKey` = `<jurisdiction>:<application number without separators>` (unique). Identifier records: `US_PATENT_APPLICATION_NUMBER`/USPTO, `EP_APPLICATION_NUMBER`/EPO, `PCT_APPLICATION_NUMBER`/WIPO, publication numbers (`US_PATENT_PUBLICATION_NUMBER`). The same digits under another issuer are another Identifier.

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| artifactType | String! | no | 'PatentApplication' | Op |
| publishedAt | DateTime | yes = unpublished or unknown | first publication (A1) | O |
| observedAt | DateTime | yes | capture instant | O |
| contentHash | String | yes | sha256 of the captured record | C |
| applicationNumber | String! | no | as printed | A |
| jurisdiction | String! | no | office code (WO for PCT) | A |
| officeKey | String! | no | materialized unique key | C |
| filingDate | Date | yes = unknown | office-stated | A |
| applicationKind | String (candidate enum PatentApplicationKind) | yes | NATIONAL, REGIONAL, PCT_INTERNATIONAL or PROVISIONAL | A |
| title | String | yes | as filed | O |
| applicantNamesVerbatim | [String!] | yes = not captured | as printed; never the current owner | O |
| inventorNamesVerbatim | [String!] | yes | as printed; not Person identity, not ownership | O |

| Edge | Dir | Range | Class | Card. | Props |
|---|---|---|---|---|---|
| FAMILY_HAS_APPLICATION | IN | PatentFamily | structural | many (one per definition) | StructuralEdgeProperties |
| APPLICATION_GRANTED_AS | OUT | GrantedPatent | asserted | zero_or_one per grant | AssertedEdgeProperties |
| HAS_PATENT_CLAIM | OUT | PatentClaim | structural | many | StructuralEdgeProperties |
| HAS_IDENTIFIER | OUT | Identifier | asserted | one_or_more | IdentifierLinkProperties |
| ASSIGNED_PATENT | IN | Organization | asserted | many | AssertedEdgeProperties |
| LICENSE_COVERS | IN | PatentLicense | asserted | many | AssertedEdgeProperties |
| IP_STATUS_OF | IN | IpRightStatus | asserted (candidate) | many episodes | AssertedEdgeProperties |

Sources: S1, S3. CQs: C05, C01.

---

## GrantedPatent

- **Meaning:** one grant publication at one office (number and kind code). In force, expiry, lapse or surrender are statuses, not properties. Claim validity is a claim-level status.
- **Archetype / labels / token:** InformationArtifact; `["GrantedPatent","InformationArtifact"]`; `hu:granted-patent:<opaque>`.
- **Identity:** uid; `officeKey` = `<jurisdiction>:<digits>` without the kind code (unique). A reissue (RE…) or reexamination certificate is a further artifact.

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| artifactType | String! | no | 'GrantedPatent' | Op |
| publishedAt / observedAt / contentHash | | yes | archetype | O/C |
| patentNumber | String! | no | as printed | A |
| kindCode | String | yes | B1, B2, E … | A |
| jurisdiction | String! | no | office | A |
| officeKey | String! | no | unique key | C |
| grantDate | Date | yes | stated | A |
| title | String | yes | | O |
| assigneeNamesVerbatim | [String!] | yes = face page not captured | printed at grant | O |
| inventorNamesVerbatim | [String!] | yes | printed | O |

Edges: APPLICATION_GRANTED_AS (IN, exactly_one, asserted); HAS_PATENT_CLAIM (OUT, structural, one_or_more); HAS_IDENTIFIER; ASSIGNED_PATENT (IN); LICENSE_COVERS (IN); IP_STATUS_OF (IN, candidate). Sources: S1, S2, S4, S5. CQs: C01, C02, EC-01.

---

## PatentClaim

- **Meaning:** one numbered claim of one publication (application or grant), with verbatim text and NFC-WS1 hash. What it reads on is a `PATENT_CLAIMS` assertion. Validity is an `IpRightStatus` episode (`CLAIM_*`). Never an efficacy finding.
- **Archetype / labels / token:** InformationArtifact; `["PatentClaim","InformationArtifact"]`; `hu:patent-claim:<opaque>`; `@fulltext PatentClaimText(claimText)`, used to find claims that recite a substance name. A curator then writes `PATENT_CLAIMS`.
- **Identity:** uid; natural key (parent officeKey, kind of parent, claimNumber), enforced by application validation (07). `claimTextHash` detects amendment between the filed and granted versions.

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| claimNumber | Int! | no | | A |
| claimKind | String! (candidate enum PatentClaimKind: INDEPENDENT, DEPENDENT) | no | | A |
| dependsOnClaimNumbers | [Int!] | yes | empty for independent | A |
| claimText | String | yes = not captured | verbatim | O |
| claimTextHash | String! | no | sha256 NFC-WS1 | C |
| claimTextNormalization | String | yes | 'NFC-WS1' | Op |

Edges: HAS_PATENT_CLAIM (IN from PatentApplication or GrantedPatent; exactly one parent in total, V-W14-06); LICENSE_COVERS (IN); IP_STATUS_OF (IN). Sources: S1 (claims 1–3 hashes `sha256:81e2351c…a5fe`, `sha256:894792f2…d21e`, `sha256:40dc15ab…cac2`). CQs: C01, C03.

---

## PatentLicense

- **Meaning:** the terms of one license agreement version. Parties and coverage are asserted episodes. Not ownership, not a study role, not efficacy, not validity.
- **Archetype / labels / token:** VersionedState; `["PatentLicense","VersionedState"]`; `hu:patent-license:<opaque>`.
- **Identity:** uid; replay identity by `payloadHash` over the payload fields. An amendment is a new node. The old node's LICENSES_PATENT / LICENSE_COVERS assertions are bounded by `SUPERSEDES {VALIDITY_BOUNDED}` between assertions (never state→state, V-507).

| Property | Type | Null | Value-state semantics | Kind |
|---|---|---|---|---|
| stateType | String! | no | 'PatentLicense' | Op |
| payloadHash | String! | no | sha256 canonical JSON | C |
| effectiveFrom / effectiveTo | DateTime | yes = unknown/not stated | source payload; query validity from episodes | A |
| agreementTitle | String | yes | | A |
| exclusive | Boolean | **null = unknown or not reported, never false** | | A |
| exclusivityReportedStatus | ReportedStatus (W00) | null = not assessed | NOT_REPORTED = withheld or redacted in source | A |
| fieldOfUse | String | null + status | verbatim | A |
| fieldOfUseReportedStatus | ReportedStatus | | | A |
| territory | String | | verbatim | A |
| territoryJurisdictions | [String!] | | ISO codes or 'WORLDWIDE' | C (normalized) |
| territoryReportedStatus | ReportedStatus | | | A |
| sublicensable | Boolean | null = unknown | | A |
| coverageRuleText | String | | verbatim rights definition; never expanded | A |
| termText | String | | verbatim term clause | A |

| Edge | Dir | Range | Class | Card. | Props |
|---|---|---|---|---|---|
| LICENSE_COVERS | OUT | PatentLicenseTarget | asserted | one_or_more | AssertedEdgeProperties |
| LICENSES_PATENT | IN | Organization (licensee) | asserted | one_or_more | AssertedEdgeProperties |
| GRANTS_PATENT_LICENSE | IN | Organization (licensor) | asserted, **CANDIDATE** | zero_or_one per episode | AssertedEdgeProperties |

Sources: S2, S3, S4. CQs: C02, C03, EC-01.

---

## Trademark

- **Meaning:** a trademark **right in one jurisdiction** (one office filing or registration). Not a ConsumerBrand, not a BrandedIngredientMaterial, not a cross-jurisdiction "mark".
- **Archetype / labels / token:** Entity; `["Trademark","Entity"]`; `hu:trademark:<opaque>`.
- **Module:** products_and_formulations (T-001: stays; W14 writes the SDL).
- **Identity:** uid; `officeKey` = `<jurisdiction>:<application serial>` (stable from filing; for a Madrid IR `WO:<IR number>`). Identifiers `USPTO_TM_SERIAL`, `USPTO_TM_REGISTRATION`, `WIPO_MADRID_IR`. A related property's number listed on an office record is the identifier of **another** Trademark (V-W14-08).

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| entityType | String! | no | 'Trademark' | Op |
| markText | String! | no | literal elements; never identity | A |
| jurisdiction | String! | no | office jurisdiction | A |
| applicationSerialNumber | String | yes | as printed | A |
| registrationNumber | String | yes = not registered or unknown | as printed | A |
| officeKey | String! | no | unique | C |
| markDrawingKind | String (candidate enum MarkDrawingKind) | yes | | A |

Edges: OWNS_TRADEMARK (IN, Organization, asserted, episodes); MARKETED_UNDER_MARK (IN, BrandedIngredientMaterial, asserted); HAS_IDENTIFIER (OUT); IP_STATUS_OF (IN, candidate). Goods/services and classes are on the status episode (`scopeText`, `niceClasses`) because amendments change them. Sources: S6, S7. CQs: C04, EC-02, MF-01.

---

## IpRightStatus (CANDIDATE)

- **Meaning:** a bounded legal status of one IP right or claim. Not RegulatoryStatus (INV-010). Asserted by the office, a court, PTAB, the owner or an aggregator. The asserter is on the `IP_STATUS_OF` assertion.
- **Archetype / labels / token:** VersionedState; `["IpRightStatus","VersionedState"]`; `hu:ip-status:<opaque>`.
- **Failing case without it:** F-STATUS-01 (Q-01: an "Active" patent with claims held invalid would be returned as enforceable). Also the renewal late arrival, the lapse and expiry bounds (Q-02, Q-08), and the correction (Q-11).

| Property | Type | Null | Meaning | Kind |
|---|---|---|---|---|
| stateType, payloadHash | String! | no | archetype | Op/C |
| effectiveFrom / effectiveTo | DateTime | null = unknown (never "perpetual") | source-stated | A |
| statusKind | String! (candidate enum IpRightStatusKind, 17 values) | no | CLAIM_* only on PatentClaim (V-W14-07) | A |
| jurisdiction | String! | no | | A |
| statusTextVerbatim | String | yes | source wording | O |
| scopeText | String | yes | goods/services as amended; claims affected | A |
| niceClasses | [Int!] | yes | trademarks | A |
| legalBasisCitation | String | yes | e.g. 35 U.S.C. § 101 | A |
| proceedingReference | String | yes | docket or appeal number | A |

Edge: IP_STATUS_OF (OUT) → IpRightStatusSubjectTarget (PatentApplication, GrantedPatent, PatentClaim, Trademark); asserted; exactly_one; AssertedEdgeProperties. predicateExclusivity proposal: NONEXCLUSIVE (kinds can coexist, for example in force plus under reexamination). The definite in-force/terminal conflict check is V-W14-14.

---

## Unions

- **PatentLicenseTarget** = PatentFamily | PatentApplication | GrantedPatent | PatentClaim (registry W14). Used by `PatentLicense.covers`.
- **IpRightStatusSubjectTarget** (CANDIDATE) = PatentApplication | GrantedPatent | PatentClaim | Trademark. Used by `IpRightStatus.statusOf`.

## Relationship types (all reuse W00 property types)

| Type | From → To | Class | Cardinality | Properties | Catalog | Forbidden-implication guard |
|---|---|---|---|---|---|---|
| FAMILY_HAS_APPLICATION | PatentFamily → PatentApplication | structural | 1..n per family | StructuralEdgeProperties | yes | membership ≠ coverage (V-W14-05) |
| APPLICATION_GRANTED_AS | PatentApplication → GrantedPatent | asserted | 0..1 per grant | AssertedEdgeProperties | yes | — |
| HAS_PATENT_CLAIM | PatentApplication or GrantedPatent → PatentClaim | structural | exactly one parent | StructuralEdgeProperties | yes | V-W14-06 |
| LICENSE_COVERS | PatentLicense → PatentLicenseTarget | asserted | 1..n | AssertedEdgeProperties | yes | `[LICENSE_COVERS, OWNS_STUDY]` via V-W14-01 |
| MARKETED_UNDER_MARK | BrandedIngredientMaterial → Trademark | asserted | many | AssertedEdgeProperties | yes | — |
| OWNS_TRADEMARK | Organization → Trademark | asserted (organizations predicate) | many episodes | AssertedEdgeProperties | predicate | proposed `[OWNS_TRADEMARK, SUPPLIES_INGREDIENT_MATERIAL|MARKETS_PRODUCT|MANUFACTURES_PRODUCT]` (V-W14-12) |
| ASSIGNED_PATENT | Organization → PatentFamily, PatentApplication or GrantedPatent | asserted | many episodes | AssertedEdgeProperties | predicate | proposed `[ASSIGNED_PATENT, GRANTS_PATENT_LICENSE]` (Q-05) |
| LICENSES_PATENT | Organization → PatentLicense | asserted | many | AssertedEdgeProperties | predicate | `[LICENSES_PATENT, OWNS_STUDY]` (V-W14-01) |
| GRANTS_PATENT_LICENSE | Organization → PatentLicense | asserted, **CANDIDATE** | 0..1 per episode | AssertedEdgeProperties | new | — |
| IP_STATUS_OF | IpRightStatus → IpRightStatusSubjectTarget | asserted, **CANDIDATE** | exactly one | AssertedEdgeProperties | new | patent-level ≠ claim-level (V-W14-07) |
| (PATENT_CLAIMS) | PatentClaim, GrantedPatent, PatentApplication or PatentFamily → IngredientMaterial, ChemicalSubstance, ChemicalForm, Product, ProductVariant or StudyIntervention | **assertion only** (no projected edge) | — | — | forbidden-implication premise | `[PATENT_CLAIMS, PROVES_EFFICACY]` (V-W14-02) |

## Enums

W14 owns no enum in the registry and adds none to the fragment. Requested closed vocabularies (W14-SR-02), shown as Strings in the SDL:

| Requested enum | Values | Used by |
|---|---|---|
| PatentFamilyDefinition | DOCDB_SIMPLE, INPADOC_EXTENDED, SOURCE_DISPLAYED, CURATED | PatentFamily.familyDefinition |
| PatentApplicationKind | NATIONAL, REGIONAL, PCT_INTERNATIONAL, PROVISIONAL | PatentApplication.applicationKind |
| PatentClaimKind | INDEPENDENT, DEPENDENT | PatentClaim.claimKind |
| IpRightStatusKind | PENDING, PUBLISHED, ALLOWED, GRANTED_IN_FORCE, REGISTERED, RENEWED, ABANDONED, WITHDRAWN, LAPSED, EXPIRED, CANCELLED, SURRENDERED, CLAIM_HELD_INVALID, CLAIM_HELD_UNPATENTABLE, CLAIM_CANCELLED, CLAIM_CONFIRMED, DECISION_VACATED | IpRightStatus.statusKind |
| MarkDrawingKind | STANDARD_CHARACTER, SPECIAL_FORM, OTHER | Trademark.markDrawingKind |

## Deferred or candidate elements kept out of the fragment

| Element | Why deferred | What would admit it |
|---|---|---|
| `NAMED_INVENTOR` (Person → PatentApplication or GrantedPatent) | No CQ fails; names are on the artifact | A CQ about an inventor's conflicts (CQ-CL-05 extension) plus a fixture where inventorship is wrongly read as IP interest |
| `LicenseAgreement` Entity grouping versions; `SUBLICENSE_OF` | Amendments work as new states with assertion-level supersession | A CQ needing the chain of amendments or the parent-license scope limit |
| Product-level mark use (`Product`/`ConsumerBrand` MARKETED_UNDER_MARK) | Catalog edge is material-only | W04/W01 seam with a label-mark CQ |
| Litigation / office-action Occurrences | Outcomes suffice (`proceedingReference`) | A CQ about litigation history itself |
| `PatentFamily`-level status | Families have no legal status | — |
