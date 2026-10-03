# Property Cards (0.2.0)

Status: provisional, merged 2026-10-03 from the five lane fragments

Each card follows the mission's property standard: name, definition, type, cardinality, nullability, units or identifier namespace, example, counterexample, meaning of absence, expected source, kind (asserted, observed, calculated, inferred, operational), temporal behaviour, provenance, query use, privacy class, and the placement decision. Cards are grouped by the lane that drafted them and the rounds they serve; where integration changed a card, the change is listed first.

Integration changes that override card text below:

- `validTimeBasis` (single) is replaced by `validFromBasis` and `validToBasis` with `validFromPrecision` and `validToPrecision` (round 0007). A basis is required only when its bound is non-null; a null bound with no basis reads as UNKNOWN.
- Asserted edges carry `assertionUid`; `projectionOfAssertionUid` is reserved for derived edges.
- `Assertion.status` is capture fidelity (projection of CAPTURE_FIDELITY adjudications and SUPERSEDES), never truth; `Adjudication.adjudicationKind` distinguishes CAPTURE_FIDELITY from SUPPORT.
- `contentHash` on Assertion and `contentHashBasis` on SourceSnapshot are required for new writes by the ingestion service and reported, not failed, when absent on legacy or fixture records (V-514b, V-111b).
- `PrivateScope` is not a production label; a private node is recognised by the `hu:private-` uid prefix and `privacyClass`.
- `RECOMMENDS_PRODUCT` is named `RECOMMENDS` (the live edge name).
- `SUPPORTED_BY` and `CONTRADICTED_BY` are structural; the six AssayVersion payload edges, `MEASURES_BIOMARKER`, `QUANTIFIES`, `VERSION_OF_ALGORITHM`, `OUTPUTS_METRIC`, `FOR_ASSAY_VERSION` and `FOR_METRIC` are structural.
- `selectorKind` gains SECTION and WHOLE_SNAPSHOT (coarse locators); `contentHashBasis` gains SYNTHETIC_FIXTURE (fixtures only).


## Round 0009: kernel and access properties

Cards for the properties the query shapes need and `catalog/schema.yaml` 0.1.0 lacks. Format follows the mission's property standard. Placement uses the seven options: node property, relationship property, referenced entity, versioned state, assertion, evidence assessment, derived projection. Several of these properties already appear in `ontology-lab/starter-property-model.md` but not in the catalog. Those cards promote them and say why a query needs them.

Kernel-change requests (K-n) are argued with their failing case in `round-0009-question-catalog-and-access-tiers.md`.

Privacy classes: public, internal, private-personal. No property below is private-personal; the private partition's properties belong to Lane 5.

### P-1 `recordedFrom`, `recordedTo` on asserted edges and `HAS_STATE` (K-1)

| Field | Value |
|---|---|
| Placement | Relationship property. The system-time episode belongs to one attachment, shares its life, and is not independently disputed. |
| Definition | `recordedFrom`: inclusive instant at which the system began to believe this attachment. `recordedTo`: exclusive instant at which it stopped. |
| Type, cardinality | `DATETIME` (zoned), one each. |
| Nullability | `recordedFrom` required (V-101). `recordedTo` null means currently believed. |
| Units | Instants in UTC. |
| Example | `{recordedFrom: 2026-01-10T00:00Z, recordedTo: 2026-06-20T00:00Z}` on the first `HAS_FORMULATION_VERSION` edge in the QS-2 fixture. |
| Counterexample | Setting `recordedTo` because the world changed (the fact ended). That is `validTo`. Also: setting `recordedFrom` to a date earlier than the system knew, to look consistent. |
| Meaning of absence | `recordedFrom` null: legacy edge, not answerable in an R-view (returned as `LEGACY_UNDATED`). `recordedTo` null: currently believed. |
| Expected source | System-assigned at commit. Never taken from a source. |
| Kind | Operational. |
| Temporal behavior | A correction closes `recordedTo` on the old edge and creates a new edge. It never edits valid time on the old edge. |
| Provenance | The authorizing assertion via `assertionUid`. |
| Query use | QS-2b, QS-2c, QS-5b; V-101, V-102, V-108. |
| Privacy class | public. |

### P-2 `assertionUid` on asserted edges (K-1)

| Field | Value |
|---|---|
| Placement | Relationship property: the pointer from an edge to the assertion that authorizes it. |
| Definition | `uid` of the one `Assertion` that makes this asserted edge authoritative. |
| Type, cardinality | `STRING` (uid), exactly one. |
| Nullability | Required on asserted edges (V-101). |
| Namespace | Catalog uid. |
| Example | `hu:assertion:demo-f1-attach-v2`. |
| Counterexample | A pointer to a derived-edge rule. That is `derivationRule`. A pointer to an adjudication. That is not an assertion. |
| Meaning of absence | The edge has no recorded authority; it fails V-101 and cannot be used in an answer. |
| Expected source | Written with the edge by the ingestion service. |
| Kind | Operational. |
| Temporal behavior | Fixed for the edge's life. A new authorizing assertion means a new edge. |
| Provenance | It is the provenance link. |
| Query use | QS-2b (support lookup), QS-4a, QS-4b. |
| Privacy class | public. |

### P-3 `projectionOfAssertionUid` on derived edges

| Field | Value |
|---|---|
| Placement | Relationship property on a derived edge that is a regenerable one-to-one projection of one asserted relationship. |
| Definition | `uid` of the assertion the edge projects. The assertion's predicate must equal the edge type, and its subject and object must be the edge's endpoints. |
| Type, cardinality | `STRING`, exactly one when the edge is a 1:1 projection. |
| Nullability | Required unless `derivationRule` and `derivedFromAssertionUids` are present (P-4). |
| Example | An `ENDORSES_PRODUCT` projection citing an assertion with predicate `ENDORSES_PRODUCT`. |
| Counterexample | An `ENDORSES_PRODUCT` edge citing an `ADVISES_ORGANIZATION` assertion: a citation exists and the forbidden implication is reintroduced (QS-4a flags `FORBIDDEN_IMPLICATION_USED_AS_PREMISE`). |
| Meaning of absence | A multi-hop derived edge (use P-4) or an uncited edge (violation). |
| Expected source | The projection job. |
| Kind | Derived. |
| Temporal behavior | Regenerated when the assertion is superseded; the edge's own `recordedTo` closes. |
| Provenance | Names the assertion. |
| Query use | QS-4a, QS-4b; V-112. Already used by `V-004` and `V-007`. |
| Privacy class | public. |

### P-4 `derivationRule` and `derivedFromAssertionUids` on multi-hop derived edges (K-2)

| Field | Value |
|---|---|
| Placement | Relationship properties on a derived edge. The edge is a derived projection; its basis is a rule applied to several records. |
| Definition | `derivationRule`: identifier and version of the rule (for example `contains/v1`). `derivedFromAssertionUids`: the assertions the rule consumed. |
| Type, cardinality | `STRING`; `LIST<STRING>`, non-empty when `derivationRule` is set. |
| Example | `CONTAINS` from a variant to a material: rule `contains/v1` over the assertions that attach the formulation, attach the component and identify the material. |
| Counterexample | One `projectionOfAssertionUid` for `CONTAINS`. The edge rests on three assertions; one uid hides two. |
| Meaning of absence | A rule with no sources is invalid (`DERIVATION_WITHOUT_SOURCE_ASSERTIONS`). |
| Expected source | The derivation job. |
| Kind | Derived. |
| Temporal behavior | The edge is regenerated whenever a cited assertion is superseded; the old edge is closed, not edited. |
| Provenance | The rule version and cited assertions. |
| Query use | QS-4a; V-112. |
| Privacy class | public. |

### P-5 `validTimeBasis` (K-1)

| Field | Value |
|---|---|
| Placement | Node property on `Assertion` (and relationship property on asserted edges and `HAS_STATE`). It qualifies the valid-time bounds of the same record and shares its life. |
| Definition | How the non-null bounds of `validFrom` and `validTo` were obtained. |
| Type | Enum `ValidTimeBasis`: `SOURCE_STATED`, `OBSERVED`, `PUBLICATION_PROXY`, `INFERRED`, `UNKNOWN`. |
| Cardinality, nullability | One. Required when either bound is non-null (V-105, V-106). Null when both bounds are null. |
| Rule for mixed bases | When the two bounds differ in basis, store the weakest (order: `SOURCE_STATED` strongest, then `OBSERVED`, `PUBLICATION_PROXY`, `INFERRED`). Per-bound basis is an open question. |
| Example | A label that states "effective 2025-09-01": `SOURCE_STATED`. A start taken from the page's publication date: `PUBLICATION_PROXY`. |
| Counterexample | `validFrom` set to the retrieval date with basis `OBSERVED`. An observation shows the fact held then. It does not start the interval, so `validFrom` stays null. |
| Meaning of absence | Bounds, if present, have an unrecorded basis; the record fails V-105. |
| Expected source | The extractor or reviewer, from the source's wording. |
| Kind | Asserted (about how the time was derived). |
| Temporal behavior | Changes only with the bounds, through a new recorded episode. |
| Provenance | The same locator as the assertion. |
| Query use | QS-2a, QS-2b result columns; V-104 to V-107. |
| Privacy class | public. |

### P-6 `validTimePrecision`

| Field | Value |
|---|---|
| Placement | Same as P-5. |
| Definition | Precision of the stated bound. |
| Type | Enum `TimePrecision`: `INSTANT`, `DAY`, `MONTH`, `YEAR`, `INTERVAL`, `UNKNOWN`. |
| Nullability | Required when precision is coarser than the stored instant (for example a month). |
| Example | "Available from March 2026": `validFrom` 2026-03-01, precision `MONTH`. |
| Counterexample | Treating `2026-03-01` as the exact start when the source said only "March". |
| Meaning of absence | The stored instant is taken as exact. |
| Query use | Not yet used by the shapes. A V at day precision inside a coarse bound should be classified as uncertain at the boundary; that refinement is listed in `open-questions.md`. |
| Privacy class | public. |

### P-7 `Assertion.polarity` (K-4)

| Field | Value |
|---|---|
| Placement | Node property on `Assertion`. It is part of the proposition and shares its life. |
| Definition | Whether the proposition affirms, denies, mixes, or leaves open. |
| Type | Enum: `POSITIVE`, `NEGATIVE`, `MIXED`, `UNKNOWN`. |
| Nullability | Required (promoted from `starter-property-model.md`). |
| Example | "No stimulants are declared on the label" asserted by a covering source: `NEGATIVE` on the predicate `DECLARES_MATERIAL`. |
| Counterexample | Using `NEGATIVE` for "not reported". Not reported is a different state and has no assertion. |
| Meaning of absence | None allowed once required. |
| Query use | QS-7 (`ASSERTED_ABSENT`, `CONFLICTING`), QS-1a. |
| Privacy class | public. |

### P-8 `SUPERSEDES` relationship (K-4)

| Field | Value |
|---|---|
| Placement | Structural relationship, `(newer:Assertion)-[:SUPERSEDES]->(older:Assertion)`. |
| Definition | The newer assertion replaces the older as the system's belief. Both remain. |
| Rule | `newer.recordedAt >= older.recordedAt` (V-109). An assertion with `status` `SUPERSEDED` has at least one incoming `SUPERSEDES`. |
| Why a relationship and not `status` | `status` is overwritten, so it cannot answer "was this accepted on R". The relationship is append-only. |
| Failing case | Assertion accepted in January and rejected in May; a March as-of query reads the current `status` and gets the wrong answer. |
| Query use | QS-2a, QS-4b, QS-7. |
| Open | Lane 5 round 0007 may choose `recordedTo` on assertions instead. The shapes isolate this test in one `NOT EXISTS` block. |
| Privacy class | public. |

### P-9 Required fields of a cited `SourceSnapshot`

| Field | Value |
|---|---|
| Placement | Node properties on `SourceSnapshot` (an information artifact). |
| Properties | `contentHash` (hash of the captured content), `retrievedAt` (recorded time: when BellLabs fetched it), `observedAt` (the instant the source showed this content). |
| Rule | An `ACCEPTED` assertion's snapshot has all three (V-111). Closes `OPEN-QUESTIONS.md` Priority 0, item 5 in part. |
| Why two clocks | An as-of read at R may use only snapshots with `retrievedAt <= R`; confirmation of an open end uses `observedAt`. |
| Counterexample | A page re-scraped today whose content hash differs from the earlier capture: a new snapshot, not an update of the old one. |
| Meaning of absence | The locator cannot be reproduced; `SNAPSHOT_NOT_REPRODUCIBLE`. |
| Query use | QS-1a, QS-2a, QS-2b. |
| Privacy class | public. |

### P-10 `PrivateScope` marker label (K-5, owned by Lane 5)

| Field | Value |
|---|---|
| Placement | A label, not a property, so that every hop of a traversal can test it cheaply (`n:!PrivateScope`). |
| Definition | Carried by every node of the private user partition. |
| Rule | No shared node has a relationship to a `PrivateScope` node (V-113). Private-to-shared references use governed types only (V-114). `PrivateScope` nodes carry no label covered by a shared index (V-115). |
| Placement note | If Lane 5 chooses a separate database, the label is defence in depth. If it shares the database, the label is the only guard. |
| Privacy class | internal (the label itself reveals no content). |

### P-11 `AnswerRecord` properties (K-7, candidate)

| Property | Definition | Type | Null | Notes |
|---|---|---|---|---|
| `recordedAsOf` | R of the answer | `DATETIME` | no | Required (V-121). |
| `validAt`, `intervalStart`, `intervalEnd` | V or interval | `DATETIME` | yes | At least one viewpoint, or null for "no valid-time filter". |
| `schemaDigest` | sha256 of the catalog the query was bound to | `STRING` | no | Binds replay to a schema version. |
| `queryShapeId`, `queryShapeVersion` | e.g. `QS-3a`, `1` | `STRING` | id: no | Shape text is under change control. |
| `accessTier`, `traceDepth` | request fields | `STRING` | tier: no | Enums in `catalog-patch.yaml`. |
| `publishedAt` | when the answer was published | `DATETIME` | yes | |

Placement: an occurrence node, because it is something that happened (a publication) and has its own relationships (`CITES_ASSERTION`). Forbidden properties: `userUid`, `ownerUid`, `questionText`. A log of what a person asked reveals their interests and belongs to the private store. Kind: operational. Privacy class: public for a published answer; an ad hoc answer must not be stored here.

### P-12 Predicate exclusivity (K-6)

| Field | Value |
|---|---|
| Placement | Attribute of the predicate in the catalog registry (`assertedPredicates.exclusivity`), not of any record. |
| Definition | `EXCLUSIVE` with `scope` keys, or `NON_EXCLUSIVE`. |
| Example | `HAS_FORMULATION_VERSION`: `EXCLUSIVE` per subject and jurisdiction. `MARKETS_PRODUCT`: `NON_EXCLUSIVE`. |
| Counterexample | Declaring `SPONSORS_STUDY` exclusive: several sponsors are normal. |
| Meaning of absence | `NON_EXCLUSIVE` until a round states otherwise. |
| Query use | V-108 (`$exclusiveTypes`). Neo4j cannot enforce it, so it is service-enforced. |
| Privacy class | public. |

### P-13 `uid` on live GraphQL nodes

| Field | Value |
|---|---|
| Placement | Node property, additive to the live schema. |
| Definition | Catalog identity `hu:<type>:<opaque>`; the opaque segment equals the live `id`. |
| Type, nullability | `STRING`; nullable until backfilled, then required. |
| Example | A live `Product` with `id` `7c1e...` has `uid` `hu:product:7c1e...`. |
| Counterexample | A uid segment equal to a product name. |
| Meaning of absence | Not yet projected into the catalog. V-118 counts missing. |
| Kind | Operational. |
| Temporal behavior | Immutable. |
| Query use | Every shape binds nodes by `uid`. QS-8 returns both `uid` and live id. |
| Privacy class | public. |

### P-14 `uidTypeTokens` registry

Placement: catalog convention, not a record property. A map from primary label to the `<type>` segment of a uid. Absence of a token blocks projecting that label. Source of truth: `catalog-patch.yaml` `conventions.uidTypeTokens`. Counterexample: computing the token from the label name, which makes a label rename change identities.

## Rounds 0002 and 0003: studies, evidence, mechanisms

Each card follows the mission property standard. Grouped fields share one card only when they share definition source, lifecycle, and placement. Privacy class is `public` for every card: no Lane 2 property holds personal data (UserContext targets are referenced by uid only, Lane 5).

#### ApplicabilityDimension.dimension

- **Definition:** Which applicability dimension this judgement covers.
- **Type:** enum applicabilityDimension
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** DOSE
- **Counterexample:** 'dose ok' free text
- **Meaning of absence:** invalid node
- **Expected source:** BellLabs assessor or method
- **Kind:** operational
- **Temporal behavior:** immutable per node
- **Provenance:** assessment methodVersion
- **Query use:** V-204/V-205; CQ-EV-04 grouping
- **Privacy class:** public
- **Placement:** node property: identity-defining attribute of the dimension node

