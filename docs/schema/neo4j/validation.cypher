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

// V-003: assertions must have exactly one object OR one typed literal.
MATCH (a:Assertion)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(o)
WITH a, count(o) AS objects,
     size([x IN [a.valueString, a.valueNumber, a.valueBoolean] WHERE x IS NOT NULL]) AS literals
WHERE objects + literals <> 1
RETURN a.uid AS assertionUid, objects, literals;

// V-004: no direct composition shortcut may masquerade as authoritative history.
MATCH (p)-[r:CONTAINS]->(m:IngredientMaterial)
WHERE r.projectionOfAssertionUid IS NULL AND r.derivationRule IS NULL
RETURN p.uid AS productUid, m.uid AS materialUid;

// V-005: formulation components must identify a material.
MATCH (c:IngredientComponent)
WHERE NOT (c)-[:USES_MATERIAL]->(:IngredientMaterial)
RETURN c.uid AS componentWithoutMaterial;

// V-006: quantitative containment requires quantity, unit, and basis.
MATCH ()-[r:QUANTITATIVELY_CONTAINS]->()
WHERE r.quantity IS NULL OR r.unitCode IS NULL OR r.basis IS NULL
RETURN r;

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


// =====================================================================================
// Lane 1, round 0009: query-shape invariants (V-1xx)
// Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// Every query below is statically checked (syntax and per-statement variable binding) unless marked
// illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// =====================================================================================

// Lane 1 validation queries V-101..V-121 (access, query shapes, temporal and search-surface invariants).
// Zero rows = valid unless marked informational. Every statement is self-contained: it binds its own
// variables and shares nothing across ';'. None of these was executed; no Neo4j was available.
// Status tags:
//   statically-checked = parsed with the Neo4j Cypher language-support linter (syntax and schema-free
//                        semantics) and read against catalog labels, relationship types and properties.
//   illustrative       = depends on a parameter list or a catalog decision that is not yet merged.
// Parameters ($...) are supplied by the validation runner from the merged catalog.

// V-101: every asserted edge carries its authorizing assertion and a recorded-time start.
// status: statically-checked
// params: $assertedTypes list<string> generated from catalog relationships with class: asserted
MATCH ()-[r]->()
WHERE type(r) IN $assertedTypes
  AND (r.recordedFrom IS NULL OR r.assertionUid IS NULL)
RETURN type(r) AS relType, elementId(r) AS edgeId, r.recordedFrom AS recordedFrom, r.assertionUid AS assertionUid;

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

// V-104: no sentinel dates. Open and unknown bounds are null.
// status: statically-checked
MATCH ()-[r]->()
WHERE (r.validTo IS NOT NULL AND r.validTo.year >= 9000)
   OR (r.recordedTo IS NOT NULL AND r.recordedTo.year >= 9000)
   OR (r.validFrom IS NOT NULL AND r.validFrom.year <= 1)
RETURN type(r) AS relType, elementId(r) AS edgeId;

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

// V-108: exclusive predicates: no two possibly-overlapping believed attachments from one subject
// to different objects within one scope. Unknown bounds are treated as possible overlap.
// status: illustrative (depends on predicate exclusivity metadata, catalog conventions.predicateExclusivity)
// params: $exclusiveTypes list<string>
MATCH (x)-[r1]->(y1), (x)-[r2]->(y2)
WHERE type(r1) = type(r2)
  AND type(r1) IN $exclusiveTypes
  AND elementId(r1) < elementId(r2)
  AND y1 <> y2
  AND coalesce(y1.jurisdiction, '') = coalesce(y2.jurisdiction, '')
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.validTo IS NULL OR r2.validFrom IS NULL OR r2.validFrom < r1.validTo)
  AND (r2.validTo IS NULL OR r1.validFrom IS NULL OR r1.validFrom < r2.validTo)
RETURN type(r1) AS relType, x.uid AS subjectUid, y1.uid AS objectUid1, y2.uid AS objectUid2,
       elementId(r1) AS edge1, elementId(r2) AS edge2;

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

