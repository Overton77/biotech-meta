// =====================================================================================================================
// W03 validation set. Zero rows = valid unless marked (informational). Sections:
//   A. Repository validators, verbatim (V-112 with W03 parameters substituted; V-230..V-239 unchanged).
//   B. Proposed replacements V-233r / V-234r (seam W03-SR-01 to W00): accept rule-mode citations.
//   C. W03 candidate validators V-W03-01..12.
// status: run (embedded Neo4j 5.26.31 Community), see 06-fixtures-and-queries.md for per-query expected rows.
// =====================================================================================================================

// ---- A. repository validators ----------------------------------------------------------------------------------
// V-112: derived and forbidden-implication edges cite live, matching assertions (QS-4a, zero rows = valid).
// status: statically-checked
// params: ['AFFECTS_MECHANISM', 'MODULATES', 'APPLIES_TO_SPECIES', 'INFLUENCES_OUTCOME', 'ACTS_IN', 'INCREASES_RISK_FOR', 'MEDIATES_RISK_THROUGH', 'ASSOCIATED_WITH_CONDITION', 'ASSOCIATED_WITH_OUTCOME'], [], [] (catalog relationships with ruleOnly: true)
MATCH (x)-[r]->(y)
WHERE type(r) IN ['AFFECTS_MECHANISM', 'MODULATES', 'APPLIES_TO_SPECIES', 'INFLUENCES_OUTCOME', 'ACTS_IN', 'INCREASES_RISK_FOR', 'MEDIATES_RISK_THROUGH', 'ASSOCIATED_WITH_CONDITION', 'ASSOCIATED_WITH_OUTCOME'] OR type(r) IN [p IN [] | p[1]]
WITH x, y, r, coalesce(r.projectionOfAssertionUid, r.assertionUid) AS citedUid
OPTIONAL MATCH (cited:Assertion {uid: citedUid})
WITH x, y, r, citedUid, cited,
     [v IN [
        CASE WHEN citedUid IS NULL AND r.derivationRule IS NULL THEN 'NO_CITATION' END,
        CASE WHEN citedUid IS NOT NULL AND cited IS NULL THEN 'CITED_ASSERTION_MISSING' END,
        CASE WHEN cited IS NOT NULL AND cited.predicate <> type(r) THEN 'CITED_PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
        CASE WHEN cited IS NOT NULL AND any(p IN [] WHERE p[1] = type(r) AND p[0] = cited.predicate) THEN 'FORBIDDEN_IMPLICATION_USED_AS_PREMISE' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) = 0
                  AND size(coalesce(r.derivedFromAssessmentUids, [])) = 0 AND r.hypothesisUid IS NULL
                  AND NOT type(r) IN [] THEN 'DERIVATION_WITHOUT_SOURCE_ASSERTIONS' END,
        CASE WHEN size(coalesce(r.derivedFromAssessmentUids, [])) > size([u IN coalesce(r.derivedFromAssessmentUids, []) WHERE EXISTS { MATCH (:EvidenceAssessment {uid: u}) }])
             THEN 'LICENSING_ASSESSMENT_MISSING' END,
        CASE WHEN r.derivationRule IS NOT NULL AND EXISTS {
               MATCH (inp:Assertion) WHERE inp.uid IN coalesce(r.derivedFromAssertionUids, [])
                 AND any(p IN [] WHERE p[1] = type(r) AND p[0] = inp.predicate)
             } THEN 'FORBIDDEN_IMPLICATION_AMONG_DERIVATION_INPUTS' END,
        CASE WHEN r.derivationRule IS NOT NULL AND size(coalesce(r.derivedFromAssertionUids, [])) >
               size([u IN coalesce(r.derivedFromAssertionUids, []) WHERE EXISTS { MATCH (:Assertion {uid: u}) }])
             THEN 'DERIVATION_INPUT_MISSING' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN type(r) AS edgeType, x.uid AS startUid, y.uid AS endUid, violations;

// V-113: no shared node points at a private node (public/private boundary).

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

// ---- B. proposed replacements --------------------------------------------------------------------------------------

// V-233r (INV-211, FI HYPOTHESIZED_STEP -> MEASURED_STEP): every mechanism projection cites only ACCEPTED, current,
// POSITIVE, DIRECT_MEASUREMENT assertions with exactly one context, through projectionOfAssertionUid or (rule mode
// mx-proj/v1) derivedFromAssertionUids. Replaces V-233, which reads projectionOfAssertionUid only.
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
RETURN type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, violations;

// V-234r (INV-211, FI MEASURED_IN_SPECIES -> APPLIES_IN_OTHER_SPECIES): APPLIES_TO_SPECIES targets a species of the
// context of at least one cited POSITIVE assertion. Replaces V-234.
MATCH (m)-[r:APPLIES_TO_SPECIES]->(sp:Species)
WITH m, r, sp,
     CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
WHERE NOT EXISTS {
  MATCH (a:Assertion)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(sp)
  WHERE a.uid IN cited AND a.polarity = 'POSITIVE'
}
RETURN m.uid AS subjectUid, sp.uid AS speciesWithoutPositiveMeasuredContext, cited;

// ---- C. W03 candidate validators --------------------------------------------------------------------------------

// V-W03-01 (INV-004 endpoint fidelity): an mx-proj/v1 edge's endpoints are the endpoints of every cited assertion
// (AFFECTS_MECHANISM / MODULATES: subject -> object; APPLIES_TO_SPECIES: mechanism is subject or object and species is
// the context species; ACTS_IN: mechanism is subject or object and the site is the context compartment).
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|ACTS_IN|INFLUENCES_OUTCOME]->(y)
WHERE r.derivationRule = 'mx-proj/v1'
UNWIND r.derivedFromAssertionUids AS u
MATCH (a:Assertion {uid: u})
WITH x, r, y, a,
  CASE type(r)
    WHEN 'AFFECTS_MECHANISM' THEN EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } AND EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) }
    WHEN 'MODULATES' THEN EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } AND EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) }
    WHEN 'INFLUENCES_OUTCOME' THEN EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } AND EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) }
    WHEN 'APPLIES_TO_SPECIES' THEN EXISTS { MATCH (a)-[:HAS_SUBJECT|HAS_OBJECT]->(x) } AND EXISTS { MATCH (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:IN_SPECIES]->(y) }
    WHEN 'ACTS_IN' THEN EXISTS { MATCH (a)-[:HAS_SUBJECT|HAS_OBJECT]->(x) } AND EXISTS { MATCH (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:MEASURED_IN]->(y) }
  END AS ok
