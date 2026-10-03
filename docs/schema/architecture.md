# Schema Architecture and Reasoning

Status: provisional
Updated: 2026-10-03 (catalog 0.2.0; rounds 0002 to 0009 integrated)

## 1. The stable semantic kernel

Domain labels grow over time, but all graph content belongs to one of six high-order archetypes:

| Archetype | Meaning | Examples |
|---|---|---|
| `Entity` | An identity that persists while descriptions change | Product, Organization, Ingredient Material, Study, Metric, Protocol |
| `VersionedState` | A state of an identity valid for a bounded scope or time | Formulation Version, Registration Version, Assay Version, Algorithm Version, Protocol Edition, Regulatory Status |
| `Occurrence` | Something that happened | Test Execution, Activity, Source Revision Event, Mechanism Evidence Context, Recommendation Snapshot |
| `InformationArtifact` | A representation or record of something | Source Snapshot, Source Locator, Label Snapshot, Publication, Study Result, Chunk |
| `Assertion` | A proposition attributable to a source or agent | "This label declares 250 mg NR"; a speaker's utterance (Claim Occurrence) |
| `EvidenceAssessment` | An adjudicated evaluation of evidence or applicability | Adjudication, Evidence Applicability, Endpoint Classification, Comparability Assessment |

An item may carry several Neo4j labels, for example `(:Entity:Product)`, `(:InformationArtifact:SourceSnapshot:LabelSnapshot)` or `(:Assertion:ClaimOccurrence)`. Every node has exactly one archetype label. Every node type and property declares a `privacyClass` (public, internal, private-personal); private-personal types never enter the shared graph (section 13).

## 2. Assertion-centered truth model

The authoritative ingest pattern is:

```text
(Source)-[:HAS_SNAPSHOT]->(SourceSnapshot)             // immutable capture with contentHash and its basis
(SourceSnapshot)-[:HAS_LOCATOR]->(SourceLocator)       // typed selector: quote, position, media time, page, region
(Assertion)-[:HAS_SUBJECT]->(Entity or State or Artifact)
(Assertion)-[:HAS_OBJECT]->(Entity or State or Artifact)   // relational proposition
(Assertion)-[:SUPPORTED_BY]->(SourceLocator)
(Assertion)-[:ASSERTED_BY]->(Person | Organization | Agent | PseudonymousActor | AnonymousActor)   // at most one
(Assertion)-[:WAS_GENERATED_BY]->(Activity)-[:WAS_ASSOCIATED_WITH]->(Agent)
(Adjudication {adjudicationKind})-[:EVALUATES]->(Assertion)
(Adjudication)-[:SUPPORTED_BY|CONTRADICTED_BY]->(SourceLocator)
(newer Assertion)-[:SUPERSEDES {supersessionKind}]->(older Assertion)
```

Literal assertions use typed fields (`valueString`, `valueNumber`, `valueBoolean`, `unitCode`) instead of an object node. The controlled `predicate` identifies proposition semantics. Three further properties qualify what kind of proposition it is:

- `basisKind`: the epistemic basis in the source or in BellLabs (DIRECT_MEASUREMENT, INFERRED_FROM_MEASUREMENT, CITED_FROM_PRIOR_WORK, HYPOTHESIS, CALCULATED). Mechanism predicates require it. A CALCULATED assertion carries `derivationRule` and `DERIVED_FROM_ASSERTION` inputs, so a salt-to-active-moiety conversion is neither a label declaration nor a measurement and can be regenerated.
- `assertionBasis` and `speechAct`: on what basis the asserter presents it (personal experience, manufacturer claim, study result, mechanism reasoning) and what the utterance does (states, reports practice, recommends, cautions). A practice report is not a recommendation.
- `polarity`: positive, negative, mixed, unknown. "No adverse events were reported" is a negative report, not evidence of absence.