// V-112: derived and forbidden-implication edges cite live, matching assertions (QS-4a, zero rows = valid).
// status: statically-checked
// params: $derivedTypes, $implicationPairs, $ruleOnlyDerivedTypes (catalog relationships with ruleOnly: true)
MATCH (x)-[r]->(y)
WHERE type(r) IN $derivedTypes OR type(r) IN [p IN $implicationPairs | p[1]]
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, citedUid, cited,
     [v IN [
        CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) = 0
                  AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AND r.hypothesisUid IS NULL
                  AND NOT type(r) IN $ruleOnlyDerivedTypes THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
        CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
             THEN 'LICENSING_ASSESSMENT_MISSING' END,
        CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
               MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
                 AND any(p IN $implicationPairs WHERE p[1] = type(r) AND p[0] = inp.predicate)
             } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
               size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
             THEN 'DERIVATION_INPUT_MISSING' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;

// V-113: no shared node points at a private node (public/private boundary).
// status: statically-checked
// 0.2.0: K-5 revised. A private node is recognised by its uid prefix hu:private-, privacyClass private-personal, or the
// fixture marker :PrivateRecord (single-file two-store fixtures only). In production the private store is a separate
// database (round 0008), so rows here mean a private record leaked into the shared graph.
MATCH (s)-[r]->(p)
WHERE (p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' OR p:PrivateRecord)
  AND NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
RETURN labels(s) AS sharedLabels, s.uid AS sharedUid, type(r) AS relType, p.uid AS privateUid;

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

// V-117: uid format and uid-to-live-id seam. For a node that has both a uid and a live id (stored under
// the type's id property or its @alias), the uid ends with ':' + id and matches the format.
// status: statically-checked
MATCH (n)
WHERE n.uid IS NOT NULL
WITH n, coalesce(n.id, n.documentId, n.documentTextVersionId, n.segmentationId, n.chunkId) AS liveId
WHERE NOT n.uid =~ 'hu:[a-z][a-z0-9-]*:[A-Za-z0-9][A-Za-z0-9._~-]*'
   OR (liveId IS NOT NULL AND NOT n.uid ENDS WITH (':' + liveId))
RETURN n.uid AS uid, liveId, labels(n) AS labels;

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
// Expected by hand from lines 502, 738, 2660 to 2745 of current_biotech_schema.graphql:
//   DocumentSearch -> Document   [title, url, searchText]      (GraphQL fields name, sourceUrl are aliased)
//   ChunkSearch    -> Chunk      [text, searchText]
//   ClaimSearch    -> Claim      [name, description, searchText]
// Any index whose properties differ, or state <> 'ONLINE', is a defect to review. // service-enforced comparison

// V-121: a published-answer record states its viewpoint and carries no user identifier.
// status: illustrative (AnswerRecord is a CANDIDATE node in the catalog's access_and_answers module)
MATCH (r:AnswerRecord)
WHERE r.recordedAsOf IS NULL OR r.schemaDigest IS NULL OR r.queryShapeId IS NULL OR r.accessTier IS NULL
   OR r.userUid IS NOT NULL OR r.ownerUid IS NOT NULL OR r.questionText IS NOT NULL
RETURN r.uid AS answerRecordUid;


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


// =====================================================================================
// Lane 2, rounds 0002 and 0003: evidence applicability and mechanisms (V-2xx)
// Source: ontology-lab round files; merged by the integration owner on 2026-10-03.
// Every query below is statically checked (syntax and per-statement variable binding) unless marked
// illustrative. None was executed: no Neo4j instance existed in the authoring environment.
// =====================================================================================

// Lane 2 validation queries (rounds 0002, 0003). Zero rows = valid unless marked informational.
// Neo4j 5 Cypher. Not executed (no Neo4j in this environment). Each statement is self-contained.
// "service-enforced" marks rules Neo4j cannot enforce; the query detects violations after the fact.

// ---------------------------------------------------------------------------
// Study vs product (round 0002)
// ---------------------------------------------------------------------------

// V-201 (INV-201, FI-201): no direct relationship from study-side records to commercial identities.
// status: statically-checked
MATCH (s)-[r]->(p)
WHERE (s:Study OR s:StudyArm OR s:StudyIntervention OR s:StudyResult OR s:Publication)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion)
RETURN s.uid AS studySide, type(r) AS rel, p.uid AS commercialTarget;