#### ApplicabilityDimension.dimensionClass

- **Definition:** Whether the dimension is CATEGORICAL, CONTINUOUS, or EXPLANATION_ONLY.
- **Type:** enum dimensionClass
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** CONTINUOUS for DOSE
- **Counterexample:** CONTINUOUS for COMPARATOR
- **Meaning of absence:** invalid
- **Expected source:** method definition (applicability-v0.1)
- **Kind:** operational
- **Temporal behavior:** fixed by method version
- **Provenance:** methodVersion
- **Query use:** V-207; composite eligibility
- **Privacy class:** public
- **Placement:** node property: fixed by dimension and method

#### ApplicabilityDimension.verdict

- **Definition:** Categorical judgement for the dimension.
- **Type:** enum applicabilityVerdict
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** UNKNOWN
- **Counterexample:** null meaning unknown; 'NO' meaning not assessed
- **Meaning of absence:** invalid; NOT_ASSESSED must be explicit
- **Expected source:** BellLabs assessment
- **Kind:** inferred
- **Temporal behavior:** new assessment version on change (recordedAt)
- **Provenance:** SUPPORTED_BY locators, CONSIDERS assertions
- **Query use:** CQ-EV-04 ordering, V-208b, V-209
- **Privacy class:** public
- **Placement:** evidence assessment: BellLabs judgement with its own provenance

#### ApplicabilityDimension.identityLevel

- **Definition:** For MATERIAL_IDENTITY, the strongest identity path established between evidence material and target.
- **Type:** enum materialIdentityLevel
- **Cardinality:** zero or one
- **Nullability:** null except MATERIAL_IDENTITY
- **Units / namespace:** n/a
- **Example:** SAME_SUBSTANCE_MATERIAL_UNRESOLVED
- **Counterexample:** SAME_BRANDED_MATERIAL_SAME_SPEC when only names match
- **Meaning of absence:** not a MATERIAL_IDENTITY node
- **Expected source:** graph paths + ResolutionHypothesis status
- **Kind:** inferred
- **Temporal behavior:** re-assessed when hypotheses resolve
- **Provenance:** SUPPORTED_BY, CONSIDERS
- **Query use:** V-208, V-208b; CQ-ID-06
- **Privacy class:** public
- **Placement:** evidence assessment

#### ApplicabilityDimension.evidenceValue / targetValue / unitCode

- **Definition:** Numeric amounts compared by a continuous dimension and their UCUM unit.
- **Type:** float, float, string
- **Cardinality:** zero or one each
- **Nullability:** null when not numeric or unknown
- **Units / namespace:** UCUM (mg, mg/d, d, /d)
- **Example:** 250.0 / 250.0 / mg
- **Counterexample:** 250 'mg NR' compared with 300 'mg/serving' without bases
- **Meaning of absence:** not extracted or not applicable; listed in missingFacts if needed
- **Expected source:** InterventionComponent, IngredientComponent, MechanismEvidenceContext
- **Kind:** observed (copied) values
- **Temporal behavior:** copy at assessment time; not updated in place
- **Provenance:** SUPPORTED_BY locators
- **Query use:** CQ-EV-04 display; ratio input
- **Privacy class:** public
- **Placement:** node property on the dimension: values as judged, frozen with the judgement

#### ApplicabilityDimension.evidenceQuantityBasis / targetQuantityBasis

- **Definition:** Per-day, per-dose, per-serving, per-kg basis of each side's amount.
- **Type:** enum quantityBasis
- **Cardinality:** zero or one each
- **Nullability:** null unless continuous
- **Units / namespace:** n/a
- **Example:** PER_DAY vs PER_SERVING
- **Counterexample:** assumed per day because a label shows per serving
- **Meaning of absence:** basis unknown: ratio must be null
- **Expected source:** Methods text; label serving size
- **Kind:** observed
- **Temporal behavior:** frozen with judgement
- **Provenance:** locators
- **Query use:** V-206
- **Privacy class:** public
- **Placement:** node property

#### ApplicabilityDimension.evidenceMassBasis / targetMassBasis

- **Definition:** Whether each amount is salt-form, active-moiety, or material mass.
- **Type:** enum massBasis
- **Cardinality:** zero or one each
- **Nullability:** null unless DOSE/EXPOSURE
- **Units / namespace:** n/a
- **Example:** UNSPECIFIED vs SALT_FORM
- **Counterexample:** assumes '250 mg NR' equals 250 mg NR chloride
- **Meaning of absence:** unknown: ratio must be null
- **Expected source:** Methods text; label declaration
- **Kind:** observed
- **Temporal behavior:** frozen with judgement
- **Provenance:** locators
- **Query use:** V-206; CQ-EV-06 missing facts
- **Privacy class:** public
- **Placement:** node property

#### ApplicabilityDimension.ratio

- **Definition:** targetValue / evidenceValue when bases match on both sides.
- **Type:** float
- **Cardinality:** zero or one
- **Nullability:** null when bases differ or values missing
- **Units / namespace:** dimensionless
- **Example:** 0.5 (500 mg product vs 1000 mg trial arm)
- **Counterexample:** 1.0 computed across salt vs unspecified bases
- **Meaning of absence:** not computable
- **Expected source:** calculated
- **Kind:** calculated
- **Temporal behavior:** recomputed only in a new assessment version
- **Provenance:** method version
- **Query use:** V-206; dose bands (deferred calibration)
- **Privacy class:** public
- **Placement:** derived projection inside the assessment; regenerable from values and bases

#### ApplicabilityDimension.missingFacts

- **Definition:** Specific facts whose absence makes the verdict UNKNOWN or PARTIAL.
- **Type:** list<string>
- **Cardinality:** zero or one list
- **Nullability:** empty list allowed; must be non-empty when UNKNOWN
- **Units / namespace:** n/a
- **Example:** ['mass basis of "NR" in the paper', 'label servings per day']
- **Counterexample:** 'more data needed'
- **Meaning of absence:** no known gap
- **Expected source:** assessor
- **Kind:** inferred
- **Temporal behavior:** frozen with judgement
- **Provenance:** assessor + method
- **Query use:** CQ-EV-06, CQ-RC-03
- **Privacy class:** public
- **Placement:** node property: answer payload; a list of strings suffices until gaps get identities

#### ApplicabilityDimension.evidenceCategory / targetCategory

- **Definition:** Categorical values compared (dosage form, route, comparator, endpoint class, population relation).
- **Type:** string from dimension-specific enum
- **Cardinality:** zero or one each
- **Nullability:** null for continuous-only dims
- **Units / namespace:** n/a
- **Example:** CAPSULE / CAPSULE
- **Counterexample:** 'pill'
- **Meaning of absence:** not captured
- **Expected source:** StudyIntervention, ProductVariant, EndpointClassification
- **Kind:** observed (copied)
- **Temporal behavior:** frozen
- **Provenance:** locators
- **Query use:** CQ-EV-04 display
- **Privacy class:** public
- **Placement:** node property

#### InterventionComponent.massBasis

- **Definition:** Whether the administered amount is expressed as salt-form, active-moiety, or material mass.
- **Type:** enum massBasis
- **Cardinality:** exactly one
- **Nullability:** non-null; UNSPECIFIED when the source does not say
- **Units / namespace:** n/a
- **Example:** UNSPECIFIED ('250 mg of NR')
- **Counterexample:** SALT_FORM inferred from the product label
- **Meaning of absence:** invalid (use UNSPECIFIED)
- **Expected source:** publication Methods, protocol
- **Kind:** observed
- **Temporal behavior:** state of the reported design; new state on correction
- **Provenance:** SUPPORTED_BY via USES_INTERVENTION_MATERIAL assertion locator
- **Query use:** V-221; DOSE dimension
- **Privacy class:** public
- **Placement:** node property: atomic, shares the component's lifecycle

#### InterventionComponent.quantityBasis (CHANGE)

- **Definition:** Per-day, per-dose, per-kg basis of quantity; now an enum.
- **Type:** enum quantityBasis
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** PER_DAY
- **Counterexample:** 'daily' free text
- **Meaning of absence:** invalid
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** as above
- **Provenance:** as above
- **Query use:** V-221, V-206
- **Privacy class:** public
- **Placement:** node property

#### InterventionComponent.verbatimDoseText

- **Definition:** Exact dose wording from the source.
- **Type:** string
- **Cardinality:** zero or one
- **Nullability:** null if not captured
- **Units / namespace:** n/a
- **Example:** '250 mg of NR (2 capsules x 125 mg)'
- **Counterexample:** normalized value only
- **Meaning of absence:** not captured
- **Expected source:** Methods, registry
- **Kind:** observed
- **Temporal behavior:** as above
- **Provenance:** locator
- **Query use:** audit; extraction QA
- **Privacy class:** public
- **Placement:** node property: preserves linguistic evidence beside normalized values

#### StudyIntervention.dosageForm

- **Definition:** Physical form administered.
- **Type:** enum (CAPSULE, SOFTGEL, TABLET, POWDER, GUMMY, LIQUID, INJECTION, OTHER)
- **Cardinality:** zero or one
- **Nullability:** null = not reported
- **Units / namespace:** n/a
- **Example:** CAPSULE (gelatin)
- **Counterexample:** dosage form on IngredientMaterial
- **Meaning of absence:** not reported
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** DOSAGE_FORM dimension
- **Privacy class:** public
- **Placement:** node property (moves from live CompoundForm.dosageForm)

#### StudyIntervention.dosesPerDay

- **Definition:** Administrations per day.
- **Type:** integer
- **Cardinality:** zero or one
- **Nullability:** null = not reported
- **Units / namespace:** /d
- **Example:** 1 (four capsules once daily)
- **Counterexample:** 4 (capsules per day)
- **Meaning of absence:** not reported
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** SCHEDULE dimension
- **Privacy class:** public
- **Placement:** node property

#### StudyIntervention.durationIso

- **Definition:** Planned intervention duration.
- **Type:** ISO 8601 duration string
- **Cardinality:** zero or one
- **Nullability:** null = not reported
- **Units / namespace:** ISO 8601
- **Example:** P8W
- **Counterexample:** '8 weeks plus follow-up' as a single value
- **Meaning of absence:** not reported
- **Expected source:** Methods, registry
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** DURATION dimension
- **Privacy class:** public
- **Placement:** node property

#### RegistrationVersion.observedAt

- **Definition:** When BellLabs observed this registry version.
- **Type:** datetime
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** UTC
- **Example:** 2026-10-03T00:00:00Z
- **Counterexample:** used as versionDate
- **Meaning of absence:** invalid
- **Expected source:** retrieval
- **Kind:** operational
- **Temporal behavior:** immutable
- **Provenance:** SourceSnapshot.retrievedAt
- **Query use:** CQ-ST-08 as-of queries
- **Privacy class:** public
- **Placement:** node property of an InformationArtifact

#### RegistrationVersion.versionDate

- **Definition:** Registry's own date for this version.
- **Type:** date
- **Cardinality:** zero or one
- **Nullability:** null = not retrievable
- **Units / namespace:** date
- **Example:** (unknown in session)
- **Counterexample:** observedAt substituted
- **Meaning of absence:** history not obtained
- **Expected source:** registry history API
- **Kind:** observed
- **Temporal behavior:** immutable
- **Provenance:** snapshot
- **Query use:** CQ-ST-04 earliest registered priority
- **Privacy class:** public
- **Placement:** node property

#### RegistrationVersion.overallStatus (CHANGE: renamed from recruitmentStatus)

- **Definition:** Registry overall status in this version.
- **Type:** enum (CT.gov OverallStatus)
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** COMPLETED
- **Counterexample:** stored on Study and overwritten on resync
- **Meaning of absence:** invalid
- **Expected source:** registry
- **Kind:** observed
- **Temporal behavior:** versioned via new RegistrationVersion
- **Provenance:** snapshot
- **Query use:** CQ-ST-08
- **Privacy class:** public
- **Placement:** versioned state (InformationArtifact per version): changes over time

#### RegistrationVersion.enrollmentCount / enrollmentCountType

- **Definition:** Enrollment and whether actual or estimated.
- **Type:** integer + enum
- **Cardinality:** zero or one each
- **Nullability:** type null = not reported by source/tool
- **Units / namespace:** persons
- **Example:** 120 / null
- **Counterexample:** 120 treated as actual
- **Meaning of absence:** not reported
- **Expected source:** registry
- **Kind:** observed
- **Temporal behavior:** versioned
- **Provenance:** snapshot
- **Query use:** CQ-ST-08
- **Privacy class:** public
- **Placement:** versioned state

#### RegistrationVersion.resultsPosted / resultsFirstPostedAt

- **Definition:** Whether a results section is posted on the registry, and when.
- **Type:** boolean + datetime
- **Cardinality:** zero or one each
- **Nullability:** null = not observed
- **Units / namespace:** n/a
- **Example:** false
- **Counterexample:** false read as 'unpublished'
- **Meaning of absence:** not observed
- **Expected source:** registry
- **Kind:** observed
- **Temporal behavior:** versioned
- **Provenance:** snapshot
- **Query use:** V-212; FI-203
- **Privacy class:** public
- **Placement:** versioned state (replaces live Study.hasResults)

#### RegistrationVersion.siteCountries

- **Definition:** Countries of registered sites.
- **Type:** list<string> ISO 3166-1 alpha-2
- **Cardinality:** zero or one list
- **Nullability:** null = not observed
- **Units / namespace:** ISO 3166
- **Example:** ['CA']
- **Counterexample:** overwritten by publication's site list
- **Meaning of absence:** not observed
- **Expected source:** registry
- **Kind:** observed
- **Temporal behavior:** versioned
- **Provenance:** snapshot
- **Query use:** CQ-ST-08 discrepancy
- **Privacy class:** public
- **Placement:** versioned state

#### OutcomeDefinition.measureKind

- **Definition:** What kind of measure the outcome is.
- **Type:** enum measureKind
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** BIOMARKER (whole-blood NAD+)
- **Counterexample:** SURROGATE_ENDPOINT (that is an assessment)
- **Meaning of absence:** invalid
- **Expected source:** protocol, registry, Methods
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** CQ-ST-03
- **Privacy class:** public
- **Placement:** node property: definitional, low dispute

#### Assertion DECLARES_OUTCOME_PRIORITY (valueString)

- **Definition:** Priority a given source assigns to an outcome.
- **Type:** Assertion with literal enum outcomePriority
- **Cardinality:** zero or more per outcome (one per source)
- **Nullability:** n/a
- **Units / namespace:** n/a
- **Example:** 'SECONDARY' (registry), 'PRIMARY' (Discussion)
- **Counterexample:** single isPrimary boolean
- **Meaning of absence:** source silent
- **Expected source:** registry, protocol, publication
- **Kind:** asserted
- **Temporal behavior:** valid at source version; recordedAt
- **Provenance:** SUPPORTED_BY locator
- **Query use:** V-223; CQ-ST-04
- **Privacy class:** public
- **Placement:** assertion: sources disagree

#### OutcomeDefinition.priority (CHANGE)

- **Definition:** Registered priority, derived from the earliest RegistrationVersion's declaration.
- **Type:** enum outcomePriority
- **Cardinality:** zero or one
- **Nullability:** null when no registry declaration
- **Units / namespace:** n/a
- **Example:** SECONDARY
- **Counterexample:** latest ingested paper's wording
- **Meaning of absence:** no registered priority
- **Expected source:** derived
- **Kind:** calculated
- **Temporal behavior:** regenerate when earlier versions arrive
- **Provenance:** derivation rule
- **Query use:** filters
- **Privacy class:** public
- **Placement:** derived projection

#### StudyResult.analysisKind

- **Definition:** Role of the analysis in the study plan.
- **Type:** enum analysisKind
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** SECONDARY_PRESPECIFIED
- **Counterexample:** PRIMARY for a paper's headline
- **Meaning of absence:** invalid
- **Expected source:** registry + Methods
- **Kind:** observed (with registry reconciliation)
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** V-215; CQ-ST-05
- **Privacy class:** public
- **Placement:** node property

#### StudyResult.comparisonKind

- **Definition:** Whether the estimate is between arms, within an arm over time, or descriptive per arm.
- **Type:** enum comparisonKind
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** WITHIN_ARM_CHANGE (NAD+ +40% vs baseline)
- **Counterexample:** BETWEEN_ARM for change from baseline
- **Meaning of absence:** invalid
- **Expected source:** Results text
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** V-216; FI-207
- **Privacy class:** public
- **Placement:** node property

#### StudyResult.statisticalConclusion

- **Definition:** Reported significance outcome of the stated comparison.
- **Type:** enum statisticalConclusion
- **Cardinality:** exactly one
- **Nullability:** non-null; NOT_REPORTED explicit
- **Units / namespace:** n/a
- **Example:** NOT_SIGNIFICANT (ATLAS peak power)
- **Counterexample:** NO_EFFECT
- **Meaning of absence:** invalid
- **Expected source:** Results
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** V-215
- **Privacy class:** public
- **Placement:** node property (replaces live isStatisticallySignificant)

