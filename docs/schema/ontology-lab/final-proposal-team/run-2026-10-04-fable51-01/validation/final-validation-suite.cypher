// Final validation suite compiled by compile-suite.mjs (Wave 6). Base: docs/schema/neo4j/validation.cypher (0.2.0, unchanged on disk)
// minus 42 statements replaced by corrections (V-003, V-006, V-101, V-104, V-108, V-112, V-113, V-117, V-121, V-201, V-203, V-211, V-215, V-217, V-218, V-221, V-231, V-233, V-234, V-235, V-302, V-303, V-304, V-313, V-322, V-324, V-333, V-334, V-407, V-409, V-416, V-423, V-432, V-503, V-504, V-505, V-508, V-509, V-512, V-521, V-525, V-526) and the retired V-423 (CL-016),
// plus 3 correction/extension files appended verbatim. Params: validation/validation-params.json (+ fable-w5-params.json).

// Each query should return zero rows in a valid committed graph unless its comment says "(informational)",
// in which case rows are expected and are for review, never a failure.
// Status tags: every query is "statically-checked" (parsed with the Neo4j Cypher language-support parser and
// read against catalog labels) and, as of 2026-10-03, "executed" against the six fixtures in ../examples on an
// embedded Neo4j 5.26 Community instance in the authoring scratchpad (see ../ontology-lab/proposal-index.md,
// section 9, for the recorded row counts). V-0xx queries carry no per-query tag; this header is their tag.
// 0.2.0 (2026-10-03): V-0xx are the 0.1.0 baseline. V-1xx to V-5xx project the invariants accepted in
// ontology-lab rounds 0002 to 0009 (see ontology-lab/proposal-index.md). Rules Neo4j cannot express are
// marked service-enforced in the catalog. Note on V-000a/V-000b: if deployed nodes carry only live labels
// and no base-archetype label, these pass vacuously; verify with CALL db.labels() (OPEN-QUESTIONS, live stack).

// V-000a: uid is globally unique across base archetypes, not merely per label.
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n.uid AS uid, collect(n) AS nodes
WHERE uid IS NULL OR size(nodes) <> 1
RETURN uid, size(nodes) AS nodeCount;

// V-000b: every semantic node has exactly one base archetype.
MATCH (n)
WHERE n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment
WITH n,
     size([label IN labels(n)
           WHERE label IN ['Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment']]) AS archetypeCount
WHERE archetypeCount <> 1
RETURN n.uid AS uid, labels(n) AS labels, archetypeCount;

// V-001: accepted assertions require exact source attribution.
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT (a)-[:SUPPORTED_BY]->(:SourceLocator)
RETURN a.uid AS assertionWithoutSource;

// V-002: assertions require exactly one subject.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
WITH a, count(s) AS subjects
WHERE subjects <> 1
RETURN a.uid AS assertionUid, subjects;

// V-004: no direct composition shortcut may masquerade as authoritative history.
MATCH (p)-[r:CONTAINS]->(m:IngredientMaterial)
WHERE r.projectionOfAssertionUid IS NULL AND r.derivationRule IS NULL
RETURN p.uid AS productUid, m.uid AS materialUid;

// V-005: formulation components must identify a material.
MATCH (c:IngredientComponent)
WHERE NOT (c)-[:USES_MATERIAL]->(:IngredientMaterial)
RETURN c.uid AS componentWithoutMaterial;

// V-007: accepted advisor-product endorsement cannot be inferred only from advising.
// 0.2.0: an ENDORSES_PRODUCT edge is an asserted projection; it must cite an ENDORSES_PRODUCT assertion, never
// an ADVISES_ORGANIZATION one, and never be unbacked.
MATCH (p)-[e:ENDORSES_PRODUCT]->(product)
OPTIONAL MATCH (a:Assertion {uid: e.assertionUid})
WITH p, e, product, a
WHERE e.assertionUid IS NULL OR a IS NULL OR a.predicate <> 'ENDORSES_PRODUCT'
RETURN p.uid AS endorserUid, product.uid AS productUid, a.predicate AS citedPredicate;

// V-008: a Certificate of Analysis must report on a lot or execution.
MATCH (c:CertificateOfAnalysis)
WHERE NOT (c)-[:CERTIFIES_RESULTS_FOR]->(:ProductLot|TestExecution)
RETURN c.uid AS orphanCertificate;

// V-009: a Certification Listing must have explicit scope.
MATCH (l:CertificationListing)
WHERE NOT (l)-[:HAS_CERTIFICATION_SCOPE]->(:CertificationScope)
RETURN l.uid AS listingWithoutScope;

// V-010: orphan designation and drug approval may not share an identity node.
MATCH (n:OrphanDesignation:DrugApproval)
RETURN n.uid AS collapsedRegulatoryIdentity;

// V-011: label declarations must not be modeled as measured results.
MATCH (n:LabelDeclaration:MeasuredResult)
RETURN n.uid AS collapsedDeclarationAndMeasurement;

// V-012: registrations, protocols, publications, and studies are distinct identities.
MATCH (n)
WHERE (n:Study AND (n:TrialRegistration OR n:ProtocolVersion OR n:Publication))
RETURN n.uid AS collapsedStudyArtifact;

// V-013: show unresolved source identifier conflicts for agent review (informational).
MATCH (a:Assertion {status: 'DISPUTED'})-[:HAS_OBJECT]->(r:TrialRegistration)
RETURN a.uid, r.registry, r.registrationId, a.confidence
ORDER BY a.recordedAt DESC;

// V-102: half-open intervals are non-empty and ordered (valid time and recorded time), on edges.
// status: statically-checked
MATCH ()-[r]->()
WHERE (r.validFrom IS NOT NULL AND r.validTo IS NOT NULL AND r.validFrom >= r.validTo)
   OR (r.recordedFrom IS NOT NULL AND r.recordedTo IS NOT NULL AND r.recordedFrom >= r.recordedTo)
RETURN type(r) AS relType, elementId(r) AS edgeId, r.validFrom AS validFrom, r.validTo AS validTo,
       r.recordedFrom AS recordedFrom, r.recordedTo AS recordedTo;

// V-103: the same ordering rule on assertions (valid time only; recordedAt is a single instant).
// status: statically-checked
MATCH (a:Assertion)
WHERE a.validFrom IS NOT NULL AND a.validTo IS NOT NULL AND a.validFrom >= a.validTo
RETURN a.uid AS assertionUid, a.validFrom AS validFrom, a.validTo AS validTo;

// V-105: a non-null valid-time bound on an assertion carries its own basis and precision (per-bound, round 0007).
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND (a.validFromBasis IS NULL OR a.validFromPrecision IS NULL
         OR NOT a.validFromBasis IN ['STATED_BY_SOURCE', 'PUBLICATION_PROXY', 'INFERRED']))
   OR (a.validTo IS NOT NULL AND (a.validToBasis IS NULL OR a.validToPrecision IS NULL
         OR NOT a.validToBasis IN ['STATED_BY_SOURCE', 'PUBLICATION_PROXY', 'INFERRED']))
   OR a.validTimeBasis IS NOT NULL
RETURN a.uid AS assertionUid, a.validFromBasis AS validFromBasis, a.validToBasis AS validToBasis, a.validTimeBasis AS legacySingleBasis;

// V-106: the same rule on asserted edges that carry a valid-time bound.
// status: statically-checked
// params: $assertedTypes
MATCH ()-[r]->()
WHERE type(r) IN $assertedTypes
  AND ((r.validFrom IS NOT NULL AND (r.validFromBasis IS NULL OR r.validFromPrecision IS NULL))
    OR (r.validTo IS NOT NULL AND (r.validToBasis IS NULL OR r.validToPrecision IS NULL))
    OR r.validTimeBasis IS NOT NULL)
RETURN type(r) AS relType, elementId(r) AS edgeId, r.validFromBasis AS validFromBasis, r.validToBasis AS validToBasis;

// V-107: ingestion time must not stand in for an unknown valid start (heuristic; rows are for review).
// status: statically-checked
MATCH (a:Assertion)
WHERE a.validFrom IS NOT NULL
  AND a.validFrom = a.recordedAt
  AND coalesce(a.validFromBasis, 'UNKNOWN') <> 'STATED_BY_SOURCE'
RETURN a.uid AS assertionUid, a.validFrom AS validFrom, a.recordedAt AS recordedAt, a.validFromBasis AS validFromBasis;

// V-109: a SUPERSEDED assertion has an incoming SUPERSEDES that was recorded no earlier than it.
// status: statically-checked
MATCH (a:Assertion {status: 'SUPERSEDED'})
OPTIONAL MATCH (b:Assertion)-[:SUPERSEDES]->(a)
WITH a, collect(b) AS supersessors
WHERE size(supersessors) = 0 OR any(b IN supersessors WHERE b.recordedAt < a.recordedAt)
RETURN a.uid AS assertionUid, size(supersessors) AS supersessorCount;

// V-110: a BellLabs review state (ACCEPTED, REJECTED, DISPUTED) must be backed by an Adjudication,
// and no Adjudication may predate the assertion it reviews.
// status: statically-checked
// 0.2.0: only a CAPTURE_FIDELITY adjudication backs a status; a SUPPORT adjudication (truth) never does (INV-103, INV-406).
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
OPTIONAL MATCH (j:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a)
WITH a, collect(j) AS adjudications
WHERE size(adjudications) = 0 OR any(j IN adjudications WHERE j.reviewedAt IS NULL OR j.reviewedAt < a.recordedAt)
RETURN a.uid AS assertionUid, a.status AS status, size(adjudications) AS captureFidelityAdjudications;

// V-111: locators behind an ACCEPTED assertion must resolve to a reproducible snapshot.
// status: statically-checked
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(loc:SourceLocator)
OPTIONAL MATCH (snap:SourceSnapshot)-[:HAS_LOCATOR]->(loc)
WITH a, loc, collect(snap) AS snaps
WHERE size(snaps) = 0 OR any(s IN snaps WHERE s.contentHash IS NULL OR s.retrievedAt IS NULL)
RETURN a.uid AS assertionUid, loc.uid AS locatorUid, size(snaps) AS snapshotCount;

// V-111b (informational): snapshots cited by ACCEPTED assertions without a declared contentHashBasis. Null weakens
// reproducibility (the hash input is unnamed); new captures must set it (service-enforced).
// status: statically-checked, executed
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
WHERE s.contentHashBasis IS NULL
RETURN DISTINCT s.uid AS snapshotWithoutHashBasis;

// V-114: private-to-shared references use only governed reference types.
// status: illustrative (Lane 5 owns the list of reference types)
// params: $allowedReferenceTypes
// 0.2.0: in production no relationship crosses the store boundary at all (references are uid properties), so
// $allowedReferenceTypes is empty and any row is a violation.
MATCH (p)-[r]->(s)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
  AND NOT type(r) IN $allowedReferenceTypes
RETURN p.uid AS privateUid, type(r) AS relType, s.uid AS sharedUid;

// V-115: private nodes do not carry labels that a shared fulltext or vector index covers.
// status: statically-checked
// params: $sharedIndexedLabels list<string>, derive with: SHOW FULLTEXT INDEXES YIELD labelsOrTypes, plus the vector index labels
MATCH (p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND any(l IN labels(p) WHERE l IN $sharedIndexedLabels)
RETURN p.uid AS privateUid, labels(p) AS labels;

// V-116: private nodes carry no search text or embedding unless a private index is declared (placement-dependent).
// status: illustrative (applies only if private records share the shared database)
MATCH (p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND (p.searchText IS NOT NULL OR p.searchEmbedding IS NOT NULL)
RETURN p.uid AS privateUid, labels(p) AS labels;

// V-118: uid backfill progress over live GraphQL nodes (informational; counts per label).
// status: statically-checked
MATCH (n)
WHERE n.id IS NOT NULL OR n.documentId IS NOT NULL OR n.chunkId IS NOT NULL
   OR n.documentTextVersionId IS NOT NULL OR n.segmentationId IS NOT NULL
WITH labels(n)[0] AS label, count(n) AS nodes, count(n.uid) AS withUid
RETURN label, nodes, withUid, nodes - withUid AS missingUid
ORDER BY missingUid DESC;

// V-119: search surface. Embeddings declare their model and dimension, the dimension matches the vector,
// and derived search text names the fields it was derived from.
// status: statically-checked
MATCH (n)
WHERE (n.searchEmbedding IS NOT NULL
       AND (n.embeddingModel IS NULL OR n.embeddingDimensions IS NULL OR size(n.searchEmbedding) <> n.embeddingDimensions))
   OR (n.searchText IS NOT NULL AND (n.searchFields IS NULL OR size(n.searchFields) = 0))
RETURN labels(n) AS labels, coalesce(n.uid, n.id) AS key, n.embeddingModel AS embeddingModel,
       n.embeddingDimensions AS declaredDimensions, size(n.searchEmbedding) AS actualDimensions;

// V-120: fulltext indexes exist on the stored property names the live directives imply.
// The Neo4j GraphQL library does not create them, and aliased fields are stored under other names.
// status: statically-checked (index metadata only; expected names come from the live schema)
SHOW FULLTEXT INDEXES YIELD name, labelsOrTypes, properties, state
WHERE name IN ['DocumentSearch', 'ChunkSearch', 'ProductSearch', 'ClaimSearch', 'OrganizationName']
RETURN name, labelsOrTypes, properties, state;


// V-123 (INV-406): status is never read from a truth verdict. Rows are assertions whose status is REJECTED or DISPUTED while
// their only adjudications are SUPPORT adjudications (truth) and no CAPTURE_FIDELITY adjudication exists, or whose status
// mirrors a SUPPORT verdict exactly when the capture adjudication says otherwise.
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE a.status IN ['REJECTED', 'DISPUTED']
  AND EXISTS { MATCH (:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a) }
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
RETURN a.uid AS statusDerivedFromTruthVerdict, a.status AS status;

// V-124 (INV-007): distinct states are never normalized to one. Rows are quantitative records with a null value and no
// qualifier saying which state applies (unknown, unmeasured, not reported, below detection, absent), or an applicability
// dimension whose verdict is UNKNOWN without missing facts and NOT_ASSESSED with missing facts (the two states swapped).
// status: statically-checked, executed
MATCH (m:MeasuredResult)
WHERE m.value IS NULL AND m.qualifier IS NULL
RETURN 'MEASURED_RESULT_NULL_WITHOUT_QUALIFIER' AS violation, m.uid AS item
UNION
MATCH (c:IngredientComponent)
WHERE c.quantity IS NULL AND c.amountReferent IS NULL AND c.declaredAs IS NULL
RETURN 'COMPONENT_WITHOUT_QUANTITY_OR_DECLARATION' AS violation, c.uid AS item
UNION
MATCH (d:ApplicabilityDimension)
WHERE d.verdict = 'NOT_ASSESSED' AND size(coalesce(d.missingFacts, [])) > 0 AND d.rationale IS NULL
RETURN 'NOT_ASSESSED_WITH_MISSING_FACTS' AS violation, d.uid AS item;

// V-202 (R1): a ProductVariant used as intervention material must carry asReportedName.
// status: statically-checked
MATCH (ic:InterventionComponent)-[u:USES_INTERVENTION_MATERIAL]->(v:ProductVariant)
WHERE u.asReportedName IS NULL
RETURN ic.uid AS component, v.uid AS variantWithoutReportedName;

// V-204 (INV-202): required dimensions present for the evidence-target kind.
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(e)
WITH ea,
     CASE WHEN e:Assertion
          THEN ['MATERIAL_IDENTITY', 'EXPOSURE', 'ROUTE', 'DURATION', 'POPULATION', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
          ELSE ['MATERIAL_IDENTITY', 'ACTIVE_COMPOSITION', 'DOSE', 'DOSAGE_FORM', 'ROUTE', 'SCHEDULE', 'DURATION', 'POPULATION', 'COMPARATOR', 'OUTCOME_RELEVANCE', 'STUDY_DESIGN_AND_QUALITY']
     END AS required
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, required, collect(d.dimension) AS present
WITH ea, [x IN required WHERE NOT x IN present] AS missing
WHERE size(missing) > 0
RETURN ea.uid AS assessment, missing;

// V-205 (INV-202): at most one dimension node per dimension per assessment.
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d:ApplicabilityDimension)
WITH ea, d.dimension AS dim, count(d) AS n
WHERE n > 1
RETURN ea.uid AS assessment, dim, n;

// V-206 (INV-203): ratios only with matching bases; otherwise ratio null and verdict not MATCH.
// status: statically-checked
MATCH (d:ApplicabilityDimension)
WHERE d.dimension IN ['DOSE', 'SCHEDULE', 'DURATION', 'EXPOSURE']
  AND (
        (d.ratio IS NOT NULL AND (d.evidenceQuantityBasis IS NULL OR d.evidenceQuantityBasis <> d.targetQuantityBasis
                                  OR coalesce(d.evidenceMassBasis, 'NA') <> coalesce(d.targetMassBasis, 'NA')
                                  OR d.evidenceMassBasis = 'UNSPECIFIED'))
     OR (d.verdict = 'MATCH' AND d.ratio IS NULL AND d.dimension IN ['DOSE', 'EXPOSURE'])
      )
RETURN d.uid AS dimension, d.dimension AS kind, d.ratio AS ratio, d.verdict AS verdict;

// V-207 (INV-204): explanation-only dimensions are NOT_SCORED with rationale; composites need all required dimensions.
// status: statically-checked
MATCH (d:ApplicabilityDimension {dimensionClass: 'EXPLANATION_ONLY'})
WHERE d.verdict <> 'NOT_SCORED' OR d.rationale IS NULL
RETURN d.uid AS badExplanationOnlyDimension, d.verdict AS verdict;

// V-207b: a composite score requires a method version and no NOT_ASSESSED MATERIAL_IDENTITY.
// status: statically-checked
MATCH (ea:EvidenceApplicability)
WHERE ea.overallScore IS NOT NULL
  AND (ea.methodVersion IS NULL
       OR NOT EXISTS { MATCH (ea)-[:HAS_DIMENSION]->(:ApplicabilityDimension {dimension: 'MATERIAL_IDENTITY'}) }
       OR EXISTS { MATCH (ea)-[:HAS_DIMENSION]->(:ApplicabilityDimension {dimension: 'MATERIAL_IDENTITY', verdict: 'NOT_ASSESSED'}) })
RETURN ea.uid AS compositeWithoutBasis;

// V-208 (INV-008): MATERIAL_IDENTITY at branded-material level or higher requires the same material on both sides.
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d:ApplicabilityDimension {dimension: 'MATERIAL_IDENTITY'})
WHERE d.identityLevel IN ['SAME_LOT', 'SAME_FORMULATION_VERSION', 'SAME_BRANDED_MATERIAL_SAME_SPEC', 'SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED']
  AND NOT EXISTS {
    MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(:StudyIntervention)-[:HAS_INTERVENTION_COMPONENT]->(:InterventionComponent)-[:USES_INTERVENTION_MATERIAL]->(m:IngredientMaterial),
          (ea)-[:ASSESSES_APPLICABILITY_TO]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(m)
  }
RETURN ea.uid AS assessment, d.identityLevel AS claimedLevel;

// V-208b: MATERIAL_IDENTITY verdict must agree with identityLevel mapping (method applicability-v0.1).
// status: statically-checked
MATCH (d:ApplicabilityDimension {dimension: 'MATERIAL_IDENTITY'})
WHERE d.identityLevel IS NOT NULL AND d.verdict <> 'NOT_ASSESSED'
  AND NOT (
       (d.identityLevel IN ['SAME_LOT', 'SAME_FORMULATION_VERSION'] AND d.verdict = 'MATCH')
    OR (d.identityLevel IN ['SAME_VARIANT_FORMULATION_UNRESOLVED', 'SAME_BRANDED_MATERIAL_SAME_SPEC', 'SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED', 'SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL'] AND d.verdict = 'PARTIAL')
    OR (d.identityLevel = 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED' AND d.verdict = 'UNKNOWN')
    OR (d.identityLevel IN ['SAME_SUBSTANCE_DIFFERENT_FORM', 'RELATED_SUBSTANCE', 'DIFFERENT'] AND d.verdict IN ['MISMATCH', 'PARTIAL'])
  )
RETURN d.uid AS dimension, d.identityLevel AS level, d.verdict AS verdict;

// V-209 (provenance rule): an assessed dimension cites a locator or an assertion; UNKNOWN lists missing facts.
// status: statically-checked
MATCH (d:ApplicabilityDimension)
WHERE d.verdict IN ['MATCH', 'PARTIAL', 'MISMATCH', 'UNKNOWN']
  AND (NOT EXISTS { MATCH (d)-[:SUPPORTED_BY]->(:SourceLocator) } AND NOT EXISTS { MATCH (d)-[:CONSIDERS]->(:Assertion) }
       OR (d.verdict = 'UNKNOWN' AND size(coalesce(d.missingFacts, [])) = 0))
RETURN d.uid AS dimensionWithoutProvenanceOrMissingFacts, d.verdict AS verdict;

// V-210 (INV-208, R10): Study identity nodes carry no registry status, publication ids, or assessment labels
// unless explicitly a derived projection naming its RegistrationVersion.
// status: statically-checked
MATCH (s:Study)
WHERE (s.overallStatus IS NOT NULL OR s.enrollmentCount IS NOT NULL OR s.hasResults IS NOT NULL)
      AND s.projectionOfRegistrationVersionUid IS NULL
   OR s.pmid IS NOT NULL OR s.doi IS NOT NULL OR s.evidenceLevel IS NOT NULL
RETURN s.uid AS studyWithMisplacedFields;

// V-212 (FI-203): informational. Rows are expected; each row is a study whose registry shows no posted
// results while a results article exists. Answers must not report these as unpublished.
// status: statically-checked (informational)
MATCH (s:Study)-[:REGISTERED_AS]->(:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv:RegistrationVersion {resultsPosted: false}),
      (pub:Publication {publicationKind: 'ARTICLE'})-[:REPORTS_ON]->(s)
RETURN s.uid AS study, rv.observedAt AS observedAt, pub.pmid AS resultsArticle;

// V-213 (INV-209): assessment labels on results and edges must name an assessment.
// status: statically-checked
MATCH (r:StudyResult)
WHERE r.isClinicallyMeaningful IS NOT NULL AND r.interpretationUid IS NULL
RETURN r.uid AS resultWithUnattributedMeaningfulness;

// V-213b: EvidenceStrength values on edges must name an EvidenceStrengthAssessment.
// status: statically-checked
MATCH ()-[e]->()
WHERE e.evidenceStrength IS NOT NULL AND e.assessmentUid IS NULL
RETURN type(e) AS relType, e.evidenceStrength AS unattributedStrength
LIMIT 100;

// V-214 (INV-205): SURROGATE_ENDPOINT classifications carry a validation level and full context of use and a source.
// status: statically-checked
MATCH (ec:EndpointClassification {endpointClass: 'SURROGATE_ENDPOINT'})
WHERE ec.surrogateValidationLevel IS NULL OR ec.contextDiseaseOrUse IS NULL OR ec.contextInterventionMechanism IS NULL
   OR NOT EXISTS { MATCH (ec)-[:SUPPORTED_BY]->(:SourceLocator) }
RETURN ec.uid AS incompleteSurrogateContext;

// V-214b (INV-205): no surrogate status as a Biomarker property.
// status: statically-checked
MATCH (b:Biomarker)
WHERE b.isSurrogate IS NOT NULL OR b.surrogateValidationLevel IS NOT NULL
RETURN b.uid AS biomarkerWithIntrinsicSurrogateStatus;

// V-216 (FI-207): within-arm changes are never CONFIRMATORY or INDEPENDENT_REPLICATION inputs.
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r:StudyResult {comparisonKind: 'WITHIN_ARM_CHANGE'})
WHERE inc.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION']
RETURN syn.uid AS synthesis, r.uid AS withinArmResult, inc.inputRole AS role;

// V-219 (KCR-2a, CQ-ST-09): synthesis supersession moves forward in recorded time; TRIGGERED_BY has criterion and effect.
// status: statically-checked
MATCH (newer:EvidenceSynthesis)-[:SUPERSEDES]->(older:EvidenceSynthesis)
WHERE newer.recordedAt IS NULL OR older.recordedAt IS NULL OR newer.recordedAt <= older.recordedAt
RETURN newer.uid AS newer, older.uid AS older;

// V-219b
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[t:TRIGGERED_BY]->(x)
WHERE t.criterionCode IS NULL OR t.effectOnVerdict IS NULL
RETURN syn.uid AS synthesis, x.uid AS trigger;

// V-219c: a synthesis version with a TRIGGERED_BY must supersede an earlier version.
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[:TRIGGERED_BY]->()
WHERE NOT EXISTS { MATCH (syn)-[:SUPERSEDES]->(:EvidenceSynthesis) }
RETURN DISTINCT syn.uid AS triggeredWithoutPredecessor;

// V-220 (FI-202): no unprojected SUPPLIES_INGREDIENT_MATERIAL edge (asserted predicate needs its assertion).
// status: statically-checked
MATCH (o:Organization)-[s:SUPPLIES_INGREDIENT_MATERIAL]->(m)
WHERE s.assertionUid IS NULL
RETURN o.uid AS organization, m.uid AS material;

// V-222 (R11): ChemicalForm has exactly one substance; substances, forms, and materials stay distinct identities;
// dosage form never sits on a material.
// status: statically-checked
MATCH (f:ChemicalForm)
OPTIONAL MATCH (f)-[:FORM_OF_SUBSTANCE]->(s:ChemicalSubstance)
WITH f, count(s) AS n
WHERE n <> 1
RETURN f.uid AS chemicalFormWithoutSingleSubstance, n;

// V-222b
// status: statically-checked
MATCH (n)
WHERE (n:ChemicalSubstance AND (n:IngredientMaterial OR n:ChemicalForm))
   OR (n:ChemicalForm AND n:IngredientMaterial)
   OR (n:IngredientMaterial AND n.dosageForm IS NOT NULL)
RETURN n.uid AS collapsedSubstanceFormOrMaterial, labels(n) AS labels;

// V-223 (CQ-ST-04): informational. Outcomes whose declared priority differs between sources (outcome switching
// candidates). Rows expected for NCT02678611 whole-blood NAD+.
// status: statically-checked (informational)
MATCH (a:Assertion {predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:HAS_SUBJECT]->(od:OutcomeDefinition)
WITH od, collect(DISTINCT a.valueString) AS priorities
WHERE size(priorities) > 1
RETURN od.uid AS outcome, priorities;

// ---------------------------------------------------------------------------
// Mechanisms (round 0003)
// ---------------------------------------------------------------------------

// V-230 (INV-210): mechanism-class assertions carry basisKind.
// status: statically-checked
MATCH (a:Assertion)
WHERE (a.predicateClass = 'MECHANISM'
       OR a.predicate IN ['INCREASES_LEVEL_OF', 'DECREASES_LEVEL_OF', 'INCREASES_ACTIVITY_OF', 'DECREASES_ACTIVITY_OF', 'INDUCES_PROCESS', 'INHIBITS_PROCESS', 'IMPROVES', 'IMPAIRS', 'EXTENDS', 'BINDS'])
  AND (a.basisKind IS NULL OR NOT a.basisKind IN ['DIRECT_MEASUREMENT', 'INFERRED_FROM_MEASUREMENT', 'CITED_FROM_PRIOR_WORK', 'HYPOTHESIS'])
RETURN a.uid AS mechanismAssertionWithoutBasisKind;

// V-232: exposure amounts carry unit and basis; unknown exposure is null with exposureStatus, never zero.
// status: statically-checked
MATCH (c:MechanismEvidenceContext)
WHERE (c.exposureAmount IS NOT NULL AND (c.exposureUnit IS NULL OR c.exposureBasis IS NULL))
   OR c.exposureAmount = 0
   OR (c.exposureAmount IS NULL AND NOT EXISTS { MATCH (c)-[:IN_STUDY_ARM]->(:StudyArm) } AND c.exposureStatus IS NULL)
RETURN c.uid AS contextWithIncompleteExposure;

// V-236 (INV-213): HED is derived, never asserted.
// status: statically-checked
MATCH (c:MechanismEvidenceContext)
WHERE c.hedValue IS NOT NULL AND c.hedMethod IS NULL
RETURN c.uid AS contextWithUnattributedHumanEquivalentDose;

// V-237 (INV-212, FI-303): applicability of a mechanism assertion needs an EXPOSURE dimension; MATCH/PARTIAL needs
// linked human exposure evidence (a StudyResult considered by the assessment).
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(:Assertion)
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d:ApplicabilityDimension {dimension: 'EXPOSURE'})
WITH ea, d
WHERE d IS NULL
   OR (d.verdict IN ['MATCH', 'PARTIAL'] AND NOT EXISTS { MATCH (ea)-[:BASED_ON_EVIDENCE]->(:StudyResult) })
RETURN ea.uid AS assessment, d.verdict AS exposureVerdict;

// V-238 (M3): a context tied to a StudyArm does not duplicate exposure fields (dose truth lives on the arm).
// status: statically-checked
MATCH (c:MechanismEvidenceContext)-[:IN_STUDY_ARM]->(:StudyArm)
WHERE c.exposureAmount IS NOT NULL OR c.exposureUnit IS NOT NULL OR c.route IS NOT NULL
RETURN c.uid AS contextDuplicatingArmExposure;

// V-239 (M1, FI-301): a level-change step's measured compartment equals its measurand's matrix.
// status: statically-checked
MATCH (a:Assertion)-[:HAS_OBJECT]->(b:Biomarker)-[:MEASURED_IN_MATRIX]->(mx:AnatomicalContext),
      (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:MEASURED_IN]->(site:AnatomicalContext)
WHERE a.predicate IN ['INCREASES_LEVEL_OF', 'DECREASES_LEVEL_OF'] AND site.uid <> mx.uid
RETURN a.uid AS assertion, b.uid AS measurand, site.uid AS measuredSite;

// ---------------------------------------------------------------------------
// Constraints Neo4j 5 can enforce (separate from the queries above)
// ---------------------------------------------------------------------------
// Uniqueness of uid for every new label is already covered by the archetype constraints in
// neo4j/constraints.cypher (Entity, VersionedState, Occurrence, InformationArtifact, EvidenceAssessment).
// The following need Neo4j Enterprise Edition (property existence and type constraints):

// status: statically-checked (Enterprise only)
// CREATE CONSTRAINT applicability_dimension_dimension IF NOT EXISTS FOR (d:ApplicabilityDimension) REQUIRE d.dimension IS NOT NULL;
// CREATE CONSTRAINT applicability_dimension_verdict IF NOT EXISTS FOR (d:ApplicabilityDimension) REQUIRE d.verdict IS NOT NULL;
// CREATE CONSTRAINT mechanism_context_setting IF NOT EXISTS FOR (c:MechanismEvidenceContext) REQUIRE c.setting IS NOT NULL;
// CREATE CONSTRAINT registration_version_observed IF NOT EXISTS FOR (r:RegistrationVersion) REQUIRE r.observedAt IS NOT NULL;
// CREATE CONSTRAINT synthesis_recorded IF NOT EXISTS FOR (s:EvidenceSynthesis) REQUIRE s.recordedAt IS NOT NULL;
// CREATE CONSTRAINT dimension_ratio_type IF NOT EXISTS FOR (d:ApplicabilityDimension) REQUIRE d.ratio IS :: FLOAT;

// Service-enforced (Neo4j cannot enforce; the queries above detect violations):
// INV-201 (V-201), INV-202 (V-203, V-204, V-205), INV-203 (V-206), INV-204 (V-207), INV-205 (V-214),
// INV-206 (V-215), INV-207 (V-217), INV-208 (V-210, V-211), INV-209 (V-213), INV-210 (V-230, V-231),
// INV-211 (V-233, V-234), INV-212 (V-237), INV-213 (V-236).


// =====================================================================================
// Lane 3, rounds 0004 and 0005: diagnostics, regulatory, manufacturing, commerce (V-3xx)
// Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// Every query below is statically checked (syntax and per-statement variable binding) unless marked
// illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// =====================================================================================

// Lane 3 validation fragment: V-301 to V-313 (diagnostics, Round 0004) and V-320 to V-335 (filing, regulatory,
// capability, commerce, declared amount; Round 0005). Each query returns zero rows in a valid committed graph
// unless marked "migration check" or "informational". Not executed (no Neo4j in this environment).
// The same queries appear in examples/diagnostic-comparison.cypher and examples/filing-vs-capability.cypher;
// this file is the canonical lane copy and adds V-305a, V-309, V-310a/b, V-311, V-313, V-321, V-327, V-329,
// V-331 to V-334, plus constraints.

// ---------------------------------------------------------------------------
// Diagnostics (Round 0004)
// ---------------------------------------------------------------------------
// V-301a: an AssayVersion with more than one method or instrument is a collapsed identity.
// status: statically-checked
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:USES_METHOD]->(mm:MeasurementMethod)
OPTIONAL MATCH (a)-[:RUNS_ON_INSTRUMENT]->(t:ToolOrInstrument)
WITH a, count(DISTINCT mm) AS methods, count(DISTINCT t) AS instruments
WHERE methods > 1 OR instruments > 1
RETURN a.uid AS assayVersionUid, methods, instruments;