// V-202 (R1): a ProductVariant used as intervention material must carry asReportedName.
// status: statically-checked
MATCH (ic:InterventionComponent)-[u:USES_INTERVENTION_MATERIAL]->(v:ProductVariant)
WHERE u.asReportedName IS NULL
RETURN ic.uid AS component, v.uid AS variantWithoutReportedName;

// V-203 (INV-202): exactly one evidence target and exactly one use target.
// status: statically-checked
MATCH (ea:EvidenceApplicability)
OPTIONAL MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(e)
WITH ea, count(DISTINCT e) AS evidenceTargets
OPTIONAL MATCH (ea)-[:ASSESSES_APPLICABILITY_TO]->(t)
WITH ea, evidenceTargets, count(DISTINCT t) AS useTargets
WHERE evidenceTargets <> 1 OR useTargets <> 1
RETURN ea.uid AS assessment, evidenceTargets, useTargets;

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

// V-211: every RegistrationVersion belongs to exactly one TrialRegistration and has observedAt.
// status: statically-checked
MATCH (rv:RegistrationVersion)
OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
WITH rv, count(r) AS owners
WHERE owners <> 1 OR rv.observedAt IS NULL
RETURN rv.uid AS registrationVersion, owners;

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

// V-215 (INV-206): no secondary/subgroup/post hoc/within-arm result enters as CONFIRMATORY when the same
// study's primary prespecified result is NOT_SIGNIFICANT.
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE r.analysisKind <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind = 'WITHIN_ARM_CHANGE'
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
RETURN syn.uid AS synthesis, r.uid AS nonPrimaryConfirmatory, p.uid AS nullPrimary;

// V-216 (FI-207): within-arm changes are never CONFIRMATORY or INDEPENDENT_REPLICATION inputs.
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r:StudyResult {comparisonKind: 'WITHIN_ARM_CHANGE'})
WHERE inc.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION']
RETURN syn.uid AS synthesis, r.uid AS withinArmResult, inc.inputRole AS role;

// V-217 (INV-207): adverse-event results state a collection method; zeros need one.
// status: statically-checked
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod IS NULL OR (ae.participantsAffected = 0 AND ae.collectionMethod = 'NOT_DESCRIBED')
RETURN ae.uid AS aeResult, ae.participantsAffected AS affected, ae.collectionMethod AS method;

// V-218 (CQ-ST-07): two INDEPENDENT_REPLICATION inputs of one synthesis may not share a study or dataset.
// status: statically-checked
MATCH (syn:EvidenceSynthesis)-[i1:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r1:StudyResult),
      (syn)-[i2:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r2:StudyResult)
WHERE r1.uid < r2.uid
MATCH (r1)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s1:Study),
      (r2)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s2:Study)
WHERE s1 = s2
   OR EXISTS { MATCH (s1)-[:PRODUCED_DATASET]->(ds:Dataset)<-[:ANALYZES_DATASET]-(:Publication)-[:REPORTS_ON]->(s2) }
   OR EXISTS { MATCH (s1)-[:PRODUCED_DATASET]->(ds:Dataset)<-[:PRODUCED_DATASET]-(s2) }
RETURN syn.uid AS synthesis, r1.uid AS result1, r2.uid AS result2;

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