WHERE NOT ok
RETURN type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, a.uid AS inconsistentInput;

// V-W03-02 (informational, projection freshness): qualifying assertions with a Mechanism object and no AFFECTS_MECHANISM
// edge citing them (the projection job has not run, or the subject is not a material/form/substance).
MATCH (a:Assertion)-[:HAS_OBJECT]->(m:Mechanism)
WHERE a.basisKind = 'DIRECT_MEASUREMENT' AND a.status = 'ACCEPTED' AND a.polarity = 'POSITIVE' AND a.recordedTo IS NULL
  AND NOT EXISTS { MATCH ()-[r:AFFECTS_MECHANISM]->(m) WHERE a.uid IN coalesce(r.derivedFromAssertionUids, []) }
RETURN a.uid AS unprojectedQualifyingAssertion;

// V-W03-03 (FI PROXY_MARKER_CHANGED -> PROCESS_FLUX_CHANGED): a process-level projection (AFFECTS_MECHANISM,
// INFLUENCES_OUTCOME, ACTS_IN, APPLIES_TO_SPECIES) never cites an assertion whose object is a Biomarker or Metric, even
// when that measurand REFLECTS_MECHANISM the target mechanism (readout-of links are curated, never premises).
MATCH (x)-[r:AFFECTS_MECHANISM|INFLUENCES_OUTCOME|ACTS_IN|APPLIES_TO_SPECIES]->(y)
WITH x, r, y, CASE WHEN r.projectionOfAssertionUid IS NOT NULL THEN [r.projectionOfAssertionUid] ELSE coalesce(r.derivedFromAssertionUids, []) END AS cited
MATCH (a:Assertion)-[:HAS_OBJECT]->(o)
WHERE a.uid IN cited AND (o:Biomarker OR o:Metric)
RETURN type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, a.uid AS proxyAssertionUsedAsFlux, o.uid AS proxyMeasurand;

// V-W03-04 (INV-210 refinement): an INFERRED_FROM_MEASUREMENT mechanism assertion names at least one premise through
// DERIVED_FROM_ASSERTION, and every premise is DIRECT_MEASUREMENT (an inference never rests on a hypothesis alone).
MATCH (a:Assertion {basisKind: 'INFERRED_FROM_MEASUREMENT'})
OPTIONAL MATCH (a)-[:DERIVED_FROM_ASSERTION]->(p:Assertion)
WITH a, collect(p) AS premises
WHERE size(premises) = 0 OR any(p IN premises WHERE coalesce(p.basisKind, '') <> 'DIRECT_MEASUREMENT')
RETURN a.uid AS inferenceWithoutMeasuredPremise, size(premises) AS premiseCount;

// V-W03-05 (CL-002 boundary): MolecularEntity is genome-encoded only; small molecules and metabolites are
// ChemicalSubstance. Rows: invalid entityKind, or a MolecularEntity sharing a name with a ChemicalSubstance.
MATCH (me:MolecularEntity)
WHERE NOT coalesce(me.entityKind, 'MISSING') IN ['GENE', 'TRANSCRIPT', 'PROTEIN', 'PROTEIN_COMPLEX', 'PROTEIN_FAMILY', 'NONCODING_RNA']
   OR EXISTS { MATCH (s:ChemicalSubstance) WHERE toLower(s.name) = toLower(me.name) OR toLower(coalesce(s.preferredName, '')) = toLower(me.name) }
RETURN me.uid AS molecularEntityOutsideBoundary, me.entityKind AS entityKind, me.name AS name;