**Status is capture fidelity, never truth.** `Assertion.status` records whether the record is an accurate capture of what the asserter said in that source, and is a current projection of CAPTURE_FIDELITY adjudications and SUPERSEDES records. Whether the proposition is supported lives on SUPPORT adjudications (`verdict`) and on evidence assessments. An ACCEPTED assertion from a retracted paper stays ACCEPTED: it still records what the paper said; a new SUPPORT adjudication records that BellLabs no longer relies on it.

**One asserter per assertion.** An Assertion has at most one asserter, and a Claim Occurrence exactly one asserter and one container. The 0.1.0 wording "supported by multiple sources" is narrowed: corroboration is several Assertions `INSTANCE_OF` one `Claim` (the proposition identity), never one Assertion with two asserters. This keeps echo chains countable (round 0006).

A first-class Assertion can therefore:

- survive a source correction (the correction is a new Assertion that `SUPERSEDES` it);
- be contradicted by other assertions and adjudications without being deleted;
- carry valid time, recorded time, jurisdiction, and extraction lineage;
- be reviewed independently;
- retain the source's claim after BellLabs rejects it;
- support alternative entity-resolution hypotheses;
- be retold: a later retelling is a distinct Assertion linked by `RETELLS`, and any lost qualification is recorded on a `RetellingFidelityAssessment`, never on either assertion.

The confidence vector stays separate: extraction, resolution, source reliability, evidence strength, applicability, adjudication, decision. A generic `confidence` is deprecated; `extractionConfidence` must name the Activity and method version that produced it.

## 3. Three relationship classes

Every relationship type is classified in the catalog:

1. `structural`: defines the internal shape of a captured record, such as a Label Snapshot having a Label Declaration.
2. `asserted`: authoritative only through an Assertion. An asserted edge is a regenerable projection of exactly one Assertion and follows the `asserted_edge` profile: `relationshipUid`, `assertionUid`, `recordedFrom`, `recordedTo`, and the assertion's valid bounds with their precision and basis.
3. `derived`: a regenerable traversal shortcut, such as `Product CONTAINS IngredientMaterial`. It carries `projectionOfAssertionUid` when it projects one asserted edge, or `derivationRule` plus `derivedFromAssertionUids` when it rests on several assertions. The cited predicate is never the premise of a forbidden implication for the edge type, so an `ENDORSES_PRODUCT` edge can never cite an `ADVISES_ORGANIZATION` assertion.

A derived relationship must never be the only historical record.

## 4. Time

The model preserves distinct clocks:

- `validFrom` / `validTo`: when the assertion or state was true in the modeled world, each bound with its own `validFromPrecision` / `validToPrecision` (INSTANT to DECADE, stored as the first instant of the period) and `validFromBasis` / `validToBasis` (STATED_BY_SOURCE, PUBLICATION_PROXY, OBSERVATION_ONLY, INFERRED, UNKNOWN);
- `recordedFrom` / `recordedTo` on states and asserted edges, `recordedAt` / `recordedTo` on assertions and assessments: when BellLabs believed it, assigned by the ingestion service at commit and never backdated;
- `observedAt`: when a webpage, offer, label, or price is known to have been displayed (an archive capture date for a late source);
- `retrievedAt`: when BellLabs fetched the bytes;
- `publishedAt`: when a source artifact was issued;
- `effectiveFrom` / `effectiveTo`: the source-stated validity of a versioned payload; query validity comes from the attachment episode.

Unknown temporal bounds remain `null`; they are not replaced with ingestion time, and a null `validTo` means an unknown end, not "ongoing". Valid time is immutable after commit. A change in belief is a new recorded-time episode, and the only later write allowed on an episode is setting `recordedTo` once.

Two events that look alike produce different graph changes (round 0007):

- **A correction** ("the source was corrected in June"): a new Assertion `SUPERSEDES {SOURCE_CORRECTION}` the old one; the old assertion's valid time is untouched and its `recordedTo` closes; the corrected state has no current attachment for the corrected interval.
- **A fact ending** ("the fact ceased in June"): a new episode `SUPERSEDES {VALIDITY_BOUNDED}` with `validTo` set; the old state stays attached for its now-bounded interval in current recorded time.