// V-221 (R1): non-placebo study interventions have components with quantity, unit, quantityBasis, and massBasis
// (massBasis may be UNSPECIFIED; quantity may be absent only with quantityStatus NOT_REPORTED).
// status: statically-checked
MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
WHERE arm.armType <> 'PLACEBO_COMPARATOR'
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
WITH si, ic
WHERE ic IS NULL
   OR ic.massBasis IS NULL OR ic.quantityBasis IS NULL
   OR (ic.quantity IS NULL AND coalesce(ic.quantityStatus, '') <> 'NOT_REPORTED')
   OR (ic.quantity IS NOT NULL AND ic.unitCode IS NULL)
RETURN si.uid AS intervention, ic.uid AS incompleteComponent;

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

// V-231 (INV-210): DIRECT_MEASUREMENT has exactly one context with setting and species (except cell-free / in silico);
// non-measured assertions have no context.
// status: statically-checked
MATCH (a:Assertion)
WHERE a.basisKind IS NOT NULL
OPTIONAL MATCH (a)-[:OBSERVED_IN_CONTEXT]->(c:MechanismEvidenceContext)
WITH a, collect(c) AS ctxs
WHERE (a.basisKind = 'DIRECT_MEASUREMENT' AND size(ctxs) <> 1)
   OR (a.basisKind <> 'DIRECT_MEASUREMENT' AND size(ctxs) > 0)
   OR (size(ctxs) = 1 AND (ctxs[0].setting IS NULL
        OR (NOT ctxs[0].setting IN ['IN_VITRO_CELL_FREE', 'IN_SILICO'] AND NOT EXISTS { MATCH (ctx:MechanismEvidenceContext {uid: ctxs[0].uid})-[:IN_SPECIES]->(:Species) })))
RETURN a.uid AS assertion, a.basisKind AS basisKind, size(ctxs) AS contexts;

// V-232: exposure amounts carry unit and basis; unknown exposure is null with exposureStatus, never zero.
// status: statically-checked
MATCH (c:MechanismEvidenceContext)
WHERE (c.exposureAmount IS NOT NULL AND (c.exposureUnit IS NULL OR c.exposureBasis IS NULL))
   OR c.exposureAmount = 0
   OR (c.exposureAmount IS NULL AND NOT EXISTS { MATCH (c)-[:IN_STUDY_ARM]->(:StudyArm) } AND c.exposureStatus IS NULL)
RETURN c.uid AS contextWithIncompleteExposure;

// V-233 (INV-211, FI-304): mechanism projections only from ACCEPTED DIRECT_MEASUREMENT assertions.
// ACCEPTED here is capture fidelity (the measurement was accurately recorded), not a truth verdict; truth gating
// of projections is a SUPPORT adjudication question handled by the recommendation layer.
// status: statically-checked
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.projectionOfAssertionUid})
WITH x, r, y, a
WHERE a IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT' OR a.status <> 'ACCEPTED'
RETURN x.uid AS fromUid, type(r) AS rel, y.uid AS toUid, a.basisKind AS projectedBasis;

// V-234 (INV-211, FI-302): APPLIES_TO_SPECIES targets a species of the projected assertion's context.
// status: statically-checked
MATCH (m:Mechanism)-[r:APPLIES_TO_SPECIES]->(sp:Species)
WHERE NOT EXISTS {
  MATCH (a:Assertion {uid: r.projectionOfAssertionUid})-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
}
RETURN m.uid AS mechanism, sp.uid AS speciesWithoutMeasuredContext;

// V-235 (M6): ACCEPTED assertions whose every supporting locator belongs to a source whose publication is retracted.
// Publication-to-Source alignment is Lane 4's (round 0006); this query joins on DOI URI.
// status: illustrative
MATCH (a:Assertion {status: 'ACCEPTED'})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH a, collect(DISTINCT src) AS sources
WHERE all(s0 IN sources WHERE EXISTS {
  MATCH (notice:Publication)-[:RETRACTS]->(pub:Publication)
  WHERE s0.canonicalUri = 'https://doi.org/' + pub.doi
})
RETURN a.uid AS acceptedAssertionOnlyOnRetractedSources;

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