// V-W03-06 (one identity per compartment): Organ nodes carry AnatomicalContext with contextKind ORGAN; no two
// AnatomicalContext nodes share an uberonId; contextKind is a known value.
MATCH (n)
WHERE (n:Organ AND (NOT n:AnatomicalContext OR coalesce(n.contextKind, '') <> 'ORGAN'))
   OR (n:AnatomicalContext AND NOT coalesce(n.contextKind, 'MISSING') IN ['TISSUE', 'CELL_TYPE', 'CELL_LINE', 'SPECIMEN_MATRIX', 'ORGAN', 'SUBCELLULAR'])
   OR (n:AnatomicalContext AND n.uberonId IS NOT NULL AND COUNT { (o:AnatomicalContext) WHERE o.uberonId = n.uberonId } > 1)
RETURN n.uid AS compartmentIdentityViolation, labels(n) AS labels, n.contextKind AS contextKind;

// V-W03-07 (INV-004 one-to-one mode): INCREASES_RISK_FOR, MEDIATES_RISK_THROUGH, ASSOCIATED_WITH_* cite one ACCEPTED,
// current, POSITIVE DIRECT_MEASUREMENT assertion with the same predicate and endpoints.
MATCH (x)-[r:INCREASES_RISK_FOR|MEDIATES_RISK_THROUGH|ASSOCIATED_WITH_CONDITION|ASSOCIATED_WITH_OUTCOME]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.projectionOfAssertionUid})
WITH x, r, y, a
WHERE a IS NULL OR a.predicate <> type(r) OR a.basisKind <> 'DIRECT_MEASUREMENT' OR a.status <> 'ACCEPTED'
   OR coalesce(a.polarity, '') <> 'POSITIVE' OR a.recordedTo IS NOT NULL
   OR NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } OR NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) }
RETURN type(r) AS rel, x.uid AS fromUid, y.uid AS toUid, r.projectionOfAssertionUid AS cited;

// V-W03-08 (classification codes are not keys): no Condition carries an ICD-10 code as a node property; ICD-10-CM
// codes live on Identifier records linked by HAS_IDENTIFIER, and a link to a code that became a header carries validTo.
MATCH (c:Condition)
WHERE c.icd10Code IS NOT NULL OR c.icd10CmCode IS NOT NULL
RETURN c.uid AS conditionWithMaterializedIcd10, coalesce(c.icd10Code, c.icd10CmCode) AS code;

// V-W03-09 (versioned ids are not identity): Pathway.externalId and REACTOME_STID Identifier values carry no version suffix.
MATCH (n)
WHERE (n:Pathway AND n.externalId =~ '.*\\.[0-9]+$')
   OR (n:Identifier AND n.scheme = 'REACTOME_STID' AND n.value =~ '.*\\.[0-9]+$')
RETURN n.uid AS versionedIdUsedAsIdentity, coalesce(n.externalId, n.value) AS value;

// V-W03-10 (informational, curation staleness): curated links whose referenceRevision differs from the revision of the
// pathway's latest capture; review, never auto-rewrite (the old link keeps the revision it was curated from).
MATCH (x)-[r:INVOLVES_PATHWAY|PARTICIPATES_IN]->(p:Pathway)
WHERE r.referenceRevision IS NOT NULL AND p.pathwayRevision IS NOT NULL AND r.referenceRevision <> p.pathwayRevision
RETURN x.uid AS curatedFrom, type(r) AS rel, p.uid AS pathway, r.referenceRevision AS curatedRevision, p.pathwayRevision AS observedRevision;

// V-W03-11 (controlled strings on MechanismEvidenceContext; candidate enums SexScope, ExposureRoute, ExposureStatus).
MATCH (c:MechanismEvidenceContext)
WHERE (c.sexScope IS NOT NULL AND NOT c.sexScope IN ['MALE', 'FEMALE', 'BOTH', 'UNKNOWN'])
   OR (c.route IS NOT NULL AND NOT c.route IN ['ORAL', 'GAVAGE', 'DIET', 'IP', 'IV', 'IN_MEDIUM', 'TOPICAL'])
   OR (c.exposureStatus IS NOT NULL AND NOT c.exposureStatus IN ['NOT_EXTRACTED', 'NOT_REPORTED', 'NOT_APPLICABLE'])
   OR (c.exposureStatus IS NOT NULL AND c.exposureAmount IS NOT NULL)
RETURN c.uid AS contextWithInvalidControlledValue, c.sexScope AS sexScope, c.route AS route, c.exposureStatus AS exposureStatus;

// V-W03-12 (species identity): ncbiTaxonomyId present, numeric and unique.
MATCH (s:Species)
WHERE s.ncbiTaxonomyId IS NULL OR NOT s.ncbiTaxonomyId =~ '[0-9]+'
   OR COUNT { (o:Species) WHERE o.ncbiTaxonomyId = s.ncbiTaxonomyId } > 1
RETURN s.uid AS speciesIdentityViolation, s.ncbiTaxonomyId AS taxon;