// V-301b: an AssayVersion is operated by exactly one laboratory.
// status: statically-checked
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:ASSAY_OPERATED_BY]->(o:Organization)
WITH a, count(DISTINCT o) AS operators
WHERE operators <> 1
RETURN a.uid AS assayVersionUid, operators;

// V-305b: every reference interval version belongs to an assay version.
// status: statically-checked
MATCH (ri:ReferenceIntervalVersion)
WHERE NOT (ri)-[:FOR_ASSAY_VERSION]->(:AssayVersion)
RETURN ri.uid AS intervalWithoutAssayVersion;

// V-306: a result is interpreted with an interval of its own assay version.
// status: statically-checked
MATCH (r:DiagnosticResult)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WHERE NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
RETURN r.uid AS resultUid, ri.uid AS intervalUid, a.uid AS intervalAssayVersion;

// V-307: no "same test" identity merge without an accepted resolution projection.
// status: statically-checked
MATCH (t1:LabTest)-[s:SAME_TEST_AS]-(t2:LabTest)
WHERE elementId(t1) < elementId(t2)
  AND s.projectionOfAssertionUid IS NULL
RETURN t1.uid AS labTest1, t2.uid AS labTest2;

// V-308: every algorithm version states its version basis.
// status: statically-checked
MATCH (v:AlgorithmVersion)
WHERE v.versionBasis IS NULL
   OR NOT v.versionBasis IN ['VENDOR_VERSION_STRING', 'PUBLICATION_VERSION', 'SERVICE_ENDPOINT_UNVERSIONED', 'UNKNOWN']
RETURN v.uid AS algorithmVersionUid, v.versionBasis AS versionBasis;

// V-312: results from an unversioned service endpoint never enter a comparison.
// status: statically-checked
MATCH (r:DiagnosticResult)-[:COMPARED_TO]-(:DiagnosticResult)
MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
WHERE v.versionBasis = 'SERVICE_ENDPOINT_UNVERSIONED'
RETURN DISTINCT r.uid AS resultUid, v.uid AS algorithmVersionUid;

// V-305a: live HAS_REFERENCE_RANGE edges from Biomarker or Metric are projections only (migration check;
// expected to list every live edge until each is regenerated from a ReferenceIntervalVersion).
// status: statically-checked
MATCH (x)-[h:HAS_REFERENCE_RANGE]->(rr:ReferenceRange)
WHERE (x:Biomarker OR x:Metric)
  AND h.projectionOfAssertionUid IS NULL AND h.derivationRule IS NULL
RETURN coalesce(x.uid, x.id) AS ownerId, coalesce(rr.uid, rr.id) AS referenceRangeId;

// V-309: a result does not indicate a condition without an assertion (outside a reference interval is not a condition).
// status: statically-checked
MATCH (r:DiagnosticResult)-[e:INDICATES_CONDITION]->(c)
WHERE e.assertionUid IS NULL
RETURN r.uid AS resultUid, c.uid AS conditionUid;

// V-310a: materialized LOINC codes are well formed (digits, hyphen, check digit).
// status: statically-checked
MATCH (m:Metric)
WHERE m.loincCode IS NOT NULL AND NOT m.loincCode =~ '^[0-9]{1,7}-[0-9]$'
RETURN m.uid AS metricUid, m.loincCode AS loincCode;

// V-310b: one Metric per LOINC code (also enforced by constraint metric_loinc_code below).
// status: statically-checked
MATCH (m:Metric)
WHERE m.loincCode IS NOT NULL
WITH m.loincCode AS code, collect(m.uid) AS uids
WHERE size(uids) > 1
RETURN code, uids;

// V-311: a ComparabilityAssessment compares exactly two versions of the same kind.
// status: statically-checked
MATCH (ca:ComparabilityAssessment)
OPTIONAL MATCH (ca)-[:COMPARES]->(x)
WITH ca, collect(x) AS xs
WHERE size(xs) <> 2
   OR NOT (all(n IN xs WHERE n:AssayVersion)
           OR all(n IN xs WHERE n:AlgorithmVersion)
           OR all(n IN xs WHERE n:ReferenceIntervalVersion))
RETURN ca.uid AS assessmentUid, size(xs) AS subjects;

// ---------------------------------------------------------------------------
// Filing versus capability, regulatory status, commerce, declared amount (Round 0005)
// ---------------------------------------------------------------------------
// V-320a: an approval status may not result from a notification, notice, registration, clearance, De Novo, or designation response.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)
WHERE s.statusKind = 'APPROVAL'
  AND resp.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'NDI_INCOMPLETE', 'NDI_OBJECTION', 'NDI_OTHER_REGULATORY_ISSUE',
                            'GRAS_NO_QUESTIONS', 'GRAS_NO_BASIS', 'GRAS_CEASED_AT_NOTIFIER_REQUEST',
                            'REGISTRATION_ACTIVE', 'REGISTRATION_CANCELLED', 'SUBSTANTIALLY_EQUIVALENT', 'DE_NOVO_GRANTED',
                            'ORPHAN_DESIGNATION_GRANTED']
RETURN s.uid AS statusUid, resp.uid AS responseUid, resp.responseKind AS responseKind;

// V-320b: an approval status may not sit under a non-approval legal basis.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE s.statusKind = 'APPROVAL'
  AND pw.pathwayKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE', 'FOOD_FACILITY_REGISTRATION', 'DEVICE_ESTABLISHMENT_REGISTRATION',
                         'PREMARKET_NOTIFICATION_510K', 'DE_NOVO', 'ORPHAN_DESIGNATION', 'COMPOUNDING_503B_BULKS_POLICY', 'LDT_POLICY']
RETURN s.uid AS statusUid, pw.pathwayKind AS pathwayKind;

// V-323: establishment or facility registration is a status of a Facility only.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(x)
WHERE s.statusKind = 'ESTABLISHMENT_REGISTRATION' AND NOT x:Facility
RETURN s.uid AS statusUid, labels(x) AS attachedTo, x.uid AS attachedUid;

// V-325: capability state edges are bitemporal and assertion-backed.
// status: statically-checked
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE h.assertionUid IS NULL OR h.recordedFrom IS NULL
RETURN holder.uid AS holderUid, c.uid AS capabilityUid;

// V-326a: SELLS_PRODUCT is derived only from seller-of-record assertions.
// status: statically-checked
MATCH (o:Organization)-[s:SELLS_PRODUCT]->(p)
WHERE s.projectionOfAssertionUid IS NULL AND s.derivationRule IS NULL
RETURN o.uid AS organizationUid, p.uid AS productUid;

// V-326c: every derivation input of SELLS_PRODUCT is a SELLER_OF_RECORD_FOR assertion (closes the derivationRule bypass
// found in review: a HOSTS_LISTING input returned zero rows from V-326a and V-112).
// status: statically-checked, executed
MATCH (o:Organization)-[s:SELLS_PRODUCT]->(p)
WHERE s.derivationRule IS NOT NULL
  AND (size(coalesce(s.derivedFromAssertionUids, [])) = 0
       OR EXISTS { MATCH (inp:Assertion) WHERE inp.uid IN s.derivedFromAssertionUids AND inp.predicate <> 'SELLER_OF_RECORD_FOR' }
       OR size(s.derivedFromAssertionUids) > size([u IN s.derivedFromAssertionUids WHERE EXISTS { MATCH (:Assertion {uid: u, predicate: 'SELLER_OF_RECORD_FOR'}) }]))
RETURN o.uid AS organizationUid, p.uid AS productUid, s.derivedFromAssertionUids AS inputs;

// V-336 (INV-304): an APPROVAL status results from an approving agency response of an approving pathway. A status
// asserted from nothing is a company characterization, not approval.
// status: statically-checked, executed
MATCH (s:RegulatoryStatus {statusKind: 'APPROVAL'})
WHERE NOT EXISTS {
  MATCH (s)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)
  WHERE resp.responseKind IN ['APPROVED', 'PMA_APPROVED']
}
RETURN s.uid AS approvalStatusWithoutApprovingResponse;

// V-326b: seller-of-record edges must be assertion-backed (hosting or fulfilling never implies it).
// status: statically-checked
MATCH (o:Organization)-[s:SELLER_OF_RECORD_FOR]->(off:Offer)
WHERE s.assertionUid IS NULL
RETURN o.uid AS organizationUid, off.uid AS offerUid,
       EXISTS { MATCH (o)-[:HOSTS_LISTING]->(:MerchantListing)-[:HAS_OFFER]->(off) } AS orgHostsTheListing,
       EXISTS { MATCH (o)-[:FULFILLS_OFFER]->(off) } AS orgFulfillsTheOffer;

// V-328: price observations carry amount, currency, observation time, and price kind.
// status: statically-checked
MATCH (po:PriceObservation)
WHERE po.amount IS NULL OR po.currency IS NULL OR po.observedAt IS NULL
   OR po.priceKind IS NULL OR NOT po.priceKind IN ['LIST', 'ONE_TIME', 'SUBSCRIPTION', 'COUPON_ADJUSTED', 'PER_UNIT']
RETURN po.uid AS priceObservationUid;

// V-330: label declarations never carry calculated referents (active moiety, nutrient equivalent).
// status: statically-checked
MATCH (q:QuantityDeclaration)
WHERE q.amountReferent IS NOT NULL
  AND NOT q.amountReferent IN ['NUTRIENT_AS_NUTRIENT', 'LISTED_INGREDIENT_AS_LISTED', 'PROPRIETARY_BLEND_TOTAL', 'EXTRACT_TOTAL', 'MARKER_CONSTITUENT', 'NOT_STATED']
RETURN q.uid AS declarationUid, q.amountReferent AS amountReferent;

// V-335: an accepted company characterization of an agency action requires a BellLabs adjudication.
// status: statically-checked
MATCH (a:Assertion)
WHERE a.predicate IN ['CHARACTERIZES_REGULATORY_RESPONSE', 'CHARACTERIZES_REGULATORY_STATUS']
  AND a.status = 'ACCEPTED'
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a) }
RETURN a.uid AS unadjudicatedCharacterization;

// V-321: regulatory record kinds never share one node.
// status: statically-checked
MATCH (n)
WHERE (n:RegulatorySubmission AND n:RegulatoryResponse)
   OR (n:RegulatoryStatus AND (n:RegulatorySubmission OR n:RegulatoryResponse))
   OR (n:OrphanDesignation AND n:DrugApproval)
   OR (n:DrugApproval AND n.statusKind IS NOT NULL AND n.statusKind <> 'APPROVAL')
   OR (n:OrphanDesignation AND n.statusKind IS NOT NULL AND n.statusKind <> 'DESIGNATION')
RETURN n.uid AS collapsedRegulatoryNode, labels(n) AS labels;

// V-327: an offer has at most one current open seller of record.
// status: statically-checked
MATCH (o:Organization)-[s:SELLER_OF_RECORD_FOR]->(off:Offer)
WHERE s.recordedTo IS NULL AND s.validTo IS NULL
WITH off, collect(DISTINCT o.uid) AS sellers
WHERE size(sellers) > 1
RETURN off.uid AS offerUid, sellers;

// V-329: live Listing price fields without a PriceObservation (migration check; informational).
// status: statically-checked
MATCH (l:Listing)
WHERE l.priceAmount IS NOT NULL
  AND NOT EXISTS { MATCH (l)-[:HAS_OFFER]->(:Offer)-[:HAS_PRICE_OBSERVATION]->(:PriceObservation) }
RETURN coalesce(l.uid, l.id) AS listingWithUnobservedPrice;

// V-331: NDI and GRAS responses keep the agency's conditions of use (informational; null means not captured).
// status: statically-checked
MATCH (sub:RegulatorySubmission)-[:SUBMISSION_HAS_RESPONSE]->(r:RegulatoryResponse)
WHERE sub.submissionKind IN ['NDI_NOTIFICATION', 'GRAS_NOTICE']
  AND r.responseKind IN ['NDI_ACKNOWLEDGED_WITHOUT_OBJECTION', 'GRAS_NO_QUESTIONS']
  AND r.conditionsOfUseText IS NULL
RETURN sub.uid AS submissionUid, r.uid AS responseUid;

// V-332: a derived product-level certification must be covered by the listing's scope.
// status: statically-checked
MATCH (x)-[:CERTIFIED_UNDER]->(l:CertificationListing)
WHERE (x:Product OR x:ProductVariant OR x:ProductLot)
  AND NOT EXISTS { MATCH (l)-[:HAS_CERTIFICATION_SCOPE]->(:CertificationScope)-[:COVERS]->(x) }
RETURN x.uid AS itemUid, l.uid AS listingUid;

// ---------------------------------------------------------------------------
// Rules Neo4j cannot enforce: -- service-enforced
// ---------------------------------------------------------------------------
// -- service-enforced: closed enums (resultKind, versionBasis, statusKind, responseKind per pathway, priceKind,
//    amountReferent, capabilityStage); V-303, V-308, V-328, V-330, V-333 detect violations after the fact.
// -- service-enforced: cardinality "exactly one" for ASSAY_OPERATED_BY, FOR_ASSAY_VERSION, STATUS_OF, and
//    "exactly two" for COMPARES (V-301b, V-305b, V-311, V-333 detect).
// -- service-enforced: COMPARED_TO and SELLS_PRODUCT are written only by the projection service from
//    ComparabilityAssessment / shared-version rules and SELLER_OF_RECORD_FOR assertions (V-302, V-304, V-326a detect).
// -- service-enforced: HAS_CAPABILITY_STATE with stage OPERATING requires non-marketing support or a SUPPORTED
//    adjudication (V-324 detects).
// -- service-enforced: a calculated quantity (active moiety, nutrient equivalent) is never written to a
//    QuantityDeclaration (V-330 detects); requires KCR-L3-001 for lineage.
// -- service-enforced: DiagnosticResult privacy filtering in public query paths (Lane 5 owns).


// =====================================================================================
// Lane 4, round 0006: claims, documents, provenance (V-4xx)
// Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// Every query below is statically checked (syntax and per-statement variable binding) unless marked
// illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// =====================================================================================

// Lane 4 validation fragment (Round 0006: claim and document provenance)
// Each query returns zero rows in a valid committed graph.
// status: statically-checked = syntax-linted with the Neo4j Cypher
// language-support parser and read for label/relationship names against the
// catalog patch and for per-statement variable binding. Nothing was executed.
// Financial-interest predicate list used below (keep in sync with catalog predicateFamilies.FINANCIAL_INTEREST
// predicateFamilies.FINANCIAL_INTEREST):
//   SPONSORS_CONTENT, INVESTED_IN, HOLDS_EQUITY_IN, BOARD_MEMBER_OF, ADVISES_ORGANIZATION,
//   HAS_IP_INTEREST_IN, RECEIVES_COMPENSATION_FROM, AFFILIATE_FOR_OFFER, FOUNDED_ORGANIZATION, EMPLOYED_BY

// ---------------------------------------------------------------------
// A. Locators and the document pipeline (CQ-PV-02, CQ-EV-01; closes P0-5)
// ---------------------------------------------------------------------

// V-401: an ACCEPTED assertion must have at least one reproducible locator:
// bound to a SourceSnapshot with contentHash and retrievedAt, a declared
// normalization, and the minimum selector fields for its selectorKind.
// status: statically-checked
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT EXISTS {
  MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
  WHERE s.contentHash IS NOT NULL AND s.retrievedAt IS NOT NULL
    AND (l.normalizationVersion IS NOT NULL OR l.selectorKind IN ['SECTION', 'WHOLE_SNAPSHOT'])
    AND (
      (l.selectorKind = 'TEXT_QUOTE' AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'MEDIA_TIME' AND l.mediaStartSeconds IS NOT NULL AND l.mediaEndSeconds IS NOT NULL
          AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'TEXT_POSITION' AND l.startOffset IS NOT NULL AND l.endOffset IS NOT NULL
          AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL
          AND EXISTS { MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(:DocumentTextVersion) })
      OR (l.selectorKind = 'PDF_PAGE' AND l.page IS NOT NULL AND l.exact IS NOT NULL AND l.quoteHash IS NOT NULL)
      OR (l.selectorKind = 'IMAGE_REGION' AND l.mediaAnnotationUid IS NOT NULL)
      OR (l.selectorKind = 'SECTION' AND l.section IS NOT NULL)
      OR (l.selectorKind = 'WHOLE_SNAPSHOT')
    )
}
RETURN a.uid AS assertionWithoutReproducibleLocator;

// V-401b (informational): ACCEPTED assertions whose only locators are coarse (SECTION or WHOLE_SNAPSHOT). They are
// reproducible to the snapshot hash but not to a span; re-anchoring to a typed selector is the follow-up.
// status: statically-checked, executed
MATCH (a:Assertion {status: 'ACCEPTED'})
WHERE NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator) WHERE l.selectorKind IN ['TEXT_QUOTE','TEXT_POSITION','MEDIA_TIME','PDF_PAGE','IMAGE_REGION'] }
RETURN count(a) AS acceptedAssertionsWithOnlyCoarseLocators;

// V-402: every SourceLocator hangs from exactly one SourceSnapshot.
// status: statically-checked
MATCH (l:SourceLocator)
OPTIONAL MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l)
WITH l, count(s) AS snapshots
WHERE snapshots <> 1
RETURN l.uid AS locatorUid, snapshots;

// V-403: character offsets are meaningless without the text version they count in.
// status: statically-checked
MATCH (l:SourceLocator)
WHERE (l.startOffset IS NOT NULL OR l.endOffset IS NOT NULL)
  AND NOT EXISTS { MATCH (l)-[:LOCATOR_IN_TEXT_VERSION]->(:DocumentTextVersion) }
RETURN l.uid AS offsetLocatorWithoutTextVersion;

// V-404: a locator's text version must derive from the same snapshot the locator hangs from.
// status: statically-checked
MATCH (s:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)-[:LOCATOR_IN_TEXT_VERSION]->(tv:DocumentTextVersion)
WHERE NOT (tv)-[:TEXT_OF_SNAPSHOT]->(s)
RETURN l.uid AS locatorUid, tv.uid AS textVersionFromOtherSnapshot;

// V-405: every DocumentTextVersion derives from exactly one SourceSnapshot.
// status: statically-checked
MATCH (tv:DocumentTextVersion)
OPTIONAL MATCH (tv)-[:TEXT_OF_SNAPSHOT]->(s:SourceSnapshot)
WITH tv, count(s) AS snapshots
WHERE snapshots <> 1
RETURN tv.uid AS textVersionUid, snapshots;

// V-406: a Chunk is a retrieval unit, never a SourceLocator implementation.
// status: statically-checked
MATCH (c:Chunk:SourceLocator)
RETURN c.uid AS chunkUsedAsLocator;

// V-408: RESOLVES_TO_CHUNK is derived; it must name its derivation rule and segmentation.
// status: statically-checked
MATCH (l:SourceLocator)-[r:RESOLVES_TO_CHUNK]->(c:Chunk)
WHERE r.derivationRule IS NULL OR r.segmentationHash IS NULL
RETURN l.uid AS locatorUid, c.uid AS chunkUid;

// ---------------------------------------------------------------------
// B. Claim occurrences, attribution, retellings (CQ-CL-01..04, CQ-CL-06)
// ---------------------------------------------------------------------

// V-410: a ClaimOccurrence has exactly one container and exactly one asserter.
// A retelling merged into its original fails here (two asserters or two containers).
// status: statically-checked
MATCH (a:ClaimOccurrence)
OPTIONAL MATCH (a)-[:OCCURS_IN]->(c)
WITH a, count(DISTINCT c) AS containers
OPTIONAL MATCH (a)-[:ASSERTED_BY]->(s)
WITH a, containers, count(DISTINCT s) AS asserters
WHERE containers <> 1 OR asserters <> 1
RETURN a.uid AS occurrenceUid, containers, asserters;

// V-411: a ClaimOccurrence's locators are in its container or a rendition of it.
// status: statically-checked
MATCH (a:ClaimOccurrence)-[:OCCURS_IN]->(c)
MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
WHERE NOT EXISTS {
  MATCH (l)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
  WHERE src = c OR (src)-[:RENDITION_OF]->(c)
}
RETURN a.uid AS occurrenceUid, l.uid AS foreignLocator, c.uid AS containerUid;

// V-412: a retelling is a distinct node: no self-loop, no cycle, no shared span with the original.
// status: statically-checked
MATCH (r:Assertion)-[:RETELLS]->(o:Assertion)
WHERE r = o
   OR EXISTS { MATCH (o)-[:RETELLS*1..10]->(r) }
   OR EXISTS { MATCH (r)-[:SUPPORTED_BY]->(:SourceLocator)<-[:SUPPORTED_BY]-(o) }
RETURN r.uid AS retellingUid, o.uid AS originalUid;

// V-413: RETELLS must state its mode and its basis; a BellLabs match needs a hypothesis,
// an explicit citation needs the citing locator.
// status: statically-checked
MATCH (r:Assertion)-[x:RETELLS]->(o:Assertion)
WHERE x.retellingMode IS NULL OR x.linkBasis IS NULL
   OR (x.linkBasis = 'BELLLABS_MATCH' AND NOT EXISTS { MATCH (h:ResolutionHypothesis) WHERE h.uid = x.hypothesisUid })
   OR (x.linkBasis = 'EXPLICIT_CITATION' AND NOT EXISTS { MATCH (cl:SourceLocator) WHERE cl.uid = x.citationLocatorUid })
RETURN r.uid AS retellingUid, o.uid AS originalUid;

// V-414: qualification loss is an assessment, never a field on an assertion.
// status: statically-checked
MATCH (a:Assertion)
WHERE a.qualificationLost IS NOT NULL OR a.lostQualificationKinds IS NOT NULL
RETURN a.uid AS assertionCarryingAssessmentField;

// V-415: a RetellingFidelityAssessment compares exactly one retelling with exactly one
// original that the retelling RETELLS (directly or through a chain).
// status: statically-checked
MATCH (f:RetellingFidelityAssessment)
OPTIONAL MATCH (f)-[:ASSESSES_RETELLING]->(r:Assertion)
WITH f, collect(r) AS rs
OPTIONAL MATCH (f)-[:AGAINST_ORIGINAL]->(o:Assertion)
WITH f, rs, collect(o) AS os
WHERE size(rs) <> 1 OR size(os) <> 1 OR f.methodVersion IS NULL
   OR NOT EXISTS { MATCH (x:Assertion)-[:RETELLS*1..10]->(y:Assertion) WHERE x = rs[0] AND y = os[0] }
RETURN f.uid AS malformedFidelityAssessment;

// V-417: INSTANCE_OF (occurrence -> proposition) is a resolution result: it names
// a derivation rule or an accepted hypothesis.
// status: statically-checked
MATCH (a:Assertion)-[i:INSTANCE_OF]->(c:Claim)
WHERE i.derivationRule IS NULL AND i.hypothesisUid IS NULL
RETURN a.uid AS assertionUid, c.uid AS claimUid;

// V-418: evidence strength is an assessment, not a Claim property (migration check).
// status: statically-checked
MATCH (c:Claim)
WHERE c.evidenceStrength IS NOT NULL
RETURN c.uid AS claimWithInlineEvidenceStrength;

// V-419: a structured RelationshipAssertion and a ClaimOccurrence must not record the
// same proposition from the same span (double counting one act of saying).
// status: statically-checked
MATCH (ra:RelationshipAssertion)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:SUPPORTED_BY]-(co:ClaimOccurrence)
WHERE ra <> co AND ra.predicate = co.predicate
  AND EXISTS { MATCH (ra)-[:HAS_SUBJECT]->(s)<-[:HAS_SUBJECT]-(co) }
RETURN ra.uid AS relationshipAssertionUid, co.uid AS duplicateOccurrenceUid, l.uid AS sharedLocator;

// V-420: live RelationshipAssertion SUBJECT/OBJECT lists collapse more than one
// proposition (catalog INV-003 needs exactly one subject).
// status: statically-checked
MATCH (ra:RelationshipAssertion)
OPTIONAL MATCH (ra)-[:SUBJECT]->(s)
WITH ra, count(s) AS subjects
OPTIONAL MATCH (ra)-[:OBJECT]->(o)
WITH ra, subjects, count(o) AS objects
WHERE subjects > 1 OR objects > 1
RETURN ra.uid AS multiPropositionRelationshipAssertion, subjects, objects;

// ---------------------------------------------------------------------
// C. Financial relationships and forbidden implications (CQ-CL-05, CQ-CL-08, CQ-EC-03)
// ---------------------------------------------------------------------

// V-421: financial-interest role edges are projections of assertions, keep the
// assertion's bounds, and have a non-negative interval.
// status: statically-checked
MATCH (s)-[r:SPONSORS_CONTENT|INVESTED_IN|HOLDS_EQUITY_IN|BOARD_MEMBER_OF|ADVISES_ORGANIZATION|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATE_FOR_OFFER|FOUNDED_ORGANIZATION|EMPLOYED_BY]->(o)
WHERE r.assertionUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion) WHERE a.uid = r.assertionUid }
   OR (r.validFrom IS NOT NULL AND r.validTo IS NOT NULL AND r.validTo <= r.validFrom)
   OR EXISTS { MATCH (a:Assertion) WHERE a.uid = r.assertionUid AND a.validTo IS NOT NULL AND r.validTo IS NULL }
RETURN s.uid AS fromUid, type(r) AS relType, o.uid AS toUid;

// V-422: ENDORSES_PRODUCT exists only as the projection of an accepted
// ENDORSES_PRODUCT assertion; sponsorship, mention, advising or use never create it.
// status: statically-checked
MATCH (p)-[e:ENDORSES_PRODUCT]->(x)
WHERE e.assertionUid IS NULL
   OR NOT EXISTS { MATCH (a:Assertion) WHERE a.uid = e.assertionUid AND a.predicate = 'ENDORSES_PRODUCT' AND a.status = 'ACCEPTED' }
RETURN p.uid AS endorserUid, x.uid AS endorsedUid;

// V-424: a truth verdict may not rest only on a financial relationship (disclosed
// sponsorship does not make a claim false; absence of a conflict does not make it true).
// status: statically-checked
MATCH (adj:Adjudication)-[:EVALUATES]->(a:Assertion)
WHERE adj.verdict IN ['CONTRADICTED', 'SUPPORTED']
  AND EXISTS { MATCH (adj)-[:CONSIDERS_ASSESSMENT]->(:ConflictRelevanceAssessment) }
  AND NOT EXISTS {
    MATCH (adj)-[:SUPPORTED_BY|CONTRADICTED_BY]->(:SourceLocator)<-[:SUPPORTED_BY]-(ev:Assertion)
    WHERE NOT ev.predicate IN ['SPONSORS_CONTENT', 'INVESTED_IN', 'HOLDS_EQUITY_IN', 'BOARD_MEMBER_OF', 'ADVISES_ORGANIZATION',
                               'HAS_IP_INTEREST_IN', 'RECEIVES_COMPENSATION_FROM', 'AFFILIATE_FOR_OFFER', 'FOUNDED_ORGANIZATION', 'EMPLOYED_BY']
  }
RETURN adj.uid AS verdictFromFinancialTieOnly, a.uid AS assertionUid, adj.verdict AS verdict;

// V-425: a ConflictRelevanceAssessment names its method, level, the occurrence and
// at least one interest assertion.
// status: statically-checked
MATCH (c:ConflictRelevanceAssessment)
WHERE c.methodVersion IS NULL OR c.relevanceLevel IS NULL OR c.disclosureFinding IS NULL
   OR NOT EXISTS { MATCH (c)-[:FOR_OCCURRENCE]->(:Assertion) }
   OR NOT EXISTS { MATCH (c)-[:ASSESSES_INTEREST]->(:Assertion) }
RETURN c.uid AS malformedConflictAssessment;