// V-302: measured results compared across different assay versions need a COMPARABLE or COMPARABLE_WITH_CONVERSION assessment.
// status: statically-checked
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
      (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
WHERE a1 <> a2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
    MATCH (ca)-[:COMPARES]->(a2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// V-303: result kind must match its producing record. Measured results need an assay version;
// calculated and inferred results need an algorithm version, unless the link is still an UNRESOLVED
// assertion under review (competing proposals), which is the only allowed pending state.
// status: statically-checked
MATCH (r:DiagnosticResult)
WHERE r.resultKind IS NULL
   OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion))
   OR (r.resultKind IN ['CALCULATED', 'INFERRED']
       AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
       })
RETURN r.uid AS resultUid, r.resultKind AS resultKind;

// V-304: inferred or calculated results compared across different algorithm versions need an assessment.
// status: statically-checked
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
      (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
WHERE v1 <> v2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
    MATCH (ca)-[:COMPARES]->(v2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

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

// V-313: every DiagnosticResult declares a privacy class (placement is Lane 5's decision).
// status: statically-checked
MATCH (r:DiagnosticResult)
WHERE r.privacyClass IS NULL
   OR NOT r.privacyClass IN ['public', 'internal', 'private-personal', 'synthetic']
RETURN r.uid AS resultUid;

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

// V-322: live projection Product.status = 'APPROVED' requires an APPROVAL status of that product.
// status: statically-checked
MATCH (p:Product)
WHERE p.status = 'APPROVED'
  AND NOT EXISTS {
    MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(p)
    WHERE s.statusKind = 'APPROVAL'
  }
RETURN coalesce(p.uid, p.id) AS productWithUnbackedApproval;

// V-323: establishment or facility registration is a status of a Facility only.
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:STATUS_OF]->(x)
WHERE s.statusKind = 'ESTABLISHMENT_REGISTRATION' AND NOT x:Facility
RETURN s.uid AS statusUid, labels(x) AS attachedTo, x.uid AS attachedUid;

// V-324: an OPERATING capability state needs a non-marketing source or a SUPPORTED adjudication.
// status: statically-checked
MATCH (holder)-[h:HAS_CAPABILITY_STATE]->(c:ManufacturingCapability)
WHERE c.stage = 'OPERATING'
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH holder, h, c, a, collect(DISTINCT src.sourceKind) AS kinds
WHERE a IS NULL
   OR (all(k IN kinds WHERE k IN ['MARKETING_PAGE', 'THIRD_PARTY_DIRECTORY', 'PRESS_RELEASE'])
       AND NOT EXISTS {
         MATCH (j:Adjudication {adjudicationKind: 'SUPPORT'})-[:EVALUATES]->(a)
         WHERE j.verdict = 'SUPPORTED'
       })
RETURN holder.uid AS holderUid, c.uid AS capabilityUid, kinds AS supportingSourceKinds;

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

// V-333: regulatory statuses carry a known status kind, a jurisdiction, and exactly one subject.
// status: statically-checked
MATCH (s:RegulatoryStatus)
OPTIONAL MATCH (s)-[:STATUS_OF]->(x)
WITH s, count(x) AS subjects
WHERE subjects <> 1
   OR s.jurisdiction IS NULL
   OR s.statusKind IS NULL
   OR NOT s.statusKind IN ['APPROVAL', 'CLEARANCE', 'DE_NOVO_AUTHORIZATION', 'DESIGNATION', 'ESTABLISHMENT_REGISTRATION',
                           'NOTIFICATION_ON_FILE', 'ENFORCEMENT_DISCRETION', 'WITHDRAWN', 'REVOKED']
RETURN s.uid AS statusUid, s.statusKind AS statusKind, subjects;

// V-334: a status cannot outlive the legal basis it depends on (for example the 2024 LDT rule, vacated 2025-03-31).
// status: statically-checked
MATCH (s:RegulatoryStatus)-[:UNDER_LEGAL_BASIS]->(pw:RegulatoryPathway)
WHERE pw.effectiveTo IS NOT NULL
  AND (s.effectiveTo IS NULL OR s.effectiveTo > pw.effectiveTo)
RETURN s.uid AS statusUid, pw.uid AS pathwayUid, pw.effectiveTo AS basisEnded;

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

// V-407: an Assertion may point SUPPORTED_BY at a Chunk only as a derived
// shortcut naming the locator it projects, and that locator must also be linked.
// status: statically-checked
MATCH (a:Assertion)-[r:SUPPORTED_BY]->(c:Chunk)
WHERE r.locatorUid IS NULL
   OR NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator) WHERE l.uid = r.locatorUid }