#### StudyResult.multiplicityAdjusted

- **Definition:** Whether the reported p-value is adjusted for multiplicity.
- **Type:** boolean
- **Cardinality:** zero or one
- **Nullability:** null = not reported
- **Units / namespace:** n/a
- **Example:** null (Basis paper)
- **Counterexample:** false when unreported
- **Meaning of absence:** not reported
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** synthesis weighting
- **Privacy class:** public
- **Placement:** node property

#### AdverseEventResult.collectionMethod

- **Definition:** How AEs were collected.
- **Type:** enum aeCollectionMethod
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** SYSTEMATIC
- **Counterexample:** null for a reported zero
- **Meaning of absence:** invalid
- **Expected source:** Methods/AE section
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** V-217; INV-207
- **Privacy class:** public
- **Placement:** node property

#### AdverseEventResult.participantsAffected / participantsAtRisk / eventCount

- **Definition:** Counts per arm for one event term and seriousness.
- **Type:** integer x3
- **Cardinality:** zero or one each
- **Nullability:** atRisk null = not extracted
- **Units / namespace:** persons, events
- **Example:** 15 / null / 25 (NRPT 1X any AE)
- **Counterexample:** 0 inferred from silence
- **Meaning of absence:** not reported
- **Expected source:** AE table/text
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** CQ-ST-06
- **Privacy class:** public
- **Placement:** node property

#### AdverseEventResult.seriousness / eventTerm / eventTermCode

- **Definition:** Event term, its code (MedDRA when reported), and seriousness class.
- **Type:** string, string, enum (ANY, SERIOUS, NON_SERIOUS)
- **Cardinality:** one, zero or one, one
- **Nullability:** code null = not reported
- **Units / namespace:** MedDRA PT when present
- **Example:** 'Serious adverse event' / null / SERIOUS
- **Counterexample:** severity used as seriousness
- **Meaning of absence:** n/a
- **Expected source:** AE section
- **Kind:** observed
- **Temporal behavior:** state
- **Provenance:** locator
- **Query use:** CQ-ST-06
- **Privacy class:** public
- **Placement:** node property

#### EndpointClassification.endpointClass

- **Definition:** Role of an outcome in inference in a stated context.
- **Type:** enum endpointClass
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** BIOMARKER_NOT_SURROGATE (whole-blood NAD+)
- **Counterexample:** SURROGATE_ENDPOINT because it is a lab value
- **Meaning of absence:** invalid
- **Expected source:** BellLabs with BEST/FDA definitions
- **Kind:** inferred
- **Temporal behavior:** versioned by recordedAt
- **Provenance:** SUPPORTED_BY locators
- **Query use:** CQ-ST-03; OUTCOME_RELEVANCE
- **Privacy class:** public
- **Placement:** evidence assessment

#### EndpointClassification.biomarkerCategory

- **Definition:** BEST biomarker category in this study's use.
- **Type:** enum biomarkerCategory
- **Cardinality:** zero or one
- **Nullability:** null if not a biomarker
- **Units / namespace:** n/a
- **Example:** SAFETY (LDL-C in NRPT trial)
- **Counterexample:** PROGNOSTIC copied from another context
- **Meaning of absence:** n/a
- **Expected source:** assessor
- **Kind:** inferred
- **Temporal behavior:** versioned
- **Provenance:** locators
- **Query use:** CQ-ST-03
- **Privacy class:** public
- **Placement:** evidence assessment

#### EndpointClassification.surrogateValidationLevel

- **Definition:** Validation level in the classification's context of use.
- **Type:** enum surrogateValidationLevel
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** VALIDATED (FDA LDL-C context); NOT_ESTABLISHED (NRPT trial)
- **Counterexample:** VALIDATED stored on Biomarker
- **Meaning of absence:** invalid
- **Expected source:** FDA table/guidance or adjudication
- **Kind:** inferred/asserted
- **Temporal behavior:** versioned
- **Provenance:** SUPPORTED_BY
- **Query use:** V-214
- **Privacy class:** public
- **Placement:** evidence assessment

#### EndpointClassification.contextDiseaseOrUse / contextPopulation / contextInterventionMechanism / contextApprovalType

- **Definition:** Context of use for a surrogate classification (FDA table columns).
- **Type:** string x3 + enum
- **Cardinality:** zero or one each; required for SURROGATE_ENDPOINT
- **Nullability:** null for non-surrogates
- **Units / namespace:** n/a
- **Example:** Hypercholesterolemia / HeFH and non-FH patients / Lipid-lowering / TRADITIONAL
- **Counterexample:** context omitted
- **Meaning of absence:** not a surrogate context
- **Expected source:** FDA table
- **Kind:** asserted (source) within assessment
- **Temporal behavior:** versioned
- **Provenance:** SUPPORTED_BY
- **Query use:** V-214; FI-204
- **Privacy class:** public
- **Placement:** evidence assessment

#### EndpointClassification.contextMatch

- **Definition:** How the study's context matches the nearest surrogate context.
- **Type:** enum (FULL, PARTIAL, NONE)
- **Cardinality:** zero or one
- **Nullability:** null when no related context
- **Units / namespace:** n/a
- **Example:** PARTIAL
- **Counterexample:** FULL because analyte matches
- **Meaning of absence:** n/a
- **Expected source:** assessor
- **Kind:** inferred
- **Temporal behavior:** versioned
- **Provenance:** COMPARED_WITH_CONTEXT
- **Query use:** CQ-ST-03
- **Privacy class:** public
- **Placement:** evidence assessment

#### ResultInterpretation.interpretation / meaningfulnessVerdict / thresholdValue / thresholdUnit

- **Definition:** BellLabs reading of a result against a stated margin or MCID.
- **Type:** enum, enum (MEANINGFUL, NOT_MEANINGFUL, UNDETERMINED), float, UCUM
- **Cardinality:** one, zero or one, zero or one, zero or one
- **Nullability:** threshold null => meaningfulness UNDETERMINED
- **Units / namespace:** outcome unit
- **Example:** INCONCLUSIVE / UNDETERMINED (ENERGIZE 6MWD)
- **Counterexample:** author's 'clinically meaningful' copied
- **Meaning of absence:** not assessed
- **Expected source:** assessor + threshold source
- **Kind:** inferred
- **Temporal behavior:** versioned
- **Provenance:** USES_THRESHOLD_SOURCE
- **Query use:** CQ-ST-05, CQ-ST-10
- **Privacy class:** public
- **Placement:** evidence assessment (replaces live isClinicallyMeaningful)

#### Assertion RESULT_CLINICALLY_MEANINGFUL

- **Definition:** Author or speaker claim that a result is clinically meaningful.
- **Type:** Assertion with boolean literal
- **Cardinality:** zero or more
- **Nullability:** n/a
- **Units / namespace:** n/a
- **Example:** true (Singh et al., 6MWT)
- **Counterexample:** BellLabs verdict
- **Meaning of absence:** no claim
- **Expected source:** publication text
- **Kind:** asserted
- **Temporal behavior:** recordedAt
- **Provenance:** SUPPORTED_BY
- **Query use:** FI-206
- **Privacy class:** public
- **Placement:** assertion

#### EvidenceSynthesis.verdict / evidenceCutoff / recordedAt

- **Definition:** Claim-level verdict, latest publication date considered, and when BellLabs recorded it.
- **Type:** enum adjudicationVerdict, date, datetime
- **Cardinality:** exactly one each
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** INSUFFICIENT / 2019-08-31 / 2019-09-15
- **Counterexample:** verdict overwritten in place
- **Meaning of absence:** invalid
- **Expected source:** BellLabs
- **Kind:** inferred
- **Temporal behavior:** new version per change (SUPERSEDES)
- **Provenance:** INCLUDES_RESULT, SUPPORTED_BY
- **Query use:** CQ-ST-09
- **Privacy class:** public
- **Placement:** evidence assessment, versioned

#### TRIGGERED_BY.criterionCode / effectOnVerdict / evidencePublishedAt

- **Definition:** Why a new synthesis version was made, what it did, and when the triggering evidence was published.
- **Type:** string from method criteria, enum evidenceChangeEffect, date
- **Cardinality:** exactly one, exactly one, zero or one
- **Nullability:** published date null = unknown
- **Units / namespace:** n/a
- **Example:** HUMAN_DIRECT_MEASUREMENT_NULL / WEAKENED / 2019-08-13
- **Counterexample:** free-text change note
- **Meaning of absence:** invalid
- **Expected source:** BellLabs
- **Kind:** inferred
- **Temporal behavior:** immutable
- **Provenance:** edge on versioned assessment
- **Query use:** CQ-ST-09 period filter
- **Privacy class:** public
- **Placement:** relationship property: qualifies one trigger edge, shares its life

#### INCLUDES_RESULT.inputRole

- **Definition:** Role a result or assertion plays in a synthesis.
- **Type:** enum synthesisInputRole
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** CONTRADICTING
- **Counterexample:** CONFIRMATORY for a within-arm change
- **Meaning of absence:** invalid
- **Expected source:** BellLabs
- **Kind:** inferred
- **Temporal behavior:** immutable per version
- **Provenance:** synthesis version
- **Query use:** V-215, V-216, V-218
- **Privacy class:** public
- **Placement:** relationship property

#### EvidenceStrengthAssessment.scheme / level / criteria

- **Definition:** Named grading scheme, level, and criteria applied.
- **Type:** string, string, list<string>
- **Cardinality:** exactly one each
- **Nullability:** non-null
- **Units / namespace:** scheme namespace (e.g. GRADE, OCEBM-2011)
- **Example:** OCEBM-2011 / '2' / [...] (illustrative)
- **Counterexample:** Study.evidenceLevel 'high'
- **Meaning of absence:** not assessed
- **Expected source:** BellLabs
- **Kind:** inferred
- **Temporal behavior:** versioned
- **Provenance:** ASSESSES_STRENGTH_OF; SUPPORTED_BY
- **Query use:** CQ-EV-02; STUDY_DESIGN_AND_QUALITY
- **Privacy class:** public
- **Placement:** evidence assessment (replaces Study.evidenceLevel and EvidenceStrength enum)

#### Publication.publicationKind

- **Definition:** Kind of publication record.
- **Type:** enum publicationKind
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** AUTHOR_CORRECTION (PMID 30155270)
- **Counterexample:** correction stored as an ARTICLE
- **Meaning of absence:** invalid
- **Expected source:** PubMed publication type, journal
- **Kind:** observed
- **Temporal behavior:** immutable
- **Provenance:** PubMed record
- **Query use:** CQ-EV-05; V-212
- **Privacy class:** public
- **Placement:** node property

#### Dataset.accessLevel / ANALYZES_DATASET.analysisRole

- **Definition:** Dataset availability; role of a publication's analysis.
- **Type:** enum (PUBLIC, CONTROLLED, ON_REQUEST, UNAVAILABLE, UNKNOWN); enum datasetAnalysisRole
- **Cardinality:** one; one per edge
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** ON_REQUEST; PRIMARY_REPORT
- **Counterexample:** dataset fields on Study
- **Meaning of absence:** n/a
- **Expected source:** Data availability statement
- **Kind:** observed
- **Temporal behavior:** state; edge immutable
- **Provenance:** locator
- **Query use:** CQ-ST-07; V-218
- **Privacy class:** public
- **Placement:** node property; relationship property

#### USES_INTERVENTION_MATERIAL.asReportedName

- **Definition:** Name under which the source reports the administered material or product.
- **Type:** string
- **Cardinality:** zero or one; required when target is ProductVariant
- **Nullability:** null for materials
- **Units / namespace:** n/a
- **Example:** 'Tru Niagen 300 mg capsules'
- **Counterexample:** current product name substituted
- **Meaning of absence:** n/a
- **Expected source:** source text
- **Kind:** observed
- **Temporal behavior:** edge life
- **Provenance:** projectionOfAssertionUid
- **Query use:** V-202
- **Privacy class:** public
- **Placement:** relationship property

#### RESULT_FOR_ARM.armRole

- **Definition:** Role of the arm in a result (INTERVENTION, COMPARATOR).
- **Type:** enum
- **Cardinality:** zero or one
- **Nullability:** null = INTERVENTION
- **Units / namespace:** n/a
- **Example:** COMPARATOR (placebo in LDL between-arm result)
- **Counterexample:** arm role inferred from order
- **Meaning of absence:** default
- **Expected source:** Results
- **Kind:** observed
- **Temporal behavior:** edge life
- **Provenance:** result locator
- **Query use:** CQ-ST-05
- **Privacy class:** public
- **Placement:** relationship property

#### Assertion.basisKind (KCR-3a)