// V-426: 'NOT_DISCLOSED' cannot be concluded when any capture of the container is partial.
// status: statically-checked
MATCH (c:ConflictRelevanceAssessment {disclosureFinding: 'NOT_DISCLOSED'})-[:FOR_OCCURRENCE]->(o:Assertion)-[:OCCURS_IN]->(container)
WHERE EXISTS {
  MATCH (container)<-[:RENDITION_OF*0..1]-(:Source)-[:HAS_SNAPSHOT]->(s:SourceSnapshot)
  WHERE s.captureCompleteness IS NULL OR s.captureCompleteness <> 'COMPLETE'
}
RETURN c.uid AS undisclosedFromPartialCapture;

// V-427: DIRECT relevance needs a role interval that can overlap the utterance.
// Rows when the role's known validTo precedes the container's publication.
// status: statically-checked
MATCH (c:ConflictRelevanceAssessment {relevanceLevel: 'DIRECT'})-[:FOR_OCCURRENCE]->(o:Assertion)-[:OCCURS_IN]->(container)
MATCH (c)-[:ASSESSES_INTEREST]->(role:Assertion)
WITH c, container, collect(role) AS roles
WHERE container.publishedAt IS NOT NULL
  AND all(r IN roles WHERE r.validTo IS NOT NULL AND r.validTo <= container.publishedAt)
RETURN c.uid AS directRelevanceWithExpiredRoles;

// ---------------------------------------------------------------------
// D. Lineage and the five provenance states (CQ-PV-01, CQ-PV-03, CQ-PV-06)
// ---------------------------------------------------------------------

// V-428: an extraction confidence without the activity that produced it is uninterpretable.
// status: statically-checked
MATCH (a:Assertion)
WHERE a.extractionConfidence IS NOT NULL
  AND NOT EXISTS { MATCH (a)-[:WAS_GENERATED_BY]->(:Activity) }
RETURN a.uid AS confidenceWithoutActivity;

// V-429: an answer-composition activity that used any locator or assertion must name
// the policy version that authorized the use (state 5).
// status: statically-checked
MATCH (act:Activity {activityKind: 'ANSWER_COMPOSITION'})-[:USED]->(x)
WHERE (x:SourceLocator OR x:Assertion)
  AND NOT EXISTS { MATCH (act)-[u:AUTHORIZED_BY]->(:PolicyVersion) WHERE u.useKind IS NOT NULL }
RETURN act.uid AS unauthorizedUse, x.uid AS usedUid;

// V-430: mongoResearchRunId is a projection seam; every committed assertion carrying it
// must also have the Activity it names (migration completeness).
// status: statically-checked
MATCH (a:Assertion)
WHERE a.mongoResearchRunId IS NOT NULL
  AND NOT EXISTS {
    MATCH (a)-[:WAS_GENERATED_BY]->(act:Activity)
    WHERE act.externalRunSystem = 'mongo-research' AND act.externalRunId = a.mongoResearchRunId
  }
RETURN a.uid AS assertionWithUnmappedRunId;

// V-431: Agent identity is not a run: runUid belongs on Activity (catalog CHANGE).
// status: statically-checked
MATCH (g:Agent)
WHERE g.runUid IS NOT NULL
RETURN g.uid AS agentCarryingRunUid;

// V-433: a consumer brand and a legal entity are never one node.
// status: statically-checked
MATCH (n:ConsumerBrand:LegalEntity)
RETURN n.uid AS collapsedBrandAndLegalEntity;

// V-434: equity or board roles stated for a corporate group are not pushed down to
// a member company without an assertion naming that company.
// status: statically-checked
MATCH (p:Person)-[r:HOLDS_EQUITY_IN|BOARD_MEMBER_OF|INVESTED_IN]->(o:Organization)
WHERE NOT EXISTS { MATCH (a:Assertion)-[:HAS_OBJECT]->(o) WHERE a.uid = r.assertionUid }
RETURN p.uid AS personUid, type(r) AS relType, o.uid AS organizationWithoutDirectAssertion;

// Service-enforced (Neo4j cannot express): exactly-one container/asserter per
// ClaimOccurrence (V-410), locator/container agreement (V-411), RETELLS acyclicity
// (V-412), selector minimum fields by selectorKind (V-401), verdict independence
// from financial ties (V-424), partial-capture disclosure findings (V-426).


// =====================================================================================
// Lane 5, rounds 0007 and 0008: time, private context, protocols, recommendations (V-5xx)
// Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// Every query below is statically checked (syntax and per-statement variable binding) unless marked
// illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// =====================================================================================

// Lane 5 validation fragment (rounds 0007 and 0008). Neo4j 5 Cypher.
// Each V-5xx query returns zero rows in a valid committed SHARED graph unless marked informational.
// None of these were executed (no Neo4j in this environment). "statically-checked" means the query was read for
// validity against catalog labels and parsed with the @neo4j-cypher/language-support linter (syntax and
// variable binding); "illustrative" means it depends on a parameter, a plugin, or the live GraphQL labels.
//
// Exclusive attachment types (catalog temporalCardinalityDeclarations): HAS_FORMULATION_VERSION (partition
// jurisdiction), HAS_REGISTRATION_VERSION, HAS_PROTOCOL_EDITION. Private-store types (HAS_CONTEXT_VERSION,
// HAS_ADOPTION_VERSION) are enforced in the PCS (see end of file).

// V-501: episode intervals are non-empty (half-open) in valid and recorded time.
// status: statically-checked
MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
WHERE (h.validFrom IS NOT NULL AND h.validTo IS NOT NULL AND h.validTo <= h.validFrom)
   OR (h.recordedTo IS NOT NULL AND h.recordedTo < h.recordedFrom)
   OR h.recordedFrom IS NULL OR h.relationshipUid IS NULL
RETURN type(h) AS relType, h.relationshipUid AS episode, h.validFrom, h.validTo, h.recordedFrom, h.recordedTo;

// V-502: no sentinel maximum dates on assertions or episodes (open bounds are null).
// status: statically-checked
MATCH (a:Assertion)
WHERE (a.validTo IS NOT NULL AND a.validTo.year >= 9999) OR (a.recordedTo IS NOT NULL AND a.recordedTo.year >= 9999)
RETURN 'ASSERTION' AS kind, a.uid AS item
UNION
MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
WHERE (h.validTo IS NOT NULL AND h.validTo.year >= 9999) OR (h.recordedTo IS NOT NULL AND h.recordedTo.year >= 9999)
RETURN 'EPISODE' AS kind, h.relationshipUid AS item;

// V-506: supersession closes the older assertion exactly at the newer one's recordedAt; status projection agrees.
// status: statically-checked
MATCH (newer:Assertion)-[s:SUPERSEDES]->(older:Assertion)
WHERE older.recordedTo IS NULL OR older.recordedTo <> s.recordedAt OR newer.recordedAt <> s.recordedAt
RETURN 'CLOSURE_MISMATCH' AS violation, older.uid AS item
UNION
MATCH (a:Assertion)
WHERE (a.recordedTo IS NOT NULL AND NOT a.status IN ['SUPERSEDED', 'REJECTED'])
   OR (a.status = 'SUPERSEDED' AND NOT ()-[:SUPERSEDES]->(a))
RETURN 'STATUS_PROJECTION_MISMATCH' AS violation, a.uid AS item;

// V-507: SUPERSEDES links like to like, points from newer to older, and has no cycles.
// status: statically-checked
MATCH (x)-[s:SUPERSEDES]->(y)
WHERE NOT ((x:Assertion AND y:Assertion) OR (x:Adjudication AND y:Adjudication) OR (x:EvidenceAssessment AND y:EvidenceAssessment))
   OR x.recordedAt < y.recordedAt
RETURN 'BAD_SUPERSESSION' AS violation, x.uid AS item
UNION
MATCH p = (x)-[:SUPERSEDES*1..20]->(x)
RETURN 'SUPERSESSION_CYCLE' AS violation, x.uid AS item;