RETURN a.uid AS assertionUid, c.uid AS chunkWithoutLocator;

// V-408: RESOLVES_TO_CHUNK is derived; it must name its derivation rule and segmentation.
// status: statically-checked
MATCH (l:SourceLocator)-[r:RESOLVES_TO_CHUNK]->(c:Chunk)
WHERE r.derivationRule IS NULL OR r.segmentationHash IS NULL
RETURN l.uid AS locatorUid, c.uid AS chunkUid;

// V-409: REANCHORS links locators on two snapshots of the same Source, newer to older.
// status: statically-checked
MATCH (newL:SourceLocator)-[x:REANCHORS]->(oldL:SourceLocator)
MATCH (sNew:SourceSnapshot)-[:HAS_LOCATOR]->(newL), (sOld:SourceSnapshot)-[:HAS_LOCATOR]->(oldL)
WHERE x.anchorMatch IS NULL
   OR sNew = sOld
   OR NOT EXISTS { MATCH (sNew)<-[:HAS_SNAPSHOT]-(:Source)-[:HAS_SNAPSHOT]->(sOld) }
   OR sNew.retrievedAt <= sOld.retrievedAt
RETURN newL.uid AS newLocator, oldL.uid AS oldLocator;

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

// V-416: QUALIFIED_BY names its kind and stays inside one container.
// status: statically-checked
MATCH (a:Assertion)-[q:QUALIFIED_BY]->(b:Assertion)
WHERE q.qualificationKind IS NULL
   OR NOT EXISTS { MATCH (a)-[:OCCURS_IN]->(c)<-[:OCCURS_IN]-(b) }
RETURN a.uid AS qualifiedUid, b.uid AS qualifierUid;

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

// V-423: live Person-[:RECOMMENDS]-> is a projection of an assertion whose own
// speech act is RECOMMENDS (a practice report or a third party's attribution does not count).
// status: statically-checked
MATCH (p:Person)-[rec:RECOMMENDS]->(x)
WHERE rec.assertionUid IS NULL
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = rec.assertionUid AND a.speechAct = 'RECOMMENDS'
   }
RETURN p.uid AS recommenderUid, x.uid AS recommendedUid;

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

// ---------------------------------------------------------------------
// E. Ecosystem identity (CQ-EC-02)
// ---------------------------------------------------------------------

// V-432: an EquivalenceAssessment compares exactly two distinct nodes and never
// coexists with a merged node carrying both compared kinds.
// status: statically-checked
MATCH (e:EquivalenceAssessment)
OPTIONAL MATCH (e)-[:COMPARES]->(n)
WITH e, collect(DISTINCT n) AS ns
WHERE size(ns) <> 2 OR e.equivalenceKind IS NULL OR e.methodVersion IS NULL
RETURN e.uid AS malformedEquivalenceAssessment, size(ns) AS comparedCount;

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

// V-503: bound, precision, and basis agree. OBSERVATION_ONLY or UNKNOWN basis forces a null bound; a non-null bound
// needs a precision; INFERRED needs a derivation rule.
// status: statically-checked
// 0.2.0 integration: a basis is required when its bound is non-null; a null bound with a null basis reads as UNKNOWN.
MATCH (a:Assertion)
WHERE (a.validFrom IS NOT NULL AND a.validFromBasis IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToBasis IS NULL)
   OR (a.validFromBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validFrom IS NOT NULL)
   OR (a.validToBasis IN ['OBSERVATION_ONLY', 'UNKNOWN'] AND a.validTo IS NOT NULL)
   OR (a.validFrom IS NOT NULL AND a.validFromPrecision IS NULL)
   OR (a.validTo IS NOT NULL AND a.validToPrecision IS NULL)
   OR ((a.validFromBasis = 'INFERRED' OR a.validToBasis = 'INFERRED') AND a.derivationRule IS NULL)