- **Definition:** Epistemic basis of the proposition in its source.
- **Type:** enum basisKind
- **Cardinality:** exactly one for mechanism predicates
- **Nullability:** optional elsewhere
- **Units / namespace:** n/a
- **Example:** HYPOTHESIS ('pterostilbene providing additional activation of SIRT1')
- **Counterexample:** DIRECT_MEASUREMENT for a cited mouse result in a human paper
- **Meaning of absence:** for mechanism predicates: invalid (V-230)
- **Expected source:** source text
- **Kind:** asserted (classification of the source's claim)
- **Temporal behavior:** immutable per assertion
- **Provenance:** SUPPORTED_BY locator
- **Query use:** CQ-MX-01; V-230, V-233
- **Privacy class:** public
- **Placement:** assertion property: qualifies how the source made the claim

#### MechanismEvidenceContext.setting

- **Definition:** Experimental setting.
- **Type:** enum mechanismSetting
- **Cardinality:** exactly one
- **Nullability:** non-null
- **Units / namespace:** n/a
- **Example:** HUMAN_INTERVENTIONAL
- **Counterexample:** IN_VIVO_MAMMAL for a human trial
- **Meaning of absence:** invalid
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** immutable (corrections via new recorded episode)
- **Provenance:** assertions referencing it
- **Query use:** CQ-MX-02; V-231
- **Privacy class:** public
- **Placement:** node property of an Occurrence

#### MechanismEvidenceContext.modelDescriptor / sexScope / ageDescriptor / sampleSize

- **Definition:** Model system description as reported.
- **Type:** string, enum (MALE, FEMALE, BOTH, UNKNOWN), string, integer
- **Cardinality:** zero or one each
- **Nullability:** null = not reported
- **Units / namespace:** persons/animals
- **Example:** 'aged men, randomized placebo-controlled crossover' / MALE / null / 12
- **Counterexample:** normalized strain name without source wording
- **Meaning of absence:** not reported
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** immutable
- **Provenance:** locators of linked assertions
- **Query use:** CQ-MX-02
- **Privacy class:** public
- **Placement:** node property

#### MechanismEvidenceContext.exposureAmount / exposureUnit / exposureBasis

- **Definition:** Exposure in the context.
- **Type:** float, UCUM string, enum exposureBasis
- **Cardinality:** zero or one each; unit and basis required with amount
- **Nullability:** null with exposureStatus when unknown; null when IN_STUDY_ARM
- **Units / namespace:** UCUM (mg/d, mg/kg/d, umol/L)
- **Example:** 1000.0 / mg/d / ABSOLUTE_PER_DAY
- **Counterexample:** 50 'mg' without per-kg basis
- **Meaning of absence:** not extracted (exposureStatus) or read from arm
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** immutable
- **Provenance:** locators
- **Query use:** CQ-MX-02, CQ-MX-04; V-232, V-238
- **Privacy class:** public
- **Placement:** node property

#### MechanismEvidenceContext.route / exposureDurationIso

- **Definition:** Route and exposure duration.
- **Type:** string enum (ORAL, GAVAGE, DIET, IP, IV, IN_MEDIUM, TOPICAL), ISO 8601 duration
- **Cardinality:** zero or one each
- **Nullability:** null = not reported or read from arm
- **Units / namespace:** ISO 8601
- **Example:** ORAL / P21D
- **Counterexample:** '3 weeks' free text
- **Meaning of absence:** not reported
- **Expected source:** Methods
- **Kind:** observed
- **Temporal behavior:** immutable
- **Provenance:** locators
- **Query use:** CQ-MX-02
- **Privacy class:** public
- **Placement:** node property

#### MechanismEvidenceContext.exposureStatus

- **Definition:** Why exposure fields are null.
- **Type:** enum (NOT_EXTRACTED, NOT_REPORTED, NOT_APPLICABLE)
- **Cardinality:** zero or one
- **Nullability:** required when exposureAmount null and no arm
- **Units / namespace:** n/a
- **Example:** NOT_EXTRACTED (Zhang 2016 in this session)
- **Counterexample:** 0 mg
- **Meaning of absence:** exposure present
- **Expected source:** extraction run
- **Kind:** operational
- **Temporal behavior:** updated by re-extraction
- **Provenance:** agentRunUid
- **Query use:** V-232; INV-007 distinct states
- **Privacy class:** public
- **Placement:** node property

#### MechanismEvidenceContext.hedValue / hedMethod

- **Definition:** Human-equivalent dose computed from an animal exposure.
- **Type:** float + string
- **Cardinality:** zero or one each; method required with value
- **Nullability:** null unless computed
- **Units / namespace:** mg/kg/d
- **Example:** (not computed)
- **Counterexample:** stored as a source fact
- **Meaning of absence:** not computed
- **Expected source:** calculation
- **Kind:** calculated
- **Temporal behavior:** regenerable
- **Provenance:** method id
- **Query use:** CQ-MX-04 display only
- **Privacy class:** public
- **Placement:** derived projection

#### Biomarker MEASURED_IN_MATRIX -> AnatomicalContext

- **Definition:** The matrix or compartment that defines the measurand.
- **Type:** relationship
- **Cardinality:** exactly one per Biomarker (proposed)
- **Nullability:** n/a
- **Units / namespace:** n/a
- **Example:** NAD+ whole blood -> whole blood
- **Counterexample:** bare 'NAD+' measurand shared by blood and muscle results
- **Meaning of absence:** measurand not compartment-specific
- **Expected source:** diagnostics catalog (Lane 3)
- **Kind:** structural
- **Temporal behavior:** stable
- **Provenance:** n/a
- **Query use:** F-7, V-239; CQ-MX-02
- **Privacy class:** public
- **Placement:** referenced entity: compartments recur and must be joinable

## Rounds 0004 and 0005: diagnostics, regulatory, manufacturing, commerce, declared amounts

Standard: name, definition, type, cardinality, nullability, units or namespace, example, counterexample, meaning of absence, expected source, kind (asserted | observed | calculated | inferred | operational), temporal behavior, provenance, query use, privacy class, placement (with one-sentence justification). Cards are grouped by owner. Properties already in catalog 0.1.0 and unchanged are not repeated.

### Diagnostics (Round 0004)

#### `Metric.loincCode` (changed: normalization stated)
- Definition: LOINC code of the measurand concept this Metric denotes.
- Type: string. Cardinality: 0..1 per Metric; unique across Metrics. Nullability: null when no LOINC concept exists.
- Namespace: LOINC (Regenstrief); pattern `^[0-9]{1,7}-[0-9]$`; release recorded on the `Identifier` record.
- Example: `4548-4`. Counterexample: `17856-6` attached to a Metric for "HbA1c by any method" (that code is method-specific and discouraged by LOINC mapping guidance).
- Absence: no LOINC concept assigned, or not yet resolved; never "method unknown".
- Expected source: LOINC record; lab compendium mapping.
- Kind: asserted (by terminology mapping). Temporal: stable; deprecations are new Identifier states.
- Provenance: `IDENTIFIED_BY` -> `Identifier` with source locator. Query use: join labs on measurand. Privacy: public.
- Placement: node property (materialized key) plus referenced `Identifier`, because uniqueness and normalization are explicit and it is filtered constantly.

#### `Metric.unitStatus` (new)
- Definition: whether the source states a unit for this measurand or feature.
- Type: enum `ReportedStatus` {REPORTED, NOT_REPORTED, NOT_APPLICABLE}. Cardinality 1. Non-null.
- Example: Owkin `density_lymphocytes_in_tumor` -> NOT_REPORTED ("per unit area", unit unstated). Counterexample: setting `canonicalUnitCode = '/mm2'` by assumption.
- Absence: not allowed (non-null).
- Source: feature or terminology definition. Kind: observed (of the source). Temporal: per Metric definition; changes create a new Metric if the definition changes.
- Query use: block trends and conversions when NOT_REPORTED. Privacy: public.
- Placement: node property, atomic and without dispute history.

#### `AssayVersion.softwareVersion` / `softwareVersionStatus` (new)
- Definition: instrument or analysis software version under which the assay ran; and whether the source reported it.
- Type: string / enum ReportedStatus. Cardinality 0..1 / 1.
- Example: `5.24` (Tosoh G8, NGSP interference table). Counterexample: a lab report date used as a version.
- Absence: `softwareVersionStatus = NOT_REPORTED`; two NOT_REPORTED assay versions never merge by default.
- Source: lab method notice, package insert, NGSP tables. Kind: asserted. Temporal: identity-defining; a change creates a new AssayVersion.
- Provenance: assertion on `PERFORMED_WITH_ASSAY_VERSION` episode. Query use: interference and comparability filters. Privacy: public.
- Placement: node property of a versioned state, because it is part of the state's identity.

#### `AssayVersion.assayKitIdentifier` (new)
- Definition: manufacturer reagent kit or application identifier.
- Type: string. 0..1. Nullable.
- Example: `B93009` (Beckman HbA1c Advanced online application, as listed by NGSP). Counterexample: a lot number (lots are not versions).
- Absence: not reported. Source: package insert, NGSP list. Kind: asserted. Temporal: identity-defining. Privacy: public.
- Placement: node property; part of AssayVersion identity.

#### `PERFORMED_WITH_ASSAY_VERSION` edge properties (new edge)
- Definition: the orderable test was performed with this assay version over a valid interval, as recorded over a system interval.
- Properties: `relationshipUid` (string, required), `validFrom`, `validTo` (datetime, nullable, half-open), `recordedFrom` (datetime, required), `recordedTo` (nullable), `assertionUid` (required).
- Example: Lab A HbA1c -> Tosoh G8 5.24, validTo 2025-06-01, recordedFrom 2025-08-20 (corrected episode). Counterexample: overwriting validTo from 2025-07-01 to 2025-06-01 in place.
- Absence: unknown validFrom = null, never ingestion time.
- Source: lab notices; reports. Kind: asserted. Temporal: bitemporal; corrections are new episodes.
- Query use: as-of trend grouping. Privacy: public (lab-level).
- Placement: relationship property, because the values qualify one pair and share its lifecycle; the claim itself is an Assertion.

#### `AlgorithmVersion.versionLabel` / `versionBasis` (new)
- Definition: version string as the source states it; and the basis on which the version is identified.
- Type: string (nullable) / enum {VENDOR_VERSION_STRING, PUBLICATION_VERSION, SERVICE_ENDPOINT_UNVERSIONED, UNKNOWN} (non-null).
- Example: GrimAge2 -> `2`, PUBLICATION_VERSION (PMID 36516495). Owkin endpoint -> null, SERVICE_ENDPOINT_UNVERSIONED. Counterexample: labeling a vendor's "GrimAge" as `2` because it is the latest.
- Absence: versionLabel null with basis UNKNOWN means the version is unresolved, and the result keeps competing assertions.
- Source: publication, vendor documentation, service help. Kind: asserted. Temporal: immutable per node.
- Query use: comparability (INV-L3-01), V-308, V-312. Privacy: public.
- Placement: node property of a versioned state; identity-defining.

#### `AlgorithmVersion.outputKind` / `outputUnitCode` (new)
- Definition: what kind of quantity the algorithm returns, and its UCUM unit.
- Type: enum {AGE_ESTIMATE, PACE, RISK_SCORE, FEATURE_MEASURE, CLASSIFICATION, CALCULATED_QUANTITY} / string UCUM.
- Example: GrimAge v1 AGE_ESTIMATE `a`; DunedinPACE PACE (years per year, UCUM `a/a`). Counterexample: differencing a PACE value against an AGE_ESTIMATE.
- Absence: not allowed for outputKind; unit null with Metric.unitStatus NOT_REPORTED.
- Source: publication. Kind: asserted. Temporal: immutable. Privacy: public.
- Placement: node property; it defines what the version produces.

#### `AlgorithmVersion.retrievedAt` (new)
- Definition: when an unversioned service endpoint was queried; the only available pin for its outputs.
- Type: datetime. 0..1. Required when versionBasis = SERVICE_ENDPOINT_UNVERSIONED.
- Example: 2026-10-03 (Owkin). Counterexample: using it as a model release date.
- Absence: not applicable for versioned algorithms. Kind: operational. Privacy: public.
- Placement: node property; one AlgorithmVersion per retrieval pin.

#### `ReferenceIntervalVersion.intervalKind` (new)
- Definition: whether the bounds are a reference interval (central percentiles of a reference population), a clinical decision limit, or a guideline target.
- Type: enum. 1. Non-null.
- Example: Lab A 4.0 to 5.6 % -> REFERENCE_INTERVAL. Counterexample: storing a diagnostic threshold as REFERENCE_INTERVAL.
- Source: lab report; guideline text. Kind: asserted. Temporal: immutable per version. Privacy: public.
- Placement: node property; it changes the meaning of the bounds.

#### `ReferenceIntervalVersion.derivationKind` (new)
- Definition: how the lab obtained the interval.
- Type: enum {ESTABLISHED, TRANSFERRED, VERIFIED, ADOPTED_FROM_MANUFACTURER, NOT_REPORTED}.
- Example: TRANSFERRED after an analyzer change (CLSI EP28 transference). Counterexample: ESTABLISHED for an interval copied from a package insert.
- Absence: NOT_REPORTED. Source: lab documentation. Kind: asserted. Privacy: public.
- Placement: node property of a versioned state.

#### `ReferenceIntervalVersion` partition fields (`sexPartition`, `ageMinYears`, `ageMaxYears`, `fastingStatus`, `pregnancyStatus`, `partitionText`) (changed from live `ReferenceRange`)
- Definition: the population partition the interval applies to.
- Type: string enums / floats; `partitionText` verbatim.
- Example: adults >= 18, all sexes. Counterexample: applying an adult interval to a pediatric result.
- Absence: null means not stated (not "all").
- Source: lab report. Kind: asserted. Privacy: public.
- Placement: node properties; typed fields are filters, text preserves source wording.

#### `ComparabilityAssessment.verdict` and dimensions (new)
- Definition: BellLabs judgment whether two versions' outputs share an axis; dimensions `measurandMatch`, `unitConversionRule`, `traceabilityMatch`, `interferenceProfileMatch`, `referenceIntervalMatch`, `replicateNoiseBasis`.
- Type: enum verdict + strings. Required: verdict, methodVersion.
- Example: Lab A (NGSP %) vs Lab B (IFCC mmol/mol): COMPARABLE_WITH_CONVERSION, rule `NGSP = 0.09148 * IFCC + 2.152`. Counterexample: one numeric "comparability score".
- Absence: no assessment means not comparable for trend purposes.
- Source: NGSP, CLSI, reliability studies. Kind: inferred (assessment). Temporal: new assessment per method version.
- Query use: license `COMPARED_TO`. Privacy: internal.
- Placement: evidence assessment, because it is BellLabs' judgment with method version and evidence.

#### `DiagnosticResult.resultKind` (new; interface contract)
- Definition: measured, calculated, or inferred.
- Type: enum. 1. Non-null (Enterprise constraint proposed).
- Example: GrimAge -> INFERRED; eAG from HbA1c -> CALCULATED. Counterexample: GrimAge as MEASURED.
- Source: report structure plus algorithm metadata. Kind: asserted (by ingestion rule). Privacy: inherits the result's class.
- Placement: node property on whatever type Lane 5 chooses; atomic.

#### `DiagnosticResult.privacyClass` (new; interface contract)
- Definition: public, internal, private-personal, or synthetic.
- Type: enum. 1. Non-null.
- Example: fixture results -> synthetic. Counterexample: missing class on a personal lab value.
- Kind: operational. Privacy: n/a (it is the class).
- Placement: node property; used by every query path filter. Enforcement is Lane 5's.

### Regulatory (Round 0005)

#### `RegulatoryStatus.statusKind` (new on live type)
- Definition: the kind of legal standing the status represents.
- Type: enum {APPROVAL, CLEARANCE, DE_NOVO_AUTHORIZATION, DESIGNATION, ESTABLISHMENT_REGISTRATION, NOTIFICATION_ON_FILE, ENFORCEMENT_DISCRETION, WITHDRAWN, REVOKED}. 1. Non-null.
- Example: NRC -> NOTIFICATION_ON_FILE (GRN 000635). Paige Prostate -> DE_NOVO_AUTHORIZATION (DEN200080). Counterexample: APPROVAL for a GRAS "no questions" response.
- Absence: not allowed.
- Source: agency record. Kind: asserted (agency) or inferred (BellLabs normalization of agency wording) with assertion. Temporal: `effectiveFrom`/`effectiveTo`.
- Query use: every "approved / cleared / registered" answer; V-320, V-322, V-333. Privacy: public.
- Placement: node property of a versioned state; the state is the status.

#### `RegulatoryStatus.legalBasisCitation` and `RegulatoryPathway.effectiveFrom/effectiveTo` (new)
- Definition: the legal text under which the status exists; the interval in which the pathway rule was in force.
- Type: string / datetime.
- Example: 2024 LDT rule (21 CFR 809.3 amendment), vacated 2025-03-31, reverted effective 2025-09-19. Counterexample: deleting LDT statuses after vacatur.
- Absence: null effectiveTo = still in force or unknown.
- Source: Federal Register, eCFR, FDA pages. Kind: asserted. Temporal: valid-time bounded. Privacy: public.
- Placement: node properties; pathway rule changes are rare and atomic.

#### `RegulatoryResponse.responseKind` (changed: closed per pathway)
- Definition: what the agency said in response to a submission.
- Type: enum `RegulatoryResponseKind`, validated per pathway.
- Example: GRN 000635 -> GRAS_NO_QUESTIONS. Counterexample: "no objection" (company wording) as a response kind.
- Source: agency letter or database. Kind: observed. Temporal: immutable; corrections are new responses. Privacy: public.
- Placement: node property of an information artifact.

#### `RegulatoryResponse.conditionsOfUseText` / `agencyDisclaimerText` (new)
- Definition: verbatim conditions of use and disclaimers stated by the agency.
- Type: string. 0..1.
- Example: "at a maximum level of 0.0057% by weight as consumed"; "The agency has not, however, made its own determination". Counterexample: "180 mg/day" taken from the company page.
- Absence: null = not captured (V-331 lists).
- Source: agency letter. Kind: observed. Privacy: public.
- Placement: node property; verbatim text with the artifact.

#### `RegulatorySubmission.filingDate` (new)
- Definition: date the agency treats as the filing date (for NDI, resets when substantive information is added).
- Type: datetime. 0..1.
- Example: NDI filing date reset by supplement. Counterexample: submittedAt reused as filing date after a reset.
- Absence: not reported. Source: agency letter. Kind: asserted. Temporal: changes are new recorded-time episodes via assertion. Privacy: public.
- Placement: node property projected from the latest accepted assertion; the history lives in assertions.

#### `RegulatoryStatus.pcccAuthorized` (new)
- Definition: whether a predetermined change control plan was authorized with a device authorization.
- Type: boolean, nullable.
- Example: DEN200080 -> false. Absence: not stated. Source: FDA database. Kind: observed. Privacy: public.
- Placement: node property; one value per authorization.

### Manufacturing readiness (Round 0005)

#### `ManufacturingCapability.stage` (new)
- Definition: operating, piloting, planned, suspended, or discontinued, as asserted.
- Type: enum. 1. Non-null.
- Example: synthetic plant PLANNED (2024 filing) then OPERATING (2025 filing) as two episodes. Counterexample: PROMOTED as a stage.
- Absence: not allowed; uncertainty is expressed by assertion status and adjudication.
- Source: filings, audits, press releases, marketing (context recorded on Source). Kind: asserted. Temporal: through `HAS_CAPABILITY_STATE` valid and recorded time.
- Query use: CQ-MF-04, V-324. Privacy: public.
- Placement: versioned state, because stage changes on bounded intervals and is disputed.

#### `ManufacturingCapability.capacityValue`, `capacityUnitCode`, `capacityBasis` (new)
- Definition: stated capacity, its UCUM unit, and whether nameplate or utilized.
- Type: float / string / enum {NAMEPLATE, UTILIZED, NOT_REPORTED}.
- Example: NOT_REPORTED for the 10-K case. Counterexample: inferring capacity from revenue.
- Source: filings. Kind: asserted. Privacy: public.
- Placement: properties of the versioned state.

#### `ManufacturingCapability.targetOperationalDate` (new)
- Definition: date by which a PLANNED capability is said to become operational.
- Type: datetime, PLANNED only.
- Example: "expected to be operational in Q3 2025" (synthetic). Counterexample: used as validFrom of an OPERATING state.
- Kind: asserted (forward-looking). Temporal: has no valid time of its own. Privacy: public.
- Placement: property of the PLANNED state.

#### `HAS_CAPABILITY_STATE` edge properties (new edge)
- Same bitemporal set as `PERFORMED_WITH_ASSAY_VERSION` (`relationshipUid`, `validFrom`, `validTo`, `recordedFrom`, `recordedTo`, `assertionUid`).
- Placement: relationship property; one holder-state pair.

### Commerce (Round 0005)

#### `PriceObservation.priceKind` (new)
- Definition: what kind of price was observed.
- Type: enum {LIST, ONE_TIME, SUBSCRIPTION, COUPON_ADJUSTED, PER_UNIT}. 1. Non-null.
- Example: $49.00 ONE_TIME; $41.65 COUPON_ADJUSTED (same day, Amazon). Counterexample: averaging the two.
- Source: listing snapshot. Kind: observed. Temporal: occurrence at observedAt. Privacy: public.
- Placement: occurrence property, one observation per price kind.

#### `SELLER_OF_RECORD_FOR` edge properties (new edge)
- Definition: the organization or seller account shown as seller of record for an offer.
- Properties: `assertionUid` (required), `validFrom`, `validTo`, `recordedFrom`, `recordedTo`.
- Example: "TRU NIAGEN" seller account for B0FS82B35K on 2026-10-03. Counterexample: Amazon as seller because it fulfills.
- Source: listing snapshot. Kind: observed. Privacy: public.
- Placement: relationship property; the role is per offer and time.

### Labels and formulations (Round 0005)

#### `QuantityDeclaration.amountReferent` / `IngredientComponent.amountReferent` (new)
- Definition: which entity a declared amount refers to.
- Type: enum {NUTRIENT_AS_NUTRIENT, LISTED_INGREDIENT_AS_LISTED, PROPRIETARY_BLEND_TOTAL, EXTRACT_TOTAL, MARKER_CONSTITUENT, NOT_STATED}. 1. Non-null when a quantity is present.
- Example: "Nicotinamide Riboside Chloride 250 mg" -> LISTED_INGREDIENT_AS_LISTED (21 CFR 101.36(b)(3)(ii)); "Calcium (as calcium carbonate) 500 mg" -> NUTRIENT_AS_NUTRIENT (101.36(b)(2)(ii)). Counterexample: ACTIVE_MOIETY on a label declaration.
- Absence: NOT_STATED when no amount.
- Source: label snapshot. Kind: asserted (label) with rule-based classification. Temporal: per label snapshot / formulation version. Privacy: public.
- Placement: property of the declaration (information artifact) and of the component populated from it; atomic and tied to that record.

#### `QuantityDeclaration.amountReferentUid` (new)
- Definition: uid of the IngredientMaterial, Nutrient, Constituent, or blend component the amount refers to.
- Type: string. 0..1.
- Placement: property (pointer to an entity); a typed edge can replace it when Neo4j projection needs traversal.

## Round 0006: claims, documents, provenance

Format: one card per new or changed property, following the mission's property standard. Fields: definition; type; cardinality; nullability; units or namespace; example; counterexample; absence means; expected source; kind (asserted | observed | calculated | inferred | operational); temporal behavior; provenance; query use; privacy class; placement (with one-sentence justification).

All examples are from the Round 0006 fixture unless marked otherwise. Privacy class is `public` unless stated.

---

### A. SourceLocator (kernel; KCR-4.1)

#### SourceLocator.selectorKind
- Definition: Which selector contract this locator follows.
- Type / cardinality / nullability: enum `selectorKind` (TEXT_QUOTE, TEXT_POSITION, MEDIA_TIME, PDF_PAGE, IMAGE_REGION); exactly one; required.
- Example: `TEXT_QUOTE` for the episode 52 transcript sentence. Counterexample: a JSON `selector` string mixing a quote and a timestamp.
- Absence means: invalid record (Enterprise constraint `source_locator_selector_kind_exists`; V-401).
- Expected source: set by the capture or extraction activity. Kind: operational.
- Temporal behavior: immutable. Provenance: `WAS_GENERATED_BY` Activity.
- Query use: chooses which required fields V-401 checks.
- Placement: node property; atomic, immutable, no dispute lifecycle.

#### SourceLocator.exact, .prefix, .suffix
- Definition: Verbatim text of the cited span and short context before and after it (W3C Web Annotation TextQuoteSelector).
- Type: String; one each; `exact` required for every text-bearing kind; `prefix`/`suffix` nullable.
- Units/namespace: text of the referenced snapshot or text version, before normalization.
- Example: exact "My 82 -year-old father, we take a gram of NMN every day."; prefix "I'm always happy to tell you what I do and what my father does. ".
- Counterexample: an extractor paraphrase ("Sinclair takes 1 g NMN") stored in `exact`.
- Absence means: `exact` absent means the locator cannot be re-anchored; prefix/suffix absent means re-anchoring may be ambiguous when the quote repeats.
- Expected source: the captured text. Kind: observed.
- Temporal behavior: immutable; a changed page yields a new locator plus `REANCHORS`.
- Provenance: the snapshot it hangs from.
- Query use: re-anchoring, display of the passage, duplicate detection.
- Privacy: public for public sources; `internal` when the source is licensed text that policy forbids redisplaying.
- Placement: node property; the span is the locator's identity content.

#### SourceLocator.quoteHash
- Definition: `sha256:<hex>` of `exact` after the normalization named in `normalizationVersion`.
- Type: String; one; required for text-bearing kinds.
- Example: `sha256:96fe6eb5c9177e4e2c18035be1bd8bfce8f7325882994ff8274de98cf4516e56`.
- Counterexample: a hash over unnormalized text with no stated normalization.
- Absence means: span equality across snapshots cannot be checked cheaply.
- Kind: calculated. Temporal: immutable. Query use: index `source_locator_quote_hash`; finds the same quote across snapshots and sources (echo detection).
- Placement: node property; derived deterministically from `exact` and stored for lookup.

#### SourceLocator.normalizationVersion
- Definition: Identifier of the text normalization used before hashing and position counting.
- Type: String from the catalog `normalizationVersions` registry (`NFC-WS1`); one; required.
- Example: `NFC-WS1`. Counterexample: "default".
- Absence means: neither the hash nor the offsets are reproducible.
- Kind: operational. Placement: node property; it qualifies only this locator's hash.

#### SourceLocator.startOffset, .endOffset
- Definition: Character positions in the linked `DocumentTextVersion`; start inclusive, end exclusive (Web Annotation 4.2.5).
- Type: Int; zero or one each; nullable; required together for TEXT_POSITION.
- Units: Unicode code points after `normalizationVersion`.
- Example: none in the fixture (capture is partial, so offsets would be misleading). Counterexample: offsets with no `LOCATOR_IN_TEXT_VERSION` edge (V-403).
- Absence means: the locator relies on its quote anchor.
- Kind: calculated. Temporal: immutable; valid only for its text version.
- Query use: fast highlight; `RESOLVES_TO_CHUNK` derivation via `Chunk.charStart/charEnd`.
- Placement: node property plus a structural edge to the text version, because offsets mean nothing without it.

#### SourceLocator.mediaStartSeconds, .mediaEndSeconds, .mediaTimeBasis
- Definition: Start and end of the span on the timeline of the rendition the locator's snapshot captured; `mediaTimeBasis` says how the times were obtained (RENDITION_TRANSCRIPT_CUE, PUBLISHER_CHAPTER, MANUAL).
- Type: Float seconds; String basis; required for MEDIA_TIME.
- Example: 287.0 to 295.0, basis RENDITION_TRANSCRIPT_CUE, YouTube rendition of episode 52.
- Counterexample: "1:07:37" as a string on an episode-level edge (live `OrderingMetadata.startTime`) with no rendition.
- Absence means: not a media locator.
- Kind: observed. Temporal: immutable; not portable to other renditions (dynamic ad insertion).
- Query use: deep links; segment classification (sponsor read).
- Placement: node property; it qualifies only this locator.

#### SourceLocator.speakerLabelInSource
- Definition: The speaker label printed in the source next to the span.
- Type: String; nullable. Example: "David Sinclair". Counterexample: a resolved person uid (that is `ASSERTED_BY`).
- Absence means: the source does not label speakers, or the span is not speech.
- Kind: observed. Query use: auditing attribution against `ASSERTED_BY`.
- Placement: node property; it is what the source printed, distinct from BellLabs' attribution.

### B. SourceSnapshot (kernel CHANGE)

#### SourceSnapshot.contentHashBasis
- Definition: What `contentHash` was computed over.
- Type: enum (RAW_BYTES, NORMALIZED_TEXT, STORED_EXCERPT_TEXT); one; required when `contentHash` is set.
- Example: STORED_EXCERPT_TEXT (fixture captures came through a third-party extractor). Counterexample: a hash of bytes that were never stored.
- Absence means: the hash cannot be recomputed by a third party.
- Kind: operational. Placement: node property; it qualifies only this snapshot's hash.

#### SourceSnapshot.captureCompleteness
- Definition: Whether the capture holds the whole rendition or only excerpts.
- Type: enum (COMPLETE, PARTIAL_EXCERPT, UNKNOWN); one; required.
- Example: PARTIAL_EXCERPT. Counterexample: COMPLETE for a relevance-ranked extract.
- Absence means: UNKNOWN; disclosure findings must then not say NOT_DISCLOSED (V-426).
- Kind: observed. Query use: V-426; answer qualification.
- Placement: node property; it is a fact about this capture.

#### SourceSnapshot.storageUri, .archiveUri
- Definition: Where BellLabs stored the captured content; an external archive copy if one exists.
- Type: String URI; nullable each. Example: `blob:sha256:9cadaee8...`; archiveUri null.
- Absence means: the content is not retrievable by BellLabs (locators are then not reproducible beyond their quote).
- Kind: operational. Privacy: `internal` for `storageUri`.
- Placement: node property.

#### SourceSnapshot.publisherRevisionNotice
- Definition: Verbatim notice by the publisher that the content is provisional or revised.
- Type: String; nullable. Example: "This transcript is currently under human review and may contain errors."
- Absence means: no notice seen in the capture.
- Kind: observed. Query use: flag answers citing provisional text; schedule re-capture.
- Placement: node property; it belongs to this capture.

### C. Assertion (kernel CHANGE, KCR-4.2)

#### Assertion.assertionBasis
- Definition: The basis on which the asserter presents the proposition.
- Type: enum `assertionBasis` (PERSONAL_EXPERIENCE, THIRD_PARTY_ANECDOTE, MANUFACTURER_CLAIM, STUDY_RESULT, MECHANISM_REASONING, EXPERT_OPINION, UNSTATED); zero or one.
- Example: PERSONAL_EXPERIENCE for "we take a gram of NMN every day". Counterexample: MANUFACTURER_CLAIM because the speaker holds a company role (affiliation is computed from role assertions, not encoded here).
- Absence means: not classified; distinct from UNSTATED (classified, no basis given).
- Expected source: the span and adjacent turns. Kind: inferred (extraction judgment).
- Temporal: immutable per assertion; re-classification creates a superseding assertion.
- Provenance: the extraction Activity; `extractionConfidence`.
- Query use: CQ-CL-02 filters; answer labels.
- Placement: node property of the Assertion, because it describes this act of asserting and shares its lifecycle.

#### Assertion.speechAct, .reportedSpeechAct
- Definition: `speechAct` is what this asserter does (states, reports own practice, recommends, cautions, speculates, questions, denies). `reportedSpeechAct` is the speech act this assertion attributes to another party (used by retellings).
- Type: enum `speechAct`; zero or one each.
- Example: original REPORTS_PRACTICE; retelling `speechAct` STATES with `reportedSpeechAct` RECOMMENDS.
- Counterexample: setting the retelling's own `speechAct` to RECOMMENDS (the digest author did not recommend; they reported a recommendation).
- Absence means: not classified.
- Kind: inferred. Query use: V-423 (a `RECOMMENDS` projection needs the asserter's own RECOMMENDS); CQ-RC-05.
- Placement: node property; same lifecycle as the assertion.

#### Assertion.quantityBasis
- Definition: What a literal amount refers to (UNSPECIFIED, ACTIVE_INGREDIENT, PRODUCT_MASS, SALT_FORM, ACTIVE_MOIETY, EXTRACT_TOTAL). Coordinate values with Lane 3 `amountReferent`.
- Type: String enum; zero or one; required when `valueNumber` is a quantity of a substance.
- Example: UNSPECIFIED for "a gram"; the Lifespan #4 correction states ACTIVE_INGREDIENT 1 to 2 mg.
- Counterexample: assuming ACTIVE_INGREDIENT for a spoken "a gram".
- Absence means: unknown basis; answers must flag it (CQ-PV-04).
- Kind: observed or inferred. Placement: node property; it qualifies only this literal.

#### Assertion.extractionConfidence
- Definition: Probability that the span was parsed into this statement correctly. Replaces generic `confidence`.
- Type: Float 0 to 1; zero or one; requires `WAS_GENERATED_BY` an Activity (V-428).
- Example: 0.95, method lane4-manual-curation-v0.1. Counterexample: 0.96 with no method (the 0.1.0 Elysium fixture pattern).
- Absence means: not estimated.
- Kind: calculated. Privacy: `internal` (operator tier).
- Placement: node property; it is the extraction dimension of the confidence vector for this record.

#### Assertion.roleTitleVerbatim, .roleCodeVerbatim, .statedTense
- Definition: For role assertions, the title or code exactly as the source printed it, and the tense in which a speaker stated it (PAST, PRESENT).
- Type: String; nullable. Example: "scientific lead guy", PRESENT; code "B".
- Counterexample: normalizing "scientific lead guy" to ADVISES_ORGANIZATION without a rule.
- Absence means: the predicate came from a structured field.
- Kind: observed. Query use: review of role normalization; disclosure display.
- Placement: node property; it is part of what this source said.

### D. Relationship properties

#### QUALIFIED_BY.qualificationKind
- Definition: The kind of caveat the qualifying occurrence attaches to the qualified one.
- Type: enum `qualificationKind`; exactly one; required.
- Example: INDIVIDUAL_VARIATION ("I'm not the same as everybody else..."). Counterexample: a free-text "caveat" note.
- Absence means: invalid edge (V-416).
- Kind: inferred. Placement: relationship property; it qualifies only this pair.

#### RETELLS.retellingMode, .linkBasis, .hypothesisUid, .citationLocatorUid
- Definition: How the retelling reproduces the original (VERBATIM_QUOTE, PARAPHRASE, SUMMARY, TRANSLATION) and why BellLabs links them (EXPLICIT_CITATION with the citing locator, or BELLLABS_MATCH with a ResolutionHypothesis).
- Type: enums and uid strings; mode and basis required; one of the uids required by basis.
- Example: PARAPHRASE, BELLLABS_MATCH, `hu:resolution:retelling-source:synthetic-digest-to-hl52-nmn`.
- Counterexample: RETELLS with no basis (V-413).
- Kind: inferred. Temporal: immutable; a rejected hypothesis removes the edge in a new recorded-time episode.
- Query use: CQ-CL-04, CQ-CL-06, CQ-PV-05.
- Placement: relationship property; the link itself is the thing being qualified.

#### REANCHORS.anchorMatch
- Definition: Whether the newer locator matched the older quote exactly or by fuzzy matching.
- Type: enum (EXACT, FUZZY); required.
- Example: FUZZY when "82 -year-old" becomes "82-year-old". Kind: calculated.
- Placement: relationship property.

#### RESOLVES_TO_CHUNK.derivationRule, .segmentationHash
- Definition: Rule and segmentation that produced this derived locator-to-chunk link.
- Type: String; both required. Example: `offset-containment-v1`, live `Segmentation.segmentationHash`.
- Absence means: invalid derived edge (V-408).
- Kind: calculated. Placement: relationship property of a derived edge.

#### SUPPORTED_BY (Assertion to Chunk, derived variant).locatorUid
- Definition: The SourceLocator this chunk shortcut projects.
- Type: String uid; required on that variant. Example: `hu:locator:hl52-page-nmn-gram-daily`.
- Absence means: the live edge is unanchored evidence (V-407). Kind: operational.
- Placement: relationship property; the shortcut must name its authority.

#### AUTHORIZED_BY.useKind
- Definition: The downstream use the policy allowed for this activity.
- Type: enum `useKind`; required. Example: QUOTE_IN_ANSWER.
- Kind: operational. Privacy: `internal`.
- Placement: relationship property; it qualifies one activity-policy pair.

#### Financial-interest edges: validFrom, validTo, validTimePrecision, validTimeBasis, assertionUid, recordedFrom, recordedTo
- Definition: As Lane 1 `relationshipClasses.asserted` and the starter property model. Lane 4 adds the rule that an edge keeps its assertion's bounds (V-421) and that "present" on an observed page is `validTo = null`.
- Example: BOARD_MEMBER_OF validFrom 2011-01-01, validTo 2018-01-01, precision YEAR (widest half-open interval consistent with "2011-2017"; precision rule pending Lane 5).
- Counterexample: validTo null for a role the source closes in 2017.
- Kind: asserted. Placement: relationship property of an asserted edge projected from an Assertion.

### E. Assessments

#### RetellingFidelityAssessment fields
- `qualificationLost` (Boolean), `lostQualificationKinds` ([qualificationKind]), `speechActChanged`/`speechActFrom`/`speechActTo`, `assertionBasisChanged`, `scopeBroadened`/`addedPurposeText`, `quantityChanged`, `attributionChanged`, `correctionIgnored`, `methodVersion` (required), `status`, `assessedAt`.
- Definition: Comparison of one retelling against one original.
- Example: qualificationLost true, [INDIVIDUAL_VARIATION], REPORTS_PRACTICE to RECOMMENDS, addedPurposeText "to slow aging".
- Counterexample: the same flags on the retelling Assertion (V-414).
- Absence means: no comparison made (not "faithful").
- Kind: inferred. Provenance: `ASSESSED_BY` Agent or Person; method version.
- Query use: CQ-CL-04; answer warnings.
- Placement: evidence assessment; it is a BellLabs judgment about a pair and can be redone by another method.

#### ConflictRelevanceAssessment fields
- `relevanceLevel` (DIRECT, INDIRECT, NOT_RELEVANT, UNKNOWN), `relevanceBasis` (SAME_PRODUCT, SAME_ORGANIZATION, COMPETING_PRODUCT, SAME_SUBSTANCE, SAME_SUBSTANCE_CLASS_VIA_GROUP, SPONSOR_OF_CONTAINER, NO_PATH_FOUND), `temporalOverlap` (OVERLAPS, DISJOINT, UNKNOWN), `disclosureFinding` (DISCLOSED_IN_CONTAINER, DISCLOSED_ELSEWHERE, NOT_FOUND_IN_PARTIAL_CAPTURE, NOT_DISCLOSED, UNKNOWN), `scopeAmbiguity` (String), `methodVersion`, `status`.
- Example: INDIRECT, SAME_SUBSTANCE_CLASS_VIA_GROUP, UNKNOWN, NOT_FOUND_IN_PARTIAL_CAPTURE.
- Counterexample: NOT_DISCLOSED from a partial capture (V-426); a verdict derived from this assessment (V-424).
- Absence means: relevance not assessed (not "no conflict").
- Kind: inferred. Query use: CQ-CL-05; source-reliability inputs.
- Placement: evidence assessment; relevance is a judgment about a pair (interest, occurrence) with its own method.

#### ClaimEvidenceAssessment.evidenceStrength (moved from Claim)
- Definition: BellLabs grade of the evidence for a Claim under named criteria.
- Type: live enum `EvidenceStrength` (LOW, MODERATE, HIGH); one per assessment.
- Example: none in fixture (intentionally). Counterexample: `Claim.evidenceStrength` (V-418).
- Absence means: not assessed.
- Kind: inferred. Temporal: superseded by later assessments; never overwritten.
- Migration: existing values become assessments with `methodVersion` `legacy-unspecified` and status PROPOSED.
- Placement: evidence assessment; evidence strength changes with evidence and method, not with the proposition.

#### EquivalenceAssessment.equivalenceKind
- Definition: How two distinct identities relate when they look alike.
- Type: enum (SAME_WORK_DIFFERENT_NAME, OVERLAPPING_SCOPE, RELATED_NOT_EQUIVALENT, NOT_EQUIVALENT); required.
- Counterexample: using it to merge nodes (identity is ResolutionHypothesis).
- Kind: inferred. Placement: evidence assessment.

### F. Lineage

#### Activity.activityKind, .methodVersion, .externalRunSystem, .externalRunId, .startedAt, .endedAt
- Definition: What kind of process ran, under which method, linked to an external run record.
- Type: enum and strings; `activityKind` required; external pair unique when present (constraint `activity_external_run_unique`).
- Example: EXTRACTION, `lane4-manual-curation-v0.1`; live mapping `externalRunSystem: 'mongo-research'`, `externalRunId: <mongoResearchRunId>`.
- Counterexample: run id stored on `Agent.runUid`.
- Absence means: lineage unknown.
- Kind: operational. Privacy: `internal`.
- Placement: Occurrence node; a run is something that happened and is used by many outputs.

#### Agent.agentKind, .toolVersion
- Definition: Kind of agent (aligned to Biolink AgentTypeEnum) and tool version.
- Example: AUTOMATED_AGENT, toolVersion unknown (Tavily extract). Kind: operational.
- Placement: node property of the Agent identity.

### G. Live-type additions

#### Chunk.charStart, .charEnd
- Definition: Character span of the chunk in its text version (same counting rule as locator offsets).
- Type: Int; nullable. Absence means: chunk-to-locator resolution falls back to quote search.
- Kind: calculated. Placement: node property of a derived retrieval unit.

#### Episode.episodeNumber
- Definition: Number assigned by the publisher. Example: 52 (Apple Podcasts). Kind: observed.
- Placement: node property; not an identity key (numbering can be reused across feeds).

#### Document.sourceKind
- Definition: Catalog `sourceKind` for the rendition (merged list in the catalog patch). Example: PODCAST_TRANSCRIPT_PAGE. Kind: operational.
- Placement: node property; complements live `documentType`, which describes the document genre.

## Rounds 0007 and 0008: time, private context, protocols, recommendations

Each card follows the mission property standard. Fields: definition; type / cardinality / nullability; units or namespace; example; counterexample; absence means; expected source; kind (asserted | observed | calculated | inferred | operational); temporal behavior; provenance; query use; privacy class; placement with justification.

"Episode" means any relationship with the `bitemporal_attachment` or `asserted_edge` profile (`HAS_STATE`, `HAS_FORMULATION_VERSION`, `HAS_PACKAGE_CONFIGURATION`, `HAS_REGISTRATION_VERSION`, `HAS_PROTOCOL_EDITION`, and in the private store `HAS_CONTEXT_VERSION`, `HAS_GOAL_VERSION`, `HAS_ADOPTION_VERSION`, `HAS_SHARING_GRANT`).

### A. Time (round 0007)

#### T-01 `validFrom` (episodes and `Assertion`)
- Definition: inclusive start of the interval in which the state or proposition held in the modeled world.
- Type / cardinality / nullability: DateTime (zoned, UTC) / 0..1 / nullable.
- Units or namespace: UTC instant; stored as the first instant of its precision period.
- Example: `2025-11-01T00:00:00Z` with `validFromPrecision: MONTH` for "formula updated November 2025".
- Counterexample: the ingestion timestamp of a page that says "available now".
- Absence means: start unknown (not "since forever", not "since ingestion").
- Expected source: dated statements in labels, registries, filings, press releases; user-declared start in the PCS.
- Kind: asserted (inferred only with `validFromBasis: INFERRED` and a `derivationRule`).
- Temporal behavior: immutable; a different start is a new assertion and episode.
- Provenance: `assertionUid` / `projectionOfAssertionUid` to the assertion and its `SourceLocator`.
- Query use: as-of filter `validFrom IS NULL OR validFrom <= $V`.
- Privacy class: public on shared records; private-personal on PCS episodes.
- Placement: relationship property on the episode plus assertion property; the edge copy serves traversal, the assertion is the history.

#### T-02 `validTo`
- Definition: exclusive end of the validity interval.
- Type / cardinality / nullability: DateTime / 0..1 / nullable.
- Units or namespace: UTC; first instant of its precision period ("ended sometime in 2023" = `2023-01-01`, `YEAR`).
- Example: `2026-06-10T00:00:00Z`, `DAY`, stated reformulation effective date.
- Counterexample: the date a page stopped listing an offer (that is an observation, not an end).
- Absence means: end unknown; not "ongoing".
- Expected source: stated end dates, successor effective dates.
- Kind: asserted or inferred (`INFERRED` with rule `successor_state_start`).
- Temporal behavior: immutable; learning an end is a `VALIDITY_BOUNDED` supersession and a new episode.
- Provenance: as T-01.
- Query use: as-of filter; exclusivity checks.
- Privacy class: as T-01.
- Placement: as T-01.

#### T-03 `validFromPrecision` (CHANGE: replaces the single `validTimePrecision`)
- Definition: granularity of `validFrom`.
- Type / cardinality / nullability: enum `TimePrecision` (`INSTANT`, `DAY`, `MONTH`, `QUARTER`, `YEAR`, `DECADE`) / 0..1 / required when `validFrom` is non-null.
- Units or namespace: catalog enum.
- Example: `MONTH` for "launched in March 2026".
- Counterexample: `DAY` assigned to "March 2026" because the parser defaulted to the 1st.
- Absence means: the bound is null.
- Expected source: the wording of the source.
- Kind: asserted (extraction of granularity).
- Temporal behavior: immutable.
- Provenance: same as the bound.
- Query use: `KNOWN` versus `POSSIBLE` evaluation; definite-overlap shrinking (V-508).
- Privacy class: follows the record.
- Placement: property next to its bound; it qualifies only that value.

#### T-04 `validToPrecision`
- Same as T-03 for `validTo`. Example: `YEAR` for "discontinued in 2023".

#### T-05 `validFromBasis` (CHANGE: replaces the single `validTimeBasis`)
- Definition: why `validFrom` has its value.
- Type / cardinality / nullability: enum `ValidTimeBasis` (`STATED_BY_SOURCE`, `PUBLICATION_PROXY`, `OBSERVATION_ONLY`, `INFERRED`, `UNKNOWN`) / 1 / required.
- Units or namespace: catalog enum.
- Example: `OBSERVATION_ONLY` for "available as of March" (bound stays null).
- Counterexample: `STATED_BY_SOURCE` for a date copied from the crawl timestamp.
- Absence means: not allowed (required).
- Expected source: extraction rules.
- Kind: operational classification of an asserted value.
- Temporal behavior: immutable.
- Provenance: extraction method version on the assertion.
- Query use: exclude `PUBLICATION_PROXY` from "known start" answers; V-503.
- Privacy class: follows the record.
- Placement: property next to its bound.

#### T-06 `validToBasis`
- Same as T-05 for `validTo`. Example: `INFERRED` for the 2019 label's end at the next formulation's start.

#### T-07 `recordedFrom` (episodes)
- Definition: when BellLabs began holding this episode as part of its record.
- Type / cardinality / nullability: DateTime / 1 / required.
- Units or namespace: UTC; transaction time.
- Example: `2026-08-01T07:10:00Z` for a 2019 label learned in 2026.
- Counterexample: `2019-05-10` (archive capture time).
- Absence means: not allowed.
- Expected source: ingestion service clock.
- Kind: operational.
- Temporal behavior: immutable; never client-supplied; never earlier than the authorizing assertion's `recordedAt`.
- Provenance: commit log.
- Query use: as-of filter `recordedFrom <= $R`.
- Privacy class: follows the record.
- Placement: relationship property; it describes the episode, not the state.

#### T-08 `recordedTo` (episodes)
- Definition: when BellLabs stopped holding this episode as current.
- Type / cardinality / nullability: DateTime / 0..1 / nullable.
- Units or namespace: UTC.
- Example: `2026-06-15T08:10:00Z` when a label erratum was recorded.
- Counterexample: the date the fact ended in the world.
- Absence means: currently recorded.
- Expected source: ingestion service at supersession.
- Kind: operational.
- Temporal behavior: written once from null.
- Provenance: the superseding assertion (`SUPERSEDES.recordedAt`).
- Query use: as-of filter; current view `recordedTo IS NULL`.
- Privacy class: follows the record.
- Placement: relationship property.

#### T-09 `Assertion.recordedAt` (clarified)
- Definition: when the assertion entered the record.
- Type / cardinality / nullability: DateTime / 1 / required.
- Units or namespace: UTC; transaction time.
- Example: `2026-03-02T10:10:00Z`.
- Counterexample: the source's `publishedAt`.
- Absence means: not allowed (C-501).
- Expected source: ingestion service.
- Kind: operational.
- Temporal behavior: immutable; never earlier than the supporting snapshot's `retrievedAt` (V-504).
- Provenance: agent run / commit.
- Query use: CQ-TM-01 as-of.
- Privacy class: public.
- Placement: node property; the assertion is the unit of record.

#### T-10 `Assertion.recordedTo` (new; KCR-0007-1)
- Definition: when the assertion stopped being a current record because it was superseded.
- Type / cardinality / nullability: DateTime / 0..1 / nullable.
- Units or namespace: UTC.
- Example: `2026-06-15T08:10:00Z` (superseded by a source correction).
- Counterexample: the time a reviewer rejected the assertion (rejection is an adjudication; the assertion stays in the record).
- Absence means: current record.
- Expected source: ingestion service at supersession.
- Kind: operational.
- Temporal behavior: written once; equals `SUPERSEDES.recordedAt`.
- Provenance: `SUPERSEDES` edge.
- Query use: as-of filter; status projection (`SUPERSEDED`).
- Privacy class: public.
- Placement: node property; alternative status-episode nodes rejected as a third vocabulary.

#### T-11 `Assertion.contentHash` (new)
- Definition: sha256 of the canonicalized immutable content (predicate, polarity, subject uid, object uid or literal, valid bounds, precisions, bases, jurisdiction).
- Type / cardinality / nullability: String / 1 / required.
- Units or namespace: `sha256:<hex>`.
- Example: `sha256:9f2c...`.
- Counterexample: a hash that includes `status` (status is a projection and may change).
- Absence means: not allowed.
- Expected source: ingestion service.
- Kind: calculated.
- Temporal behavior: immutable.
- Provenance: canonicalization version in catalog.
- Query use: tamper detection (fixture F-V12, illustrative).
- Privacy class: public.
- Placement: node property.

#### T-12 `Assertion.derivationRule` (new)
- Definition: named rule that produced an inferred bound.
- Type / cardinality / nullability: String (controlled) / 0..1 / required when a basis is `INFERRED`.
- Units or namespace: catalog rule ids, e.g. `successor_state_start`.
- Example: `successor_state_start`.
- Counterexample: free-text reviewer notes.
- Absence means: no inferred bound.
- Expected source: inference service.
- Kind: inferred.
- Temporal behavior: immutable.
- Provenance: rule version.
- Query use: separate stated from inferred bounds; V-503.
- Privacy class: public.
- Placement: node property on the assertion.

#### T-13 `relationshipUid` (episodes)
- Definition: stable audit id of one episode relationship.
- Type / cardinality / nullability: String / 1 / required.
- Units or namespace: `hu:rel:<opaque>`; private store `hu:private-rel:<opaque>`.
- Example: `hu:rel:fixture-eA2`.
- Counterexample: Neo4j `elementId` (not stable across stores or rebuilds).
- Absence means: not allowed.
- Expected source: ingestion service.
- Kind: operational.
- Temporal behavior: immutable.
- Provenance: commit.
- Query use: MERGE key for parallel episodes; audit; C-505.
- Privacy class: follows the record.
- Placement: relationship property.

#### T-14 `assertionUid` / `projectionOfAssertionUid` (episodes)
- Definition: the assertion that authorizes the episode.
- Type / cardinality / nullability: String / 0..1 / required when source-derived.
- Units or namespace: `hu:assertion:<opaque>`.
- Example: `hu:assertion:synthetic-sleepwell-variant-fv-a1-corrected`.
- Counterexample: a `SourceLocator` uid.
- Absence means: structural or user-declared episode (PCS) with no source assertion.
- Expected source: ingestion.
- Kind: operational.
- Temporal behavior: immutable.
- Provenance: is the provenance link.
- Query use: V-504, V-505; explanation.
- Privacy class: public.
- Placement: relationship property (the live GraphQL `TemporalMetadata` gains it).

#### T-15 `VersionedState.payloadHash` (CHANGE: required in catalog)
- Definition: sha256 of the canonicalized payload of an immutable state.
- Type / cardinality / nullability: String / 1 / required.
- Units or namespace: `sha256:<hex>`.
- Example: hash of a `ProtocolEdition` step list.
- Counterexample: a hash including `createdAt`.
- Absence means: not allowed.
- Expected source: ingestion.
- Kind: calculated.
- Temporal behavior: immutable.
- Provenance: canonicalization version.
- Query use: edition detection (CQ-PR-01); snapshot replay comparison (CQ-RC-04).
- Privacy class: follows the record.
- Placement: node property.

#### T-16 `SUPERSEDES.supersessionKind` (new)
- Definition: why a newer assertion or adjudication replaced an older one.
- Type / cardinality / nullability: enum `SupersessionKind` / 1 / required.
- Units or namespace: `SOURCE_CORRECTION`, `VALIDITY_BOUNDED`, `EXTRACTION_FIX`, `RESOLUTION_FIX`, `DUPLICATE_MERGE`, `RE_REVIEW`, `SOURCE_REVISION`.
- Example: `SOURCE_CORRECTION` for a label erratum.
- Counterexample: `SOURCE_CORRECTION` for a reformulation (that is `VALIDITY_BOUNDED` plus a new state).
- Absence means: not allowed.
- Expected source: ingestion rules and reviewer.
- Kind: operational classification.
- Temporal behavior: immutable.
- Provenance: `sourceRevisionEventUid` when a revision event exists.
- Query use: CQ-TM-07; CQ-RC-07 triage.
- Privacy class: public.
- Placement: relationship property; it qualifies only this supersession.

#### T-17 `SUPERSEDES.recordedAt`
- Definition: when the supersession was committed.
- Type / cardinality / nullability: DateTime / 1 / required.
- Example: `2026-06-20T09:10:00Z`.
- Counterexample: the effective date of the change in the world.
- Absence means: not allowed.
- Expected source / kind: ingestion service / operational.
- Temporal behavior: immutable; equals newer `recordedAt` and older `recordedTo`.
- Provenance: commit.
- Query use: CQ-RC-07 (`recordedAt > evidenceRecordedAt`).
- Privacy class: public.
- Placement: relationship property.

#### T-18 `SourceSnapshot.publishedAt` (+ `publishedAtPrecision`) (KCR-0007-3)
- Definition: the issuer's date for this version of the artifact.
- Type / cardinality / nullability: DateTime / 0..1 / nullable.
- Units or namespace: UTC; precision enum.
- Example: `2010-02-06`, `DAY` (retraction notice PMID 20137807).
- Counterexample: the crawl time.
- Absence means: the source shows no issue date.
- Expected source: bibliographic metadata, page metadata.
- Kind: observed.
- Temporal behavior: immutable.
- Provenance: the snapshot itself.
- Query use: CQ-TM-03; `PUBLICATION_PROXY` basis.
- Privacy class: public.
- Placement: node property of the immutable snapshot.

#### T-19 `SourceSnapshot.observedAt`
- Definition: when the content was seen as displayed (crawl time for live capture; capture time for archives).
- Type / cardinality / nullability: DateTime / 1 / required.
- Example: `2019-05-10` for an archive capture.
- Counterexample: `2026-08-01`, the time BellLabs fetched the archive.
- Absence means: not allowed.
- Expected source: capture tool; archive capture metadata.
- Kind: observed.
- Temporal behavior: immutable.
- Provenance: capture log.
- Query use: witness instants for `OBSERVATION_ONLY` validity; CQ-TM-02.
- Privacy class: public.
- Placement: node property.

#### T-20 `SourceSnapshot.retrievedAt` (existing, clarified)
- Definition: when BellLabs fetched the bytes.
- Type / cardinality / nullability: DateTime / 1 / required.
- Example: `2026-08-01T07:00:00Z`.
- Counterexample: archive capture time.
- Absence means: not allowed.
- Expected source / kind: capture tool / operational.
- Temporal behavior: immutable.
- Provenance: capture log.
- Query use: lower bound for assertion `recordedAt` (V-504); adjudication citation check (V-511).
- Privacy class: public.
- Placement: node property.

#### T-21 `SourceRevisionEvent.revisionKind` (new)
- Definition: kind of revision the publisher made.
- Type / cardinality / nullability: enum `SourceRevisionKind` / 1 / required.
- Units or namespace: `ERRATUM`, `RETRACTION`, `EXPRESSION_OF_CONCERN`, `CORRECTED_AND_REPUBLISHED`, `NEW_VERSION`, `SILENT_CONTENT_CHANGE`, `WITHDRAWAL`, `REINSTATEMENT` (follows NLM publication types).
- Example: `RETRACTION` for PMID 9500320 (notice PMID 20137807).
- Counterexample: `RETRACTION` for a page that simply moved URL.
- Absence means: not allowed.
- Expected source: PubMed publication types and links; publisher notices; snapshot diffs.
- Kind: observed (asserted by the publisher's notice) or inferred (`SILENT_CONTENT_CHANGE`).
- Temporal behavior: immutable.
- Provenance: `ANNOUNCED_IN` notice snapshot.
- Query use: CQ-TM-06 impact (Q-505).
- Privacy class: public.
- Placement: node property of a first-class occurrence (it has its own time, notice, and several snapshot links).

#### T-22 `SourceRevisionEvent.occurredAt` / `recordedAt`
- Definition: when the publisher made the revision / when BellLabs learned of it.
- Type / cardinality / nullability: DateTime / 0..1 and 1 / `occurredAt` nullable, `recordedAt` required.
- Example: `occurredAt 2010-02-06` (notice date), `recordedAt 2026-10-03`.
- Counterexample: using `recordedAt` as the retraction date.
- Absence means: issuer time unknown.
- Expected source: notice metadata / ingestion clock.
- Kind: observed / operational.
- Temporal behavior: immutable.
- Provenance: notice snapshot.
- Query use: CQ-TM-06, CQ-RC-07.
- Privacy class: public.
- Placement: node properties.

#### T-23 `Adjudication.recordedAt` (new; KCR-0007-2) and `reviewerType` values `POLICY`, `MIGRATION`
- Definition: when the adjudication was committed; `POLICY` marks automated acceptance, `MIGRATION` marks synthetic records created at the 0.2.0 migration.
- Type / cardinality / nullability: DateTime / 1 / required; enum / 1 / required.
- Example: `2026-03-02T10:20:00Z`, `POLICY`.
- Counterexample: `reviewedAt` of a review drafted earlier and committed later (keep both).
- Absence means: not allowed (C-503).
- Expected source: review service.
- Kind: operational.
- Temporal behavior: immutable; re-review is a superseding adjudication.
- Provenance: reviewer or policy id.
- Query use: status as of `R` (CQ-TM-01).
- Privacy class: internal for rationale text; verdict public.
- Placement: node property.

#### T-24 `temporalCardinality` / `exclusivityPartition` (catalog metadata, not instance data)
- Definition: whether two episodes of a relationship type from one subject may overlap, and which properties partition the check.
- Type / cardinality / nullability: enum (`EXCLUSIVE`, `NONEXCLUSIVE`) plus list of property names / 1 per relationship type / default `NONEXCLUSIVE`.
- Example: `HAS_FORMULATION_VERSION: EXCLUSIVE, partitionBy [jurisdiction]`.
- Counterexample: `MARKETS_PRODUCT: EXCLUSIVE` (several marketers are legitimate).
- Absence means: `NONEXCLUSIVE`.
- Expected source: ontology lab decision.
- Kind: operational schema metadata.
- Temporal behavior: versioned with the catalog.
- Provenance: round record.
- Query use: V-508, V-509, commit-time check.
- Privacy class: public.
- Placement: catalog entry on the relationship type.

### B. Recommendation decisions (round 0008)

#### R-01 `RecommendationSnapshot.decidedAt`
- Definition: when the decision was computed. Type: DateTime / 1 / required. Units: UTC.
- Example: `2026-04-10T09:00:05Z`. Counterexample: the time the person later opened the explanation.
- Absence means: not allowed. Expected source: decision service. Kind: operational.
- Temporal behavior: immutable. Provenance: service log. Query use: ordering of a person's decisions.
- Privacy class: private-personal. Placement: property of a private occurrence (insert-only).

#### R-02 `RecommendationSnapshot.recordedAt`
- Definition: when the snapshot was committed. Type: DateTime / 1 / required.
- Example: `2026-04-10T09:00:06Z`. Counterexample: `decidedAt` of a recomputed decision.
- Absence: not allowed. Source: PCS. Kind: operational. Temporal: immutable. Provenance: commit.
- Query use: F-V1 (nothing attached later). Privacy: private-personal. Placement: node property.

#### R-03 `evidenceRecordedAt`
- Definition: the shared-graph system-time viewpoint `R` used to read evidence.
- Type: DateTime / 1 / required. Units: UTC.
- Example: `2026-04-10T09:00:00Z`. Counterexample: `now()` at replay time.
- Absence means: not allowed; without it replay is impossible.
- Source: decision service (the graph read timestamp). Kind: operational.
- Temporal: immutable. Provenance: decision service. Query use: replay (Q-1, F-V2), CQ-RC-07 (Q-3).
- Privacy: private-personal. Placement: snapshot property; one viewpoint per decision.

#### R-04 `evidenceValidAt`
- Definition: domain-time viewpoint `V` evaluated by the decision.
- Type: DateTime / 1 / required.
- Example: `2026-04-10T09:00:00Z`. Counterexample: a product launch date.
- Absence: not allowed. Source/kind: decision service / operational. Temporal: immutable.
- Query use: replay. Privacy: private-personal. Placement: snapshot property.

#### R-05 `userContextVersionUid`
- Definition: the exact private context version used. Type: String / 1 / required.
- Namespace: `hu:private-user-context-version:<opaque>`.
- Example: `...-synthetic-0001-v1`. Counterexample: the `UserContext` uid (not a version).
- Absence: not allowed. Source: PCS. Kind: operational. Temporal: immutable.
- Provenance: PCS foreign key. Query use: CQ-PC-02, F-V1.
- Privacy: private-personal. Placement: snapshot property (PCS foreign key).

#### R-06 `policyVersionUid` / `algorithmVersion`
- Definition: shared ranking and safety policy version / code or model build that applied it.
- Type: String / 1 each / required.
- Namespace: `hu:policy-version:<opaque>` / build identifier.
- Example: `hu:policy-version:sleep-support-ranking-v3`, `ranker-2026.04.1`.
- Counterexample: "latest".
- Absence: not allowed. Source: decision service. Kind: operational. Temporal: immutable.
- Query use: CQ-RC-02; cohort audits by policy.
- Privacy: snapshot field private-personal; the PolicyVersion node itself internal.
- Placement: snapshot properties referencing a shared internal node by uid.

#### R-07 `catalogVersion`
- Definition: catalog semantic version in force at decision. Type: String / 1 / required.
- Example: `0.2.0`. Counterexample: GraphQL schema digest alone.
- Source/kind: service / operational. Query use: interpreting stored enums after catalog change.
- Privacy: private-personal (as part of the snapshot). Placement: snapshot property.

#### R-08 `intendedUse`
- Definition: what the recommendation was for.
- Type: enum (`INFORMATIONAL_COMPARISON`, `PURCHASE_DECISION_SUPPORT`, `PROTOCOL_ADJUSTMENT_REVIEW`, `DISCUSS_WITH_CLINICIAN`) / 1 / required.
- Example: `PURCHASE_DECISION_SUPPORT`. Counterexample: "health improvement".
- Absence: not allowed. Source: request. Kind: asserted (by the person or the product flow).
- Temporal: immutable. Query use: policy scoping; disclosure decisions.
- Privacy: private-personal. Placement: request and snapshot property.

#### R-09 `decisionOutcome`
- Definition: overall outcome.
- Type: enum (`RECOMMENDED_ONE`, `RECOMMENDED_SEVERAL`, `RECOMMENDED_NONE`, `BLOCKED_BY_CONSTRAINT`, `INSUFFICIENT_EVIDENCE`) / 1 / required.
- Example: `RECOMMENDED_ONE`. Counterexample: a numeric score.
- Absence: not allowed. Kind: calculated. Temporal: immutable. Query use: F-V11; outcome audits.
- Privacy: private-personal. Placement: snapshot property.

#### R-10 `rationaleSummary`
- Definition: human-readable explanation generated at decision time; explanation only.
- Type: String / 0..1 / nullable.
- Example: "SleepWell selected: material matches studied material...". Counterexample: a filterable reason code (use `rejectionReason`).
- Absence: no generated text; structured fields still explain.
- Source: decision service. Kind: calculated. Temporal: immutable.
- Query use: display only. Privacy: private-personal. Placement: snapshot property; never used as a filter.

#### R-11 `decisionConfidence` / `decisionConfidenceMethod`
- Definition: the decision dimension of the confidence vector and the method that produced it.
- Type: Float in [0,1] / String / 0..1 each; method required when value present.
- Example: `0.55`, `policy-v3-rank-stability-1`. Counterexample: an average of evidence-strength and extraction scores.
- Absence means: not computed.
- Source: decision service. Kind: calculated. Temporal: immutable.
- Query use: surfacing fragile decisions. Privacy: private-personal. Placement: snapshot property.

#### R-12 `missingFactKeys`
- Definition: controlled keys of facts whose absence could change the ranking.
- Type: List<String> / 0..n / nullable.
- Namespace: policy-defined fact keys.
- Example: `['BASELINE_SERUM_MAGNESIUM']`. Counterexample: free text "more data needed".
- Absence means: policy declared none missing.
- Source: decision policy. Kind: calculated. Temporal: immutable.
- Query use: CQ-RC-03; opening `PendingItem`s.
- Privacy: private-personal. Placement: snapshot property.

#### R-13 `snapshotHash`
- Definition: sha256 of canonicalized snapshot plus options at commit.
- Type: String / 1 / required. Example: `sha256:...`.
- Counterexample: a hash recomputed after edits and overwritten.
- Kind: calculated. Temporal: immutable. Query use: tamper detection.
- Privacy: private-personal. Placement: snapshot property.

#### R-14 `RecommendationOption.subjectUid` / `subjectType`
- Definition: the shared thing considered.
- Type: String / 1; enum of shared labels / 1.
- Namespace: shared `hu:<type>:<opaque>`.
- Example: `hu:product-variant:synthetic-sleepwell-magnesium-us-capsule`, `ProductVariant`.
- Counterexample: a product name string.
- Absence: not allowed. Kind: operational. Temporal: immutable.
- Query use: replay join; "how often was X considered" (PCS-side aggregate only).
- Privacy: private-personal (the link between a person and an option). Placement: option property; uid reference only, never a relationship to the shared node.

#### R-15 `disposition`
- Definition: what the policy did with the option.
- Type: enum (`SELECTED`, `ALTERNATIVE`, `REJECTED`, `BLOCKED`) / 1 / required.
- Example: `REJECTED`. Counterexample: `CHOSE` (that is the person's `UserDecision`).
- Kind: calculated. Temporal: immutable. Query use: CQ-RC-01, CQ-RC-05, F-V11.
- Privacy: private-personal. Placement: option property.

#### R-16 `rejectionReason`
- Definition: controlled reason for rejection.
- Type: enum (`INSUFFICIENT_APPLICABILITY`, `SAFETY_CONSTRAINT`, `USER_PREFERENCE`, `PRICE`, `AVAILABILITY`, `DOMINATED_BY_SELECTED`) / 0..1 / required when `REJECTED`.
- Example: `USER_PREFERENCE`. Counterexample: free text.
- Kind: calculated. Query use: CQ-RC-01. Privacy: private-personal. Placement: option property.

#### R-17 `rank`
- Definition: position among non-blocked options. Type: Integer / 0..1 / null when blocked.
- Example: `2`. Counterexample: a rank given to a blocked option.
- Kind: calculated. Query use: CQ-RC-01. Privacy: private-personal. Placement: option property.

#### R-18 `blockingConstraintUids`
- Definition: constraints that made the option ineligible.
- Type: List<String> / 0..n / required non-empty when `BLOCKED`.
- Namespace: shared `hu:constraint:` or safety assertion uids; private declaration uids when the constraint is personal.
- Example: `['hu:constraint:...']`. Counterexample: a lowered score with no block.
- Kind: calculated. Query use: CQ-RC-06, F-V11.
- Privacy: private-personal. Placement: option property.

#### R-19 Evidence reference lists: `evidenceAssertionUids`, `adjudicationUids`, `applicabilityUids`, `stateUids`, `offerObservationUids`
- Definition: the exact shared records (and state versions) the option's evaluation used.
- Type: List<String> / 0..n each.
- Namespace: shared uids.
- Example: `stateUids: ['hu:formulation:synthetic-sleepwell-fv-a1-as-first-recorded']`.
- Counterexample: the product uid alone (loses the version).
- Absence means: not used.
- Kind: operational. Temporal: immutable.
- Provenance: decision service read log at `evidenceRecordedAt`.
- Query use: replay (F-V2), CQ-RC-02, CQ-RC-07 (Q-3).
- Privacy: private-personal. Placement: option properties (PCS child table in production).

#### R-20 `UserDecision.decisionKind` / `optionUid` / `decidedAt`
- Definition: what the person did with the recommendation.
- Type: enum (`CHOSE`, `DECLINED`, `DEFERRED`) / 1; String / 0..1; DateTime / 1.
- Example: `CHOSE`, option a, `2026-04-10T09:05:00Z`. Counterexample: inferring `CHOSE` from `SELECTED`.
- Source: the person. Kind: asserted (by the person). Temporal: immutable; a later change of mind is a new `UserDecision`.
- Query use: CQ-RC-05. Privacy: private-personal. Placement: separate private occurrence.

### C. Private context (round 0008)

#### P-01 `UserContextVersion.measurementUids` (and `goalVersionUids`, `declaredConditionUids`, `declaredIntakeUids`, `preferenceKeys`)
- Definition: the private inputs that made up the person's context in this version.
- Type: List<String> / 0..n each.
- Namespace: private uids; `declaredConditionUids` and `declaredIntakeUids` are shared `Condition` / `ChemicalSubstance` / `IngredientMaterial` uids; `preferenceKeys` controlled keys.
- Example: `['hu:private-personal-measurement:synthetic-0001-m1']`. Counterexample: a measurement appended to an existing version.
- Absence means: none in this version.
- Source: the person, device imports, lab uploads. Kind: asserted (person) or observed (device/lab).
- Temporal: immutable; additions create a new version.
- Query use: CQ-PC-02, F-V1. Privacy: private-personal. Placement: versioned state in the PCS.

#### P-02 `PersonalMeasurement.metricUid` (+ `labTestUid`, `deviceUid`, `methodUid`)
- Definition: shared identity of what was measured and how.
- Type: String / 1 for metric; 0..1 others.
- Namespace: shared `hu:metric:`, `hu:lab-test:`, `hu:device:` uids; `Metric.loincCode` carries LOINC (e.g. 19123-9).
- Example: `hu:metric:serum-magnesium-mass-concentration`. Counterexample: the free-text test name on a report.
- Absence means: metric unresolved; the record is held but not comparable.
- Source: lab report parsing, device import mapping. Kind: observed plus resolution.
- Temporal: immutable. Provenance: `labReportUid`, `provenanceKind`.
- Query use: CQ-PC-06, CQ-PR-03, CQ-PR-04. Privacy: private-personal (the reference). Placement: PCS record property.

#### P-03 `PersonalMeasurement.valueNumber` / `unitCode`
- Definition: reported value and UCUM unit.
- Type: Float / 0..1; String / required with value.
- Units: UCUM. Example: `2.1`, `mg/dL`. Counterexample: value converted silently to another unit without recording the original.
- Absence means: see `resultQualifier`.
- Source: report or device. Kind: observed. Temporal: immutable.
- Query use: trigger evaluation. Privacy: private-personal. Placement: PCS record property.

#### P-04 `PersonalMeasurement.resultQualifier`
- Definition: which of the distinct result states applies.
- Type: enum (`NUMERIC`, `BELOW_DETECTION`, `ABOVE_QUANTIFICATION`, `NOT_MEASURED`, `INVALID_SPECIMEN`) / 1 / required.
- Example: `BELOW_DETECTION`. Counterexample: storing `0` for below detection.
- Absence: not allowed (INV-007 distinct states). Kind: observed. Query use: trigger evaluation correctness.
- Privacy: private-personal. Placement: PCS record property.

#### P-05 `PersonalMeasurement.effectiveAt` / `recordedAt`
- Definition: when the specimen or reading was taken / when the PCS recorded it.
- Type: DateTime / 1 each.
- Example: `2026-05-20T08:00Z` / `2026-05-22T12:00Z`. Counterexample: report print date used as `effectiveAt`.
- Source: report/device / PCS clock. Kind: observed / operational. Temporal: immutable.
- Query use: CQ-PR-03 recency (`maxBaselineAgeDays`); F-V1.
- Privacy: private-personal; never exported at more than year precision in de-identified contributions (Safe Harbor benchmark).
- Placement: PCS record properties.

#### P-06 `PersonalMeasurement.provenanceKind`
- Definition: how the value entered the PCS. Type: enum (`LAB_REPORT_UPLOAD`, `DEVICE_IMPORT`, `MANUAL_ENTRY`) / 1.
- Example: `LAB_REPORT_UPLOAD`. Counterexample: `MANUAL_ENTRY` for a parsed PDF.
- Kind: operational. Query use: reliability weighting by policy. Privacy: private-personal. Placement: PCS record property.

#### P-07 `SharingGrant.granteeKind` / `granteeRef`
- Definition: who may receive data. Type: enum / 1; String (opaque PCS id) / 1.
- Example: `COACH`, `pcs-grantee:synthetic-coach-01`. Counterexample: a grantee email stored in the shared graph.
- Source: the person. Kind: asserted (by the person). Temporal: immutable per grant version.
- Query use: CQ-PC-04, F-V10. Privacy: private-personal. Placement: versioned state in the PCS (FHIR Consent provision actor).

#### P-08 `SharingGrant.dataCategories` / `recordUids`
- Definition: what may be shared. Type: List<enum> / 1..n; List<String> / 0..n (optional narrowing).
- Example: `['RECOMMENDATION_SNAPSHOTS', 'PROTOCOL_IN_USE']`. Counterexample: "all my data" without categories.
- Kind: asserted. Query use: disclosure check. Privacy: private-personal. Placement: grant property.

#### P-09 `SharingGrant.purpose` / `permittedActions` / `decision`
- Definition: purpose of use; allowed actions (`VIEW`, `EXPORT`, `CONTRIBUTE_DEIDENTIFIED`); `PERMIT` or `DENY`.
- Type: enum / 1; List<enum> / 1..n; enum / 1.
- Example: `COACHING_REVIEW`, `['VIEW']`, `PERMIT`. Counterexample: `VIEW` treated as permission to publish.
- Kind: asserted. Query use: F-V10; contribution pipeline gate. Privacy: private-personal. Placement: grant properties.

#### P-10 Grant period (`HAS_SHARING_GRANT.validFrom` / `validTo`)
- Definition: how long the grant applies. Type: DateTime / both required for grants (every grant expires; renewal is a new episode).
- Example: `2026-04-12` to `2026-07-12`. Counterexample: a revocation written as an earlier `validTo` on the original episode.
- Absence: not allowed for grants. Kind: asserted. Temporal: revocation is a new episode with `validTo` at revocation and `recordedFrom` at revocation, never earlier.
- Query use: CQ-PC-04. Privacy: private-personal. Placement: episode properties (round 0007 profile).

#### P-11 `DisclosureEvent.grantUid` / `occurredAt` / `dataCategories`
- Definition: one actual disclosure and the grant that authorized it.
- Type: String / 1; DateTime / 1; List<enum> / 1..n.
- Example: coach view on `2026-04-20`. Counterexample: a disclosure without a grant.
- Kind: operational. Temporal: immutable. Query use: CQ-PC-04 audit; F-V10.
- Privacy: private-personal. Placement: PCS occurrence.

#### P-12 `PendingItem.pendingKind`
- Definition: what the person is waiting on.
- Type: enum (see catalog) / 1. Example: `AWAITING_LAB_RESULT`. Counterexample: a free-text "todo".
- Kind: operational. Query use: CQ-PC-03. Privacy: private-personal. Placement: PCS occurrence property.

#### P-13 `PendingItem.expectedBy`
- Definition: planned or promised time of resolution (planned time, not valid time).
- Type: DateTime / 0..1 / nullable. Example: delivery estimate `2026-04-15`. Counterexample: `resolvedAt`.
- Absence: no expectation stated. Source: merchant estimate, protocol period end, lab turnaround. Kind: asserted.
- Query use: overdue items. Privacy: private-personal. Placement: occurrence property.

#### P-14 `PendingItem.blocksUid` / `openedAt` / `resolvedAt` / `resolvedByUid`
- Definition: what the item blocks; when opened; when resolved and by which record.
- Type: String / 1; DateTime / 1; DateTime / 0..1; String / 0..1.
- Example: resolved by `hu:private-personal-measurement:synthetic-0001-m1`. Counterexample: resolving by editing the blocked snapshot.
- Kind: operational. Temporal: `resolvedAt` written once. Query use: CQ-PC-03.
- Privacy: private-personal. Placement: occurrence properties.

#### P-15 `PurchaseEvent.eventKind` (+ `offerUid`, `productVariantUid`, `packageConfigurationUid`, `lotUid`)
- Definition: one step of the purchase and use lifecycle, with shared references.
- Type: enum (`INTENDED`, `ORDERED`, `DELIVERED`, `STARTED_USE`, `PAUSED_USE`, `STOPPED_USE`, `RETURNED`) / 1; Strings / 0..1.
- Example: `DELIVERED` with variant uid. Counterexample: a shared `Product -[:PURCHASED_BY]-> Person` edge.
- Source: person, merchant integration. Kind: asserted or observed. Temporal: immutable occurrences.
- Query use: CQ-PC-07. Privacy: private-personal. Placement: PCS occurrences.

#### P-16 `ErasureTombstone.subjectKeyHash` / `erasedAt` / `scope` / `propagationStatus`
- Definition: content-free record that an erasure happened and how far it has propagated.
- Type: String / 1; DateTime / 1; enum / 1; map of projection id to status / 1.
- Example: `propagationStatus: {searchIndex: DONE, analytics: PENDING}`. Counterexample: retaining snapshot content in the tombstone.
- Kind: operational. Query use: CQ-PC-05. Privacy: private-personal (minimal). Placement: PCS occurrence.

#### P-17 `contributionToken` (on shared contributed records)
- Definition: HMAC of the authorizing grant uid with a PCS secret; lets the PCS find and withdraw a contribution without the shared graph knowing the person.
- Type: String / 0..1. Example: `hmac:...`. Counterexample: the grant uid or user uid in clear.
- Absence: not a personal contribution. Source: publication pipeline. Kind: calculated.
- Query use: withdrawal on revocation or erasure. Privacy: public (opaque). Placement: property on the shared contributed record.

#### P-18 `PersonalApplicabilityAssessment` dimensions (`sharedApplicabilityUid`, `userContextVersionUid`, `populationMatch`, `doseMatch`, `durationMatch`, `methodVersion`)
- Definition: person-specific match of shared applicability to a context version.
- Type: Strings / enums / 1 each.
- Example: `populationMatch: PARTIAL`. Counterexample: shared `EvidenceApplicability` linked to `UserContext`.
- Kind: calculated. Query use: CQ-EV-04 for a person. Privacy: private-personal. Placement: private evidence assessment.

### D. Protocols (round 0008)

#### PR-01 `ProtocolEdition.editionLabel`
- Definition: the source's own version label for this edition. Type: String / 0..1 / nullable.
- Example: `v1`; protocols.io version number. Counterexample: a label invented by BellLabs.
- Absence means: the source shows no label (common for pages that change in place).
- Source: protocol page or platform. Kind: observed. Temporal: immutable.
- Query use: display; source-versioned change provenance. Privacy: public. Placement: edition property.

#### PR-02 `ProtocolStep.stepKey`
- Definition: identifier stable across editions of one protocol for "the same step".
- Type: String / 1 / required. Namespace: per-protocol slug.
- Example: `magnesium-evening`. Counterexample: the step's display text (changes with wording).
- Source: BellLabs alignment of steps across editions. Kind: operational (alignment), reviewed.
- Temporal: immutable. Query use: CQ-PR-01 diff. Privacy: public. Placement: step property.

#### PR-03 `ProtocolStep.requirementLevel` (refines live `isOptional`)
- Definition: how the source frames the step's necessity.
- Type: enum (`ESSENTIAL`, `RECOMMENDED`, `OPTIONAL`, `CONDITIONAL`, `NOT_STATED`) / 1.
- Example: `CONDITIONAL` for "Full body MRI annually (if over 40 or a family history of high risk)".
- Counterexample: `ESSENTIAL` derived from `isOptional: false`.
- Absence: not allowed (`NOT_STATED` instead). Source: protocol text. Kind: asserted.
- Temporal: immutable per edition. Query use: CQ-PR-02, V-525. Privacy: public. Placement: step property (edition payload).

#### PR-04 `ProtocolStep.requirementBasis`
- Definition: whether the level is stated by the source or inferred editorially.
- Type: enum (`STATED_BY_SOURCE`, `EDITORIAL_INFERENCE`, `NOT_STATED`) / 1.
- Example: `EDITORIAL_INFERENCE` for items under an "Other Advanced Therapies" heading. Counterexample: BellLabs mechanistic judgment (that is an assessment).
- Kind: operational classification. Query use: CQ-PR-02. Privacy: public. Placement: step property.

#### PR-05 `ProtocolStep.notReportedFields`
- Definition: step fields the source explicitly leaves unstated (distinct from null meaning not extracted).
- Type: List<String> / 0..n. Namespace: step field names.
- Example: `['durationDaysMin', 'durationDaysMax']`. Counterexample: listing a field the extractor simply skipped.
- Absence means: no fields declared unreported.
- Source: extraction review. Kind: observed (absence in source). Query use: CQ-PR-03.
- Privacy: public. Placement: step property; a per-field state node would be heavier than the question needs.

#### PR-06 `ProtocolStep.payloadHash`
- As T-15, for one step. Query use: CQ-PR-01 modified/unchanged detection.

#### PR-07 `DEPENDS_ON.dependencyKind`
- Definition: how one step depends on another.
- Type: enum (`REQUIRES_PRIOR_COMPLETION`, `REQUIRES_RESULT_OF`, `CONCURRENT_WITH`, `MUTUALLY_EXCLUSIVE_WITH`) / 1.
- Example: magnesium step `REQUIRES_RESULT_OF` baseline measurement. Counterexample: ordering only (use `HAS_STEP.orderIndex`).
- Kind: asserted. Query use: CQ-PR-02. Privacy: public. Placement: relationship property (qualifies only this pair).

#### PR-08 `HAS_CONSTRAINT.constraintRole` and `Constraint.constraintKind` (refines live `constraintType` String)
- Definition: role of a constraint for a step (`APPLIES_WHEN`, `CONTRAINDICATED_WHEN`, `REQUIRES_BEFORE`); kind of constraint (`POPULATION`, `CONDITION_PRESENT`, `CONDITION_ABSENT`, `MEASUREMENT_THRESHOLD`, `PHASE`, `TIME_WINDOW`, `CO_INTERVENTION`).
- Type: enums / 1 each.
- Example: `APPLIES_WHEN` + `POPULATION` for "if over 40". Counterexample: the free-text `constraintType: 'age'`.
- Kind: asserted. Query use: CQ-PR-02, CQ-PR-03. Privacy: public. Placement: relationship property / node property.

#### PR-09 `MeasurementPlan.planTiming` / `requiredForEvaluation` / `maxBaselineAgeDays` / `cadenceMinDays` / `cadenceMaxDays`
- Definition: when the plan measures; whether its result is needed to evaluate the protocol for a person; maximum age of a baseline value.
- Type: enum (`BASELINE`, `DURING`, `FOLLOW_UP`, `PERIODIC`) / 1; Boolean / 1; Integer days / 0..1.
- Example: `PERIODIC` for "Blood draw, every 3 to 6 months" (`cadenceMinDays` 90, `cadenceMaxDays` 183; a range, never a midpoint). Counterexample: a person's actual blood draw.
- Kind: asserted (source) / operational (BellLabs default for max age). Query use: CQ-PR-03.
- Privacy: public. Placement: node properties.

#### PR-10 `ProtocolAdjustmentRule.triggerKind` / `comparator` / `thresholdValue` / `thresholdUnitCode` / `triggerAction` / `ruleBasis` (refines live `ruleType` String)
- Definition: when an observation should trigger review and what to do.
- Type: enums / Float / UCUM String / enums.
- Example: `THRESHOLD_CROSSED`, `OUTSIDE_REFERENCE_RANGE`, `REVIEW`, `STATED_BY_SOURCE`. Counterexample: a BellLabs safety rule stored as if the source stated it.
- Kind: asserted (source) or policy (`BELLLABS_SAFETY_POLICY`, scoped to a PolicyVersion).
- Query use: CQ-PR-04; PCS trigger evaluation. Privacy: public (source) / internal (policy). Placement: node properties.

#### PR-11 `ProtocolAdoptionVersion.adoptedEditionUid`
- Definition: the single public edition a person adopted in this version.
- Type: String / 1 / required. Namespace: `hu:protocol-edition:`.
- Example: edition 2 uid. Counterexample: the `Protocol` uid (loses the version).
- Source: the person. Kind: asserted. Temporal: immutable; switching editions is a new adoption version.
- Query use: CQ-PR-05; trigger evaluation scope. Privacy: private-personal. Placement: PCS versioned state (FHIR CarePlan `instantiatesCanonical`).

#### PR-12 `ProtocolDeviation.stepKey` / `deviationKind` / personal values / `substituteSubjectUid`
- Definition: how the person's use departs from the adopted edition.
- Type: String / 1; enum (`OMITTED`, `MODIFIED_DOSE`, `MODIFIED_TIMING`, `ADDED_STEP`, `SUBSTITUTED_PRODUCT`) / 1; values / 0..1; String / 0..1.
- Example: `fixed-bedtime`, `MODIFIED_TIMING`. Counterexample: editing the public step to match the person.
- Kind: asserted (person). Query use: CQ-PR-05. Privacy: private-personal. Placement: PCS versioned state.

#### PR-13 `privacyClass` (catalog convention, also stored on shared nodes)
- Definition: where an element may live: `public`, `internal`, `private-personal`.
- Type: enum / 1 per catalog element; on shared nodes / 1.
- Example: `internal` on `PolicyVersion`. Counterexample: null read as public.
- Absence means: a validation finding (V-522), never public by default.
- Source: catalog. Kind: operational. Query use: projection filtering; V-520 to V-522.
- Placement: catalog metadata plus node property for defense in depth; Neo4j RBAC on this property is not the primary control because DENY rules fail open on nulls.

### E. Live GraphQL field refinements (seam)

#### L-01 `TemporalMetadata` additions: `validFromPrecision`, `validToPrecision`, `validFromBasis`, `validToBasis`, `assertionUid`, `relationshipUid`
- As T-03 to T-06, T-13, T-14. Existing `confidence` and `notes`: not written for new records.

#### L-02 `*Snapshot` additions: `payloadHash`, `validFromPrecision`, `validToPrecision`, `validFromBasis`, `validToBasis`, `assertionUids`
- Meaning as T-15 and A-section cards; node-level time remains the projection of a single episode.

#### L-03 `RecommendationMetadata` additions: `assertionUid`, `validFrom`, `validTo`, `recordedFrom`, `recordedTo`, precisions, bases
- Meaning: a source's recommendation as a projection of an assertion. `strength` and `confidence` not written for new records.