// V-507b: a VALIDITY_BOUNDED supersession keeps object and start and only closes an open end.
// status: statically-checked
MATCH (newer:Assertion)-[:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED'}]->(older:Assertion)
OPTIONAL MATCH (newer)-[:HAS_OBJECT]->(newObj)
OPTIONAL MATCH (older)-[:HAS_OBJECT]->(oldObj)
WITH newer, older, newObj, oldObj
WHERE coalesce(newObj.uid, '-') <> coalesce(oldObj.uid, '-')
   OR coalesce(toString(newer.valueNumber), '-') <> coalesce(toString(older.valueNumber), '-')
   OR coalesce(newer.valueString, '-') <> coalesce(older.valueString, '-')
   OR coalesce(toString(newer.validFrom), '-') <> coalesce(toString(older.validFrom), '-')
   OR older.validTo IS NOT NULL OR newer.validTo IS NULL
RETURN newer.uid AS boundingAssertion, older.uid AS boundedAssertion;

// V-510: accepted literal assertions of an exclusive predicate do not definitely overlap with different values.
// $exclusivePredicates is the catalog list (for example ['REGISTRATION_RECRUITMENT_STATUS']).
// status: illustrative
MATCH (a1:Assertion)-[:HAS_SUBJECT]->(s)<-[:HAS_SUBJECT]-(a2:Assertion)
WHERE a1.predicate IN $exclusivePredicates AND a2.predicate = a1.predicate AND elementId(a1) < elementId(a2)
  AND a1.status = 'ACCEPTED' AND a2.status = 'ACCEPTED' AND a1.recordedTo IS NULL AND a2.recordedTo IS NULL
  AND coalesce(a1.valueString, toString(a1.valueNumber), toString(a1.valueBoolean))
      <> coalesce(a2.valueString, toString(a2.valueNumber), toString(a2.valueBoolean))
  AND a1.validFrom IS NOT NULL AND a2.validFrom IS NOT NULL AND a1.validTo IS NOT NULL AND a2.validTo IS NOT NULL
  AND a1.validFrom < a2.validTo AND a2.validFrom < a1.validTo
RETURN s.uid AS subjectUid, a1.predicate AS predicate, a1.uid AS assertion1, a2.uid AS assertion2;

// V-511: historical adjudications are not re-pointed. An adjudication cites only snapshots retrieved before it was
// recorded; every adjudication has recordedAt.
// status: statically-checked
MATCH (adj:Adjudication)
WHERE adj.recordedAt IS NULL
RETURN 'ADJUDICATION_WITHOUT_RECORDED_AT' AS violation, adj.uid AS item
UNION
MATCH (adj:Adjudication)-[:SUPPORTED_BY|CONTRADICTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE sn.retrievedAt > adj.recordedAt
RETURN 'ADJUDICATION_CITES_LATER_SNAPSHOT' AS violation, adj.uid AS item;

// V-513: live TemporalSnapshot projection nodes are frozen after commit except for the single recordedTo write.
// Uses live GraphQL labels and their @timestamp fields.
// status: illustrative
MATCH (s)
WHERE (s:ProductSnapshot OR s:OrganizationSnapshot OR s:ListingSnapshot)
  AND s.updatedAt > s.createdAt
  AND (s.recordedTo IS NULL OR s.updatedAt > s.recordedTo + duration('PT1M'))
RETURN labels(s) AS labels, s.id AS liveId, s.createdAt, s.updatedAt, s.recordedTo;

// V-514: assertion kernel fields present (KCR-0007-1).
// status: statically-checked
// 0.2.0 integration: recordedAt is required everywhere; contentHash and the per-bound bases are required for new writes
// by the ingestion service (service-enforced) and reported here informationally when absent.
MATCH (a:Assertion)
WHERE a.recordedAt IS NULL
RETURN a.uid AS assertionMissingRecordedAt;

// V-514b (informational): assertions without contentHash (legacy or fixture records; new writes must carry it).
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE a.contentHash IS NULL
RETURN count(a) AS assertionsWithoutContentHash;

// V-520: no private-store labels in the shared graph (production form of fixture F-V6).
// status: statically-checked
// Nodes labelled :PrivateRecord are excluded: that label exists only in single-file two-store fixtures (recommendation-snapshot),
// whose own F-V6 queries cover them. In production the private store is a separate database and no node carries the label.
MATCH (n)
WHERE NOT n:PrivateRecord AND (n:UserContext OR n:UserContextVersion OR n:UserGoal OR n:UserGoalVersion
   OR n:PersonalMeasurement OR n:PersonalLabReport OR n:ProtocolInUse OR n:ProtocolAdoptionVersion OR n:ProtocolDeviation
   OR n:SharingGrant OR n:DisclosureEvent OR n:PendingItem OR n:PurchaseEvent OR n:PersonalApplicabilityAssessment
   OR n:ErasureTombstone OR n:RecommendationRequest OR n:RecommendationSnapshot OR n:RecommendationOption
   OR n:DecisionCriterionValue OR n:UserDecision)
RETURN labels(n) AS labels, n.uid AS privateNodeInSharedGraph;

// V-522 (informational): semantic nodes without a privacyClass. Null must never be read as public.
// status: statically-checked
MATCH (n)
WHERE (n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment)
  AND n.privacyClass IS NULL
RETURN labels(n) AS labels, n.uid AS nodeWithoutPrivacyClass
LIMIT 100;

// V-523: no timeless recommendation edges; a source's RECOMMENDS is a projection of an assertion.
// status: statically-checked
MATCH (p)-[r:RECOMMENDED_FOR]->(g)
RETURN 'RECOMMENDED_FOR_EDGE' AS violation, p.uid AS fromUid, g.uid AS toUid
UNION
MATCH (src:Person)-[r:RECOMMENDS]->(t)
WHERE r.assertionUid IS NULL AND r.recordedFrom >= datetime($catalogV020CutoverAt)
RETURN 'SOURCE_RECOMMENDS_WITHOUT_ASSERTION' AS violation, src.uid AS fromUid, t.uid AS toUid;

// V-524: shared applicability never targets a personal context; private measurements never collapse into Observation.
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:ASSESSES_APPLICABILITY_TO]->(u:UserContext)
RETURN 'APPLICABILITY_TO_USER_CONTEXT' AS violation, ea.uid AS item
UNION
MATCH (x:Observation:PersonalMeasurement)
RETURN 'OBSERVATION_PERSONAL_MEASUREMENT_COLLAPSE' AS violation, x.uid AS item;

// Q-505 (CQ-TM-06): impact of a source revision: assertions supported by the prior snapshot, their latest
// adjudication, and whether a newer adjudication or a superseding assertion exists.
// status: statically-checked
MATCH (ev:SourceRevisionEvent {uid: $revisionEventUid})-[:PRIOR_SNAPSHOT]->(sn:SourceSnapshot)-[:HAS_LOCATOR]->(l:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
OPTIONAL MATCH (adj:Adjudication)-[:EVALUATES]->(a)
OPTIONAL MATCH (newer:Assertion)-[s:SUPERSEDES]->(a)
RETURN ev.revisionKind AS revisionKind, ev.recordedAt AS learnedAt, a.uid AS affectedAssertion,
       collect(DISTINCT {adjudication: adj.uid, verdict: adj.verdict, recordedAt: adj.recordedAt}) AS adjudications,
       newer.uid AS supersededBy, s.supersessionKind AS supersessionKind;

// =====================================================================================
// Rules Neo4j cannot enforce
// =====================================================================================
// -- service-enforced: recordedFrom / recordedAt assigned by the ingestion service at commit; clients cannot supply them (INV-502).
// -- service-enforced: only one write to recordedTo, from null, on assertions and episodes (INV-501).
// -- service-enforced: DEFINITE exclusive overlaps refused at commit (V-508 detects any that slipped through).
// -- service-enforced: contentHash and payloadHash computed at commit over canonicalized content.
// -- service-enforced (PCS): RecommendationSnapshot, RecommendationOption, DecisionCriterionValue, UserContextVersion,
//    UserGoalVersion, ProtocolAdoptionVersion, SharingGrant rows are insert-only for the application role; only the
//    erasure job may delete them (INV-507).
// -- service-enforced (PCS, native temporal key): one HAS_CONTEXT_VERSION episode per context and instant, e.g.
//    PostgreSQL: PRIMARY KEY (user_context_uid, valid_period WITHOUT OVERLAPS) on the current-recorded episode table
//    (SRC-PG-WIKI-SQL2011-TEMPORAL; verify the deployed PostgreSQL version supports it).
// -- service-enforced (PCS): every DisclosureEvent falls inside a current PERMIT grant episode covering its categories;
//    revocation episodes have validTo >= their recordedFrom (no retroactive revocation) (INV-509).
// -- service-enforced (PCS): erasure deletes all rows for the subject, writes an ErasureTombstone, destroys the per-user
//    data key, and blocks until every registered projection acknowledges purge (CQ-PC-05).
// -- service-enforced (publication pipeline): de-identified contributions carry year-only dates and a contributionToken;
//    no private uid crosses into the shared graph (V-521 detects violations).


// ======== W00/validation-corrections.cypher ========
// =====================================================================================================
// W00 validation corrections (reconciliation pass, run-2026-10-04-fable51-01).
// Each block: "<new id> -- replaces <frozen id>; ruling W00-R-nn", the requester's failing case, the ORIGINAL frozen text from
// docs/schema/neo4j/validation.cypher kept as comments (never executed), and the REVISED query. Zero rows = valid unless marked
// (informational). Every statement is self-contained. Parameters come from fixtures/validation-params-w00.json (Fable's
// validation/validation-params.json plus the deltas listed in 10-kernel-operations-delta.md section 3).
// Executed on embedded Neo4j 5.26.31 Community + APOC 5.26.31 against W00 fixtures 00-13 and the targeted worker fixtures;
// row counts (original vs revised) are in fixtures/results/validation-corrections-runs.md.
// Validators adopted by reference and NOT copied here (owner keeps the text, Fable assigns final ids): V-314..V-318 (W07),
// W20-V02..W20-V10 (W20), V-W21-01..V-W21-12 except -06/-12 (W21), V-601..V-615 (W22), V-W23-* (W23; -09/-10 absorbed by V-521r).
// =====================================================================================================

// ===================================================================================================
// V-003r -- replaces V-003; ruling W00-R-02
// INV-003 literal-xor-object stays for every predicateClass except QUANTITY, which may carry one object plus one numeric
// literal (valueNumber + unitCode). Failing cases: W02 fx-91 (two literal-only CALCULATED amounts, refersTo null), W04 w04-03
// (component -> NR cation 263.42 mg fails V-003), W07-SR-13 (CHANGED_BETWEEN with delta).
// ORIGINAL (kept for comparison; not executed):
// | // V-003: assertions must have exactly one object OR one typed literal.
// | MATCH (a:Assertion)
// | OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
// | WITH a, count(o) AS objects,
// |      size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
// | WHERE objects + literals <> 1
// | RETURN a.uid AS assertionUid, objects, literals;
// REVISED:
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, count(o) AS objects,
     size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
WITH a, objects, literals, coalesce(a.predicateClass, '') = $quantityPredicateClass AS isQuantity
WHERE (NOT isQuantity AND objects + literals <> 1)
   OR (isQuantity AND (objects > 1 OR literals > 1 OR objects + literals = 0
        OR (objects = 1 AND literals = 1 AND (a.valueNumber IS NULL OR a.unitCode IS NULL))))
RETURN 'V-003r' AS check, a.uid AS assertionUid, a.predicateClass AS predicateClass, objects, literals;

// ===================================================================================================
// V-006r -- replaces V-006; ruling W00-R-33
// QUANTITATIVELY_CONTAINS quantity shape agrees with its comparator (ranges and one-sided limits). Failing case W02 fx-91:
// Ph. Eur. Ginkgo BETWEEN edges -> frozen V-006 2 rows on complete statements.
// Revised text source: W02/operations.cypher V-W02-10 (W02-SR-02)
// ORIGINAL (kept for comparison; not executed):
// | // V-006: quantitative containment requires quantity, unit, and basis.
// | MATCH ()-[r:QUANTITATIVELY_CONTAINS]->()
// | WHERE r.quantity IS NULL OR r.unitCode IS NULL OR r.basis IS NULL
// | RETURN r;
// REVISED:
MATCH (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
WHERE r.unitCode IS NULL OR r.basis IS NULL OR r.contentStatementKind IS NULL OR r.comparator IS NULL
   OR (r.comparator IN ['EQ', 'APPROX', 'GE', 'GT', 'LE', 'LT'] AND r.quantity IS NULL)
   OR (r.comparator = 'BETWEEN' AND (r.quantityLow IS NULL OR r.quantityHigh IS NULL OR r.quantityLow >= r.quantityHigh OR r.quantity IS NOT NULL))
RETURN 'V-006r' AS check, x.uid AS material, y.uid AS target, r.comparator AS comparator, r.quantity AS quantity, r.basis AS basis;

// ===================================================================================================
// V-101r -- replaces V-101; ruling W00-R-41
// Unchanged text; the W00 copy (validation-w00.cypher) had an inlined list. Runs with validation-params-w00.json $assertedTypes,
// which adds the W01 organization edges (W01-SR-06), W15 commerce edges (W15-SR-11b), W21 edges (W21-SR-16), HAS_PATHWAY_VERSION
// and drops IDENTIFIED_BY (relabelled HAS_IDENTIFIER, W00-R-20). Failing case W15 N9 / W01 N4, N8.
// ORIGINAL (kept for comparison; not executed):
// | // =====================================================================================
// | // Lane 1, round 0009: query-shape invariants (V-1xx)
// | // Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// | // Every query below is statically checked (syntax and per-statement variable binding) unless marked
// | // illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// | // =====================================================================================
// | 
// | // Lane 1 validation queries V-101..V-121 (access, query shapes, temporal and search-surface invariants).
// | // Zero rows = valid unless marked informational. Every statement is self-contained: it binds its own
// | // variables and shares nothing across ';'. None of these was executed; no Neo4j was available.
// | // Status tags:
// | //   statically-checked = parsed with the Neo4j Cypher language-support linter (syntax and schema-free
// | //                        semantics) and read against catalog labels, relationship types and properties.
// | //   illustrative       = depends on a parameter list or a catalog decision that is not yet merged.
// | // Parameters ($...) are supplied by the validation runner from the merged catalog.
// | 
// | // V-101: every asserted edge carries its authorizing assertion and a recorded-time start.
// | // status: statically-checked
// | // params: $assertedTypes list<string> generated from catalog relationships with class: asserted
// | MATCH ()-[r]->()
// | WHERE type(r) IN $assertedTypes
// |   AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL)
// | RETURN type(r) AS relType, elementId(r) AS edgeId, r.recordedFrom AS recordedFrom, r.assertionUid AS assertionUid;
// REVISED:
MATCH ()-[r]->()
WHERE type(r) IN $assertedTypes
  AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL)
RETURN 'V-101r' AS check, type(r) AS relType, elementId(r) AS edgeId, r.recordedFrom AS recordedFrom, r.assertionUid AS assertionUid;

// ===================================================================================================
// V-108r (informational) -- replaces V-108; ruling W00-R-39
// Informational: POSSIBLE overlaps go to the review queue (V-509r); DEFINITE overlaps are V-508r errors. Partition key is the
// edge property with the target node as fallback: coalesce(r.jurisdiction, t.jurisdiction). Failing case W04 w04-04 (Basis variant,
// two OBSERVATION_ONLY formulation versions; frozen V-108 reports a violation for an honest unknown transition date).
// ORIGINAL (kept for comparison; not executed):
// | // V-108: exclusive predicates: no two possibly-overlapping believed attachments from one subject
// | // to different objects within one scope. Unknown bounds are treated as possible overlap.
// | // status: illustrative (depends on predicate exclusivity metadata, catalog conventions.predicateExclusivity)
// | // params: $exclusiveTypes list<string>
// | MATCH (x)-[r1]->(y1), (x)-[r2]->(y2)
// | WHERE type(r1) = type(r2)
// |   AND type(r1) IN $exclusiveTypes
// |   AND elementId(r1) < elementId(r2)
// |   AND y1 <> y2
// |   AND coalesce(y1.jurisdiction, '') = coalesce(y2.jurisdiction, '')
// |   AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
// |   AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
// |   AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
// |   AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
// | RETURN type(r1) AS relType, x.uid AS subjectUid, y1.uid AS objectUid1, y2.uid AS objectUid2,
// |        elementId(r1) AS edge1, elementId(r2) AS edge2;
// REVISED:
MATCH (x)-[r1]->(y1), (x)-[r2]->(y2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND y1 <> y2
  AND coalesce(r1.jurisdiction, y1.jurisdiction, '') = coalesce(r2.jurisdiction, y2.jurisdiction, '')
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
  AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
RETURN 'V-108r' AS check, type(r1) AS relType, x.uid AS subjectUid, y1.uid AS objectUid1, y2.uid AS objectUid2, 'REVIEW_QUEUE' AS action;

// ===================================================================================================
// V-508r -- replaces V-508; ruling W00-R-39
// DEFINITE overlap of exclusive attachments, over every $exclusiveTypes type (adds STRAIN_OF, HAS_PATHWAY_VERSION) with the
// edge-first partition key. Path-partitioned types (HAS_CAPABILITY_STATE, GOVERNED_BY_SPECIFICATION) are audited by V-W11-02/07.
// ORIGINAL (kept for comparison; not executed):
// | // V-508: DEFINITE overlap of mutually exclusive attachments in both valid and recorded time.
// | // Bounds are shrunk by their precision before comparison; null bounds never produce a definite overlap.
// | // status: statically-checked
// | MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
// |       (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
// | WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
// |   AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
// |   AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
// |   AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
// |   AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
// | WITH s, r1, r2, t1, t2,
// |      r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
// |                     WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
// |      r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
// |                     WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
// | WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
// | RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;
// REVISED:
MATCH (s)-[r1]->(t1), (s)-[r2]->(t2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(r1.jurisdiction, t1.jurisdiction, '-') = coalesce(r2.jurisdiction, t2.jurisdiction, '-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
     r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
     r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN 'V-508r' AS check, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// ===================================================================================================
// V-509r (informational) -- replaces V-509; ruling W00-R-39
// POSSIBLE overlap (review queue) over $exclusiveTypes with the edge-first partition key.
// ORIGINAL (kept for comparison; not executed):
// | // V-509 (informational, review queue): POSSIBLE overlap of exclusive attachments caused by a null or imprecise bound,
// | // among currently recorded episodes.
// | // status: statically-checked
// | MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
// |       (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
// | WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
// |   AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
// |   AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
// |   AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
// |   AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
// |   AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
// |        OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
// | RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;
// REVISED:
MATCH (s)-[r1]->(t1), (s)-[r2]->(t2)
WHERE type(r1) = type(r2) AND type(r1) IN $exclusiveTypes AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(r1.jurisdiction, t1.jurisdiction, '-') = coalesce(r2.jurisdiction, t2.jurisdiction, '-')
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
  AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
  AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
       OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
RETURN 'V-509r' AS check, s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;

// ===================================================================================================
// V-112r -- replaces V-112; ruling W00-R-23
// (1) the hypothesis citation is read from derivedFromAssessmentUids (W00-SR-06: no relationship-property type has hypothesisUid);
// (2) $ruleOnlyDerivedTypes adds RESOLVES_TO_CHUNK, HAS_CHUNK, CHUNK_IN_SEGMENT, ABOUT, MENTIONS_ENTITY (W20-SR-01), HAS_CURRENT_PROTOCOL_STEP
// (W16-SR-06) and COMPARED_TO (W07-SR-10); (3) a rule-only COMPARED_TO is legal only between results of the same assay or algorithm
// version (RULE_ONLY_ACROSS_VERSIONS). Failing cases: W20 fixture 01 (offset-overlap-v1 edges), W07 positive fixture (2 rows).
// ORIGINAL (kept for comparison; not executed):
// | // V-112: derived and forbidden-implication edges cite live, matching assertions (QS-4a, zero rows = valid).
// | // status: statically-checked
// | // params: $derivedTypes, $implicationPairs, $ruleOnlyDerivedTypes (catalog relationships with ruleOnly: true)
// | MATCH (x)-[r]->(y)
// | WHERE type(r) IN $derivedTypes OR type(r) IN [p IN $implicationPairs | p[1]]
// | WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
// | OPTIONAL MATCH (cited:Assertion {uid: citedUid})
// | WITH x, y, r, citedUid, cited,
// |      [v IN [
// |         CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
// |         CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
// |         CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
// |         CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) = 0
// |                   AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AND r.hypothesisUid IS NULL
// |                   AND NOT type(r) IN $ruleOnlyDerivedTypes THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
// |         CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
// |              THEN 'LICENSING_ASSESSMENT_MISSING' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
// |                MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
// |                  AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = inp.predicate)
// |              } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
// |         CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
// |                size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
// |              THEN 'DERIVATION_INPUT_MISSING' END
// |      ] WHERE v IS NOT NULL] AS violations
// | WHERE size(violations) > 0
// | RETURN type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;
// REVISED:
MATCH (x)-[r]->(y)
WHERE type(r) IN $derivedTypes OR type(r) IN [p IN $implicationPairs | p[1]]
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, citedUid, cited,
     size(coalesce(r.derivedFromAssertionUids, [])) = 0 AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AS noInputs,
     [v IN [
        CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
        CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
             THEN 'LICENSING_ASSESSMENT_MISSING' END,
        CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
               MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
                 AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = inp.predicate)
             } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
               size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
             THEN 'DERIVATION_INPUT_MISSING' END
     ] WHERE v IS NOT NULL] AS firstViolations
WITH x, y, r, noInputs, firstViolations + [v IN [
        CASE WHEN r.derivationRule IS NOT NULL AND noInputs AND NOT type(r) IN $ruleOnlyDerivedTypes THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
        CASE WHEN type(r) = 'COMPARED_TO' AND r.derivationRule IS NOT NULL AND noInputs AND (
               EXISTS { MATCH (x)-[:PRODUCED_BY_ASSAY_VERSION]->(av1), (y)-[:PRODUCED_BY_ASSAY_VERSION]->(av2) WHERE av1 <> av2 }
            OR EXISTS { MATCH (x)-[:COMPUTED_BY_ALGORITHM_VERSION]->(gv1), (y)-[:COMPUTED_BY_ALGORITHM_VERSION]->(gv2) WHERE gv1 <> gv2 })
             THEN 'RULE_ONLY_ACROSS_VERSIONS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-112r' AS check, type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;

// ===================================================================================================
// V-W00-02r -- replaces V-W00-02 (W00 packet); ruling W00-R-41
// Citation-field discipline (D-011) read from $assertedTypes / $derivedTypes instead of an inlined list (W15-SR-11b: N9 caught by the
// catalog V-101 but not by the W00 list). A legacy RECOMMENDS edge with assertionUid reports here as a migration item (W00-R-25).
// ORIGINAL (kept for comparison; not executed):
// | // V-W00-02 (D-011, CL-009): asserted edges carry assertionUid, derived edges projectionOfAssertionUid, never both;
// | // an asserted type never carries projectionOfAssertionUid; a derived type never carries assertionUid.
// | MATCH ()-[r]->()
// | WHERE (r.assertionUid IS NOT NULL AND r.projectionOfAssertionUid IS NOT NULL)
// |    OR (type(r) IN ['HAS_FORMULATION_VERSION','HAS_STATE','HAS_IDENTIFIER','BOARD_MEMBER_OF','ADVISES_ORGANIZATION','SELLER_OF_RECORD_FOR','HOSTS_LISTING','LISTS_OFFER','ENDORSES_PRODUCT','IDENTIFIED_BY'] AND r.projectionOfAssertionUid IS NOT NULL)
// |    OR (type(r) IN ['SELLS_PRODUCT','CONTAINS','INSTANCE_OF'] AND r.assertionUid IS NOT NULL)
// | RETURN 'V-W00-02' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge;
// REVISED:
MATCH ()-[r]->()
WHERE (r.assertionUid IS NOT NULL AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN $assertedTypes AND r.projectionOfAssertionUid IS NOT NULL)
   OR (type(r) IN $derivedTypes AND r.assertionUid IS NOT NULL)
RETURN 'V-W00-02r' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge,
       CASE WHEN type(r) IN $derivedTypes THEN 'ASSERTION_UID_ON_DERIVED_EDGE' ELSE 'PROJECTION_UID_ON_ASSERTED_EDGE' END AS violation;

// ===================================================================================================
// V-211r -- replaces V-211; ruling W00-R-34
// Count DISTINCT owning registrations (W09-CR-03): the round-0007 re-bounding shape (closed e1 + e1b) gives owners = 2 under V-211.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-211: every RegistrationVersion belongs to exactly one TrialRegistration and has observedAt.
// | // status: statically-checked
// | MATCH (rv:RegistrationVersion)
// | OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
// | WITH rv, count(r) AS owners
// | WHERE owners <> 1 OR rv.observedAt IS NULL
// | RETURN rv.uid AS registrationVersion, owners;
// REVISED:
MATCH (rv:RegistrationVersion)
OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
WITH rv, count(DISTINCT r) AS owners
WHERE owners <> 1 OR rv.observedAt IS NULL
RETURN 'V-211r' AS check, rv.uid AS registrationVersion, owners;

// ===================================================================================================
// V-217r -- replaces V-217; ruling W00-R-34
// Hard part of INV-207 only (W09-CR-01): a missing collection method. Faithful NOT_DESCRIBED zeros move to V-217i.
// Failing case: S-07 Basis and S-19 ENERGIZE captures, frozen V-217 5 rows.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-217 (INV-207): adverse-event results state a collection method; zeros need one.
// | // status: statically-checked
// | MATCH (ae:AdverseEventResult)
// | WHERE ae.collectionMethod IS NULL OR (ae.participantsAffected = 0 AND ae.collectionMethod = 'NOT_DESCRIBED')
// | RETURN ae.uid AS aeResult, ae.participantsAffected AS affected, ae.collectionMethod AS method;
// REVISED:
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod IS NULL
RETURN 'V-217r' AS check, ae.uid AS aeResultWithoutCollectionMethod, ae.eventCount AS eventCount, ae.participantsAffected AS affected;

// ===================================================================================================
// V-217i (informational) -- replaces V-217 (zero branch); ruling W00-R-34
// Informational companion of V-217r: zeros whose collection method the source does not describe.
// Revised text source: W09/fixtures/80-queries.cypher
// REVISED:
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod = 'NOT_DESCRIBED' AND (ae.participantsAffected = 0 OR ae.eventCount = 0)
RETURN 'V-217i' AS check, ae.uid AS zeroWithUndescribedCollection, ae.collectionMethodText AS sourceWording;

// ===================================================================================================
// V-221r -- replaces V-221; ruling W00-R-34
// Null armType checked; sham/no-intervention exempt; bases only for REPORTED amounts; device components NOT_APPLICABLE;
// definition-only interventions complete (W09-CR-02). Failing case W09 fixture 04: 4 false positives, 4 silently skipped arms.
// Revised text source: W09/fixtures/80-queries.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-221 (R1): non-placebo study interventions have components with quantity, unit, quantityBasis, and massBasis
// | // (massBasis may be UNSPECIFIED; quantity may be absent only with quantityStatus NOT_REPORTED).
// | // status: statically-checked
// | MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
// | WHERE arm.armType <> 'PLACEBO_COMPARATOR'
// | OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
// | WITH si, ic
// | WHERE ic IS NULL
// |    OR ic.massBasis IS NULL OR ic.quantityBasis IS NULL
// |    OR (ic.quantity IS NULL AND coalesce(ic.quantityStatus, '') <> 'NOT_REPORTED')
// |    OR (ic.quantity IS NOT NULL AND ic.unitCode IS NULL)
// | RETURN si.uid AS intervention, ic.uid AS incompleteComponent;
// REVISED:
MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
WHERE NOT coalesce(arm.armType, 'UNKNOWN') IN ['PLACEBO_COMPARATOR', 'SHAM_COMPARATOR', 'NO_INTERVENTION']
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
WITH si, ic, EXISTS { MATCH (si)-[:FOLLOWS_INTERVENTION_DEFINITION]->() } AS hasDefinition
WITH si, ic, hasDefinition,
     CASE WHEN ic IS NULL THEN null ELSE EXISTS { MATCH (ic)-[:USES_INTERVENTION_DEVICE]->(:Device) } END AS isDevice
WHERE (ic IS NULL AND NOT hasDefinition)
   OR (ic IS NOT NULL AND isDevice AND coalesce(ic.quantityStatus, '') <> 'NOT_APPLICABLE')
   OR (ic IS NOT NULL AND NOT isDevice AND ic.quantityStatus IS NULL AND ic.quantity IS NULL)
   OR (ic IS NOT NULL AND NOT isDevice AND coalesce(ic.quantityStatus, 'REPORTED') = 'REPORTED'
       AND (ic.quantity IS NULL OR ic.unitCode IS NULL OR ic.quantityBasis IS NULL OR ic.massBasis IS NULL))
RETURN 'V-221r' AS check, si.uid AS intervention, ic.uid AS incompleteComponent;

// ===================================================================================================
// V-231r -- replaces V-231; ruling W00-R-49
// INV-210 binds mechanism-class assertions ("Every mechanism-class Assertion ..."); V-231 tests every assertion with a basisKind, so a
// non-mechanism DIRECT_MEASUREMENT (an adverse-event count, a lab value) without a MechanismEvidenceContext is reported although
// INV-210 does not apply to it (W17-SR-09). A null predicateClass is read as MECHANISM (conservative).
// ORIGINAL (kept for comparison; not executed):
// | // V-231 (INV-210): DIRECT_MEASUREMENT has exactly one context with setting and species (except cell-free / in silico);
// | // non-measured assertions have no context.
// | // status: statically-checked
// | MATCH (a:Assertion)
// | WHERE a.basisKind IS NOT NULL
// | OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
// | WITH a, collect(c) AS ctxs
// | WHERE (a.basisKind = 'DIRECT_MEASUREMENT' AND size(ctxs) <> 1)
// |    OR (a.basisKind <> 'DIRECT_MEASUREMENT' AND size(ctxs) > 0)
// |    OR (size(ctxs) = 1 AND (ctxs[0].setting IS NULL
// |         OR (NOT ctxs[0].setting IN ['IN_VITRO_CELL_FREE', 'IN_SILICO'] AND NOT EXISTS { MATCH (ctx:MechanismEvidenceContext {uid: ctxs[0].uid})-[:IN_SPECIES]->(:Species) })))
// | RETURN a.uid AS assertion, a.basisKind AS basisKind, size(ctxs) AS contexts;
// REVISED:
MATCH (a:Assertion)
WHERE a.basisKind IS NOT NULL AND coalesce(a.predicateClass, 'MECHANISM') = 'MECHANISM'
OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
WITH a, collect(c) AS ctxs
WHERE (a.basisKind = 'DIRECT_MEASUREMENT' AND size(ctxs) <> 1)
   OR (a.basisKind <> 'DIRECT_MEASUREMENT' AND size(ctxs) > 0)
   OR (size(ctxs) = 1 AND (ctxs[0].setting IS NULL
        OR (NOT ctxs[0].setting IN ['IN_VITRO_CELL_FREE', 'IN_SILICO'] AND NOT EXISTS { MATCH (ctx:MechanismEvidenceContext {uid: ctxs[0].uid})-[:IN_SPECIES]->(:Species) })))
RETURN 'V-231r' AS check, a.uid AS assertion, a.basisKind AS basisKind, a.predicateClass AS predicateClass, size(ctxs) AS contexts;

// ===================================================================================================
// V-233r -- replaces V-233; ruling W00-R-26
// Mechanism projections may cite inputs in rule mode mx-proj/v1 + derivedFromAssertionUids (W03-SR-01); V-112 stays the citation
// check. Failing case W03 positive fixture: six valid rule-mode edges, verbatim V-233 4 rows.
// Revised text source: W03/fixtures/w03-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-233 (INV-211, FI-304): mechanism projections only from ACCEPTED DIRECT_MEASUREMENT assertions.
// | // ACCEPTED here is capture fidelity (the measurement was accurately recorded), not a truth verdict; truth gating
// | // of projections is a SUPPORT adjudication question handled by the recommendation layer.
// | // status: statically-checked
// | MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME]->(y)
// | OPTIONAL MATCH (a:Assertion {uid: r.projectionOfAssertionUid})
// | WITH x, r, y, a
// | WHERE a IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT' OR a.status <> 'ACCEPTED'
// | RETURN x.uid AS fromUid, type(r) AS rel, y.uid AS toUid, a.basisKind AS projectedBasis;
// REVISED:
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME|ACTS_IN]->(y)
WITH x, r, y,
     CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN cited
WITH x, r, y, cited, collect(a) AS found
WITH x, r, y, cited, found,
     [v IN [
       CASE WHEN size(cited) = 0 THEN 'NO_CITATION' END,
       CASE WHEN size(found) < size(cited) THEN 'CITED_ASSERTION_MISSING' END,
       CASE WHEN r.projectionOfAssertionUid IS NULL AND coalesce(r.derivationRule, '') <> 'mx-proj/v1' THEN 'UNKNOWN_DERIVATION_RULE' END,
       CASE WHEN any(a IN found WHERE a.basisKind IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT') THEN 'NON_MEASURED_INPUT' END,
       CASE WHEN any(a IN found WHERE a.status <> 'ACCEPTED' OR a.recordedTo IS NOT NULL) THEN 'NON_CURRENT_OR_UNACCEPTED_INPUT' END,
       CASE WHEN any(a IN found WHERE coalesce(a.polarity, 'UNKNOWN') <> 'POSITIVE') THEN 'NON_POSITIVE_INPUT' END,
       CASE WHEN any(a IN found WHERE COUNT { (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext) } <> 1) THEN 'INPUT_WITHOUT_SINGLE_CONTEXT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-233r' AS check, type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, violations;

// ===================================================================================================
// V-234r -- replaces V-234; ruling W00-R-26
// As V-233r for the species clause (W03-SR-01). Verbatim V-234 2 rows on the W03 positive fixture.
// Revised text source: W03/fixtures/w03-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-234 (INV-211, FI-302): APPLIES_TO_SPECIES targets a species of the projected assertion's context.
// | // status: statically-checked
// | MATCH (m:Mechanism)-[r:APPLIES_TO_SPECIES]->(sp:Species)
// | WHERE NOT EXISTS {
// |   MATCH (a:Assertion {uid: r.projectionOfAssertionUid})-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
// | }
// | RETURN m.uid AS mechanism, sp.uid AS speciesWithoutMeasuredContext;
// REVISED:
MATCH (m)-[r:APPLIES_TO_SPECIES]->(sp:Species)
WITH m, r, sp,
     CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
WHERE NOT EXISTS {
  MATCH (a:Assertion)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
  WHERE a.uid IN cited AND a.polarity = 'POSITIVE'
}
RETURN 'V-234r' AS check, m.uid AS subjectUid, sp.uid AS speciesWithoutPositiveMeasuredContext, cited;

// ===================================================================================================
// V-235r -- replaces V-235; ruling W00-R-15
// Join a Source to its work by RENDITION_OF, not by "https://doi.org/" + doi (W19-SR-10: doi.org is a resolver, never a canonicalUri),
// and also read a RETRACTION SourceRevisionEvent on the Source not followed by a REINSTATEMENT. Failing case W19 fixture 90 N2.
// ORIGINAL (kept for comparison; not executed):
// | // V-235 (M6): ACCEPTED assertions whose every supporting locator belongs to a source whose publication is retracted.
// | // Publication-to-Source alignment is Lane 4's (round 0006); this query joins on DOI URI.
// | // status: illustrative
// | MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
// | WITH a, collect(DISTINCT src) AS sources
// | WHERE all(s0 IN sources WHERE EXISTS {
// |   MATCH (notice:Publication)-[:RETRACTS]->(pub:Publication)
// |   WHERE s0.canonicalUri = 'https://doi.org/' + pub.doi
// | })
// | RETURN a.uid AS acceptedAssertionOnlyOnRetractedSources;
// REVISED:
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH a, collect(DISTINCT src) AS sources
WHERE all(s0 IN sources WHERE
        EXISTS { MATCH (s0)-[:RENDITION_OF]->(pub:Publication)<-[:RETRACTS]-(:Publication) }
     OR EXISTS { MATCH (s0)<-[:REVISES_SOURCE]-(ev:SourceRevisionEvent {revisionKind: 'RETRACTION'})
                 WHERE NOT EXISTS { MATCH (s0)<-[:REVISES_SOURCE]-(re:SourceRevisionEvent {revisionKind: 'REINSTATEMENT'}) WHERE re.recordedAt > ev.recordedAt } })
RETURN 'V-235r' AS check, a.uid AS acceptedAssertionOnlyOnRetractedSources;

// ===================================================================================================
// V-302r -- replaces V-302; ruling W00-R-35
// Only a well-formed current ComparabilityAssessment licenses a cross-assay pair (W07-SR-11: N10 masks N1 under V-302).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-302: measured results compared across different assay versions need a COMPARABLE or COMPARABLE_WITH_CONVERSION assessment.
// | // status: statically-checked
// | MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
// | WHERE elementId(r1) < elementId(r2)
// | MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
// |       (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
// | WHERE a1 <> a2
// |   AND NOT EXISTS {
// |     MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
// |     MATCH (ca)-[:COMPARES]->(a2)
// |     WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
// |   }
// | RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;
// REVISED:
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
      (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
WHERE a1 <> a2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
    MATCH (ca)-[:COMPARES]->(a2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
      AND NOT ca.status IN ['SUPERSEDED', 'WITHDRAWN'] AND ca.recordedTo IS NULL
      AND COUNT { (ca)-[:COMPARES]->() } = 2
  }
RETURN 'V-302r' AS check, r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// ===================================================================================================
// V-303r -- replaces V-303; ruling W00-R-35
// A MEASURED result may be pending through an UNRESOLVED PRODUCED_BY_ASSAY_VERSION assertion (W07-SR-09, Everlywell S7).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-303: result kind must match its producing record. Measured results need an assay version;
// | // calculated and inferred results need an algorithm version, unless the link is still an UNRESOLVED
// | // assertion under review (competing proposals), which is the only allowed pending state.
// | // status: statically-checked
// | MATCH (r:DiagnosticResult)
// | WHERE r.resultKind IS NULL
// |    OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion))
// |    OR (r.resultKind IN ['CALCULATED', 'INFERRED']
// |        AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
// |        AND NOT EXISTS {
// |          MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
// |          WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
// |        })
// | RETURN r.uid AS resultUid, r.resultKind AS resultKind;
// REVISED:
MATCH (r:DiagnosticResult)
WHERE r.resultKind IS NULL
   OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'PRODUCED_BY_ASSAY_VERSION' AND x.status = 'UNRESOLVED'
       })
   OR (r.resultKind IN ['CALCULATED', 'INFERRED']
       AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
       })
RETURN 'V-303r' AS check, r.uid AS resultUid, r.resultKind AS resultKind;

// ===================================================================================================
// V-304r -- replaces V-304; ruling W00-R-35
// Same well-formed licence rule as V-302r for algorithm versions (W07-SR-11).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-304: inferred or calculated results compared across different algorithm versions need an assessment.
// | // status: statically-checked
// | MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
// | WHERE elementId(r1) < elementId(r2)
// | MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
// |       (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
// | WHERE v1 <> v2
// |   AND NOT EXISTS {
// |     MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
// |     MATCH (ca)-[:COMPARES]->(v2)
// |     WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
// |   }
// | RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;
// REVISED:
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
      (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
WHERE v1 <> v2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
    MATCH (ca)-[:COMPARES]->(v2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
      AND NOT ca.status IN ['SUPERSEDED', 'WITHDRAWN'] AND ca.recordedTo IS NULL
      AND COUNT { (ca)-[:COMPARES]->() } = 2
  }
RETURN 'V-304r' AS check, r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

// ===================================================================================================
// V-305c -- replaces (new; INV-302 exactly one, complements V-305b); ruling W00-R-35
// No reference interval version bound to two assay versions (W07-SR-11 N4).
// Revised text source: W07/fixtures/w07-validation.cypher
// REVISED:
MATCH (ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WITH ri, collect(DISTINCT a.uid) AS assays
WHERE size(assays) > 1
RETURN 'V-305c' AS check, ri.uid AS intervalUid, assays;

// ===================================================================================================
// V-313r -- replaces V-313; ruling W00-R-06
// Stored privacy classes are the GraphQL enum names PUBLIC/INTERNAL (W07-SR-15: V-313 flags all 15 W07 positive results).
// Revised text source: W07/fixtures/w07-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-313: every DiagnosticResult declares a privacy class (placement is Lane 5's decision).
// | // status: statically-checked
// | MATCH (r:DiagnosticResult)
// | WHERE r.privacyClass IS NULL
// |    OR NOT r.privacyClass IN ['public', 'internal', 'private-personal', 'synthetic']
// | RETURN r.uid AS resultUid;
// REVISED:
MATCH (r:DiagnosticResult)
WHERE r.privacyClass IS NULL OR NOT r.privacyClass IN ['PUBLIC', 'INTERNAL'] OR r.uid STARTS WITH 'hu:private-'
RETURN 'V-313r' AS check, r.uid AS resultUid, r.privacyClass AS privacyClass;

// ===================================================================================================
// V-322r -- replaces V-322; ruling W00-R-36
// A current APPROVAL status backed by an approving response (W13-SR-15, N-07).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-322: live projection Product.status = 'APPROVED' requires an APPROVAL status of that product.
// | // status: statically-checked
// | MATCH (p:Product)
// | WHERE p.status = 'APPROVED'
// |   AND NOT EXISTS {
// |     MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(p)
// |     WHERE s.statusKind = 'APPROVAL'
// |   }
// | RETURN coalesce(p.uid, p.id) AS productWithUnbackedApproval;
// REVISED:
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus {statusKind: 'APPROVAL'})-[e:STATUS_OF]->(p)
    WHERE e.recordedTo IS NULL
      AND EXISTS { (s)-[:RESULTS_FROM_RESPONSE]->(r:RegulatoryResponse) WHERE r.responseKind IN ['APPROVED', 'PMA_APPROVED'] }
  }
RETURN 'V-322r' AS check, p.uid AS productWithUnbackedApproval;

// ===================================================================================================
// V-324r -- replaces V-324; ruling W00-R-36
// Allowlist of authority-bearing source kinds instead of a marketing denylist (W11-SR-11).
// Revised text source: W11/fixtures/w11-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-324: an OPERATING capability state needs a non-marketing source or a SUPPORTED adjudication.
// | // status: statically-checked
// | MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
// | WHERE c.stage = 'OPERATING'
// | OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
// | OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
// | WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
// | WHERE a IS NULL
// |    OR (all(k IN kinds WHERE k IN ['MARKETING_PAGE', 'THIRD_PARTY_DIRECTORY', 'PRESS_RELEASE'])
// |        AND NOT EXISTS {
// |          MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
// |          WHERE j.verdict = 'SUPPORTED'
// |        })
// | RETURN holder.uid AS holderUid, c.uid AS capabilityUid, kinds AS supportingSourceKinds;
// REVISED:
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE c.stage = 'OPERATING'
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
WHERE a IS NULL
   OR (NOT any(k IN kinds WHERE k IN ['SECURITIES_FILING', 'REGULATORY_RECORD', 'AUDIT_REPORT', 'CERTIFICATION_LISTING', 'LEGAL_RECORD'])
       AND NOT EXISTS {
         MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
         WHERE j.verdict = 'SUPPORTED' AND j.recordedTo IS NULL
       })
RETURN 'V-324r' AS check, holder.uid AS holderUid, h.relationshipUid AS episode, c.uid AS capabilityUid, kinds AS supportingSourceKinds;

// ===================================================================================================
// V-333r -- replaces V-333; ruling W00-R-36
// Count DISTINCT subjects; at most one current STATUS_OF episode (W13-SR-15, LDT ED v2).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-333: regulatory statuses carry a known status kind, a jurisdiction, and exactly one subject.
// | // status: statically-checked
// | MATCH (s:RegulatoryStatus)
// | OPTIONAL MATCH (s)-[:STATUS_OF]->(x)
// | WITH s, count(x) AS subjects
// | WHERE subjects <> 1
// |    OR s.jurisdiction IS NULL
// |    OR s.statusKind IS NULL
// |    OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
// |                            'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
// | RETURN s.uid AS statusUid, s.statusKind AS statusKind, subjects;
// REVISED:
MATCH (s:RegulatoryStatus)
OPTIONAL MATCH (s)-[e:STATUS_OF]->(x)
WITH s, count(DISTINCT x) AS subjects, count(CASE WHEN e.recordedTo IS NULL THEN 1 END) AS currentEpisodes
WHERE subjects <> 1 OR currentEpisodes > 1
   OR s.jurisdiction IS NULL OR s.statusKind IS NULL
   OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
                           'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
RETURN 'V-333r' AS check, s.uid AS statusUid, s.statusKind AS statusKind, subjects, currentEpisodes;

// ===================================================================================================
// V-334r -- replaces V-334; ruling W00-R-36
// Compare the current STATUS_OF episode with the current HAS_PATHWAY_VERSION episode of its legal-basis version (W13-SR-15).
// Revised text source: W13/fixtures/w13-validation.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-334: a status cannot outlive the legal basis it depends on (for example the 2024 LDT rule, vacated 2025-03-31).
// | // status: statically-checked
// | MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
// | WHERE pw.effectiveTo IS NOT NULL
// |   AND (s.effectiveTo IS NULL OR s.effectiveTo > pw.effectiveTo)
// | RETURN s.uid AS statusUid, pw.uid AS pathwayUid, pw.effectiveTo AS basisEnded;
// REVISED:
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS_VERSION]->(v:RegulatoryPathwayVersion)<-[pv:HAS_PATHWAY_VERSION]-(:RegulatoryPathway)
WHERE pv.recordedTo IS NULL
MATCH (s)-[e:STATUS_OF]->()
WHERE e.recordedTo IS NULL
WITH s, v, pv, e
WHERE (pv.validTo IS NOT NULL AND (e.validTo IS NULL OR e.validTo > pv.validTo))
   OR (pv.validFrom IS NOT NULL AND e.validFrom IS NOT NULL AND e.validFrom < pv.validFrom)
RETURN 'V-334r' AS check, s.uid AS statusUid, v.uid AS versionUid, e.validFrom AS statusFrom, e.validTo AS statusTo,
       pv.validFrom AS basisFrom, pv.validTo AS basisTo;

// ===================================================================================================
// V-407r -- replaces V-407; ruling W00-R-40
// W20-V01 adopted (W20-SR-18): every start label and SUPPORTED_BY_CHUNK; fixture 02: V-407 1 of 4 defects, W20-V01 all 4.
// Revised text source: W20/operations.cypher W20-V01
// ORIGINAL (kept for comparison; not executed):
// | // V-407: an Assertion may point SUPPORTED_BY at a Chunk only as a derived
// | // shortcut naming the locator it projects, and that locator must also be linked.
// | // status: statically-checked
// | MATCH (a:Assertion)-[r:SUPPORTED_BY]->(c:Chunk)
// | WHERE r.locatorUid IS NULL
// |    OR NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator) WHERE l.uid = r.locatorUid }
// | RETURN a.uid AS assertionUid, c.uid AS chunkWithoutLocator;
// REVISED:
MATCH (x)-[r:SUPPORTED_BY|SUPPORTED_BY_CHUNK]->(c:Chunk)
OPTIONAL MATCH (l:SourceLocator {uid: r.locatorUid})
WITH x, r, c, l,
     [v IN [
        CASE WHEN type(r) = 'SUPPORTED_BY' THEN 'LEGACY_SUPPORTED_BY_TO_CHUNK' END,
        CASE WHEN r.locatorUid IS NULL THEN 'NO_LOCATOR_UID' END,
        CASE WHEN r.locatorUid IS NOT NULL AND l IS NULL THEN 'LOCATOR_MISSING' END,
        CASE WHEN r.derivationRule IS NULL THEN 'NO_DERIVATION_RULE' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (l)-[rr:RESOLVES_TO_CHUNK]->(c) WHERE rr.segmentationHash = r.segmentationHash }
             THEN 'LOCATOR_DOES_NOT_RESOLVE_TO_CHUNK' END,
        CASE WHEN l IS NOT NULL AND NOT EXISTS {
               MATCH (sa:Assertion)-[:SUPPORTED_BY]->(l) WHERE sa.uid IN coalesce(r.derivedFromAssertionUids, []) }
             THEN 'NO_INPUT_ASSERTION_SUPPORTED_BY_LOCATOR' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-407r' AS check, type(r) AS relType, x.uid AS startUid, labels(x)[0] AS startLabel, c.uid AS chunkUid, violations
ORDER BY startUid, chunkUid;

// ===================================================================================================
// V-409r -- replaces V-409; ruling W00-R-31
// Order REANCHORS by the content clock coalesce(observedAt, retrievedAt) (W19-SR-09, W04-SR-02): archive captures fetched late.
// Revised text source: W00 fixtures/validation-w00.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-409: REANCHORS links locators on two snapshots of the same Source, newer to older.
// | // status: statically-checked
// | MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
// | MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
// | WHERE x.anchorMatch IS NULL
// |    OR sNew = sOld
// |    OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
// |    OR sNew.retrievedAt <= sOld.retrievedAt
// | RETURN newL.uid AS newLocator, oldL.uid AS oldLocator;
// REVISED:
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR coalesce(sNew.observedAt, sNew.retrievedAt) <= coalesce(sOld.observedAt, sOld.retrievedAt)
RETURN 'V-409r' AS check, newL.uid AS newLocator, oldL.uid AS oldLocator;

// ===================================================================================================
// V-416r -- replaces V-416; ruling W00-R-40
// QUALIFIED_BY without a container requires a shared SourceSnapshot (W21-SR-23 / W08-SR-10 device qualifiers).
// Revised text source: W21/fixtures/w21-validation.cypher V-W21-12
// ORIGINAL (kept for comparison; not executed):
// | // V-416: QUALIFIED_BY names its kind and stays inside one container.
// | // status: statically-checked
// | MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
// | WHERE q.qualificationKind IS NULL
// |    OR NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) }
// | RETURN a.uid AS qualifiedUid, b.uid AS qualifierUid;
// REVISED:
MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
WHERE q.qualificationKind IS NULL
   OR ((EXISTS { (a)-[:OCCURS_IN]->() } OR EXISTS { (b)-[:OCCURS_IN]->() })
       AND NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) })
   OR (NOT EXISTS { (a)-[:OCCURS_IN]->() } AND NOT EXISTS { (b)-[:OCCURS_IN]->() }
       AND NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(b) })
RETURN 'V-416r' AS check, a.uid AS qualifiedUid, b.uid AS qualifierUid;

// ===================================================================================================
// V-423r -- replaces V-423; ruling W00-R-25
// Derived RECOMMENDS: derivationRule + exactly one derivedFromAssertionUids whose assertion has speechAct RECOMMENDS, is asserted by
// the start node and names the end node (W21-SR-07; D-011 forbids assertionUid on derived edges; legacy assertionUid accepted only
// as a migration fallback and reported by V-W00-02r). Failing case W21 fx07: verbatim V-423 1 row on a correct edge.
// Revised text source: W21/fixtures/w21-validation.cypher V-W21-06
// ORIGINAL (kept for comparison; not executed):
// | // V-423: live Person-[:RECOMMENDS]-> is a projection of an assertion whose own
// | // speech act is RECOMMENDS (a practice report or a third party's attribution does not count).
// | // status: statically-checked
// | MATCH (p:Person)-[rec:RECOMMENDS]->(x)
// | WHERE rec.assertionUid IS NULL
// |    OR NOT EXISTS {
// |      MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
// |      WHERE a.uid = rec.assertionUid AND a.speechAct = 'RECOMMENDS'
// |    }
// | RETURN p.uid AS recommenderUid, x.uid AS recommendedUid;
// REVISED:
MATCH (p)-[rec:RECOMMENDS]->(x)
WITH p, x, rec, coalesce(rec.derivedFromAssertionUids, CASE WHEN rec.assertionUid IS NULL THEN [] ELSE [rec.assertionUid] END) AS cited
WHERE size(cited) <> 1
   OR (rec.assertionUid IS NULL AND rec.derivationRule IS NULL)
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = cited[0] AND a.speechAct = 'RECOMMENDS' AND NOT a.status IN ['REJECTED', 'SUPERSEDED']
       AND (EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR EXISTS { (a)-[:HAS_OBJECT]->(x) })
   }
RETURN 'V-423r' AS check, p.uid AS recommenderUid, x.uid AS recommendedUid, cited;

// ===================================================================================================
// V-432r -- replaces V-432; ruling W00-R-32
// COMPARES_IDENTITIES (not COMPARES, which is W07 ComparabilityAssessment) plus the SAME_IDENTITY_MERGED redirect fields
// (W23-SR-07, W00-SR-12, W00-R-11). Failing case W23 fixture 04 and W00 fixture 08: comparedCount 0 on well-formed assessments.
// ORIGINAL (kept for comparison; not executed):
// | // ---------------------------------------------------------------------
// | // E. Ecosystem identity (CQ-EC-02)
// | // ---------------------------------------------------------------------
// | 
// | // V-432: an EquivalenceAssessment compares exactly two distinct nodes and never
// | // coexists with a merged node carrying both compared kinds.
// | // status: statically-checked
// | MATCH (e:EquivalenceAssessment)
// | OPTIONAL MATCH (e)-[:COMPARES]->(n)
// | WITH e, collect(DISTINCT n) AS ns
// | WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
// | RETURN e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount;
// REVISED:
MATCH (e:EquivalenceAssessment)
OPTIONAL MATCH (e)-[:COMPARES_IDENTITIES]->(n)
WITH e, collect(DISTINCT n) AS ns
WITH e, ns, [n IN ns | n.uid] AS uids
WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
   OR (e.equivalenceKind = 'SAME_IDENTITY_MERGED'
       AND (e.survivingUid IS NULL OR e.retiredUid IS NULL OR e.survivingUid = e.retiredUid
            OR NOT e.survivingUid IN uids OR NOT e.retiredUid IN uids))
   OR (e.equivalenceKind <> 'SAME_IDENTITY_MERGED' AND (e.survivingUid IS NOT NULL OR e.retiredUid IS NOT NULL))
RETURN 'V-432r' AS check, e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount, e.equivalenceKind AS equivalenceKind;

// ===================================================================================================
// V-503r -- replaces V-503; ruling W00-R-37
// Bound/precision/basis agreement on assertions AND on every bitemporal edge ($episodeTypes or any edge with assertionUid),
// including HAS_CERTIFICATION_SCOPE (W12-SR-09, negative N11: OBSERVATION_ONLY end caught only by V-W12-10); statedAsOf needs its
// precision (W00-R-13). INFERRED needs a derivationRule on the assertion (edges inherit it through V-505r).
// ORIGINAL (kept for comparison; not executed):
// | // V-503: bound, precision, and basis agree. OBSERVATION_ONLY or UNKNOWN basis forces a null bound; a non-null bound
// | // needs a precision; INFERRED needs a derivation rule.
// | // status: statically-checked
// | // 0.2.0 integration: a basis is required when its bound is non-null; a null bound with a null basis reads as UNKNOWN.
// | MATCH (a:Assertion)
// | WHERE (a.validFrom IS NOT NULL AND a.validFromBasis IS NULL)
// |    OR (a.validTo IS NOT NULL AND a.validToBasis IS NULL)
// |    OR (a.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validFrom IS NOT NULL)
// |    OR (a.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validTo IS NOT NULL)
// |    OR (a.validFrom IS NOT NULL AND a.validFromPrecision IS NULL)
// |    OR (a.validTo IS NOT NULL AND a.validToPrecision IS NULL)
// |    OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
// | RETURN a.uid AS assertionWithInconsistentTimeQualifiers;
// REVISED:
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND a.validFromBasis IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToBasis IS NULL)
   OR (a.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validFrom IS NOT NULL)
   OR (a.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validTo IS NOT NULL)
   OR (a.validFrom IS NOT NULL AND a.validFromPrecision IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToPrecision IS NULL)
   OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
   OR (a.statedAsOf IS NOT NULL AND a.statedAsOfPrecision IS NULL)