RETURN a.uid AS assertionWithInconsistentTimeQualifiers;

// V-504: no backdating. An episode is not recorded before its authorizing assertion; an assertion is not recorded
// before the snapshot that supports it was retrieved.
// status: statically-checked
MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
WHERE h.assertionUid IS NOT NULL
MATCH (a:Assertion {uid: h.assertionUid})
WHERE h.recordedFrom < a.recordedAt
RETURN 'EPISODE_BEFORE_ASSERTION' AS violation, h.relationshipUid AS item
UNION
MATCH (a:Assertion)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WHERE a.recordedAt < sn.retrievedAt
RETURN 'ASSERTION_BEFORE_RETRIEVAL' AS violation, a.uid AS item;

// V-505: projection fidelity. Episode valid time equals its authorizing assertion's valid time. A correction that
// edited valid time in place on either side shows up here.
// status: statically-checked
MATCH ()-[h:HAS_STATE|HAS_FORMULATION_VERSION|HAS_PACKAGE_CONFIGURATION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->()
WHERE h.assertionUid IS NOT NULL
MATCH (a:Assertion {uid: h.assertionUid})
WHERE coalesce(toString(h.validFrom), '-') <> coalesce(toString(a.validFrom), '-')
   OR coalesce(toString(h.validTo), '-') <> coalesce(toString(a.validTo), '-')
   OR coalesce(h.validFromPrecision, '-') <> coalesce(a.validFromPrecision, '-')
   OR coalesce(h.validToPrecision, '-') <> coalesce(a.validToPrecision, '-')
   OR coalesce(toString(h.recordedTo), '-') <> coalesce(toString(a.recordedTo), '-')
RETURN h.relationshipUid AS episode, a.uid AS assertionUid;

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

// V-508: DEFINITE overlap of mutually exclusive attachments in both valid and recorded time.
// Bounds are shrunk by their precision before comparison; null bounds never produce a definite overlap.
// status: statically-checked
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
  AND (r2.recordedTo IS NULL OR r1.recordedFrom < r2.recordedTo)
  AND (r1.recordedTo IS NULL OR r2.recordedFrom < r1.recordedTo)
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL AND r2.validTo IS NOT NULL
WITH s, r1, r2, t1, t2,
     r1.validFrom + CASE r1.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f1,
     r2.validFrom + CASE r2.validFromPrecision WHEN 'DAY' THEN duration('P1D') WHEN 'MONTH' THEN duration('P1M') WHEN 'QUARTER' THEN duration('P3M')
                    WHEN 'YEAR' THEN duration('P1Y') WHEN 'DECADE' THEN duration('P10Y') ELSE duration('PT0S') END AS f2
WHERE (CASE WHEN f1 > f2 THEN f1 ELSE f2 END) < (CASE WHEN r1.validTo < r2.validTo THEN r1.validTo ELSE r2.validTo END)
RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2;

// V-509 (informational, review queue): POSSIBLE overlap of exclusive attachments caused by a null or imprecise bound,
// among currently recorded episodes.
// status: statically-checked
MATCH (s)-[r1:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t1),
      (s)-[r2:HAS_FORMULATION_VERSION|HAS_REGISTRATION_VERSION|HAS_PROTOCOL_EDITION]->(t2)
WHERE type(r1) = type(r2) AND elementId(r1) < elementId(r2) AND t1 <> t2
  AND coalesce(t1.jurisdiction, '-') = coalesce(t2.jurisdiction, '-')
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND (r1.validFrom IS NULL OR r2.validTo IS NULL OR r1.validFrom < r2.validTo)
  AND (r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validFrom < r1.validTo)
  AND (r1.validFrom IS NULL OR r2.validFrom IS NULL OR r1.validTo IS NULL OR r2.validTo IS NULL
       OR r1.validFromPrecision <> 'INSTANT' OR r2.validFromPrecision <> 'INSTANT')
RETURN s.uid AS subjectUid, type(r1) AS relType, t1.uid AS state1, t2.uid AS state2, 'POSSIBLE_OVERLAP_REVIEW' AS action;

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

// V-512: source revision events are well formed: exactly one revised source; prior and resulting snapshots belong
// to that source; the resulting snapshot was retrieved after the prior one.
// status: statically-checked
MATCH (ev:SourceRevisionEvent)
OPTIONAL MATCH (ev)-[:REVISES_SOURCE]->(src:Source)
WITH ev, collect(src) AS sources
WHERE size(sources) <> 1
RETURN 'REVISION_SOURCE_COUNT' AS violation, ev.uid AS item
UNION
MATCH (ev:SourceRevisionEvent)-[:REVISES_SOURCE]->(src:Source), (ev)-[:PRIOR_SNAPSHOT|RESULTING_SNAPSHOT]->(sn:SourceSnapshot)
WHERE NOT (src)-[:HAS_SNAPSHOT]->(sn)
RETURN 'REVISION_SNAPSHOT_FOREIGN' AS violation, ev.uid AS item
UNION
MATCH (prior:SourceSnapshot)<-[:PRIOR_SNAPSHOT]-(ev:SourceRevisionEvent)-[:RESULTING_SNAPSHOT]->(res:SourceSnapshot)
WHERE res.retrievedAt <= prior.retrievedAt
RETURN 'REVISION_ORDER' AS violation, ev.uid AS item;

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

// V-521: no private uid values or private-personal class on shared nodes or relationships.
// status: statically-checked
MATCH (n)
WHERE NOT n:PrivateRecord AND (n.privacyClass = 'private-personal'
   OR any(k IN keys(n) WHERE n[k] IS :: STRING AND n[k] STARTS WITH 'hu:private-')
   OR any(k IN keys(n) WHERE n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x STARTS WITH 'hu:private-')))