A **late-arriving historical fact** keeps its past `validFrom`; `recordedFrom` is the commit time; the archive capture time goes in `SourceSnapshot.observedAt`. The system therefore never pretends to have known the fact earlier.

Mutually exclusive attachments (declared in `predicateExclusivity`, for example one Formulation Version per Variant per jurisdiction) may not definitely overlap in both valid and recorded time; overlaps that depend on an unknown or imprecise bound go to a review queue. Non-exclusive assertions may overlap freely.

Publisher revisions (erratum, retraction, expression of concern, new version, silent change, withdrawal, reinstatement) are `SourceRevisionEvent` occurrences linked to the source, the prior and resulting snapshots and the notice. Snapshots and adjudications are immutable; historical adjudications keep pointing at the snapshots they examined.

## 5. Product and formulation backbone

```text
Product
  -> ProductVariant
    -> PackageConfiguration
    -> FormulationVersion
      -> IngredientComponent {quantity, unitCode, quantityBasis, massBasis, amountReferent}
        -> IngredientMaterial
          -> ChemicalSubstance / ChemicalForm / BotanicalPreparation / MicrobialPreparation / MaterialMixture
```

`Product`, `ProductVariant`, and `FormulationVersion` are intentionally separate:

- Product is the enduring marketed concept.
- Product Variant is a consumer-distinguishable realization (strength, dosage form, flavor, jurisdiction, or other identity-relevant choice).
- Formulation Version is a time-bounded composition for a variant.
- Package Configuration is count, package form, and quantity; it does not automatically create a formulation.
- Offer is a merchant's time-bounded proposition and never establishes product identity by itself.

The precise lifecycle test for variant versus formulation change remains provisional (round 0001, `OPEN-QUESTIONS.md`). The live `Compound` type merges into `ChemicalSubstance`; the live `CompoundForm` splits into `ChemicalForm`, `IngredientMaterial` and the dosage form on the variant or intervention; the live `CONTAINS_COMPOUND_FORM` edge with dose metadata is a derived projection of Ingredient Components.

## 6. Ingredient composition is not a flat `CONTAINS` edge

`IngredientComponent` is a contextual component inside one formulation. It carries role, order, quantities, serving basis, mass basis and nesting. It points to an `IngredientMaterial`, which represents the actual material identity.

An Ingredient Material can be:

- a chemically defined substance or specified salt/form;
- a branded material governed by a specification;
- a botanical preparation defined by taxon, plant part, extraction, and standardization;
- a microbial preparation defined by organism, strain, and preparation;
- a mixture with nested material components.

`PROVIDES_CONSTITUENT` is not `QUANTITATIVELY_CONTAINS`. A tomato/rosemary extract mixture that says it provides carotenoids does not become synonymous with lycopene and does not establish a measured lycopene amount.

A declared amount refers to its `amountReferent` (US Supplement Facts: a nutrient as the nutrient, a listed ingredient as listed, a proprietary blend total, an extract total, a marker constituent). Active-moiety and nutrient-equivalent amounts are CALCULATED assertions with a cited rule and inputs; they are never label declarations and never measurements.

## 7. Evidence and applicability

A Study is not its registration, protocol, publication, arm, intervention, or result. The evidence path is explicit:

```text
Study -> StudyArm -> StudyIntervention -> InterventionComponent -> IngredientMaterial (as administered at study time)
Study -> TrialRegistration -> RegistrationVersion {overallStatus, enrollmentCount, resultsPosted, dates, design}
Study -> OutcomeDefinition {measureKind} -> StudyResult {analysisKind, comparisonKind, statisticalConclusion}
Publication -> REPORTS_ON -> Study;  Publication -> ANALYZES_DATASET -> Dataset
EvidenceApplicability -> HAS_EVIDENCE_TARGET -> StudyIntervention | mechanism Assertion
EvidenceApplicability -> ASSESSES_APPLICABILITY_TO -> Product | ProductVariant | FormulationVersion | IngredientMaterial | UseContextProfile
EvidenceApplicability -> HAS_DIMENSION -> ApplicabilityDimension {dimension, dimensionClass, verdict, ratio, missingFacts}
```

A study reaches a commercial product only through `EvidenceApplicability` (INV-201). The live `Study -EVALUATES-> Product` edge is read-only legacy and is never written for a current product. Applicability dimensions are categorical (material identity with an ordered level, active composition, dosage form, route, population, comparator, outcome relevance, design and quality), continuous with a ratio computed only when quantity basis and mass basis match on both sides (dose, schedule, duration, exposure), or explanation-only and never scored (background context, recency and corrections). UNKNOWN and NOT_ASSESSED stay distinct, and each dimension lists its missing facts. A composite score, if exposed, is a decision-layer projection with a method version.

Outcomes have four layers: what was measured (`measureKind`), how each source ranked it (per-source priority assertions), its role in inference (`EndpointClassification` with BEST biomarker category, surrogate validation level and context of use), and "patient-important", which is derived. Surrogate status never transfers across contexts of use. A null primary result is INCONCLUSIVE unless a non-inferiority margin supports EVIDENCE_OF_NO_MEANINGFUL_EFFECT; secondary and subgroup results after a null primary enter a synthesis only as supportive or hypothesis-generating. A reported zero adverse-event count carries its collection method. `EvidenceSynthesis` is versioned and each version records what triggered it and the effect on the verdict, so "which findings in a period changed the evidence picture" is an assessment with criteria.

Mechanisms (round 0003): a mechanism assertion records `basisKind` and, when directly measured, exactly one `MechanismEvidenceContext` (setting, species, tissue or compartment, exposure and route, or the study arm when the context is a human trial). A level change targets a compartment-specific measurand: NAD+ in whole blood is not NAD+ in muscle. An ingredient-level mechanism never implies that a commercial formulation delivers that exposure; the EXPOSURE dimension may be MATCH or PARTIAL only when human exposure evidence exists for the product's own material and form. Live mechanism edges are derived projections of directly measured, accepted assertions.

## 8. Quality chain

```text
ProductLot -> TestSample -> TestExecution -> MeasuredResult
TestExecution -> TestMethod
TestExecution -> TestingLaboratory
MeasuredResult -> SpecificationCriterion -> SpecificationVersion
CertificateOfAnalysis -> CERTIFIES_RESULTS_FOR -> ProductLot/TestExecution
CertificationListing -> HAS_CERTIFICATION_SCOPE -> CertificationScope -> COVERS -> Product/ProductVariant/ProductLot/Facility/TradeItemIdentifier
```

A statement such as "conforms to internal specs" can be represented as a sourced pass/fail assertion. It does not create absent measured values, laboratory identities, methods, uncertainty, or a signed Certificate of Analysis.

## 9. Organizations are role relationships

Legal entity, brand, facility, laboratory, and certification body remain separate identities. Roles such as marketer, distributor, manufacturer, supplier, specification owner, sponsor, funder, CRO, patent licensee, marketplace host, seller of record, fulfillment provider, content sponsor, investor and board member are time-bounded asserted relationships under the `asserted_edge` profile.

No role implies another unless an explicit, source-backed assertion exists. In particular:

```text
ADVISES_ORGANIZATION != ENDORSES_PRODUCT
SPONSORS_STUDY != EXECUTES_STUDY
DISTRIBUTES_PRODUCT != MANUFACTURES_PRODUCT
LICENSES_PATENT != OWNS_STUDY
HOSTS_LISTING | LISTS_OFFER | FULFILLS_OFFER | AFFILIATE_FOR_OFFER != SELLS_PRODUCT   (SELLS_PRODUCT is derived from SELLER_OF_RECORD_FOR only)
PROVIDES_INVESTIGATIONAL_PRODUCT != SUPPLIES_INGREDIENT_MATERIAL
SPONSORS_CONTENT | any FINANCIAL_INTEREST != ENDORSES_PRODUCT
RECOMMENDS_PRODUCT (a source) != BELLLABS_RECOMMENDS
```

Financial relationships form one predicate family, FINANCIAL_INTEREST, with typed members. Whether a tie is relevant to a statement, and where it was disclosed, is a `ConflictRelevanceAssessment`. A disclosed tie never makes a claim false, and an undisclosed one never makes it true; "not found in a partial capture" is not "not disclosed".

## 10. Regulatory, manufacturing readiness, and IP semantics

Regulatory events and statuses are jurisdiction-specific artifacts and states, not badges on a product. The model separates `RegulatorySubmission` (what was filed), `RegulatoryResponse` (what the agency answered, with a closed per-pathway response kind and the agency's own disclaimer text) and `RegulatoryStatus` (a time-bounded state with a closed `statusKind`). Only `APPROVAL` is approval. Establishment registration is a status of a Facility only. NDI acknowledgement, GRAS "no questions", 510(k) clearance, De Novo authorization, enforcement discretion, orphan designation and approval stay distinct, and a company's restatement of an agency response is a separate assertion (`CHARACTERIZES_REGULATORY_RESPONSE`).

Manufacturing readiness is a `ManufacturingCapability` versioned state (OPERATING, PILOTING, PLANNED, SUSPENDED, DISCONTINUED) attached through a time-bounded asserted edge. "Promoted" is not a stage; it is the kind of source that made the claim. An OPERATING state requires a non-marketing source or a SUPPORT adjudication. What a filing disclosed and what a home page promotes are two assertions; which one BellLabs relies on is an adjudication.

Patent family, application, grant, and claim; assignee, inventor, and licensee; trademark and the branded material sold under it remain separate as in 0.1.0.

## 11. Diagnostics

What a test measures and what it infers are different nodes. `Biomarker` is the biological referent; `Metric` is the measurand (a LOINC code identifies this level only); `LabTest` is the test a lab offers; `AssayVersion` is how a given lab ran it (method, instrument, kit, software version, calibration traceability); `AlgorithmVersion` is the version behind a score, with a `versionBasis` that says whether the version is a vendor string, a publication, an unversioned service endpoint, or unknown; `ReferenceIntervalVersion` is bound to one assay version and records how the interval was derived. Two results share a trend axis only if they share a version or a `ComparabilityAssessment` covers the pair; a within-version score difference is not a measured biological change until a reliability source licenses it. `DiagnosticResult` is a contract only: `PersonalMeasurement` implements it in the private store, `Observation` for public, protocol-linked, source-attributed results.

## 12. Claims, documents, and the live evidence pipeline

The live pipeline `Document -> DocumentTextVersion -> Segmentation -> Chunk` and the catalog chain `Source -> SourceSnapshot -> SourceLocator` are aligned without a third vocabulary: a live `Document` is a `Source` (one retrieval endpoint per canonical URI); a `DocumentTextVersion` comes from exactly one `SourceSnapshot`; a `Chunk` is a derived retrieval unit that is never a locator, because re-chunking changes its text; live `SUPPORTED_BY -> Chunk` edges are derived shortcuts that must name their `SourceLocator`. A `Claim` is the identity of a proposition and carries no truth value or evidence strength. A `ClaimOccurrence` is `(:Assertion:ClaimOccurrence)`: one speaker, one container (Episode or Document), supported by locators in that container's renditions, with `assertionBasis` and `speechAct`. `RelationshipAssertion` is kept for structured statements with no utterance (table rows, registry fields). `Claim.evidenceStrength` moves to a `ClaimEvidenceAssessment`. Speakers who are known only by a handle are `PseudonymousActor`s; a link to a Person is a resolution hypothesis.

The five provenance states any answer must separate are: someone said it (Assertion plus `ASSERTED_BY`); a source supports it (`SUPPORTED_BY` a locator in a snapshot); evidence warrants a broader conclusion (EvidenceAssessment or SUPPORT Adjudication); an agent used the source (`Activity` with `USED`, `WAS_GENERATED_BY`, `WAS_ASSOCIATED_WITH`); a policy allows a downstream use (`AUTHORIZED_BY {useKind}` to a `PolicyVersion`). The mapping to W3C PROV-O is recorded in round 0006.

## 13. Private user context and recommendation history

The shared world model and private user context are logically and physically separate (round 0008). A transactional private context store (PostgreSQL recommended) is the system of record for goals, personal context versions, measurements and lab reports, protocols in use and deviations, recommendation snapshots and user decisions, consent and sharing grants, and purchase lifecycle. The shared graph holds zero private-personal nodes, properties, relationships or private uid values (INV-506); `PolicyVersion` and `DecisionCriterion` are internal and live in the shared graph. Neo4j role-based access control was rejected as the primary control because it is Enterprise-only and a DENY rule fails open on a null or misspelled criterion; it remains defence in depth where available.

Private records reference shared things only by uid plus the recorded-time viewpoint they used. A shared uid merge publishes a redirect; private records are not rewritten. Erasure deletes whole records, leaves a content-free `ErasureTombstone`, and propagates to derived copies and consented de-identified contributions through an HMAC withdrawal token.

A recommendation is not `Product-[:RECOMMENDED_FOR]->Goal`. It is a replayable, insert-only `RecommendationSnapshot` that keeps the personal-context version, the evidence versions and viewpoint (assertion, adjudication and applicability uids with the recorded time used), the options considered with their disposition (SELECTED, ALTERNATIVE, REJECTED, BLOCKED), rationale, uncertainty, intended use, and the policy and algorithm version. The person's own choice is a separate `UserDecision`. A new measurement creates a new `UserContextVersion` and never rewrites the earlier decision; a correction of a shared assertion after the decision is a new recorded-time episode, and a replay at the decision's viewpoint still returns the old belief.

Public protocols are `Protocol -> ProtocolEdition -> ProtocolStep {stepKey, requirementLevel, dependencies, constraints, review triggers}`; `ProtocolVersion` keeps its study-protocol meaning. A person's adoption is a private `ProtocolInUse` with deviations; adopting an edition never implies following every step. Live `Observation` stays a public, protocol-linked, source-attributed type; it is not the private measurement store.

## 14. Agent-facing uncertainty and evolution

Agents produce `ResolutionHypothesis` and `GraphCandidate` records in the research runtime before authoritative commit. In the committed graph, uncertainty remains visible through Assertion status (capture fidelity), SUPPORT adjudications, evidence assessments with method versions, and modeling-issue references. Every projection an agent receives is purpose-bound (intent, competency questions, modules, temporal viewpoint, access tier, trace depth) and never includes a private-personal module unless the tier is OWNER_PRIVATE.

Required distinctions:

- `unknown`: not currently established;
- `unmeasured`: no measurement was performed or available;
- `notReported`: source did not report it;
- `belowDetection`: a measurement had this outcome;
- `absent`: evidence supports non-presence;
- `false`: an assertion was adjudicated false.

The schema itself uses maturity states. Retrieval telemetry, failed resolution cases, and validation results should determine which provisional concepts are promoted, split, merged, or deprecated.

## 15. What remains outside this release

Media semantics, events and narrative, consumer devices (firmware is handled as an assay's software version for now), safety and constraints (a candidate module), and the calibration of applicability scoring remain seams or open rounds. Genomics and clinical care are not modeled. The live GraphQL types in these areas keep their meaning and are projected unchanged.