RETURN 'V-503r' AS check, 'ASSERTION' AS kind, a.uid AS item
UNION
MATCH ()-[h]->()
WHERE type(h) IN $episodeTypes OR h.assertionUid IS NOT NULL
WITH h
WHERE h.validFromBasis IS NULL OR h.validToBasis IS NULL
   OR (h.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND h.validFrom IS NOT NULL)
   OR (h.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND h.validTo IS NOT NULL)
   OR (h.validFrom IS NOT NULL AND h.validFromPrecision IS NULL)
   OR (h.validTo IS NOT NULL AND h.validToPrecision IS NULL)
RETURN 'V-503r' AS check, 'EDGE:' + type(h) AS kind, coalesce(h.relationshipUid, elementId(h)) AS item;

// ===================================================================================================
// V-505r -- replaces V-505 (and V-W00-11); ruling W00-R-37 / W00-R-03
// Projection fidelity on EVERY edge that names an authorizing assertion (asserted_edge and bitemporal_attachment, all episode types;
// W12-SR-09) - V-W00-11 generalized - plus qualifier fidelity (W09-SR-12): an edge property outside the profile fields that the
// assertion also stores must be equal on both (QUALIFIER_DIFFERS:<key>).
// ORIGINAL (kept for comparison; not executed):
// | // V-505: projection fidelity. Episode valid time equals its authorizing assertion's valid time. A correction that
// | // edited valid time in place on either side shows up here.
// | // status: statically-checked
// | MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
// | WHERE h.assertionUid IS NOT NULL
// | MATCH (a:Assertion {uid: h.assertionUid})
// | WHERE coalesce(toString(h.validFrom), '-') <> coalesce(toString(a.validFrom), '-')
// |    OR coalesce(toString(h.validTo), '-') <> coalesce(toString(a.validTo), '-')
// |    OR coalesce(h.validFromPrecision, '-') <> coalesce(a.validFromPrecision, '-')
// |    OR coalesce(h.validToPrecision, '-') <> coalesce(a.validToPrecision, '-')
// |    OR coalesce(toString(h.recordedTo), '-') <> coalesce(toString(a.recordedTo), '-')
// | RETURN h.relationshipUid AS episode, a.uid AS assertionUid;
// REVISED:
MATCH (x)-[r]->(y)
WHERE r.assertionUid IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, y, r, a,
  ['relationshipUid','assertionUid','validFrom','validTo','validFromPrecision','validToPrecision','validFromBasis','validToBasis',
   'recordedFrom','recordedTo','mongoResearchRunId','privacyClass','createdAt','updatedAt','notes','derivedAt'] AS profile
WITH x, y, r, a,
  [v IN [
    CASE WHEN a IS NULL THEN 'ASSERTION_MISSING' END,
    CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } THEN 'SUBJECT_IS_NOT_EDGE_START' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) } THEN 'OBJECT_IS_NOT_EDGE_END' END,
    CASE WHEN a IS NOT NULL AND (coalesce(toString(r.validFrom),'-') <> coalesce(toString(a.validFrom),'-')
           OR coalesce(toString(r.validTo),'-') <> coalesce(toString(a.validTo),'-')
           OR coalesce(r.validFromPrecision,'-') <> coalesce(a.validFromPrecision,'-')
           OR coalesce(r.validToPrecision,'-') <> coalesce(a.validToPrecision,'-')
           OR coalesce(r.validFromBasis,'UNKNOWN') <> coalesce(a.validFromBasis,'UNKNOWN')
           OR coalesce(r.validToBasis,'UNKNOWN') <> coalesce(a.validToBasis,'UNKNOWN')) THEN 'VALID_TIME_DIFFERS' END,
    CASE WHEN a IS NOT NULL AND r.recordedFrom < a.recordedAt THEN 'RECORDED_BEFORE_ASSERTION' END,
    CASE WHEN a IS NOT NULL AND coalesce(toString(r.recordedTo),'-') <> coalesce(toString(a.recordedTo),'-') THEN 'RECORDED_TO_DIFFERS' END
  ] WHERE v IS NOT NULL]
  + CASE WHEN a IS NULL THEN [] ELSE [k IN keys(r) WHERE NOT k IN profile AND a[k] IS NOT NULL AND a[k] <> r[k] | 'QUALIFIER_DIFFERS:' + k] END AS violations
WHERE size(violations) > 0
RETURN 'V-505r' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, violations;

// ===================================================================================================
// V-505i (informational) -- replaces (new; W09-SR-12 migration audit); ruling W00-R-03
// Informational: an asserted edge carries a qualifier property that its authorizing assertion does not store (the edge would lose it on
// regeneration). Rows are migration items, not violations.
// REVISED:
MATCH ()-[r]->()
WHERE r.assertionUid IS NOT NULL
MATCH (a:Assertion {uid: r.assertionUid})
WITH r, a, [k IN keys(r) WHERE NOT k IN ['relationshipUid','assertionUid','validFrom','validTo','validFromPrecision','validToPrecision',
   'validFromBasis','validToBasis','recordedFrom','recordedTo','mongoResearchRunId','privacyClass','createdAt','updatedAt','notes','derivedAt']
   AND a[k] IS NULL] AS edgeOnly
WHERE size(edgeOnly) > 0
RETURN 'V-505i' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, edgeOnly;

// ===================================================================================================
// V-512r -- replaces V-512; ruling W00-R-31
// REVISION_ORDER on the content clock (W19-SR-09).
// Revised text source: W00 fixtures/validation-w00.cypher
// ORIGINAL (kept for comparison; not executed):
// | // V-512: source revision events are well formed: exactly one revised source; prior and resulting snapshots belong
// | // to that source; the resulting snapshot was retrieved after the prior one.
// | // status: statically-checked
// | MATCH (ev:SourceRevisionEvent)
// | OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
// | WITH ev, collect(src) AS sources
// | WHERE size(sources) <> 1
// | RETURN 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
// | UNION
// | MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
// | WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
// | RETURN 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
// | UNION
// | MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
// | WHERE res.retrievedAt <= prior.retrievedAt
// | RETURN 'REVISION_ORDER' AS violation, ev.uid AS item;
// REVISED:
MATCH (ev:SourceRevisionEvent)
OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
WITH ev, collect(src) AS sources
WHERE size(sources) <> 1
RETURN 'V-512r' AS check, 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
UNION
MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
RETURN 'V-512r' AS check, 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
UNION
MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
WHERE coalesce(res.observedAt, res.retrievedAt) <= coalesce(prior.observedAt, prior.retrievedAt)
RETURN 'V-512r' AS check, 'REVISION_ORDER' AS violation, ev.uid AS item;

// ===================================================================================================
// V-521r -- replaces V-521; ruling W00-R-06
// Privacy class branch: any stored value other than PUBLIC/INTERNAL is a violation (catches PRIVATE_PERSONAL; W23-SR-08 fixture 10 2e),
// and private uids inside LIST properties of relationships (V-W23-10). Absorbs V-W23-09 and V-W23-10.
// ORIGINAL (kept for comparison; not executed):
// | // V-521: no private uid values or private-personal class on shared nodes or relationships.
// | // status: statically-checked
// | MATCH (n)
// | WHERE NOT n:PrivateRecord AND (n.privacyClass = 'private-personal'
// |    OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
// |    OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
// | RETURN 'NODE' AS kind, n.uid AS item
// | UNION
// | MATCH (x)-[r]->(y)
// | WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
// |   AND (r.privacyClass = 'private-personal'
// |        OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-'))
// | RETURN 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item;
// REVISED:
MATCH (n)
WHERE NOT n:PrivateRecord AND ((n.privacyClass IS NOT NULL AND NOT n.privacyClass IN ['PUBLIC', 'INTERNAL'])
   OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
   OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
RETURN 'V-521r' AS check, 'NODE' AS kind, n.uid AS item, n.privacyClass AS privacyClass
UNION
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
  AND ((r.privacyClass IS NOT NULL AND NOT r.privacyClass IN ['PUBLIC', 'INTERNAL'])
       OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-')
       OR any(k IN keys(r) WHERE r[k] IS :: LIST<STRING> AND any(v IN r[k] WHERE v STARTS WITH 'hu:private-')))
RETURN 'V-521r' AS check, 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item, r.privacyClass AS privacyClass;

// ===================================================================================================
// V-525r -- replaces V-525; ruling W00-R-38
// Restated on HAS_PROTOCOL_STEP (D-004 implementation; catalog V-525 matches HAS_STEP and sees nothing) (W16-SR-14).
// Revised text source: W16/fixtures/00-w16-validators.cypher V-525p
// ORIGINAL (kept for comparison; not executed):
// | // V-525: protocol editions: stepKey unique within an edition; CONDITIONAL steps name an APPLIES_WHEN constraint.
// | // status: statically-checked
// | MATCH (e:ProtocolEdition)-[:HAS_STEP]->(s:ProtocolStep)
// | WITH e, s.stepKey AS stepKey, count(*) AS n
// | WHERE stepKey IS NULL OR n > 1
// | RETURN 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item
// | UNION
// | MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
// | WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
// | RETURN 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item;
// REVISED:
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WITH e, s.stepKey AS stepKey, count(*) AS n
WHERE stepKey IS NULL OR n > 1
RETURN 'V-525r' AS check, 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item, stepKey AS detail
UNION
MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
RETURN 'V-525r' AS check, 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item, s.stepKey AS detail;

// ===================================================================================================
// V-526r (informational) -- replaces V-526; ruling W00-R-38
// Restated on HAS_PROTOCOL_STEP (W16-SR-14).
// Revised text source: W16/fixtures/00-w16-validators.cypher V-526p
// ORIGINAL (kept for comparison; not executed):
// | // V-526: protocol steps are immutable payload: a step shared by two editions keeps one payloadHash by construction;
// | // two different step nodes with the same stepKey and payloadHash inside one protocol lineage are duplicates (informational).
// | // status: statically-checked
// | MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s1:ProtocolStep),
// |       (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s2:ProtocolStep)
// | WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
// | RETURN DISTINCT p.uid AS protocolUid, s1.stepKey AS duplicatedStep;
// REVISED:
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s1:ProtocolStep),
      (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s2:ProtocolStep)
WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
RETURN DISTINCT 'V-526r' AS check, 'DUPLICATE_STEP_PAYLOAD' AS violation, p.uid AS item, s1.stepKey AS detail;

// ===================================================================================================
// V-504a -- replaces (new; V-504 generalized to EvidenceAssessments); ruling W00-R-51
// No backdating for assessments (INV-502): an EvidenceAssessment is never recorded before the retrieval of a snapshot whose locator it
// is SUPPORTED_BY (W10-SR-05; failing case: inherited hu:synthesis:nr-muscle-mito-function-older-humans-v2 recorded 2019-09-15, supported by
// a 2026-10-03 snapshot; V-504 silent). W10-V16b adopted under this id.
// REVISED:
MATCH (e:EvidenceAssessment)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot)
WHERE e.recordedAt IS NOT NULL AND s.retrievedAt IS NOT NULL AND e.recordedAt < s.retrievedAt
RETURN DISTINCT 'V-504a' AS check, e.uid AS assessmentUid, s.uid AS laterSnapshot, e.recordedAt AS recordedAt, s.retrievedAt AS retrievedAt;

// ===================================================================================================
// V-W00-13 -- replaces (new); ruling W00-R-11
// Merge redirect hygiene: a SAME_IDENTITY_MERGED retired node is kept with maturity DEPRECATED, never a private uid, and redirects do
// not form a two-step cycle. Fixture 13 exercises it.
// REVISED:
MATCH (e:EquivalenceAssessment {equivalenceKind: 'SAME_IDENTITY_MERGED'})
OPTIONAL MATCH (old {uid: e.retiredUid})
OPTIONAL MATCH (back:EquivalenceAssessment {equivalenceKind: 'SAME_IDENTITY_MERGED', retiredUid: e.survivingUid, survivingUid: e.retiredUid})
WITH e, old, back
WHERE old IS NULL OR coalesce(old.maturity, '') <> 'DEPRECATED'
   OR e.survivingUid STARTS WITH 'hu:private-' OR e.retiredUid STARTS WITH 'hu:private-'
   OR back IS NOT NULL
RETURN 'V-W00-13' AS check, e.uid AS redirect, e.retiredUid AS retiredUid, old.maturity AS retiredMaturity, back.uid AS cycleWith;

// ===================================================================================================
// V-W00-15 -- replaces (new); ruling W00-R-16 / -17 / -19 / -20
// One relationship type, one meaning (CL-014): HAS_SNAPSHOT only Source -> SourceSnapshot (state caches use HAS_STATE); EVALUATES only
// Adjudication -> Assertion (legacy study edge is LEGACY_EVALUATES); MENTIONS only SourceLocator -> Mention (retrieval uses
// MENTIONS_ENTITY); IDENTIFIED_BY is relabelled HAS_IDENTIFIER; OCCURS_IN_SEGMENT is the W21 structural ClaimOccurrence ->
// EpisodeSegment edge and a chunk overlap is CHUNK_IN_SEGMENT (W00-R-23). Rows are migration items until the relabel runs.
// REVISED:
MATCH (x)-[r:HAS_SNAPSHOT|EVALUATES|MENTIONS|IDENTIFIED_BY|OCCURS_IN_SEGMENT]->(y)
WITH x, r, y, CASE type(r)
    WHEN 'HAS_SNAPSHOT' THEN CASE WHEN x:Source AND y:SourceSnapshot THEN null ELSE 'USE_HAS_STATE' END
    WHEN 'EVALUATES' THEN CASE WHEN x:Adjudication AND y:Assertion THEN null ELSE 'USE_LEGACY_EVALUATES' END
    WHEN 'MENTIONS' THEN CASE WHEN x:SourceLocator AND y:Mention THEN null ELSE 'USE_MENTIONS_ENTITY' END
    WHEN 'OCCURS_IN_SEGMENT' THEN CASE WHEN x:Chunk THEN 'USE_CHUNK_IN_SEGMENT' ELSE null END
    ELSE 'USE_HAS_IDENTIFIER' END AS fix
WHERE fix IS NOT NULL
RETURN 'V-W00-15' AS check, type(r) AS relType, labels(x)[0] AS fromLabel, labels(y)[0] AS toLabel, count(*) AS edges, fix;

// ===================================================================================================
// V-W00-17 -- replaces (new); ruling W00-R-08
// sourceKind OTHER requires sourceKindNote (W19-SR-01); revision states are never kinds.
// REVISED:
MATCH (s:Source)
WHERE s.sourceKind = 'OTHER' AND (s.sourceKindNote IS NULL OR trim(s.sourceKindNote) = '')
RETURN 'V-W00-17' AS check, s.uid AS sourceWithoutKindNote;

// ===================================================================================================
// V-W00-19 -- replaces (new; W19 Q-02 promoted); ruling W00-R-15
// A Source canonicalUri is a retrieval endpoint, never an identifier resolver (W19-SR-10, fixture 90 N2).
// REVISED:
MATCH (s:Source)
WHERE s.canonicalUri =~ '(?i)https?://(dx\\.)?doi\\.org/.*' OR s.canonicalUri =~ '(?i)https?://identifiers\\.org/.*'
   OR s.canonicalUri =~ '(?i)https?://(www\\.)?ncbi\\.nlm\\.nih\\.gov/pubmed/\\?term=.*'
RETURN 'V-W00-19' AS check, s.uid AS sourceWithResolverUri, s.canonicalUri AS canonicalUri;

// ======== validation/fable-w5-validators.cypher ========
// =====================================================================================================================
// fable-w5-validators.cypher -- Wave 5 validator corrections compiled from the Challenger reports
// (validation/challengers/CH-W09W10-study-transfer, CH-W23-privacy, CH-W16-protocols, CH-W21W22-media, CH-W00-kernel; dispositions in
// reports/08-challenger-resolution-matrix.md), run-2026-10-04-fable51-01, Opus 5.5 worker, 2026-10-04.
//
// Contract: one statement per correction; each statement returns rows ONLY on violations (zero rows = valid). Statements
// marked "(review)" return review-queue rows that are violations of a method rule that cannot be checked as a hard
// structural rule (they still return zero rows on the valid fixtures). Every statement binds its own variables; nothing
// crosses ';'. Every row carries `check` = its V-F5 id.
// Parameters: validation/validation-params.json merged with validation/fable-w5-params.json (list keys unioned).
// Not covered here, because Fable fixes them in the SDL / operations / fixtures (cross-reference only): CH-P-02, CH-P-04
// (vector indexes), CH-P-12 (operations section 7), CH-P-16, CH-P-17/CH-R-12 (DiagnosticResult label), CH-P-18, CH-R-04,
// CH-R-05 (DERIVED_FROM_PROTOCOL field), CH-R-13 (HAS_STEP migration and fixture), CH-S-18, and the kernel items CH-K-08a/09 (gen-params),
// CH-K-10b/13 (generated-label-checks.cypher), CH-K-16a/b (operations 5b), CH-K-18a-d (operations 6a/7), CH-K-19 (99-normalize).
// Retired by this file: kernel V-423 (superseded by V-W21-06 and now by V-F5-47, CL-016), V-201 (-> V-F5-01),
// V-218 (-> V-F5-08), V-215r (-> V-F5-07), V-203 (-> V-F5-05, in addition to the count check), W10-V08 (-> V-F5-06),
// W10-V14 (-> V-F5-18 + V-F5-20), V-604 (-> V-F5-43), V-605 (-> V-F5-41 + V-F5-42), V-W21-06 (-> V-F5-47).
// Tested on embedded Neo4j 5.26.31 Community instances c3, c4, c5; results in reports/08-challenger-resolution-matrix.md.
// =====================================================================================================================

// ------------------------------------------------- study transfer (W09/W10) -------------------------------------------

// V-F5-01 -- resolves CH-S-01, CH-S-02; replaces V-201; rule: no relationship in either direction between a study-side record and a commercial identity, except InterventionComponent -USES_INTERVENTION_MATERIAL-> ProductVariant|ProductLot.
// (V-201r verbatim as tested by the study-transfer Challenger.)
MATCH (s)-[r]-(p)
WHERE (s:Study OR s:StudyArm OR s:StudyIntervention OR s:InterventionComponent OR s:StudyResult OR s:Publication OR s:Dataset
       OR s:OutcomeDefinition OR s:StudyPopulation OR s:RegistrationVersion OR s:TrialRegistration OR s:ProtocolVersion)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion OR p:PackageConfiguration OR p:ProductLot OR p:MerchantListing
       OR p:Offer OR p:ConsumerBrand OR p:Bundle)
  AND NOT (s:InterventionComponent AND type(r) = 'USES_INTERVENTION_MATERIAL' AND startNode(r) = s AND (p:ProductVariant OR p:ProductLot))
RETURN DISTINCT 'V-F5-01' AS check, s.uid AS studySide, type(r) AS rel, p.uid AS commercial;

// V-F5-02 -- resolves CH-S-02a; extends V-W09-03; rule: USES_INTERVENTION_MATERIAL goes from an InterventionComponent to IngredientMaterial, ProductVariant or ProductLot only (catalog range).
MATCH (ic)-[u:USES_INTERVENTION_MATERIAL]->(m)
WHERE NOT ic:InterventionComponent OR NOT (m:IngredientMaterial OR m:ProductVariant OR m:ProductLot)
RETURN 'V-F5-02' AS check, ic.uid AS component, labels(m) AS targetLabels, m.uid AS target;

// V-F5-03 -- resolves CH-S-03; extends V-202; rule: a ProductVariant used as intervention material is pinned to the formulation as administered: the use carries a known validFrom covered by a current HAS_FORMULATION_VERSION episode of that variant with a known start (or names asAdministeredFormulationVersionUid of that variant).
MATCH (ic:InterventionComponent)-[u:USES_INTERVENTION_MATERIAL]->(v:ProductVariant)
WHERE NOT EXISTS { MATCH (v)-[:HAS_FORMULATION_VERSION]->(f:FormulationVersion) WHERE f.uid = u.asAdministeredFormulationVersionUid }
  AND (u.validFrom IS NULL
       OR NOT EXISTS { MATCH (v)-[h:HAS_FORMULATION_VERSION]->(:FormulationVersion)
                       WHERE h.recordedTo IS NULL AND h.validFrom IS NOT NULL AND h.validFrom <= u.validFrom
                         AND (h.validTo IS NULL OR u.validFrom < h.validTo) })
RETURN 'V-F5-03' AS check, ic.uid AS component, v.uid AS variant, u.validFrom AS usedFrom,
       CASE WHEN u.validFrom IS NULL THEN 'VARIANT_USE_WITHOUT_VALID_FROM' ELSE 'NO_FORMULATION_EPISODE_COVERS_USE' END AS violation;

// V-F5-04 -- resolves CH-S-04b; new (W10-V17); rule: each flat applicability field equals the verdict of its dimension node (identityMatch=MATERIAL_IDENTITY, doseMatch=DOSE|EXPOSURE, routeMatch=ROUTE, scheduleMatch=SCHEDULE, durationMatch=DURATION, populationMatch=POPULATION, outcomeMatch=OUTCOME_RELEVANCE); a flat value without its dimension node is a violation.
MATCH (ea:EvidenceApplicability)
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d)
WITH ea, collect(d) AS ds
WITH ea, [m IN [['identityMatch', ['MATERIAL_IDENTITY']], ['doseMatch', ['DOSE', 'EXPOSURE']], ['routeMatch', ['ROUTE']],
                ['scheduleMatch', ['SCHEDULE']], ['durationMatch', ['DURATION']], ['populationMatch', ['POPULATION']],
                ['outcomeMatch', ['OUTCOME_RELEVANCE']]] |
          {field: m[0], flat: ea[m[0]], dims: [x IN ds WHERE x.dimension IN m[1] | x.verdict]}] AS pairs
WITH ea, [p IN pairs WHERE p.flat IS NOT NULL AND (size(p.dims) = 0 OR any(v IN p.dims WHERE v IS NULL OR v <> p.flat))] AS diverging
WHERE size(diverging) > 0
RETURN 'V-F5-04' AS check, ea.uid AS applicability, ea.status AS status, diverging;

// V-F5-05 -- resolves CH-S-05; replaces V-203 (adds the label test); rule: HAS_EVIDENCE_TARGET ends on a StudyIntervention or an Assertion, never a whole Study or any other record.
MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(t)
WHERE NOT (t:StudyIntervention OR t:Assertion)
RETURN 'V-F5-05' AS check, ea.uid AS applicability, labels(t) AS targetLabels, t.uid AS target;

// V-F5-06 -- resolves CH-S-06a; replaces W10-V08 (extends it); rule: a classification compared with a context classification must concern the same biomarker (CLASSIFIES_BIOMARKER or the outcome's MEASURES_BIOMARKER), and a FULL context match needs equal contextDiseaseOrUse and contextInterventionMechanism.
MATCH (ec:EndpointClassification)-[:COMPARED_WITH_CONTEXT]->(ctx:EndpointClassification)
WITH ec, ctx,
     [(ec)-[:CLASSIFIES_BIOMARKER]->(b) | b.uid] + [(ec)-[:CLASSIFIES_OUTCOME]->(:OutcomeDefinition)-[:MEASURES_BIOMARKER]->(b) | b.uid] AS ecBiomarkers,
     [(ctx)-[:CLASSIFIES_BIOMARKER]->(b) | b.uid] + [(ctx)-[:CLASSIFIES_OUTCOME]->(:OutcomeDefinition)-[:MEASURES_BIOMARKER]->(b) | b.uid] AS ctxBiomarkers