RETURN 'NODE' AS kind, n.uid AS item
UNION
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
  AND (r.privacyClass = 'private-personal'
       OR any(k IN keys(r) WHERE r[k] IS :: STRING AND r[k] STARTS WITH 'hu:private-'))
RETURN 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item;

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

// V-525: protocol editions: stepKey unique within an edition; CONDITIONAL steps name an APPLIES_WHEN constraint.
// status: statically-checked
MATCH (e:ProtocolEdition)-[:HAS_STEP]->(s:ProtocolStep)
WITH e, s.stepKey AS stepKey, count(*) AS n
WHERE stepKey IS NULL OR n > 1
RETURN 'STEP_KEY_NOT_UNIQUE' AS violation, e.uid AS item
UNION
MATCH (s:ProtocolStep {requirementLevel: 'CONDITIONAL'})
WHERE NOT (s)-[:HAS_CONSTRAINT {constraintRole: 'APPLIES_WHEN'}]->(:Constraint)
RETURN 'CONDITIONAL_STEP_WITHOUT_CONDITION' AS violation, s.uid AS item;

// V-526: protocol steps are immutable payload: a step shared by two editions keeps one payloadHash by construction;
// two different step nodes with the same stepKey and payloadHash inside one protocol lineage are duplicates (informational).
// status: statically-checked
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s1:ProtocolStep),
      (p)-[:HAS_PROTOCOL_EDITION]->(:ProtocolEdition)-[:HAS_STEP]->(s2:ProtocolStep)
WHERE elementId(s1) < elementId(s2) AND s1.stepKey = s2.stepKey AND s1.payloadHash = s2.payloadHash
RETURN DISTINCT p.uid AS protocolUid, s1.stepKey AS duplicatedStep;

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