WITH ec, ctx, ecBiomarkers, ctxBiomarkers,
     [v IN [
        CASE WHEN size(ecBiomarkers) = 0 OR size(ctxBiomarkers) = 0 OR none(b IN ecBiomarkers WHERE b IN ctxBiomarkers)
             THEN 'COMPARED_CONTEXT_CLASSIFIES_ANOTHER_BIOMARKER' END,
        CASE WHEN ec.contextMatch = 'FULL' AND (coalesce(ec.contextDiseaseOrUse, '-') <> coalesce(ctx.contextDiseaseOrUse, '~')
                  OR coalesce(ec.contextInterventionMechanism, '-') <> coalesce(ctx.contextInterventionMechanism, '~'))
             THEN 'FULL_MATCH_WITH_DIFFERENT_CONTEXT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-06' AS check, ec.uid AS classification, ctx.uid AS comparedContext, ecBiomarkers, ctxBiomarkers, violations;

// V-F5-07 -- resolves CH-S-08; replaces V-215r and W10-V11 (V-215r2); rule: after a NOT_SIGNIFICANT primary prespecified result, every other result of that study (analysisKind null counts as non-primary; an Assertion input is resolved to the StudyResult it is about) enters only as SUPPORTIVE or HYPOTHESIS_GENERATING.
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(x)
WHERE NOT coalesce(inc.inputRole, '-') IN ['SUPPORTIVE', 'HYPOTHESIS_GENERATING']
OPTIONAL MATCH (x)-[:HAS_SUBJECT|HAS_OBJECT]->(viaAssertion:StudyResult)
WITH syn, inc, x, CASE WHEN x:StudyResult THEN [x] ELSE collect(viaAssertion) END AS results
UNWIND results AS r
MATCH (r)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE coalesce(r.analysisKind, 'UNKNOWN') <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind = 'WITHIN_ARM_CHANGE'
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
WHERE p <> r
RETURN DISTINCT 'V-F5-07' AS check, syn.uid AS synthesis, x.uid AS input, r.uid AS resolvedResult,
       coalesce(r.analysisKind, 'UNKNOWN') AS analysisKind, inc.inputRole AS role, p.uid AS nullPrimary;

// V-F5-08 -- resolves CH-S-09; replaces V-218; rule: two INDEPENDENT_REPLICATION inputs of one synthesis never share a study or a dataset (PRODUCED by the study or ANALYZED by its publications), independent of uid order.
// (V-218r verbatim as tested by the study-transfer Challenger.)
MATCH (syn:EvidenceSynthesis)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s:Study)
OPTIONAL MATCH (s)-[:PRODUCED_DATASET]->(d1:Dataset)
OPTIONAL MATCH (s)<-[:REPORTS_ON]-(:Publication)-[:ANALYZES_DATASET]->(d2:Dataset)
WITH syn, r, s, collect(DISTINCT d1.uid) + collect(DISTINCT d2.uid) AS ds
WITH syn, collect({r: r.uid, s: s.uid, ds: ds}) AS inputs
UNWIND inputs AS a
UNWIND inputs AS b
WITH syn, a, b WHERE a.r < b.r AND (a.s = b.s OR any(x IN a.ds WHERE x IN b.ds))
RETURN 'V-F5-08' AS check, syn.uid AS synthesis, a.r AS result1, b.r AS result2;

// V-F5-09 -- resolves CH-S-10; extends V-W00-15 (V-W09-14); rule: after the cutover no Study writes EVALUATES, and every LEGACY_EVALUATES edge carries the stamp of the one-time migration (migrationRunId and migratedAt); a stampless legacy edge is a laundered new write.
MATCH (s:Study)-[e:EVALUATES|LEGACY_EVALUATES]->(x)
WHERE type(e) = 'EVALUATES' OR e.migrationRunId IS NULL OR e.migratedAt IS NULL
RETURN 'V-F5-09' AS check, type(e) AS rel, s.uid AS study, x.uid AS target,
       CASE type(e) WHEN 'EVALUATES' THEN 'REJECT_WRITE_USE_ASSIGNS_INTERVENTION_PATH' ELSE 'LEGACY_EDGE_WITHOUT_MIGRATION_STAMP' END AS violation;

// V-F5-10 -- resolves CH-S-11; extends V-W09-11 and V-112r (V-W09-11r); rule: a derived SPONSORED_BY/OPERATED_BY/INVESTIGATED_BY names rule inverse-of:<P>@n where P is the registered premise, cites at least one live Assertion of predicate P whose subject is the edge end and whose object is the edge start; REPORTS_SAFETY_SIGNAL is rule ss-study/v1 citing its SafetySignal, which is based on the study or on a result of it.
MATCH (x)-[r:SPONSORED_BY|OPERATED_BY|INVESTIGATED_BY]->(y)
WITH x, y, r, coalesce($derivedEdgePremises[type(r)], '<unregistered>') AS premise, coalesce(r.derivedFromAssertionUids, []) AS inputs
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN inputs
WITH x, y, r, premise, inputs, collect(a) AS found
WITH x, y, r, [v IN [
        CASE WHEN NOT x:Study THEN 'START_IS_NOT_A_STUDY' END,
        CASE WHEN r.assertionUid IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL THEN 'DERIVED_EDGE_WRITTEN_AS_ASSERTED' END,
        CASE WHEN r.derivationRule IS NULL OR NOT r.derivationRule =~ ('inverse-of:' + premise + '@[0-9]+') THEN 'RULE_DOES_NOT_NAME_REGISTERED_PREMISE' END,
        CASE WHEN size(inputs) = 0 THEN 'NO_DERIVATION_INPUTS' END,
        CASE WHEN size(found) < size(inputs) THEN 'DERIVATION_INPUT_MISSING' END,
        CASE WHEN any(a IN found WHERE a.predicate <> premise) THEN 'INPUT_PREDICATE_IS_NOT_THE_RULE_PREMISE' END,
        CASE WHEN any(a IN found WHERE NOT EXISTS { (a)-[:HAS_SUBJECT]->(y) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(x) }) THEN 'INPUT_IS_NOT_THE_INVERSE_OF_THE_EDGE' END,
        CASE WHEN any(a IN found WHERE coalesce(a.status, '-') IN ['REJECTED', 'SUPERSEDED']) THEN 'INPUT_NOT_LIVE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-10' AS check, type(r) AS rel, x.uid AS startUid, y.uid AS endUid, violations
UNION
MATCH (x)-[r:REPORTS_SAFETY_SIGNAL]->(y)
WITH x, y, r, [v IN [
        CASE WHEN NOT x:Study OR NOT y:SafetySignal THEN 'WRONG_ENDPOINTS' END,
        CASE WHEN r.assertionUid IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL THEN 'DERIVED_EDGE_WRITTEN_AS_ASSERTED' END,
        CASE WHEN coalesce(r.derivationRule, '-') <> 'ss-study/v1' THEN 'RULE_IS_NOT_SS_STUDY_V1' END,
        CASE WHEN NOT y.uid IN coalesce(r.derivedFromAssessmentUids, []) THEN 'SIGNAL_NOT_CITED' END,
        CASE WHEN NOT (EXISTS { (y)-[:SIGNAL_BASED_ON]->(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:StudyResult)-[:RESULT_FOR_ARM]->(:StudyArm)<-[:HAS_ARM]-(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(sr:StudyResult)-[:RESULT_FOR_ARM]->(:StudyArm)<-[:HAS_ARM]-(x) })
             THEN 'SIGNAL_NOT_BASED_ON_THIS_STUDY' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-10' AS check, type(r) AS rel, x.uid AS startUid, y.uid AS endUid, violations;

// V-F5-11 -- resolves CH-S-12a; extends V-508r (V-W09-15); rule: a registration has at most one current-recorded HAS_REGISTRATION_VERSION episode with an open valid end (the ingester re-bounds the previous episode).
MATCH (t)-[h1:HAS_REGISTRATION_VERSION]->(v1), (t)-[h2:HAS_REGISTRATION_VERSION]->(v2)
WHERE elementId(h1) < elementId(h2) AND v1 <> v2
  AND h1.recordedTo IS NULL AND h2.recordedTo IS NULL AND h1.validTo IS NULL AND h2.validTo IS NULL
RETURN 'V-F5-11' AS check, t.uid AS registration, v1.uid AS version1, v2.uid AS version2;

// V-F5-12 -- resolves CH-S-12b; new (V-W09-16, generalized to $episodeTypes); rule: an episode is never recorded before the observation or retrieval of the version it attaches, and a version is never observed or retrieved after it was created (recorded time is service-assigned, never backdated).
MATCH (s)-[r]->(t)
WHERE type(r) IN $episodeTypes AND r.recordedFrom IS NOT NULL
WITH s, r, t, coalesce(t.observedAt, t.retrievedAt) AS observed
WHERE (observed IS NOT NULL AND r.recordedFrom < observed)
   OR (t.createdAt IS NOT NULL AND observed IS NOT NULL AND observed > t.createdAt)
RETURN 'V-F5-12' AS check, type(r) AS rel, coalesce(r.relationshipUid, elementId(r)) AS episode, s.uid AS subject, t.uid AS version,
       r.recordedFrom AS recordedFrom, observed, t.createdAt AS versionCreatedAt,
       CASE WHEN observed IS NOT NULL AND r.recordedFrom < observed THEN 'RECORDED_BEFORE_OBSERVED' ELSE 'OBSERVED_AFTER_CREATED' END AS violation;

// V-F5-13 -- resolves CH-S-13; new (V-W09-17); rule: every OutcomeDefinition has exactly one DEFINES_OUTCOME parent (instruments of another study are separate OutcomeDefinitions).
MATCH (od:OutcomeDefinition)
WITH od, [(st)-[:DEFINES_OUTCOME]->(od) | st.uid] AS parents
WHERE size(parents) <> 1
RETURN 'V-F5-13' AS check, od.uid AS outcomeDefinition, parents;

// V-F5-14 -- resolves CH-S-14; extends W10-V13 (W10-V13b + W10-V07s); rule: at most one ACCEPTED synthesis with recordedTo null per claim, and SUPERSEDES closes the older synthesis at the newer recordedAt with status SUPERSEDED.
MATCH (s:EvidenceSynthesis)-[:ASSESSES_CLAIM]->(c)
WHERE s.status = 'ACCEPTED' AND s.recordedTo IS NULL
WITH c, collect(s.uid) AS current
WHERE size(current) > 1
RETURN 'V-F5-14' AS check, 'TWO_CURRENT_ACCEPTED_SYNTHESES' AS violation, c.uid AS item, current AS detail
UNION
MATCH (n:EvidenceSynthesis)-[:SUPERSEDES]->(o:EvidenceSynthesis)
WHERE o.recordedTo IS NULL OR n.recordedAt IS NULL OR o.recordedTo <> n.recordedAt OR coalesce(o.status, '-') <> 'SUPERSEDED'
RETURN 'V-F5-14' AS check, 'SUPERSEDED_VERSION_NOT_CLOSED' AS violation, o.uid AS item, [n.uid, coalesce(o.status, 'null'), toString(o.recordedTo)] AS detail;

// V-F5-15 -- resolves CH-S-15; extends V-102/V-103 to nodes (V-102r); rule: a node's recordedTo is never earlier than its own recordedAt and never at or before its recordedFrom.
MATCH (n)
WHERE n.recordedTo IS NOT NULL
  AND ((n.recordedAt IS NOT NULL AND n.recordedTo < n.recordedAt) OR (n.recordedFrom IS NOT NULL AND n.recordedTo <= n.recordedFrom))
RETURN 'V-F5-15' AS check, labels(n) AS labels, n.uid AS item, n.recordedAt AS recordedAt, n.recordedFrom AS recordedFrom, n.recordedTo AS recordedTo;

// V-F5-16 -- resolves CH-S-17; new (W10-V20); rule: every EvidenceSynthesis assesses exactly one claim (exactly one ASSESSES_CLAIM edge).
MATCH (s:EvidenceSynthesis)
WITH s, [(s)-[:ASSESSES_CLAIM]->(c) | c.uid] AS claims
WHERE size(claims) <> 1
RETURN 'V-F5-16' AS check, s.uid AS synthesis, s.status AS status, claims;

// V-F5-17 -- (review) resolves CH-S-07 partially (DEFERRED as a hard rule); new (W10-V19 review queue); rule: a current ACCEPTED SUPPORTED synthesis needs at least one CONFIRMATORY or INDEPENDENT_REPLICATION input that is SIGNIFICANT_FAVORABLE (or a POSITIVE Assertion), and a TRIGGERED_BY STRENGTHENED trigger must itself be such an input.
MATCH (s:EvidenceSynthesis {verdict: 'SUPPORTED', status: 'ACCEPTED'})
WHERE s.recordedTo IS NULL
OPTIONAL MATCH (s)-[i:INCLUDES_RESULT]->(x)
WHERE i.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION']
WITH s, [y IN collect(x) WHERE (y:StudyResult AND y.statisticalConclusion = 'SIGNIFICANT_FAVORABLE') OR (y:Assertion AND y.polarity = 'POSITIVE')] AS favorable
OPTIONAL MATCH (s)-[t:TRIGGERED_BY {effectOnVerdict: 'STRENGTHENED'}]->(trig)
WITH s, favorable, [tg IN collect(trig) WHERE NOT EXISTS { MATCH (s)-[j:INCLUDES_RESULT]->(tg) WHERE j.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION'] } | tg.uid] AS weakTriggers
WHERE size(favorable) = 0 OR size(weakTriggers) > 0
RETURN 'V-F5-17' AS check, s.uid AS synthesis, size(favorable) AS favorableStrongInputs, weakTriggers,
       'REVIEW_VERDICT_NOT_CARRIED_BY_CONFIRMATORY_INPUTS' AS violation;

// ------------------------------------------------- privacy and access (W23) -------------------------------------------
// The private-token regex is derived in Cypher from $privateUidTokens (literal tokens; regex metacharacters escaped), joined
// as a case-insensitive, word-bounded alternation, OR an e-mail address. Every STRING and LIST<STRING> property is tested.

// V-F5-18 -- resolves CH-S-16, CH-P-05, CH-P-07d, CH-P-07e, CH-P-11, CH-R-07a; replaces the STARTS WITH branches of V-521r and W10-V14 (node side); rule: no shared node holds, in any string or list-of-string property, a private-store uid token (anywhere in the value, any case), an e-mail address, or a birth-date / record-number pattern ($personalDataPatterns).
WITH '(?is)(.*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c)))
     + ').*|.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*)' AS re
MATCH (n)
WHERE NOT n:PrivateRecord
WITH n, re, [k IN keys(n) WHERE
        (n[k] IS :: STRING AND (n[k] =~ re OR any(p IN $personalDataPatterns WHERE n[k] =~ p)))
     OR (n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x =~ re OR any(p IN $personalDataPatterns WHERE x =~ p)))] AS hits
WHERE size(hits) > 0
RETURN 'V-F5-18' AS check, labels(n) AS labels, n.uid AS item, hits AS properties;

// V-F5-19 -- resolves CH-P-07a, CH-P-07b, CH-P-07c; replaces the relationship branches of V-521r and V-W23-10; rule: no relationship between shared nodes holds a private-store uid token or an e-mail address in any string or list-of-string property (derived, asserted and structural edges alike).
WITH '(?is)(.*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c)))
     + ').*|.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*)' AS re
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
WITH x, r, y, [k IN keys(r) WHERE (r[k] IS :: STRING AND r[k] =~ re) OR (r[k] IS :: LIST<STRING> AND any(v IN r[k] WHERE v =~ re))] AS hits
WHERE size(hits) > 0
RETURN 'V-F5-19' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS item, x.uid AS fromUid, y.uid AS toUid, hits AS properties;

// V-F5-20 -- resolves CH-R-07b (and the list key of CH-P-07d); extends V-534p and W10-V14 (key allow-list); rule: no shared node carries a private-store property name ($privateOnlyPropertyNames or a pcs*/personal*/userContext*/privateStore* key), and Observation and ProtocolResult carry only their SDL properties ($observationAllowedKeys, $protocolResultAllowedKeys).
MATCH (n)
WHERE NOT n:PrivateRecord
WITH n, [k IN keys(n) WHERE k IN $privateOnlyPropertyNames OR k =~ '(?i)^(pcs|personal|usercontext|privatestore).*'] AS privateKeys,
     CASE WHEN n:Observation THEN [k IN keys(n) WHERE NOT k IN $observationAllowedKeys]
          WHEN n:ProtocolResult THEN [k IN keys(n) WHERE NOT k IN $protocolResultAllowedKeys]
          ELSE [] END AS undeclaredKeys
WHERE size(privateKeys) > 0 OR size(undeclaredKeys) > 0
RETURN 'V-F5-20' AS check, labels(n) AS labels, n.uid AS item, privateKeys, undeclaredKeys;

// V-F5-21 -- resolves CH-P-10, CH-R-06 (public-identity half); new; rule: every Person and PseudonymousActor is the asserter, subject, object or attributed speaker of at least one Assertion SUPPORTED_BY a locator in a snapshot of a public Source (canonicalUri not on $privateSourceUriPatterns); a BellLabs user is never minted as a Person.
MATCH (p)
WHERE (p:Person OR p:PseudonymousActor) AND NOT p:PrivateRecord
  AND NOT EXISTS {
    MATCH (a:Assertion)-[:ASSERTED_BY|HAS_SUBJECT|HAS_OBJECT|ATTRIBUTES_TO]->(p)
    MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
    WHERE src.canonicalUri IS NOT NULL AND NOT any(pat IN $privateSourceUriPatterns WHERE src.canonicalUri =~ pat)
  }
RETURN 'V-F5-21' AS check, labels(p) AS labels, p.uid AS item, p.privacyClass AS privacyClass, 'ACTOR_WITHOUT_PUBLIC_SOURCE_ASSERTION' AS violation;

// V-F5-22 -- resolves CH-P-09, CH-R-06 (record half); replaces V-W23-05 ENDPOINT_NOT_PUBLIC (compiled) and adds V-W16-06; rule: RECORDS and POSTS_RESULT connect two PUBLIC records and their authorizing assertion is supported only by snapshots of public-web Sources (never an operator application, upload or media-store Source, never an upload SourceKind).
MATCH (x)-[e:RECORDS|POSTS_RESULT]->(y)
OPTIONAL MATCH (a:Assertion {uid: e.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH x, e, y, collect(DISTINCT src) AS sources
WITH x, e, y, sources, [v IN [
        CASE WHEN coalesce(x.privacyClass, '-') <> 'PUBLIC' THEN 'RECORDER_NOT_PUBLIC' END,
        CASE WHEN coalesce(y.privacyClass, '-') <> 'PUBLIC' THEN 'RECORD_NOT_PUBLIC' END,
        CASE WHEN size(sources) = 0 THEN 'NO_SOURCE_SNAPSHOT_SUPPORT' END,
        CASE WHEN any(s IN sources WHERE s.canonicalUri IS NULL OR any(pat IN $privateSourceUriPatterns WHERE s.canonicalUri =~ pat)
                                      OR coalesce(s.sourceKind, '-') IN $privateUploadSourceKinds) THEN 'SUPPORTED_BY_OPERATOR_OR_UPLOAD_SOURCE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-22' AS check, type(e) AS relType, x.uid AS fromUid, y.uid AS toUid, violations;

// V-F5-23 -- resolves CH-P-05, CH-P-06, CH-P-13, CH-P-14 (detection); replaces V-121 (compiles V-W23-01a and extends V-W23-02); rule: a shared AnswerRecord is INTERNAL, never OWNER_PRIVATE or computed with private context, carries no free-text name/description, and a PUBLIC_ANSWER record cites only PUBLIC records outside the excluded INTERNAL layer.
MATCH (r:AnswerRecord)
WITH r, [v IN [
        CASE WHEN r.accessTier IS NULL OR NOT r.accessTier IN ['PUBLIC_ANSWER', 'OPERATOR_AUDIT', 'AGENT_PROJECTION'] THEN 'TIER_NOT_SHAREABLE' END,
        CASE WHEN coalesce(r.privateContext, '-') <> 'EXCLUDED' THEN 'PRIVATE_CONTEXT_NOT_EXCLUDED' END,
        CASE WHEN coalesce(r.privacyClass, '-') <> 'INTERNAL' THEN 'ANSWER_RECORD_NOT_INTERNAL' END,
        CASE WHEN r.name IS NOT NULL OR r.description IS NOT NULL OR r.userUid IS NOT NULL OR r.ownerUid IS NOT NULL OR r.questionText IS NOT NULL
             THEN 'FREE_TEXT_OR_ASKER_FIELD_ON_ANSWER_RECORD' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-23' AS check, r.uid AS answerRecord, null AS cited, violations
UNION
MATCH (r:AnswerRecord {accessTier: 'PUBLIC_ANSWER'})-[:CITES_ASSERTION|CITES_ASSESSMENT]->(x)
WHERE coalesce(x.privacyClass, '-') <> 'PUBLIC' OR any(l IN labels(x) WHERE l IN $publicAnswerExcludedLabels)
RETURN 'V-F5-23' AS check, r.uid AS answerRecord, x.uid AS cited, ['PUBLIC_ANSWER_CITES_NON_PUBLIC_RECORD'] AS violations;

// V-F5-24 -- resolves CH-P-03, CH-P-04 (embedding provenance); extends V-119 and V-W23-04; rule: searchFields name only public shared properties ($publicSearchFields, never $privateOnlyPropertyNames) that the node actually stores, and a node with searchText or searchEmbedding declares its searchFields.
MATCH (n)
WHERE n.searchFields IS NOT NULL OR n.searchText IS NOT NULL OR n.searchEmbedding IS NOT NULL
WITH n, [f IN coalesce(n.searchFields, []) WHERE NOT f IN $publicSearchFields OR f IN $privateOnlyPropertyNames] AS notAllowed,
     [f IN coalesce(n.searchFields, []) WHERE n[f] IS NULL] AS notStored
WHERE size(notAllowed) > 0 OR size(notStored) > 0
   OR ((n.searchText IS NOT NULL OR n.searchEmbedding IS NOT NULL) AND size(coalesce(n.searchFields, [])) = 0)
RETURN 'V-F5-24' AS check, labels(n) AS labels, n.uid AS item, notAllowed, notStored, n.searchEmbedding IS NOT NULL AS hasEmbedding;

// V-F5-25 -- resolves CH-P-01 (graph half; the tier sub-schema is Fable's); new; rule: a PUBLIC Assertion never has an INTERNAL subject or object, nor one of the excluded INTERNAL-layer types ($publicAnswerExcludedLabels), so a PUBLIC trace cannot step into lineage or policy.
MATCH (a:Assertion)-[h:HAS_SUBJECT|HAS_OBJECT]->(t)
WHERE a.privacyClass = 'PUBLIC'
  AND (t.privacyClass = 'INTERNAL' OR any(l IN labels(t) WHERE l IN $publicAnswerExcludedLabels))
RETURN 'V-F5-25' AS check, a.uid AS assertion, type(h) AS rel, labels(t) AS targetLabels, t.uid AS target, t.privacyClass AS targetClass;

// V-F5-26 -- resolves CH-P-12 (validator half; the operations section 7 respelling is Fable's); replaces V-113, V-115, V-116 (recognizer); rule: a node is private when it is :PrivateRecord, its uid contains a private-store token, or its privacyClass is set to anything but PUBLIC/INTERNAL (so 'PRIVATE-PERSONAL', 'PRIVATE_PERSONAL' and 'private-personal' are all recognised); no shared node points at it, it carries no shared-indexed label and no search text or embedding.
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS re
MATCH (s)-[r]->(p)
WHERE (p:PrivateRecord OR coalesce(p.uid, '') =~ re OR (p.privacyClass IS NOT NULL AND NOT p.privacyClass IN ['PUBLIC', 'INTERNAL']))
  AND NOT (s:PrivateRecord OR coalesce(s.uid, '') =~ re OR (s.privacyClass IS NOT NULL AND NOT s.privacyClass IN ['PUBLIC', 'INTERNAL']))
RETURN 'V-F5-26' AS check, 'SHARED_NODE_POINTS_AT_PRIVATE_NODE' AS violation, s.uid AS item, type(r) + ' -> ' + coalesce(p.uid, elementId(p)) AS detail
UNION
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS re
MATCH (p)
WHERE (p:PrivateRecord OR coalesce(p.uid, '') =~ re OR (p.privacyClass IS NOT NULL AND NOT p.privacyClass IN ['PUBLIC', 'INTERNAL']))
  AND (any(l IN labels(p) WHERE l IN $sharedIndexedLabels) OR p.searchText IS NOT NULL OR p.searchEmbedding IS NOT NULL)
RETURN 'V-F5-26' AS check, 'PRIVATE_NODE_IN_SHARED_SEARCH_SURFACE' AS violation, coalesce(p.uid, elementId(p)) AS item, toString(p.privacyClass) AS detail;

// V-F5-27 -- resolves CH-P-11; extends V-W23-06; rule: a CohortParticipant carries no name or description, and its participantToken is not an e-mail address, URL, phone number or social handle.
MATCH (cp:CohortParticipant)
WITH cp, [v IN [
        CASE WHEN cp.name IS NOT NULL OR cp.description IS NOT NULL THEN 'PARTICIPANT_HAS_FREE_TEXT_IDENTITY' END,
        CASE WHEN coalesce(cp.participantToken, '') =~ '(?is).*(@|https?://|www\\.|\\+?\\d[\\d ().-]{6,}\\d).*' THEN 'TOKEN_LOOKS_LIKE_CONTACT_OR_HANDLE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-27' AS check, cp.uid AS item, cp.participantToken AS participantToken, violations;

// V-F5-28 -- resolves CH-P-08 partially (the cross-store copy audit is DEFERRED to the PCS); compiles V-532p and tightens it; rule: every PUBLIC Observation is the subject or object of its own Assertion SUPPORTED_BY a locator in a SourceSnapshot (attribution per observation, never by inclusion in a ProtocolResult).
MATCH (o:Observation)
WHERE NOT o:PrivateRecord AND o.privacyClass = 'PUBLIC'
  AND NOT EXISTS { MATCH (a:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(o)
                   WHERE EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot) } }
RETURN 'V-F5-28' AS check, o.uid AS observation, 'OBSERVATION_WITHOUT_OWN_SOURCE_ATTRIBUTION' AS violation;

// ------------------------------------------------- protocols (W16) ----------------------------------------------------

// V-F5-29 -- resolves CH-R-01; replaces the deny-list of V-534p (edge and property halves); rule: an adherence-, adoption- or follows-like edge (type =~ (?i).*(ADHER|ADOPT|FOLLOW).*) from a Person to a Protocol, ProtocolEdition or ProtocolStep exists only as the projection of the person's own source-supported REPORTS_PRACTICE Assertion of the same predicate (never derived), and no adherence/adoption/deviation-like property sits on a public protocol record.
MATCH (p:Person)-[r]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND type(r) =~ '(?i).*(ADHER|ADOPT|FOLLOW).*'
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH p, r, x, a
WHERE a IS NULL OR r.derivationRule IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL OR a.predicate <> type(r)
   OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(p) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(x) } OR NOT EXISTS { (a)-[:ASSERTED_BY]->(p) }
   OR NOT EXISTS { (a)-[:SUPPORTED_BY]->(:SourceLocator) } OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
RETURN 'V-F5-29' AS check, 'ADHERENCE_LIKE_EDGE_WITHOUT_LICENSING_ASSERTION' AS violation, p.uid AS item, type(r) + ' -> ' + x.uid AS detail
UNION
MATCH (n)
WHERE n:Protocol OR n:ProtocolEdition OR n:ProtocolStep
WITH n, [k IN keys(n) WHERE k =~ '(?i).*(adher|adopt|follow|deviat|omit).*'] AS ks
WHERE size(ks) > 0
RETURN 'V-F5-29' AS check, 'ADHERENCE_LIKE_PROPERTY_ON_PUBLIC_PROTOCOL' AS violation, n.uid AS item, reduce(s = '', k IN ks | s + k + ' ') AS detail;

// V-F5-30 -- resolves CH-R-02; replaces V-528p and extends V-531p; rule: DEPENDS_ON fails closed: a loop through any dependency that is not symmetric (null or unknown kind counts as ordering) is a cycle; every dependency names a StepDependencyKind; a pair is never both CONCURRENT_WITH and ordered.
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
MATCH p = (s)-[:DEPENDS_ON*1..25]->(s)
WHERE any(r IN relationships(p) WHERE NOT coalesce(r.dependencyKind, '-') IN ['CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH'])
RETURN DISTINCT 'V-F5-30' AS check, 'DEPENDENCY_CYCLE' AS violation, e.uid AS item, s.stepKey AS detail
UNION
MATCH (a:ProtocolStep)-[d:DEPENDS_ON]->(b)
WHERE d.dependencyKind IS NULL OR NOT d.dependencyKind IN ['REQUIRES_PRIOR_COMPLETION', 'REQUIRES_RESULT_OF', 'CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH']
RETURN 'V-F5-30' AS check, 'DEPENDENCY_KIND_MISSING_OR_UNKNOWN' AS violation, a.uid AS item, coalesce(d.dependencyKind, 'null') + ' -> ' + b.uid AS detail
UNION
MATCH (a:ProtocolStep)-[c:DEPENDS_ON {dependencyKind: 'CONCURRENT_WITH'}]-(b:ProtocolStep), (a)-[o:DEPENDS_ON]-(b)
WHERE o <> c AND NOT coalesce(o.dependencyKind, '-') IN ['CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH'] AND elementId(a) < elementId(b)
RETURN DISTINCT 'V-F5-30' AS check, 'CONCURRENT_AND_ORDERED' AS violation, a.uid AS item, b.uid AS detail;

// V-F5-31 -- (review) resolves CH-R-03; extends V-529b; rule: when a verbatim schedule field (scheduleText, frequencyText, timingText) states a range ("3-6 months", "three to six months", "q3-6 mo"), the stored bounds are not collapsed (min = max) and, for source-unit bounds, both stored bounds appear as that range (digits or number words).
MATCH (n)
WHERE n:ProtocolStep OR n:MeasurementPlan
UNWIND [k IN ['scheduleText', 'frequencyText', 'timingText'] WHERE n[k] IS :: STRING] AS k
WITH n, k, n[k] AS txt, '(\\d+|' + reduce(acc = '', w IN $numberWords | acc + CASE WHEN acc = '' THEN '' ELSE '|' END + w) + ')' AS num
WHERE txt =~ ('(?is).*\\b(q\\s*)?' + num + '\\s*(-|–|to)\\s*' + num + '\\s*(days?|d|weeks?|wks?|months?|mos?|years?|yrs?)\\b.*')
WITH n, k, txt, toInteger(coalesce(n.cadenceIntervalMin, n.cadenceMinDays)) AS mn, toInteger(coalesce(n.cadenceIntervalMax, n.cadenceMaxDays)) AS mx
WHERE mn IS NOT NULL AND mx IS NOT NULL
  AND (mn = mx
       OR (n.cadenceIntervalMin IS NOT NULL
           AND NOT txt =~ ('(?is).*\\b(q\\s*)?(' + toString(mn) + CASE WHEN mn >= 0 AND mn < size($numberWords) THEN '|' + $numberWords[mn] ELSE '' END
                           + ')\\s*(-|–|to)\\s*(' + toString(mx) + CASE WHEN mx >= 0 AND mx < size($numberWords) THEN '|' + $numberWords[mx] ELSE '' END + ')\\b.*')))
RETURN 'V-F5-31' AS check, n.uid AS item, k AS textField, txt AS text, mn AS storedMin, mx AS storedMax,
       CASE WHEN mn = mx THEN 'RANGE_COLLAPSED' ELSE 'RANGE_NARROWED_OR_ALTERED' END AS violation;

// V-F5-32 -- resolves CH-R-05 (validator half; DERIVED_FROM_PROTOCOL is Fable's SDL fix); extends V-530p (V-530q); rule: an edition attached to a Protocol is never asserted on a THIRD_PARTY_* basis, never asserted by anyone other than the protocol's author, and (when authorship is sourced) its support comes from the author's own Source or an archived copy of it.
MATCH (p:Protocol)-[h:HAS_PROTOCOL_EDITION]->(e)
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
WITH p, h, e, a,
     [(au:Assertion)-[:HAS_SUBJECT]->(p) WHERE au.predicate IN ['AUTHORED_PROTOCOL', 'AUTHORED_PROTOCOL_EDITION'] AND NOT coalesce(au.status, '-') IN ['REJECTED', 'SUPERSEDED'] | au] AS auths
WITH p, h, e, a,
     reduce(acc = [], l IN [au IN auths | [(au)-[:HAS_OBJECT]->(o) | o.uid]] | acc + l) AS authors,
     reduce(acc = [], l IN [au IN auths | [(au)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) | s]] | acc + l) AS ownSources,
     CASE WHEN a IS NULL THEN [] ELSE [(a)-[:ASSERTED_BY]->(w) | w.uid] END AS asserters,
     CASE WHEN a IS NULL THEN [] ELSE [(a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) | s] END AS editionSources
WITH p, e, [v IN [
        CASE WHEN a IS NOT NULL AND coalesce(a.assertionBasis, '') STARTS WITH 'THIRD_PARTY' THEN 'EDITION_ASSERTED_ON_THIRD_PARTY_BASIS' END,
        CASE WHEN size(authors) > 0 AND any(w IN asserters WHERE NOT w IN authors) THEN 'EDITION_ASSERTED_BY_NON_AUTHOR' END,
        CASE WHEN size(ownSources) > 0 AND size(editionSources) > 0
                  AND none(s IN editionSources WHERE any(o IN ownSources WHERE s = o OR EXISTS { (s)-[:ARCHIVED_COPY_OF]->(o) }
                                                       OR (s.canonicalUri IS NOT NULL AND o.canonicalUri IS NOT NULL AND s.canonicalUri CONTAINS o.canonicalUri)))
             THEN 'EDITION_NOT_FROM_PROTOCOL_OWN_SOURCE' END,
        CASE WHEN coalesce(e.changeProvenance, '') = 'THIRD_PARTY_REPORTED' THEN 'EDITION_FROM_THIRD_PARTY_REPORT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-32' AS check, p.uid AS protocol, e.uid AS edition, violations;

// V-F5-33 -- resolves CH-R-08; replaces V-536p (V-536q); rule: ABOUT_CONDITION is the projection of a matching ABOUT_CONDITION Assertion (same subject and object) that is not CALCULATED, names no derivationRule, and has no DERIVED_FROM_ASSERTION input (transitively) whose predicate is a premise of a forbidden implication concluding CONDITION_PRESENT, INDICATES_CONDITION or ABOUT_CONDITION.
MATCH (o)-[r:ABOUT_CONDITION]->(c)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH o, r, c, a, [pr IN $implicationPairs WHERE pr[1] IN ['CONDITION_PRESENT', 'INDICATES_CONDITION', 'ABOUT_CONDITION'] | pr[0]] AS premises
WITH o, c, [v IN [
        CASE WHEN a IS NULL OR r.derivationRule IS NOT NULL THEN 'CONDITION_NOT_ASSERTED' END,
        CASE WHEN a IS NOT NULL AND (a.predicate <> 'ABOUT_CONDITION' OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(o) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(c) })
             THEN 'ASSERTION_DOES_NOT_MATCH_EDGE' END,
        CASE WHEN a IS NOT NULL AND (a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL) THEN 'LICENSED_BY_CALCULATED_ASSERTION' END,
        CASE WHEN a IS NOT NULL AND EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION*1..5]->(inp:Assertion) WHERE inp.predicate IN premises }
             THEN 'THRESHOLD_TRIGGER_AMONG_INPUTS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-33' AS check, o.uid AS observation, c.uid AS condition, violations;

// V-F5-34 -- resolves CH-R-09; extends V-534p and V-112 (V-534q); rule: a deviation/non-adherence-like edge or Assertion about a protocol record is only the person's own source-supported REPORTS_PRACTICE statement (never CALCULATED, never asserted by an Agent or another party), and is never derived from a statement about an OPTIONAL step; every step attached to an edition states requirementLevel and requirementBasis from their enums.
MATCH (p)-[r]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND type(r) =~ '(?i).*(DEVIAT|NON_?ADHER|OMIT|SKIP).*'
WITH p, r, x, coalesce(r.derivedFromAssertionUids, []) + [u IN [r.projectionOfAssertionUid, r.assertionUid] WHERE u IS NOT NULL] AS cited
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN cited
WITH p, r, x, collect(a) AS licences
WITH p, r, x, [v IN [
        CASE WHEN any(a IN licences WHERE EXISTS { MATCH (a)-[:HAS_SUBJECT|HAS_OBJECT]->(:ProtocolStep {requirementLevel: 'OPTIONAL'}) }
                                      OR EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION*1..5]->(:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(:ProtocolStep {requirementLevel: 'OPTIONAL'}) })
             THEN 'DEVIATION_DERIVED_FROM_OPTIONAL_STEP' END,
        CASE WHEN size(licences) = 0 OR r.derivationRule IS NOT NULL
                  OR any(a IN licences WHERE a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
                                         OR NOT EXISTS { (a)-[:ASSERTED_BY]->(p) })
             THEN 'NOT_A_SELF_REPORTED_PRACTICE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-34' AS check, type(r) AS kind, p.uid AS item, x.uid AS target, violations
UNION
MATCH (a:Assertion)-[:HAS_OBJECT]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND a.predicate =~ '(?i)(.*DEVIAT.*|(NON_)?ADHER.*|.*OMIT.*|.*SKIP.*)'
  AND (a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
       OR NOT EXISTS { MATCH (a)-[:ASSERTED_BY]->(w)<-[:HAS_SUBJECT]-(a) } OR EXISTS { (a)-[:ASSERTED_BY]->(:Agent) })
RETURN 'V-F5-34' AS check, a.predicate AS kind, a.uid AS item, x.uid AS target, ['CALCULATED_OR_THIRD_PARTY_ADHERENCE_VERDICT'] AS violations
UNION
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE s.requirementLevel IS NULL OR s.requirementBasis IS NULL
   OR NOT s.requirementLevel IN ['ESSENTIAL', 'RECOMMENDED', 'OPTIONAL', 'CONDITIONAL', 'NOT_STATED']
   OR NOT s.requirementBasis IN ['STATED_BY_SOURCE', 'EDITORIAL_INFERENCE', 'NOT_STATED']
RETURN 'V-F5-34' AS check, 'STEP_REQUIREMENT' AS kind, s.uid AS item, e.uid AS target, ['REQUIREMENT_LEVEL_OR_BASIS_MISSING'] AS violations;

// V-F5-35 -- resolves CH-R-10; new (V-543p + V-543b); rule: two editions of one Protocol never share a payloadHash under one canonicalization version, and two editions with an identical ordered list of (stepKey, step payloadHash) are a cosmetic split (review).
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(e1:ProtocolEdition), (p)-[:HAS_PROTOCOL_EDITION]->(e2:ProtocolEdition)
WHERE elementId(e1) < elementId(e2) AND e1.payloadHash = e2.payloadHash
  AND coalesce(e1.payloadCanonicalizationVersion, '-') = coalesce(e2.payloadCanonicalizationVersion, '-')
RETURN 'V-F5-35' AS check, 'EDITIONS_SHARE_PAYLOAD_HASH' AS violation, p.uid AS item, [e1.uid, e2.uid] AS editions
UNION
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition)
WITH p, e, COLLECT { MATCH (e)-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep) WITH o, s ORDER BY o.orderIndex, s.stepKey RETURN s.stepKey + '|' + coalesce(s.payloadHash, '-') } AS signature
WHERE size(signature) > 0
WITH p, signature, collect(e.uid) AS editions
WHERE size(editions) > 1
RETURN 'V-F5-35' AS check, 'IDENTICAL_STEP_LIST_COSMETIC_SPLIT' AS violation, p.uid AS item, editions;

// V-F5-36 -- resolves CH-R-11; new (V-525q); rule: every HAS_PROTOCOL_STEP carries an orderIndex, unique within the edition unless the two steps are linked by CONCURRENT_WITH.
MATCH (e:ProtocolEdition)-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE o.orderIndex IS NULL
RETURN 'V-F5-36' AS check, 'ORDER_INDEX_MISSING' AS violation, e.uid AS item, s.stepKey AS detail
UNION
MATCH (e:ProtocolEdition)-[o1:HAS_PROTOCOL_STEP]->(s1:ProtocolStep), (e)-[o2:HAS_PROTOCOL_STEP]->(s2:ProtocolStep)
WHERE elementId(o1) < elementId(o2) AND o1.orderIndex = o2.orderIndex
  AND NOT EXISTS { (s1)-[:DEPENDS_ON {dependencyKind: 'CONCURRENT_WITH'}]-(s2) }
RETURN 'V-F5-36' AS check, 'DUPLICATE_ORDER_INDEX' AS violation, e.uid AS item, s1.stepKey + ' = ' + s2.stepKey AS detail;

// V-F5-37 -- resolves CH-R-12d (the DiagnosticResult label half is Fable's); extends V-112r (licence half of V-302r); rule: a COMPARED_TO citing derivedFromAssessmentUids cites live ComparabilityAssessments with verdict COMPARABLE or COMPARABLE_WITH_CONVERSION that compare exactly the two producing versions of its endpoints.
MATCH (x)-[r:COMPARED_TO]->(y)
WHERE size(coalesce(r.derivedFromAssessmentUids, [])) > 0
UNWIND r.derivedFromAssessmentUids AS au
OPTIONAL MATCH (ca:EvidenceAssessment {uid: au})
WITH x, y, au, ca,
     [(x)-[:PRODUCED_BY_ASSAY_VERSION|COMPUTED_BY_ALGORITHM_VERSION]->(v) | v] + [(y)-[:PRODUCED_BY_ASSAY_VERSION|COMPUTED_BY_ALGORITHM_VERSION]->(v) | v] AS versions
WITH x, y, au, [v IN [
        CASE WHEN ca IS NULL OR NOT ca:ComparabilityAssessment THEN 'LICENCE_IS_NOT_A_COMPARABILITY_ASSESSMENT' END,
        CASE WHEN ca IS NOT NULL AND NOT coalesce(ca.verdict, '-') IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION'] THEN 'LICENCE_VERDICT_DOES_NOT_PERMIT_COMPARISON' END,
        CASE WHEN ca IS NOT NULL AND (coalesce(ca.status, '-') IN ['REJECTED', 'SUPERSEDED'] OR ca.recordedTo IS NOT NULL) THEN 'LICENCE_NOT_CURRENT' END,
        CASE WHEN ca IS NOT NULL AND size(versions) > 0
                  AND (any(v IN versions WHERE NOT EXISTS { (ca)-[:COMPARES]->(v) }) OR COUNT { (ca)-[:COMPARES]->() } <> 2)
             THEN 'LICENCE_COMPARES_OTHER_VERSIONS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-37' AS check, x.uid AS fromUid, y.uid AS toUid, au AS licence, violations;

// V-F5-38 -- resolves CH-R-13 (validator half; migration and fixture are Fable's), CH-K-18b detection; new (V-544p); rule: HAS_STEP starts only at a ManufacturingProcess, and HAS_PROTOCOL_STEP is only ProtocolEdition -> ProtocolStep.
MATCH (a)-[r:HAS_STEP]->(b)
WHERE NOT a:ManufacturingProcess
RETURN 'V-F5-38' AS check, 'HAS_STEP_OUTSIDE_MANUFACTURING' AS violation, a.uid AS fromUid, b.uid AS toUid
UNION
MATCH (a)-[r:HAS_PROTOCOL_STEP]->(b)
WHERE NOT (a:ProtocolEdition AND b:ProtocolStep)
RETURN 'V-F5-38' AS check, 'HAS_PROTOCOL_STEP_WRONG_DOMAIN' AS violation, a.uid AS fromUid, b.uid AS toUid;

// V-F5-39 -- resolves CH-R-14; replaces V-542p (V-542q); rule: Protocol.currentSteps (HAS_CURRENT_PROTOCOL_STEP) are the steps of ONE edition of the protocol and their stepKeys are unique.
MATCH (p:Protocol)-[:HAS_CURRENT_PROTOCOL_STEP]->(s:ProtocolStep)
WITH p, collect(s) AS steps
WITH p, steps, [x IN steps | x.stepKey] AS keys
WITH p, steps, [k IN keys WHERE size([y IN keys WHERE y = k]) > 1] AS duplicated
WHERE size(duplicated) > 0
   OR NOT EXISTS { MATCH (p)-[:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition) WHERE all(s IN steps WHERE EXISTS { (e)-[:HAS_PROTOCOL_STEP]->(s) }) }
RETURN 'V-F5-39' AS check, p.uid AS protocol, size(steps) AS currentSteps,
       reduce(acc = [], k IN duplicated | CASE WHEN k IN acc THEN acc ELSE acc + k END) AS duplicatedStepKeys;

// V-F5-40 -- resolves CH-R-15; extends V-539p and V-012 (V-545p); rule: HAS_PROTOCOL_EDITION goes from a Protocol to a ProtocolEdition that is not also a ProtocolVersion, and no node is both ProtocolEdition and ProtocolVersion.
MATCH (p)-[h:HAS_PROTOCOL_EDITION]->(e)
WHERE NOT p:Protocol OR NOT e:ProtocolEdition OR e:ProtocolVersion
RETURN 'V-F5-40' AS check, 'EDITION_TARGET_NOT_A_PROTOCOL_EDITION' AS violation, e.uid AS item, labels(e) AS labels
UNION
MATCH (n:ProtocolEdition:ProtocolVersion)
RETURN 'V-F5-40' AS check, 'PROTOCOL_EDITION_COLLAPSED_WITH_PROTOCOL_VERSION' AS violation, n.uid AS item, labels(n) AS labels;

// ------------------------------------------------- media and claims (W21/W22) -----------------------------------------

// V-F5-41 -- resolves CH-M-01, CH-M-02; replaces V-605 (allow-list form) and constrains MEDIA-EV-1; rule: EVIDENCES starts only at a MediaAsset whose generationMode is CAPTURED or EXTRACTED, that is neither synthetic nor edited, whose ORIGINAL rendition (and the asset itself) is not the output of a MEDIA_TRANSFORMATION (a BellLabs edit), and whose supporting snapshot is not on an operator store.
MATCH (m)-[e:EVIDENCES]->(x)
OPTIONAL MATCH (m)-[:HAS_MEDIA_VARIANT]->(o:MediaVariant {variantKind: 'ORIGINAL'})
WITH m, x, collect(o) AS originals
WITH m, x, [v IN [
        CASE WHEN NOT m:MediaAsset THEN 'EVIDENCING_NODE_IS_NOT_A_MEDIA_ASSET' END,
        CASE WHEN NOT coalesce(m.generationMode, 'UNKNOWN') IN ['CAPTURED', 'EXTRACTED'] THEN 'GENERATION_MODE_NOT_CAPTURED_OR_EXTRACTED' END,
        CASE WHEN coalesce(m.isSynthetic, false) OR coalesce(m.isEdited, false) THEN 'SYNTHETIC_OR_EDITED_ASSET' END,
        CASE WHEN EXISTS { (m)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'MEDIA_TRANSFORMATION'}) }
                  OR any(o IN originals WHERE EXISTS { (o)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'MEDIA_TRANSFORMATION'}) })
             THEN 'ORIGINAL_IS_A_BELLLABS_EDIT' END,
        CASE WHEN EXISTS { MATCH (x)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
                           WHERE any(pat IN $privateSourceUriPatterns WHERE coalesce(src.canonicalUri, '') =~ pat) }
             THEN 'SUPPORT_SNAPSHOT_ON_OPERATOR_STORE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-41' AS check, m.uid AS evidencingAsset, x.uid AS evidenced, violations;

// V-F5-42 -- resolves CH-M-03; replaces V-605 branch 2 (keys on bytes, not edge names) and adds V-617; rule: no MediaAsset keeps the pre-CL-014 HAS_VARIANT edge, and no snapshot whose bytes equal a rendition of a GENERATED or synthetic asset backs a non-media assertion.
MATCH (m:MediaAsset)-[r:HAS_VARIANT]->(v)
RETURN 'V-F5-42' AS check, 'LEGACY_HAS_VARIANT_ON_MEDIA_ASSET' AS violation, m.uid AS item, v.uid AS detail
UNION
MATCH (m:MediaAsset)-[:HAS_VARIANT|HAS_MEDIA_VARIANT]->(v:MediaVariant)
WHERE (m.generationMode = 'GENERATED' OR coalesce(m.isSynthetic, false)) AND v.contentHash IS NOT NULL
MATCH (ss:SourceSnapshot {contentHash: v.contentHash})-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(x:Assertion)
WHERE NOT x.predicate IN ['DEPICTS', 'EXPLAINS', 'VISUALIZES', 'ANNOTATES_SUBJECT', 'HAS_RIGHTS_RECORD']
RETURN DISTINCT 'V-F5-42' AS check, 'GENERATED_BYTES_SUPPORT_NON_MEDIA_ASSERTION' AS violation, m.uid AS item, x.uid AS detail;

// V-F5-43 -- resolves CH-M-04; replaces V-604 (V-604r); rule: an EVIDENCES edge names MEDIA-EV-1 and its input assertion, and the full MEDIA-EV-1 path exists: assertion -> IMAGE_REGION locator hanging from a SourceSnapshot whose bytes equal the ORIGINAL rendition of the evidencing asset that carries the annotated region (or the panel's own region).
MATCH (m)-[e:EVIDENCES]->(x)
WHERE e.derivationRule IS NULL OR NOT x.uid IN coalesce(e.derivedFromAssertionUids, [])
   OR NOT (
     EXISTS { MATCH (x)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m)
              MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
              WHERE l.mediaAnnotationUid = ann.uid AND v.contentHash = ss.contentHash }
     OR EXISTS { MATCH (x)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(:MediaAnnotation)<-[:FROM_ANNOTATION]-(m)
                 MATCH (:SourceSnapshot)-[:HAS_LOCATOR]->(l) })
RETURN 'V-F5-43' AS check, m.uid AS evidencingAsset, x.uid AS evidenced, e.derivationRule AS rule;

// V-F5-44 -- resolves CH-M-06; extends V-W21-01 (V-W21-01b); rule: two locators on snapshots of DIFFERENT renditions of one Episode never carry the same media start, end and time basis (a rendition's timecode is never copied to another rendition).
MATCH (ep:Episode)<-[:RENDITION_OF]-(s1:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l1:SourceLocator),
      (ep)<-[:RENDITION_OF]-(s2:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l2:SourceLocator)
WHERE s1 <> s2 AND elementId(l1) < elementId(l2) AND l1.mediaStartSeconds IS NOT NULL
  AND l1.mediaStartSeconds = l2.mediaStartSeconds AND coalesce(l1.mediaEndSeconds, -1.0) = coalesce(l2.mediaEndSeconds, -1.0)
  AND coalesce(l1.mediaTimeBasis, '-') = coalesce(l2.mediaTimeBasis, '-')
RETURN 'V-F5-44' AS check, ep.uid AS episode, l1.uid AS locator1, s1.sourceKind AS rendition1, l2.uid AS locator2, s2.sourceKind AS rendition2,
       l1.mediaStartSeconds AS mediaStartSeconds, l1.mediaTimeBasis AS basis;

// V-F5-45 -- (review) resolves CH-M-07; new (V-W21-13); rule: an assertion that is INSTANCE_OF a Claim and reports someone else's speech act (reportedSpeechAct set, or ATTRIBUTES_TO someone other than its asserter) is a retelling and must carry RETELLS, or it is counted as first-hand.
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim)
WHERE NOT EXISTS { (a)-[:RETELLS]->() } AND coalesce(a.speechAct, '-') <> 'QUESTIONS'
  AND (a.reportedSpeechAct IS NOT NULL OR EXISTS { MATCH (a)-[:ATTRIBUTES_TO]->(w) WHERE NOT EXISTS { (a)-[:ASSERTED_BY]->(w) } })
RETURN 'V-F5-45' AS check, a.uid AS assertion, c.uid AS claim, a.reportedSpeechAct AS reportedSpeechAct, 'UNLINKED_RETELLING' AS violation;

// V-F5-46 -- resolves CH-M-08; new (V-W21-14); rule: two live (not SUPERSEDED/REJECTED) instances of one Claim with the same asserter and container that share a locator, an equal quoteHash, or an overlapping media span on one snapshot are one utterance captured twice.
MATCH (a1:Assertion)-[:INSTANCE_OF]->(c:Claim)<-[:INSTANCE_OF]-(a2:Assertion)
WHERE elementId(a1) < elementId(a2)
  AND NOT coalesce(a1.status, '-') IN ['SUPERSEDED', 'REJECTED'] AND NOT coalesce(a2.status, '-') IN ['SUPERSEDED', 'REJECTED']
  AND EXISTS { MATCH (a1)-[:ASSERTED_BY]->(w)<-[:ASSERTED_BY]-(a2) }
  AND EXISTS { MATCH (a1)-[:OCCURS_IN]->(k)<-[:OCCURS_IN]-(a2) }
  AND (EXISTS { MATCH (a1)-[:SUPPORTED_BY]->(:SourceLocator)<-[:SUPPORTED_BY]-(a2) }
       OR (a1.quoteHash IS NOT NULL AND a1.quoteHash = a2.quoteHash)
       OR EXISTS { MATCH (a1)-[:SUPPORTED_BY]->(l1:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(l2:SourceLocator)<-[:SUPPORTED_BY]-(a2)
                   WHERE l1.mediaStartSeconds IS NOT NULL AND l2.mediaStartSeconds IS NOT NULL
                     AND l1.mediaStartSeconds < coalesce(l2.mediaEndSeconds, l2.mediaStartSeconds + 0.001)
                     AND l2.mediaStartSeconds < coalesce(l1.mediaEndSeconds, l1.mediaStartSeconds + 0.001) })
RETURN 'V-F5-46' AS check, c.uid AS claim, a1.uid AS occurrence1, a2.uid AS occurrence2, 'DUPLICATE_CAPTURE_OF_ONE_UTTERANCE' AS violation;

// V-F5-47 -- resolves CH-M-09, CH-M-10, CH-M-17; replaces kernel V-423 (RETIRED: it fires on the valid fx07 projection; CL-016) and V-W21-06/V-423r; rule: a RECOMMENDS edge derives from exactly one live Assertion asserted by the start node whose own speechAct is RECOMMENDS with polarity POSITIVE, that is not a sponsor read (segmentKind/assertionBasis SPONSOR_READ or OCCURS_IN_SEGMENT a SPONSOR_READ segment), and whose subject or object is the end node; the legacy assertionUid is accepted only as the migration fallback V-W00-02r reports.
MATCH (p)-[rec:RECOMMENDS]->(x)
WITH p, x, rec, coalesce(rec.derivedFromAssertionUids, CASE WHEN rec.assertionUid IS NULL THEN [] ELSE [rec.assertionUid] END) AS cited
WHERE size(cited) <> 1
   OR (rec.assertionUid IS NULL AND rec.derivationRule IS NULL)
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = cited[0] AND a.speechAct = 'RECOMMENDS' AND NOT coalesce(a.status, '-') IN ['REJECTED', 'SUPERSEDED']
       AND coalesce(a.polarity, 'UNKNOWN') = 'POSITIVE'
       AND coalesce(a.segmentKind, '-') <> 'SPONSOR_READ' AND coalesce(a.assertionBasis, '-') <> 'SPONSOR_READ'
       AND NOT EXISTS { (a)-[:OCCURS_IN_SEGMENT]->(:EpisodeSegment {segmentType: 'SPONSOR_READ'}) }
       AND (EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR EXISTS { (a)-[:HAS_OBJECT]->(x) })
   }
RETURN 'V-F5-47' AS check, p.uid AS recommenderUid, x.uid AS recommendedUid, cited;

// V-F5-48 -- resolves CH-M-11; extends V-W21-02 (V-W21-02b); rule: an occurrence whose media-time locator lies inside the delimiting interval of a SPONSOR_READ segment on the same rendition carries segmentKind SPONSOR_READ and OCCURS_IN_SEGMENT that segment.
MATCH (a:ClaimOccurrence)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WHERE l.mediaStartSeconds IS NOT NULL
MATCH (g:EpisodeSegment {segmentType: 'SPONSOR_READ'})-[:DELIMITED_BY]->(d:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src)
WITH a, l, g, min(d.mediaStartSeconds) AS segStart, max(coalesce(d.mediaEndSeconds, d.mediaStartSeconds)) AS segEnd
WHERE l.mediaStartSeconds >= segStart AND l.mediaStartSeconds < segEnd
  AND (coalesce(a.segmentKind, '-') <> 'SPONSOR_READ' OR NOT EXISTS { (a)-[:OCCURS_IN_SEGMENT]->(g) })
RETURN 'V-F5-48' AS check, a.uid AS occurrence, l.mediaStartSeconds AS at, g.uid AS sponsorSegment, segStart, segEnd;

// V-F5-49 -- resolves CH-M-12; extends V-W21-08 (V-W21-08b interim form); rule: when a span cited by a live quantitative assertion is re-anchored non-exactly (FUZZY, or textChange SUBSTANTIVE) and the numbers or quantity words differ between the cited and the re-anchored text, the assertion has a SUPERSEDES {SOURCE_CORRECTION} successor.
MATCH (cur:SourceLocator)-[ra:REANCHORS]->(old:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
WHERE (coalesce(ra.anchorMatch, '-') <> 'EXACT' OR ra.textChange = 'SUBSTANTIVE')
  AND NOT coalesce(a.status, '-') IN ['SUPERSEDED', 'REJECTED']
  AND (a.valueNumber IS NOT NULL OR a.quantity IS NOT NULL OR a.valueString IS NOT NULL)
  AND NOT EXISTS { MATCH (:Assertion)-[s:SUPERSEDES]->(a) WHERE s.supersessionKind = 'SOURCE_CORRECTION' }
WITH a, old, cur, ra,
     [t IN split(reduce(x = toLower(coalesce(old.exact, '')), c IN [',', '.', ';', ':', '!', '?', '(', ')', '"', '\'', '-', '/', '–'] | replace(x, c, ' ')), ' ')
        WHERE t =~ '\\d+' OR t IN $numberWords OR t IN $quantityWords] AS oldNums,
     [t IN split(reduce(x = toLower(coalesce(cur.exact, '')), c IN [',', '.', ';', ':', '!', '?', '(', ')', '"', '\'', '-', '/', '–'] | replace(x, c, ' ')), ' ')
        WHERE t =~ '\\d+' OR t IN $numberWords OR t IN $quantityWords] AS newNums
WHERE ra.textChange = 'SUBSTANTIVE' OR any(t IN oldNums WHERE NOT t IN newNums) OR any(t IN newNums WHERE NOT t IN oldNums)
RETURN 'V-F5-49' AS check, a.uid AS assertion, old.uid AS citedLocator, cur.uid AS reanchoredLocator, oldNums, newNums,
       'SUBSTANTIVE_CHANGE_WITHOUT_SOURCE_CORRECTION' AS violation;

// V-F5-50 -- resolves CH-M-13; new (V-W19-xx); rule: a bibliographic record is never a rendition of a work, and an abstract-only rendition (BIBLIOGRAPHIC_RECORD kind or $abstractOnlyUriPatterns) never claims renditionCoverage FULL.
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, w, [v IN [
        CASE WHEN s.sourceKind = 'BIBLIOGRAPHIC_RECORD' THEN 'BIBLIOGRAPHIC_RECORD_AS_RENDITION' END,
        CASE WHEN s.renditionCoverage = 'FULL' AND (s.sourceKind = 'BIBLIOGRAPHIC_RECORD' OR any(pat IN $abstractOnlyUriPatterns WHERE coalesce(s.canonicalUri, '') =~ pat))
             THEN 'FULL_COVERAGE_ON_ABSTRACT_ONLY_RENDITION' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-50' AS check, s.uid AS rendition, w.uid AS work, violations;

// V-F5-51 -- resolves CH-M-14; new (V-618, Community form of media_rights_record_*_exists); rule: every MediaRightsRecord states rightsStatus, statementKind and statementScope (unknown rights are never permission).
MATCH (r:MediaRightsRecord)
WHERE r.rightsStatus IS NULL OR r.statementKind IS NULL OR r.statementScope IS NULL
RETURN 'V-F5-51' AS check, r.uid AS rightsRecord, r.rightsStatus AS rightsStatus, r.statementKind AS statementKind, r.statementScope AS statementScope;

// V-F5-52 -- resolves CH-M-15; extends V-608b; rule: a DISPLAY_MEDIA use never displays an asset whose current rights record forbids commercial use (unless the PolicyVersion's useClass is NON_COMMERCIAL), and a non-ORIGINAL rendition is displayed only when a current record allows derivatives (or the status is PUBLIC_DOMAIN / HELD_BY_OPERATOR).
MATCH (act:Activity)-[u:AUTHORIZED_BY]->(pv:PolicyVersion)
WHERE u.useKind = 'DISPLAY_MEDIA'
MATCH (act)-[:USED]->(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
OPTIONAL MATCH (m)-[h:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
WHERE h.recordedTo IS NULL AND h.validTo IS NULL
WITH act, pv, v, m, collect(r) AS records
WITH act, v, m, [x IN [
        CASE WHEN any(r IN records WHERE r.commercialUseAllowed = false) AND coalesce(pv.useClass, 'COMMERCIAL') = 'COMMERCIAL' THEN 'COMMERCIAL_USE_NOT_PERMITTED' END,
        CASE WHEN coalesce(v.variantKind, '-') <> 'ORIGINAL'
                  AND NOT any(r IN records WHERE r.derivativesAllowed = true OR r.rightsStatus IN ['PUBLIC_DOMAIN', 'HELD_BY_OPERATOR'])
             THEN 'DERIVATIVE_DISPLAY_NOT_PERMITTED' END
     ] WHERE x IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-52' AS check, act.uid AS activity, m.uid AS asset, v.variantKind AS displayedRendition, violations;

// V-F5-53 -- resolves CH-M-16; promotes W19 Q-03 (CL-003 R3); rule: a Source renders at most one work, and RENDITION_OF ends on an Episode or Publication (never another Source).
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, collect(DISTINCT w) AS works
WHERE size(works) > 1 OR any(w IN works WHERE w:Source OR NOT (w:Episode OR w:Publication))
RETURN 'V-F5-53' AS check, s.uid AS rendition, [w IN works | w.uid] AS works;

// ------------------------------------------------- kernel (W00) -------------------------------------------------------

// V-F5-54 -- resolves CH-K-01a; replaces V-504 first branch (all asserted edge types, not five episode types); rule: an edge that names its authorizing assertion is never recorded before that assertion was recorded nor before any snapshot supporting the assertion was retrieved.
MATCH (x)-[r]->(y)
WHERE r.assertionUid IS NOT NULL AND r.recordedFrom IS NOT NULL
MATCH (a:Assertion {uid: r.assertionUid})
WITH r, a, [(a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot) WHERE s.retrievedAt IS NOT NULL AND s.retrievedAt > r.recordedFrom | s.uid] AS laterSnapshots
WHERE (a.recordedAt IS NOT NULL AND r.recordedFrom < a.recordedAt) OR size(laterSnapshots) > 0
RETURN 'V-F5-54' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, a.uid AS assertion,
       r.recordedFrom AS recordedFrom, a.recordedAt AS assertionRecordedAt, laterSnapshots;

// V-F5-55 -- resolves CH-K-02b; new (V-504b); rule: a record WAS_GENERATED_BY an Activity is never recorded before that activity started (PROV-O generation inside the activity; recorded time is never backdated).
MATCH (x)-[:WAS_GENERATED_BY]->(act:Activity)
WITH x, act, coalesce(x.recordedAt, x.recordedFrom) AS recorded
WHERE recorded IS NOT NULL AND act.startedAt IS NOT NULL AND recorded < act.startedAt
RETURN 'V-F5-55' AS check, x.uid AS item, act.uid AS activity, recorded, act.startedAt AS activityStartedAt;

// V-F5-56 -- resolves CH-K-03a; new (V-507c); rule: a SOURCE_CORRECTION or SOURCE_REVISION supersession that names a sourceRevisionEventUid resolves to a SourceRevisionEvent, and one that names none never has the fact-ending shape (same object and validFrom, the older open-ended, the newer only closing validTo), which must be VALIDITY_BOUNDED.
MATCH (n:Assertion)-[s:SUPERSEDES]->(o:Assertion)
WHERE s.supersessionKind IN ['SOURCE_CORRECTION', 'SOURCE_REVISION']
WITH n, s, o,
     s.sourceRevisionEventUid IS NOT NULL AND NOT EXISTS { MATCH (:SourceRevisionEvent {uid: s.sourceRevisionEventUid}) } AS unresolved,
     s.sourceRevisionEventUid IS NULL
       AND [(n)-[:HAS_OBJECT]->(x) | x.uid] = [(o)-[:HAS_OBJECT]->(x) | x.uid]
       AND coalesce(toString(n.validFrom), '-') = coalesce(toString(o.validFrom), '-')
       AND coalesce(toString(n.valueNumber), '-') = coalesce(toString(o.valueNumber), '-')
       AND coalesce(n.valueString, '-') = coalesce(o.valueString, '-')
       AND o.validTo IS NULL AND n.validTo IS NOT NULL AS endingShape
WHERE unresolved OR endingShape
RETURN 'V-F5-56' AS check, n.uid AS newer, o.uid AS older, s.supersessionKind AS kind,
       CASE WHEN unresolved THEN 'SOURCE_REVISION_EVENT_MISSING' ELSE 'FACT_ENDING_RECORDED_AS_CORRECTION' END AS violation;

// V-F5-57 -- resolves CH-K-04; compiles packet V-W00-06; rule: an Assertion is immutable after commit (INV-501/INV-504 analogue): updatedAt never exceeds createdAt; a change of valid time is a new assertion that SUPERSEDES the old one.
MATCH (a:Assertion)
WHERE a.updatedAt IS NOT NULL AND a.createdAt IS NOT NULL AND a.updatedAt > a.createdAt
RETURN 'V-F5-57' AS check, a.uid AS assertion, a.createdAt AS createdAt, a.updatedAt AS updatedAt, 'ASSERTION_EDITED_IN_PLACE' AS violation;

// V-F5-58 -- resolves CH-K-05b, CH-K-05c, CH-K-05d, CH-K-05e; replaces V-104 and V-502 (all temporal properties of all nodes and relationships); rule: no temporal value is a sentinel: year >= 9000, year <= 1, or the Unix epoch 1970-01-01T00:00Z (open and unknown bounds are null).
WITH ['validFrom', 'validTo', 'recordedAt', 'recordedFrom', 'recordedTo', 'effectiveFrom', 'effectiveTo', 'startedAt', 'endedAt', 'observedAt',
      'retrievedAt', 'publishedAt', 'reviewedAt', 'createdAt', 'updatedAt', 'derivedAt', 'reportedAt', 'intervalStart', 'intervalEnd',
      'recordedAsOf', 'validAt', 'evidenceCutoff', 'migratedAt'] AS tk
MATCH (n)
WITH n, [k IN keys(n) WHERE k IN tk AND (n[k] IS :: DATE OR n[k] IS :: ZONED DATETIME OR n[k] IS :: LOCAL DATETIME)
                            AND (n[k].year >= 9000 OR n[k].year <= 1 OR (n[k].year = 1970 AND n[k].month = 1 AND n[k].day = 1
                                 AND (n[k] IS :: DATE OR (n[k].hour = 0 AND n[k].minute = 0 AND n[k].second = 0))))] AS sentinels
WHERE size(sentinels) > 0
RETURN 'V-F5-58' AS check, 'NODE' AS kind, coalesce(n.uid, elementId(n)) AS item, sentinels
UNION
WITH ['validFrom', 'validTo', 'recordedAt', 'recordedFrom', 'recordedTo', 'effectiveFrom', 'effectiveTo', 'startedAt', 'endedAt', 'observedAt',
      'retrievedAt', 'publishedAt', 'reviewedAt', 'createdAt', 'updatedAt', 'derivedAt', 'reportedAt', 'evidencePublishedAt'] AS tk
MATCH ()-[r]->()
WITH r, [k IN keys(r) WHERE k IN tk AND (r[k] IS :: DATE OR r[k] IS :: ZONED DATETIME OR r[k] IS :: LOCAL DATETIME)
                            AND (r[k].year >= 9000 OR r[k].year <= 1 OR (r[k].year = 1970 AND r[k].month = 1 AND r[k].day = 1
                                 AND (r[k] IS :: DATE OR (r[k].hour = 0 AND r[k].minute = 0 AND r[k].second = 0))))] AS sentinels
WHERE size(sentinels) > 0
RETURN 'V-F5-58' AS check, 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item, sentinels;

// V-F5-59 -- resolves CH-K-06; compiles packet V-W00-01 (generalizes V-410's asserter half to every Assertion); rule: an Assertion has at most one ASSERTED_BY (INV-003, contract A.3).
MATCH (a:Assertion)-[:ASSERTED_BY]->(w)
WITH a, collect(DISTINCT coalesce(w.uid, elementId(w))) AS asserters, count(*) AS edges
WHERE edges > 1
RETURN 'V-F5-59' AS check, a.uid AS assertion, asserters, edges;

// V-F5-60 -- resolves CH-K-07b, CH-K-07c; new (V-402b); rule: every SourceSnapshot belongs to exactly one Source (one incoming HAS_SNAPSHOT) and that Source has a canonicalUri, so every locator is reproducible from a retrieval endpoint.
MATCH (s:SourceSnapshot)
WITH s, [(src)-[:HAS_SNAPSHOT]->(s) | src] AS sources
WHERE size(sources) <> 1 OR NOT sources[0]:Source OR sources[0].canonicalUri IS NULL
RETURN 'V-F5-60' AS check, s.uid AS snapshot, [x IN sources | x.uid] AS sources,
       CASE WHEN size(sources) = 0 THEN 'SNAPSHOT_WITHOUT_SOURCE' WHEN size(sources) > 1 THEN 'SNAPSHOT_CLAIMED_BY_SEVERAL_SOURCES'
            ELSE 'SOURCE_WITHOUT_CANONICAL_URI' END AS violation;

// V-F5-61 -- resolves CH-K-11b, CH-K-11c; replaces V-117 (V-117r) and compiles V-W00-08; rule: the live id is read from the property of the node's own type (Document documentId, DocumentTextVersion documentTextVersionId, Segmentation segmentationId, Chunk chunkId, otherwise id); every uid-bearing archetype node has it, it equals the uid's opaque segment, and a Document-family node carries no stray `id` that differs from its alias.
MATCH (n)
WHERE n.uid IS NOT NULL AND NOT n:PrivateRecord
  AND (n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment)
WITH n, CASE WHEN n:Document THEN n.documentId WHEN n:DocumentTextVersion THEN n.documentTextVersionId WHEN n:Segmentation THEN n.segmentationId
             WHEN n:Chunk THEN n.chunkId ELSE n.id END AS liveId,
     (n:Document OR n:DocumentTextVersion OR n:Segmentation OR n:Chunk) AS aliased
WITH n, liveId, [v IN [
        CASE WHEN liveId IS NULL THEN 'LIVE_ID_MISSING' END,
        CASE WHEN liveId IS NOT NULL AND NOT n.uid ENDS WITH (':' + liveId) THEN 'LIVE_ID_DIFFERS_FROM_UID_SEGMENT' END,
        CASE WHEN aliased AND n.id IS NOT NULL AND n.id <> coalesce(liveId, '') THEN 'STRAY_ID_DIFFERS_FROM_ALIAS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-61' AS check, labels(n) AS labels, n.uid AS uid, liveId, violations;

// V-F5-62 -- resolves CH-K-12b, CH-K-12c; replaces V-W00-16 (V-W00-16r); rule: the uid token is the registered token of the node's own domain label (archetype labels count only when the node has no tokened domain label); a 0.2.0 alias token is a migration item only when $uidAliasTokenLabels maps it to one of the node's labels, otherwise it is a violation.
MATCH (n)
WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND NOT n.uid STARTS WITH 'hu:private-' AND NOT n:PrivateRecord
WITH n, split(n.uid, ':')[1] AS token,
     [l IN labels(n) WHERE NOT l IN ['Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment'] AND $uidTypeTokens[l] IS NOT NULL | $uidTypeTokens[l]] AS domainTokens,
     [l IN labels(n) WHERE $uidTypeTokens[l] IS NOT NULL | $uidTypeTokens[l]] AS anyTokens
WITH n, token, CASE WHEN size(domainTokens) > 0 THEN domainTokens ELSE anyTokens END AS expected
WHERE NOT token IN expected
  AND NOT any(l IN coalesce($uidAliasTokenLabels[token], []) WHERE l IN labels(n))
RETURN 'V-F5-62' AS check, n.uid AS uid, labels(n) AS labels, token, expected,
       CASE WHEN token IN $uidAliasTokens THEN 'ALIAS_TOKEN_OF_ANOTHER_TYPE' WHEN size(expected) = 0 THEN 'LABEL_HAS_NO_TOKEN'
            ELSE 'TOKEN_NOT_REGISTERED_FOR_PRIMARY_LABEL' END AS violation;

// V-F5-63 -- resolves CH-K-14b, CH-K-14c; extends V-102/V-103/V-501 to every interval pair on nodes and relationships, and V-506/V-507 to strict order; rule: every half-open interval is non-empty (from < to) for (validFrom, validTo), (recordedAt, recordedTo), (recordedFrom, recordedTo), (effectiveFrom, effectiveTo), (startedAt, endedAt), (intervalStart, intervalEnd); a superseding assertion is recorded strictly after the one it supersedes.
WITH [['validFrom', 'validTo'], ['recordedAt', 'recordedTo'], ['recordedFrom', 'recordedTo'], ['effectiveFrom', 'effectiveTo'], ['startedAt', 'endedAt'], ['intervalStart', 'intervalEnd']] AS pairs
MATCH (n)
WITH n, [p IN pairs WHERE n[p[0]] IS NOT NULL AND n[p[1]] IS NOT NULL AND n[p[0]] >= n[p[1]] | p[0] + '>=' + p[1]] AS empty
WHERE size(empty) > 0
RETURN 'V-F5-63' AS check, 'NODE_INTERVAL_EMPTY' AS violation, coalesce(n.uid, elementId(n)) AS item, empty AS detail
UNION
WITH [['validFrom', 'validTo'], ['recordedFrom', 'recordedTo'], ['effectiveFrom', 'effectiveTo']] AS pairs
MATCH ()-[r]->()
WITH r, [p IN pairs WHERE r[p[0]] IS NOT NULL AND r[p[1]] IS NOT NULL AND r[p[0]] >= r[p[1]] | p[0] + '>=' + p[1]] AS empty
WHERE size(empty) > 0
RETURN 'V-F5-63' AS check, 'RELATIONSHIP_INTERVAL_EMPTY' AS violation, coalesce(r.relationshipUid, elementId(r)) AS item, empty AS detail
UNION
MATCH (n:Assertion)-[:SUPERSEDES]->(o:Assertion)
WHERE n.recordedAt IS NOT NULL AND o.recordedAt IS NOT NULL AND n.recordedAt <= o.recordedAt
RETURN 'V-F5-63' AS check, 'SUPERSESSION_NOT_STRICTLY_LATER' AS violation, n.uid AS item, [o.uid] AS detail;

// V-F5-64 -- resolves CH-K-15; new (V-514c); rule: every Assertion predicate is a controlled string registered in the catalog ($registeredPredicates = catalog assertedPredicates and relationship names, final SDL relationship types, W00 predicate-registry REGISTERED/CANDIDATE/CONFIRMED).
MATCH (a:Assertion)
WHERE a.predicate IS NULL OR NOT a.predicate IN $registeredPredicates
RETURN 'V-F5-64' AS check, a.uid AS assertion, a.predicate AS predicate, 'PREDICATE_NOT_REGISTERED' AS violation;

// V-F5-65 -- resolves CH-K-17c; new (V-101b); rule: a relationshipUid is a stable audit id: it names exactly one relationship across ALL relationship types (the per-type constraints cannot see cross-type reuse or types without a constraint).
MATCH ()-[r]->()
WHERE r.relationshipUid IS NOT NULL
WITH r.relationshipUid AS relationshipUid, collect(type(r)) AS types
WHERE size(types) > 1
RETURN 'V-F5-65' AS check, relationshipUid, types;

// ======== validation/generated-label-checks.cypher ========
// Generated by gen-params.mjs from the final SDL: every primary label carries the labels its @node declares (one archetype per node).
// V-F5-LBL-Source
MATCH (n:Source) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Source' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceSnapshot
MATCH (n:SourceSnapshot) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'SourceSnapshot' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceLocator
MATCH (n:SourceLocator) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'SourceLocator' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceRevisionEvent
MATCH (n:SourceRevisionEvent) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'SourceRevisionEvent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Adjudication
MATCH (n:Adjudication) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'Adjudication' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ResolutionHypothesis
MATCH (n:ResolutionHypothesis) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ResolutionHypothesis' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Agent
MATCH (n:Agent) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Agent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Activity
MATCH (n:Activity) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'Activity' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Identifier
MATCH (n:Identifier) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Identifier' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TradeItemIdentifier
MATCH (n:TradeItemIdentifier) WHERE NOT (n:Identifier AND n:Entity) RETURN 'V-F5-LBL' AS check, 'TradeItemIdentifier' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Mention
MATCH (n:Mention) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'Mention' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EquivalenceAssessment
MATCH (n:EquivalenceAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EquivalenceAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Organization
MATCH (n:Organization) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Organization' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-LegalEntity
MATCH (n:LegalEntity) WHERE NOT (n:Organization AND n:Entity) RETURN 'V-F5-LBL' AS check, 'LegalEntity' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ConsumerBrand
MATCH (n:ConsumerBrand) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ConsumerBrand' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Facility
MATCH (n:Facility) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Facility' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-OrganizationSnapshot
MATCH (n:OrganizationSnapshot) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'OrganizationSnapshot' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Person
MATCH (n:Person) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Person' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PseudonymousActor
MATCH (n:PseudonymousActor) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'PseudonymousActor' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AnonymousActor
MATCH (n:AnonymousActor) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'AnonymousActor' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CohortParticipant
MATCH (n:CohortParticipant) WHERE NOT (n:PseudonymousActor AND n:Entity) RETURN 'V-F5-LBL' AS check, 'CohortParticipant' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-IngredientMaterial
MATCH (n:IngredientMaterial) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'IngredientMaterial' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-BrandedIngredientMaterial
MATCH (n:BrandedIngredientMaterial) WHERE NOT (n:IngredientMaterial AND n:Entity) RETURN 'V-F5-LBL' AS check, 'BrandedIngredientMaterial' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-BotanicalPreparation
MATCH (n:BotanicalPreparation) WHERE NOT (n:IngredientMaterial AND n:Entity) RETURN 'V-F5-LBL' AS check, 'BotanicalPreparation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MicrobialPreparation
MATCH (n:MicrobialPreparation) WHERE NOT (n:IngredientMaterial AND n:Entity) RETURN 'V-F5-LBL' AS check, 'MicrobialPreparation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MaterialMixture
MATCH (n:MaterialMixture) WHERE NOT (n:IngredientMaterial AND n:Entity) RETURN 'V-F5-LBL' AS check, 'MaterialMixture' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ChemicalSubstance
MATCH (n:ChemicalSubstance) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ChemicalSubstance' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ChemicalForm
MATCH (n:ChemicalForm) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ChemicalForm' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-BotanicalTaxon
MATCH (n:BotanicalTaxon) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'BotanicalTaxon' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MicrobialTaxon
MATCH (n:MicrobialTaxon) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MicrobialTaxon' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MicrobialStrain
MATCH (n:MicrobialStrain) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MicrobialStrain' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Constituent
MATCH (n:Constituent) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Constituent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Nutrient
MATCH (n:Nutrient) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Nutrient' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MechanismEvidenceContext
MATCH (n:MechanismEvidenceContext) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'MechanismEvidenceContext' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Mechanism
MATCH (n:Mechanism) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Mechanism' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Pathway
MATCH (n:Pathway) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Pathway' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MolecularEntity
MATCH (n:MolecularEntity) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MolecularEntity' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Species
MATCH (n:Species) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Species' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AnatomicalContext
MATCH (n:AnatomicalContext) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'AnatomicalContext' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Organ
MATCH (n:Organ) WHERE NOT (n:AnatomicalContext AND n:Entity) RETURN 'V-F5-LBL' AS check, 'Organ' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Outcome
MATCH (n:Outcome) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Outcome' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Condition
MATCH (n:Condition) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Condition' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RiskFactor
MATCH (n:RiskFactor) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'RiskFactor' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Product
MATCH (n:Product) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Product' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProductVariant
MATCH (n:ProductVariant) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ProductVariant' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PackageConfiguration
MATCH (n:PackageConfiguration) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'PackageConfiguration' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProductSnapshot
MATCH (n:ProductSnapshot) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'ProductSnapshot' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-FormulationVersion
MATCH (n:FormulationVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'FormulationVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-IngredientComponent
MATCH (n:IngredientComponent) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'IngredientComponent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-LabelSnapshot
MATCH (n:LabelSnapshot) WHERE NOT (n:SourceSnapshot AND n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'LabelSnapshot' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-LabelDeclaration
MATCH (n:LabelDeclaration) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'LabelDeclaration' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-QuantityDeclaration
MATCH (n:QuantityDeclaration) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'QuantityDeclaration' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ServingDefinition
MATCH (n:ServingDefinition) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'ServingDefinition' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-FoodItem
MATCH (n:FoodItem) WHERE NOT (n:IngredientMaterial AND n:Entity) RETURN 'V-F5-LBL' AS check, 'FoodItem' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Exposure
MATCH (n:Exposure) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Exposure' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Lifestyle
MATCH (n:Lifestyle) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Lifestyle' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Treatment
MATCH (n:Treatment) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Treatment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Procedure
MATCH (n:Procedure) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Procedure' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Biomarker
MATCH (n:Biomarker) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Biomarker' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Metric
MATCH (n:Metric) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Metric' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-LabTest
MATCH (n:LabTest) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'LabTest' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PanelDefinition
MATCH (n:PanelDefinition) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'PanelDefinition' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MeasurementMethod
MATCH (n:MeasurementMethod) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MeasurementMethod' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Specimen
MATCH (n:Specimen) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Specimen' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ReferenceSystem
MATCH (n:ReferenceSystem) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ReferenceSystem' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Algorithm
MATCH (n:Algorithm) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Algorithm' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AssayVersion
MATCH (n:AssayVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'AssayVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AlgorithmVersion
MATCH (n:AlgorithmVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'AlgorithmVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ReferenceIntervalVersion
MATCH (n:ReferenceIntervalVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'ReferenceIntervalVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ComparabilityAssessment
MATCH (n:ComparabilityAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ComparabilityAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ReferenceRange
MATCH (n:ReferenceRange) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'ReferenceRange' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TechnologyPlatform
MATCH (n:TechnologyPlatform) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'TechnologyPlatform' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ToolOrInstrument
MATCH (n:ToolOrInstrument) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ToolOrInstrument' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Device
MATCH (n:Device) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Device' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Modality
MATCH (n:Modality) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Modality' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Sensor
MATCH (n:Sensor) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Sensor' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-FirmwareVersion
MATCH (n:FirmwareVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'FirmwareVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Study
MATCH (n:Study) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Study' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TrialRegistration
MATCH (n:TrialRegistration) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'TrialRegistration' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegistrationVersion
MATCH (n:RegistrationVersion) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'RegistrationVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProtocolVersion
MATCH (n:ProtocolVersion) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'ProtocolVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-StudyArm
MATCH (n:StudyArm) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'StudyArm' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-StudyIntervention
MATCH (n:StudyIntervention) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'StudyIntervention' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-InterventionComponent
MATCH (n:InterventionComponent) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'InterventionComponent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-StudyPopulation
MATCH (n:StudyPopulation) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'StudyPopulation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-OutcomeDefinition
MATCH (n:OutcomeDefinition) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'OutcomeDefinition' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-StudyResult
MATCH (n:StudyResult) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'StudyResult' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AdverseEventResult
MATCH (n:AdverseEventResult) WHERE NOT (n:StudyResult AND n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'AdverseEventResult' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Publication
MATCH (n:Publication) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'Publication' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Dataset
MATCH (n:Dataset) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Dataset' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EvidenceApplicability
MATCH (n:EvidenceApplicability) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EvidenceApplicability' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ApplicabilityDimension
MATCH (n:ApplicabilityDimension) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ApplicabilityDimension' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-UseContextProfile
MATCH (n:UseContextProfile) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'UseContextProfile' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EndpointClassification
MATCH (n:EndpointClassification) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EndpointClassification' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ResultInterpretation
MATCH (n:ResultInterpretation) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ResultInterpretation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EvidenceSynthesis
MATCH (n:EvidenceSynthesis) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EvidenceSynthesis' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EvidenceStrengthAssessment
MATCH (n:EvidenceStrengthAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EvidenceStrengthAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ManufacturingSpecification
MATCH (n:ManufacturingSpecification) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ManufacturingSpecification' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SpecificationVersion
MATCH (n:SpecificationVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'SpecificationVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ManufacturingProcess
MATCH (n:ManufacturingProcess) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ManufacturingProcess' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ManufacturingStep
MATCH (n:ManufacturingStep) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ManufacturingStep' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ManufacturingCapability
MATCH (n:ManufacturingCapability) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'ManufacturingCapability' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProductLot
MATCH (n:ProductLot) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ProductLot' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TestSample
MATCH (n:TestSample) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'TestSample' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TestExecution
MATCH (n:TestExecution) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'TestExecution' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TestMethod
MATCH (n:TestMethod) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'TestMethod' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-TestingLaboratory
MATCH (n:TestingLaboratory) WHERE NOT (n:Organization AND n:Entity) RETURN 'V-F5-LBL' AS check, 'TestingLaboratory' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MeasuredResult
MATCH (n:MeasuredResult) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'MeasuredResult' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SpecificationCriterion
MATCH (n:SpecificationCriterion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'SpecificationCriterion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PassFailInterpretation
MATCH (n:PassFailInterpretation) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'PassFailInterpretation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-LotTestSummary
MATCH (n:LotTestSummary) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'LotTestSummary' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CertificateOfAnalysis
MATCH (n:CertificateOfAnalysis) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'CertificateOfAnalysis' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CertificationProgram
MATCH (n:CertificationProgram) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'CertificationProgram' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CertificationListing
MATCH (n:CertificationListing) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'CertificationListing' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CertificationScope
MATCH (n:CertificationScope) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'CertificationScope' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryAgency
MATCH (n:RegulatoryAgency) WHERE NOT (n:Organization AND n:Entity) RETURN 'V-F5-LBL' AS check, 'RegulatoryAgency' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryPathway
MATCH (n:RegulatoryPathway) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'RegulatoryPathway' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryPathwayVersion
MATCH (n:RegulatoryPathwayVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'RegulatoryPathwayVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryStep
MATCH (n:RegulatoryStep) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'RegulatoryStep' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatorySubmission
MATCH (n:RegulatorySubmission) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'RegulatorySubmission' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryResponse
MATCH (n:RegulatoryResponse) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'RegulatoryResponse' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryStatus
MATCH (n:RegulatoryStatus) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'RegulatoryStatus' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-OrphanDesignation
MATCH (n:OrphanDesignation) WHERE NOT (n:RegulatoryStatus AND n:VersionedState) RETURN 'V-F5-LBL' AS check, 'OrphanDesignation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-DrugApproval
MATCH (n:DrugApproval) WHERE NOT (n:RegulatoryStatus AND n:VersionedState) RETURN 'V-F5-LBL' AS check, 'DrugApproval' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RegulatoryInspection
MATCH (n:RegulatoryInspection) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'RegulatoryInspection' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PatentFamily
MATCH (n:PatentFamily) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'PatentFamily' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Trademark
MATCH (n:Trademark) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Trademark' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PatentApplication
MATCH (n:PatentApplication) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'PatentApplication' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-GrantedPatent
MATCH (n:GrantedPatent) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'GrantedPatent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PatentClaim
MATCH (n:PatentClaim) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'PatentClaim' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PatentLicense
MATCH (n:PatentLicense) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'PatentLicense' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-IpRightStatus
MATCH (n:IpRightStatus) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'IpRightStatus' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MerchantListing
MATCH (n:MerchantListing) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MerchantListing' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Offer
MATCH (n:Offer) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'Offer' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PriceObservation
MATCH (n:PriceObservation) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'PriceObservation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SubscriptionPlan
MATCH (n:SubscriptionPlan) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'SubscriptionPlan' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Bundle
MATCH (n:Bundle) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Bundle' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-BundleComponent
MATCH (n:BundleComponent) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'BundleComponent' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-InventoryItem
MATCH (n:InventoryItem) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'InventoryItem' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-IndividualUnit
MATCH (n:IndividualUnit) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'IndividualUnit' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AffiliateLink
MATCH (n:AffiliateLink) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'AffiliateLink' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-CommerceMatch
MATCH (n:CommerceMatch) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'CommerceMatch' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Protocol
MATCH (n:Protocol) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Protocol' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProtocolEdition
MATCH (n:ProtocolEdition) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'ProtocolEdition' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProtocolStep
MATCH (n:ProtocolStep) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ProtocolStep' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Constraint
MATCH (n:Constraint) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Constraint' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MeasurementPlan
MATCH (n:MeasurementPlan) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'MeasurementPlan' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProtocolAdjustmentRule
MATCH (n:ProtocolAdjustmentRule) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'ProtocolAdjustmentRule' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Target
MATCH (n:Target) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Target' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-FunctionalGoal
MATCH (n:FunctionalGoal) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'FunctionalGoal' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Observation
MATCH (n:Observation) WHERE NOT (n:DiagnosticResult AND n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'Observation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProtocolResult
MATCH (n:ProtocolResult) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'ProtocolResult' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AdverseEffect
MATCH (n:AdverseEffect) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'AdverseEffect' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SafetySignal
MATCH (n:SafetySignal) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'SafetySignal' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ContraindicationAssertion
MATCH (n:ContraindicationAssertion) WHERE NOT (n:Assertion) RETURN 'V-F5-LBL' AS check, 'ContraindicationAssertion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-InteractionAssertion
MATCH (n:InteractionAssertion) WHERE NOT (n:Assertion) RETURN 'V-F5-LBL' AS check, 'InteractionAssertion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-UseConstraint
MATCH (n:UseConstraint) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'UseConstraint' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Community
MATCH (n:Community) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Community' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Conference
MATCH (n:Conference) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Conference' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Event
MATCH (n:Event) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'Event' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-NarrativeArc
MATCH (n:NarrativeArc) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'NarrativeArc' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EventImpactAssessment
MATCH (n:EventImpactAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'EventImpactAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceAuthorityAssessment
MATCH (n:SourceAuthorityAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'SourceAuthorityAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceCoverageRequirement
MATCH (n:SourceCoverageRequirement) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'SourceCoverageRequirement' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-SourceDiscoveryRecord
MATCH (n:SourceDiscoveryRecord) WHERE NOT (n:Activity AND n:Occurrence) RETURN 'V-F5-LBL' AS check, 'SourceDiscoveryRecord' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Document
MATCH (n:Document) WHERE NOT (n:Source AND n:Entity) RETURN 'V-F5-LBL' AS check, 'Document' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-DocumentTextVersion
MATCH (n:DocumentTextVersion) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'DocumentTextVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Segmentation
MATCH (n:Segmentation) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'Segmentation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Chunk
MATCH (n:Chunk) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'Chunk' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Platform
MATCH (n:Platform) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Platform' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Channel
MATCH (n:Channel) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Channel' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Series
MATCH (n:Series) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Series' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Episode
MATCH (n:Episode) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Episode' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-EpisodeSegment
MATCH (n:EpisodeSegment) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'EpisodeSegment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-Claim
MATCH (n:Claim) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'Claim' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ClaimOccurrence
MATCH (n:ClaimOccurrence) WHERE NOT (n:Assertion) RETURN 'V-F5-LBL' AS check, 'ClaimOccurrence' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RelationshipAssertion
MATCH (n:RelationshipAssertion) WHERE NOT (n:Assertion) RETURN 'V-F5-LBL' AS check, 'RelationshipAssertion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ClaimEvidenceAssessment
MATCH (n:ClaimEvidenceAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ClaimEvidenceAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-RetellingFidelityAssessment
MATCH (n:RetellingFidelityAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'RetellingFidelityAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ConflictRelevanceAssessment
MATCH (n:ConflictRelevanceAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'ConflictRelevanceAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MediaAsset
MATCH (n:MediaAsset) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'MediaAsset' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MediaVariant
MATCH (n:MediaVariant) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'MediaVariant' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MediaAnnotation
MATCH (n:MediaAnnotation) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'MediaAnnotation' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-GraphView
MATCH (n:GraphView) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'GraphView' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-FigurePanel
MATCH (n:FigurePanel) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'FigurePanel' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-ProductLabelRegion
MATCH (n:ProductLabelRegion) WHERE NOT (n:InformationArtifact) RETURN 'V-F5-LBL' AS check, 'ProductLabelRegion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MediaSuitabilityAssessment
MATCH (n:MediaSuitabilityAssessment) WHERE NOT (n:EvidenceAssessment) RETURN 'V-F5-LBL' AS check, 'MediaSuitabilityAssessment' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-MediaRightsRecord
MATCH (n:MediaRightsRecord) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'MediaRightsRecord' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-AnswerRecord
MATCH (n:AnswerRecord) WHERE NOT (n:Occurrence) RETURN 'V-F5-LBL' AS check, 'AnswerRecord' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-PolicyVersion
MATCH (n:PolicyVersion) WHERE NOT (n:VersionedState) RETURN 'V-F5-LBL' AS check, 'PolicyVersion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-LBL-DecisionCriterion
MATCH (n:DecisionCriterion) WHERE NOT (n:Entity) RETURN 'V-F5-LBL' AS check, 'DecisionCriterion' AS label, n.uid AS uid, labels(n) AS labels;
// V-F5-ARCH-1: exactly one archetype label per node that carries any
MATCH (n) WITH n, [l IN labels(n) WHERE l IN ["Entity","VersionedState","Occurrence","InformationArtifact","Assertion","EvidenceAssessment"]] AS a WHERE size(a) <> 1 AND size(labels(n)) > 0 RETURN 'V-F5-ARCH-1' AS check, n.uid AS uid, labels(n) AS labels;
// V-F5-ARCH-2: a uid-bearing node carries an archetype label (otherwise the archetype uid constraint cannot see it)
MATCH (n) WHERE n.uid IS NOT NULL AND none(l IN labels(n) WHERE l IN ["Entity","VersionedState","Occurrence","InformationArtifact","Assertion","EvidenceAssessment"]) RETURN 'V-F5-ARCH-2' AS check, n.uid AS uid, labels(n) AS labels;
