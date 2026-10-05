// CH-W09W10 study-transfer Challenger (Wave 5), run-2026-10-04-fable51-01. Author: Opus 5.5 Challenger W09+W10.
// Target: Neo4j 5.26.31 Community + APOC core, loaded with docs/schema/neo4j/final_biotech_schema_operations.cypher, the six
// translated 0.2.0 fixtures (validation/fixtures-final/) + 99-normalize, then W09 fixtures 01-07 and W10 w10-01..w10-05 in
// their documented order. Validators run after each attack: docs/schema/neo4j/validation.cypher,
// workers/W00/validation-corrections.cypher, workers/W09/fixtures/80-queries.cypher, workers/W10/operations.cypher (Part B),
// params = validation/validation-params.json + workers/W10/fixtures/w10-params.json.
// Protocol: run ONE attack block, run the four validator files, diff against the clean baseline, then run its UNDO block.
// Every block is self-contained (no variable crosses a ';'). Observed results are in CH-W09W10-study-transfer.md.
// Synthetic uids contain 'ch-s-'; after all undos `MATCH (n) WHERE n.uid CONTAINS 'ch-s-' RETURN count(n)` returns 0 (verified).

// =====================================================================================================
// CH-S-01 Product/variant -> Study/StudyResult reverse shortcut
// =====================================================================================================
// CH-S-01a: reverse-direction shortcut "the product was studied" (Product -> Study), reusing the registered asserted type
// STUDIED_IN with a complete asserted_edge profile and its (PROPOSED) authorizing Assertion.
MATCH (p:Product {uid: 'hu:product:elysium-basis'}), (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
CREATE (a:Assertion {uid: 'hu:assertion:ch-s-01-basis-studied-in', id: 'ch-s-01-basis-studied-in', predicate: 'STUDIED_IN', status: 'PROPOSED', polarity: 'POSITIVE',
        recordedAt: datetime('2026-10-04T05:00:00Z'), contentHash: 'sha256:abababababababababababababababababababababababababababababababab', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z')})
CREATE (a)-[:HAS_SUBJECT]->(p), (a)-[:HAS_OBJECT]->(s)
CREATE (p)-[:STUDIED_IN {relationshipUid: 'hu:rel:ch-s-01-product-studied-in', assertionUid: 'hu:assertion:ch-s-01-basis-studied-in',
        recordedFrom: datetime('2026-10-04T05:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(s);
// CH-S-01b: ProductVariant -> StudyResult (the 2016 1X within-arm NAD+ result hung on today's variant), unregistered type.
MATCH (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'}), (r:StudyResult {uid: 'hu:study-result:nct02678611-nad-1x-d30'})
CREATE (v)-[:HAS_CLINICAL_RESULT {relationshipUid: 'hu:rel:ch-s-01-variant-has-result'}]->(r);
// ---- UNDO ----
// CH-S-01 undo
MATCH ()-[r]->() WHERE r.relationshipUid STARTS WITH 'hu:rel:ch-s-01-' DELETE r;
MATCH (n {uid: 'hu:assertion:ch-s-01-basis-studied-in'}) DETACH DELETE n;

// =====================================================================================================
// CH-S-02 study-side records outside the V-201 label set -> commercial identities
// =====================================================================================================
// CH-S-02a: InterventionComponent -USES_INTERVENTION_MATERIAL-> Product (outside the catalog range IngredientMaterial|ProductVariant|ProductLot), full asserted profile.
MATCH (si:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-2x'}), (p:Product {uid: 'hu:product:elysium-basis'})
CREATE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:ch-s-02-2x-basis', id: 'ch-s-02-2x-basis', stateType: 'InterventionComponent',
        payloadHash: 'sha256:abababababababababababababababababababababababababababababababab', createdAt: datetime('2026-10-04T05:00:00Z'), privacyClass: 'PUBLIC',
        quantity: 500.0, unitCode: 'mg/d', quantityBasis: 'PER_DAY', massBasis: 'UNSPECIFIED', quantityStatus: 'REPORTED', verbatimDoseText: '4 NRPT capsules daily'})
CREATE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
CREATE (a:Assertion {uid: 'hu:assertion:ch-s-02-uses-basis', id: 'ch-s-02-uses-basis', predicate: 'USES_INTERVENTION_MATERIAL', status: 'PROPOSED', polarity: 'POSITIVE',
        recordedAt: datetime('2026-10-04T05:00:00Z'), contentHash: 'sha256:abababababababababababababababababababababababababababababababab', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z')})
CREATE (a)-[:HAS_SUBJECT]->(ic), (a)-[:HAS_OBJECT]->(p)
CREATE (ic)-[:USES_INTERVENTION_MATERIAL {relationshipUid: 'hu:rel:ch-s-02-uses-basis', assertionUid: 'hu:assertion:ch-s-02-uses-basis', recordedFrom: datetime('2026-10-04T05:00:00Z'),
        validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(p);
// CH-S-02b: RegistrationVersion -> ProductVariant (registry intervention name resolved to today's variant)
MATCH (rv:RegistrationVersion {uid: 'hu:registration-version:nct02678611-observed-2026-10-03'}), (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
CREATE (rv)-[:LISTS_INTERVENTION {relationshipUid: 'hu:rel:ch-s-02-rv-lists-variant'}]->(v);
// CH-S-02c: Dataset -> Product
MATCH (d:Dataset {uid: 'hu:dataset:nct02678611-participant-data'}), (p:Product {uid: 'hu:product:elysium-basis'})
CREATE (d)-[:ABOUT_PRODUCT {relationshipUid: 'hu:rel:ch-s-02-dataset-about-product'}]->(p);
// CH-S-02d: OutcomeDefinition -> FormulationVersion
MATCH (od:OutcomeDefinition {uid: 'hu:outcome:nct02678611-nad-whole-blood'}), (fv:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'})
CREATE (od)-[:MEASURED_FOR {relationshipUid: 'hu:rel:ch-s-02-outcome-for-formulation'}]->(fv);
// CH-S-02e: Study -> MerchantListing (a commercial identity outside V-201's three labels)
MATCH (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (l:MerchantListing {uid: 'hu:listing:amazon-us-b0fs82b35k'})
CREATE (s)-[:EVALUATED_LISTING {relationshipUid: 'hu:rel:ch-s-02-study-listing'}]->(l);
// ---- UNDO ----
// CH-S-02 undo
MATCH ()-[r]->() WHERE r.relationshipUid STARTS WITH 'hu:rel:ch-s-02-' DELETE r;
MATCH (n) WHERE n.uid IN ['hu:intervention-component:ch-s-02-2x-basis', 'hu:assertion:ch-s-02-uses-basis'] DETACH DELETE n;

// =====================================================================================================
// CH-S-03 2016 as-administered intervention linked as the marketed ProductVariant
// =====================================================================================================
// CH-S-03: the 2016 NRPT 1X intervention linked "as the same" to today's marketed Basis variant. A second component of the
// 1X intervention targets the ProductVariant with asReportedName set (V-202 satisfied); the as-administered material was
// 250 mg/d NR of UNSPECIFIED mass basis in gelatin capsules, while the variant's current formulation (2026-07-10) declares
// NR chloride in hypromellose capsules. Valid time of the use is the 2016 conduct window.
MATCH (si:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-1x'}), (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
CREATE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:ch-s-03-1x-as-basis', id: 'ch-s-03-1x-as-basis', stateType: 'InterventionComponent',
        payloadHash: 'sha256:abababababababababababababababababababababababababababababababab', createdAt: datetime('2026-10-04T05:00:00Z'), privacyClass: 'PUBLIC',
        quantity: 250.0, unitCode: 'mg/d', quantityBasis: 'PER_DAY', massBasis: 'UNSPECIFIED', quantityStatus: 'REPORTED', verbatimDoseText: '2 NRPT capsules + 2 placebo capsules daily'})
CREATE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
CREATE (a:Assertion {uid: 'hu:assertion:ch-s-03-1x-uses-basis-variant', id: 'ch-s-03-1x-uses-basis-variant', predicate: 'USES_INTERVENTION_MATERIAL', status: 'PROPOSED', polarity: 'POSITIVE',
        recordedAt: datetime('2026-10-04T05:00:00Z'), contentHash: 'sha256:abababababababababababababababababababababababababababababababab', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'),
        validFrom: datetime('2016-01-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE',
        validTo: datetime('2016-08-01T00:00:00Z'), validToPrecision: 'MONTH', validToBasis: 'STATED_BY_SOURCE'})
CREATE (a)-[:HAS_SUBJECT]->(ic), (a)-[:HAS_OBJECT]->(v)
CREATE (ic)-[:USES_INTERVENTION_MATERIAL {relationshipUid: 'hu:rel:ch-s-03-1x-uses-basis-variant', assertionUid: 'hu:assertion:ch-s-03-1x-uses-basis-variant',
        recordedFrom: datetime('2026-10-04T05:00:00Z'), validFrom: datetime('2016-01-01T00:00:00Z'), validFromPrecision: 'MONTH', validFromBasis: 'STATED_BY_SOURCE',
        validTo: datetime('2016-08-01T00:00:00Z'), validToPrecision: 'MONTH', validToBasis: 'STATED_BY_SOURCE',
        asReportedName: 'NRPT (commercially known as Basis)'}]->(v);
// ---- UNDO ----
// CH-S-03 undo
MATCH (n) WHERE n.uid IN ['hu:intervention-component:ch-s-03-1x-as-basis', 'hu:assertion:ch-s-03-1x-uses-basis-variant'] DETACH DELETE n;

// =====================================================================================================
// CH-S-04 applicability without dimension records; flat-field divergence
// =====================================================================================================
// CH-S-04a: ACCEPTED EvidenceApplicability with one evidence target and one use target but NO dimension records, while its
// derived flat fields (read-only in GraphQL, writable in Cypher) say MATCH.
MATCH (si:StudyIntervention {uid: 'hu:study-intervention:nct02678611-nrpt-2x'}), (fv:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'})
CREATE (ea:EvidenceApplicability:EvidenceAssessment {uid: 'hu:applicability:ch-s-04-2x-to-basis-no-dimensions', id: 'ch-s-04-2x-to-basis-no-dimensions',
        assessmentType: 'EvidenceApplicability', methodVersion: 'applicability-v0.2-candidate', status: 'ACCEPTED', privacyClass: 'PUBLIC',
        recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'),
        identityMatch: 'MATCH', doseMatch: 'MATCH', routeMatch: 'MATCH', scheduleMatch: 'MATCH', durationMatch: 'MATCH', populationMatch: 'MATCH', outcomeMatch: 'MATCH',
        summary: 'Applies.'})
CREATE (ea)-[:HAS_EVIDENCE_TARGET]->(si), (ea)-[:ASSESSES_APPLICABILITY_TO]->(fv);
// CH-S-04b: flat-field divergence on the W10 v2 assessment: dimension nodes say DOSE PARTIAL and MATERIAL_IDENTITY UNKNOWN,
// the filterable flat projection now says MATCH (original values restored by the undo).
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'})
SET ea.doseMatch = 'MATCH', ea.identityMatch = 'MATCH';
// ---- UNDO ----
// CH-S-04 undo
MATCH (n {uid: 'hu:applicability:ch-s-04-2x-to-basis-no-dimensions'}) DETACH DELETE n;
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'}) SET ea.doseMatch = 'PARTIAL', ea.identityMatch = 'UNKNOWN';

// =====================================================================================================
// CH-S-05 applicability evidence target = whole Study
// =====================================================================================================
// CH-S-05: applicability at whole-Study granularity: evidence target is the Study (1X 250 mg/d AND 2X 500 mg/d arms) rather
// than one StudyIntervention; the 13 dimension nodes are copied from the W10 1X assessment (so every required dimension is
// present, with its provenance edges). Status ACCEPTED.
MATCH (src:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'})-[:ASSESSES_APPLICABILITY_TO]->(ut)
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
CREATE (ea:EvidenceApplicability:EvidenceAssessment)
SET ea = apoc.map.merge(properties(src), {uid: 'hu:applicability:ch-s-05-whole-study-to-basis', id: 'ch-s-05-whole-study-to-basis',
    recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'), status: 'ACCEPTED'})
CREATE (ea)-[:HAS_EVIDENCE_TARGET]->(st), (ea)-[:ASSESSES_APPLICABILITY_TO]->(ut);
MATCH (src:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'})-[:HAS_DIMENSION]->(d)
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:ch-s-05-whole-study-to-basis'})
CREATE (nd:ApplicabilityDimension:EvidenceAssessment)
SET nd = apoc.map.merge(properties(d), {uid: 'hu:applicability-dimension:ch-s-05-' + toLower(d.dimension), id: 'ch-s-05-' + toLower(d.dimension),
    recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z')})
CREATE (ea)-[:HAS_DIMENSION]->(nd)
WITH d, nd
MATCH (d)-[r]->(x) WHERE type(r) IN ['SUPPORTED_BY', 'CONSIDERS', 'CONSIDERS_ASSESSMENT']
CALL apoc.create.relationship(nd, type(r), properties(r), x) YIELD rel
RETURN count(rel) AS copiedProvenanceEdges;
// ---- UNDO ----
// CH-S-05 undo
MATCH (n) WHERE n.uid STARTS WITH 'hu:applicability-dimension:ch-s-05-' OR n.uid = 'hu:applicability:ch-s-05-whole-study-to-basis' DETACH DELETE n;

// =====================================================================================================
// CH-S-06 surrogate transfer (cross-analyte context; biomarker -> clinical-outcome claim)
// =====================================================================================================
// CH-S-06a: surrogate status transferred across analytes and contexts. The NRPT trial's whole-blood NAD+ outcome is
// classified SURROGATE_ENDPOINT / VALIDATED / contextMatch FULL by "comparing" it with the FDA LDL-C hypercholesterolemia
// context (a different biomarker, disease and mechanism), citing the FDA LDL-C table row.
MATCH (od:OutcomeDefinition {uid: 'hu:outcome:nct02678611-nad-whole-blood'}),
      (ldl:EndpointClassification {uid: 'hu:endpoint-classification:w10-ldl-c-fda-hypercholesterolemia-lipid-lowering-v2'}),
      (loc:SourceLocator {uid: 'hu:locator:fda-surrogate-table-2026-10-04-hypercholesterolemia-row'})
CREATE (ec:EndpointClassification:EvidenceAssessment {uid: 'hu:endpoint-classification:ch-s-06-nad-as-validated-surrogate', id: 'ch-s-06-nad-as-validated-surrogate',
        assessmentType: 'EndpointClassification', methodVersion: 'endpoint-class-v0.1', status: 'ACCEPTED', privacyClass: 'PUBLIC',
        recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'),
        endpointClass: 'SURROGATE_ENDPOINT', surrogateValidationLevel: 'VALIDATED', contextMatch: 'FULL',
        contextDiseaseOrUse: 'Hypercholesterolemia', contextInterventionMechanism: 'Lipid-lowering', contextApprovalType: 'TRADITIONAL',
        contextPopulation: 'Healthy older adults', rationale: 'Copied from the FDA table context.'})
CREATE (ec)-[:CLASSIFIES_OUTCOME]->(od), (ec)-[:COMPARED_WITH_CONTEXT]->(ldl), (ec)-[:SUPPORTED_BY]->(loc);
// CH-S-06b: a biomarker (LDL-C, BIOMARKER_NOT_SURROGATE in this trial) result is the only CONFIRMATORY input to a CLINICAL
// OUTCOME claim ("reduces cardiovascular events"); verdict SUPPORTED, status ACCEPTED.
MATCH (r:StudyResult {uid: 'hu:study-result:nct02678611-ldl-1x-vs-placebo-d60'})
CREATE (c:Claim:Entity {uid: 'hu:claim:ch-s-06-nrpt-reduces-cardiovascular-events', id: 'ch-s-06-nrpt-reduces-cardiovascular-events', entityType: 'Claim',
        privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), claimText: 'NRPT reduces cardiovascular events in older adults'})
CREATE (s:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ch-s-06-nrpt-cv-events-v1', id: 'ch-s-06-nrpt-cv-events-v1', assessmentType: 'EvidenceSynthesis',
        methodVersion: 'synthesis-v0.1', status: 'ACCEPTED', privacyClass: 'PUBLIC', verdict: 'SUPPORTED',
        recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'),
        claimText: 'NRPT reduces cardiovascular events in older adults', rationale: 'LDL-C lowered vs placebo.'})
CREATE (s)-[:ASSESSES_CLAIM]->(c), (s)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r);
// ---- UNDO ----
// CH-S-06 undo
MATCH (n) WHERE n.uid IN ['hu:endpoint-classification:ch-s-06-nad-as-validated-surrogate', 'hu:claim:ch-s-06-nrpt-reduces-cardiovascular-events', 'hu:synthesis:ch-s-06-nrpt-cv-events-v1'] DETACH DELETE n;

// =====================================================================================================
// CH-S-07 null primary, favorable secondary promoted into the synthesis verdict
// =====================================================================================================
// CH-S-07: null-primary promotion into the verdict. A correctly versioned v2 of the W10 ATLAS synthesis keeps every input
// role legal (null primary CONFIRMATORY, favorable secondary SUPPORTIVE, post hoc subgroup HYPOTHESIS_GENERATING) but
// flips the verdict INSUFFICIENT -> SUPPORTED, TRIGGERED_BY the favorable secondary, and is ACCEPTED.
MATCH (v1:EvidenceSynthesis {uid: 'hu:synthesis:w10-ua-muscle-function-middle-aged-v1'})-[:ASSESSES_CLAIM]->(c)
MATCH (h:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'})
CREATE (v2:EvidenceSynthesis:EvidenceAssessment)
SET v2 = apoc.map.merge(properties(v1), {uid: 'hu:synthesis:ch-s-07-ua-muscle-function-v2', id: 'ch-s-07-ua-muscle-function-v2', status: 'ACCEPTED',
    verdict: 'SUPPORTED', recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'),
    rationale: 'Muscle strength improved significantly vs placebo; urolithin A improves muscle function.'})
CREATE (v2)-[:ASSESSES_CLAIM]->(c)
CREATE (v2)-[:SUPERSEDES {supersessionKind: 'RE_REVIEW', recordedAt: datetime('2026-10-04T05:00:00Z')}]->(v1)
CREATE (v2)-[:TRIGGERED_BY {criterionCode: 'SECONDARY_ENDPOINT_SIGNIFICANT', effectOnVerdict: 'STRENGTHENED'}]->(h)
SET v1.recordedTo = datetime('2026-10-04T05:00:00Z'), v1.status = 'SUPERSEDED'
WITH v1, v2
MATCH (v1)-[i:INCLUDES_RESULT]->(r)
CREATE (v2)-[:INCLUDES_RESULT {inputRole: i.inputRole}]->(r);
// ---- UNDO ----
// CH-S-07 undo
MATCH (n {uid: 'hu:synthesis:ch-s-07-ua-muscle-function-v2'}) DETACH DELETE n;
MATCH (v1:EvidenceSynthesis {uid: 'hu:synthesis:w10-ua-muscle-function-middle-aged-v1'}) SET v1.status = 'PROPOSED' REMOVE v1.recordedTo;

// =====================================================================================================
// CH-S-08 INV-206 bypass: Assertion-wrapped secondary; analysisKind null
// =====================================================================================================
// CH-S-08a: INV-206 bypass by wrapping. The favorable secondary (ATLAS hamstring, after the null primary) enters a synthesis
// as CONFIRMATORY through an Assertion that reports it (SynthesisInputTarget = StudyResult | Assertion).
MATCH (h:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'}), (c:Claim {uid: 'hu:claim:w10-ua-improves-muscle-function-middle-aged'})
CREATE (a:Assertion {uid: 'hu:assertion:ch-s-08-hamstring-strength-improved', id: 'ch-s-08-hamstring-strength-improved', predicate: 'REPORTS_RESULT', status: 'PROPOSED',
        polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T05:00:00Z'), contentHash: 'sha256:abababababababababababababababababababababababababababababababab',
        privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), valueString: 'UA improved hamstring strength vs placebo'})
CREATE (a)-[:HAS_SUBJECT]->(h)
CREATE (s:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ch-s-08-ua-muscle-function-wrapped', id: 'ch-s-08-ua-muscle-function-wrapped', assessmentType: 'EvidenceSynthesis',
        methodVersion: 'synthesis-v0.1', status: 'ACCEPTED', privacyClass: 'PUBLIC', verdict: 'SUPPORTED',
        recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'), claimText: c.claimText})
CREATE (s)-[:ASSESSES_CLAIM]->(c), (s)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(a);
// CH-S-08b: same study, a favorable secondary between-arm result whose analysisKind was never captured (null), entered as
// CONFIRMATORY beside the null primary.
MATCH (od:OutcomeDefinition {uid: 'hu:outcome:atlas-isokinetic-strength-d120'}), (s:EvidenceSynthesis {uid: 'hu:synthesis:ch-s-08-ua-muscle-function-wrapped'}),
      (p:StudyResult {uid: 'hu:study-result:atlas-power-ua-vs-placebo-d120'})
CREATE (r:StudyResult:InformationArtifact {uid: 'hu:study-result:ch-s-08-atlas-knee-extension-unlabelled', id: 'ch-s-08-atlas-knee-extension-unlabelled',
        artifactType: 'StudyResult', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'),
        comparisonKind: 'BETWEEN_ARM', statisticalConclusion: 'SIGNIFICANT_FAVORABLE', isStatisticallySignificant: true, resultText: 'knee extension strength improved vs placebo'})
CREATE (r)-[:RESULT_FOR]->(od)
CREATE (s)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r), (s)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(p);
// ---- UNDO ----
// CH-S-08 undo
MATCH (n) WHERE n.uid IN ['hu:assertion:ch-s-08-hamstring-strength-improved', 'hu:synthesis:ch-s-08-ua-muscle-function-wrapped', 'hu:study-result:ch-s-08-atlas-knee-extension-unlabelled'] DETACH DELETE n;

// =====================================================================================================
// CH-S-09 dataset non-independence counted as INDEPENDENT_REPLICATION
// =====================================================================================================
// CH-S-09 setup: a reanalysis study B of the NCT00938340 walnut dataset, two third-party-cohort studies C and D that both
// analyse one biobank dataset produced by neither, their publications, outcome definitions and between-arm results.
CREATE (b:Study:Entity {uid: 'hu:study:ch-s-09-walnut-reanalysis', id: 'ch-s-09-walnut-reanalysis', entityType: 'Study', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), name: 'Reanalysis of NCT00938340 sera'})
CREATE (c:Study:Entity {uid: 'hu:study:ch-s-09-cohort-c', id: 'ch-s-09-cohort-c', entityType: 'Study', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), name: 'Biobank analysis C'})
CREATE (d:Study:Entity {uid: 'hu:study:ch-s-09-cohort-d', id: 'ch-s-09-cohort-d', entityType: 'Study', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), name: 'Biobank analysis D'})
CREATE (bb:Dataset:Entity {uid: 'hu:dataset:ch-s-09-biobank', id: 'ch-s-09-biobank', entityType: 'Dataset', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), name: 'Third-party biobank release 1'})
WITH b, c, d
UNWIND [['pub-b', 'Reanalysis of walnut sera'], ['pub-c', 'Biobank analysis C'], ['pub-d', 'Biobank analysis D']] AS p
CREATE (:Publication:InformationArtifact {uid: 'hu:publication:ch-s-09-' + p[0], id: 'ch-s-09-' + p[0], artifactType: 'Publication', publicationKind: 'ARTICLE', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), name: p[1]});
UNWIND [['hu:study:ch-s-09-walnut-reanalysis', 'hu:outcome:ch-s-09-b-rhi'], ['hu:study:ch-s-09-cohort-c', 'hu:outcome:ch-s-09-c-ldl'], ['hu:study:ch-s-09-cohort-d', 'hu:outcome:ch-s-09-d-ldl']] AS x
MATCH (s:Study {uid: x[0]})
CREATE (od:OutcomeDefinition:VersionedState {uid: x[1], id: split(x[1], ':')[2], stateType: 'OutcomeDefinition', payloadHash: 'sha256:abababababababababababababababababababababababababababababababab', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), measureKind: 'BIOMARKER'})
CREATE (s)-[:DEFINES_OUTCOME]->(od);
UNWIND [['hu:study-result:aaa-ch-s-09-reanalysis-rhi', 'hu:outcome:ch-s-09-b-rhi'],
        ['hu:study-result:zzz-ch-s-09-walnut-rhi-between', 'hu:outcome:nct00938340-rhi-240min'],
        ['hu:study-result:aa0-ch-s-09-walnut-rhi-ctrl', 'hu:outcome:nct00938340-rhi-240min'],
        ['hu:study-result:aab-ch-s-09-reanalysis-rhi-ctrl', 'hu:outcome:ch-s-09-b-rhi'],
        ['hu:study-result:ch-s-09-c-ldl', 'hu:outcome:ch-s-09-c-ldl'],
        ['hu:study-result:ch-s-09-d-ldl', 'hu:outcome:ch-s-09-d-ldl']] AS x
MATCH (od:OutcomeDefinition {uid: x[1]})
CREATE (r:StudyResult:InformationArtifact {uid: x[0], id: split(x[0], ':')[2], artifactType: 'StudyResult', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'),
        analysisKind: 'PRIMARY_PRESPECIFIED', comparisonKind: 'BETWEEN_ARM', statisticalConclusion: 'SIGNIFICANT_FAVORABLE', isStatisticallySignificant: true})
CREATE (r)-[:RESULT_FOR]->(od);
// asserted edges with full profile and authorizing assertions
UNWIND [{k: 'b-reports', f: 'hu:publication:ch-s-09-pub-b', t: 'hu:study:ch-s-09-walnut-reanalysis', ty: 'REPORTS_ON', x: {}},
        {k: 'b-analyzes', f: 'hu:publication:ch-s-09-pub-b', t: 'hu:dataset:nct00938340-participant-data-and-sera', ty: 'ANALYZES_DATASET', x: {analysisRole: 'REANALYSIS'}},
        {k: 'c-reports', f: 'hu:publication:ch-s-09-pub-c', t: 'hu:study:ch-s-09-cohort-c', ty: 'REPORTS_ON', x: {}},
        {k: 'c-analyzes', f: 'hu:publication:ch-s-09-pub-c', t: 'hu:dataset:ch-s-09-biobank', ty: 'ANALYZES_DATASET', x: {analysisRole: 'SECONDARY_ANALYSIS'}},
        {k: 'd-reports', f: 'hu:publication:ch-s-09-pub-d', t: 'hu:study:ch-s-09-cohort-d', ty: 'REPORTS_ON', x: {}},
        {k: 'd-analyzes', f: 'hu:publication:ch-s-09-pub-d', t: 'hu:dataset:ch-s-09-biobank', ty: 'ANALYZES_DATASET', x: {analysisRole: 'SECONDARY_ANALYSIS'}}] AS e
MATCH (x {uid: e.f}), (y {uid: e.t})
CREATE (a:Assertion {uid: 'hu:assertion:ch-s-09-' + e.k, id: 'ch-s-09-' + e.k, predicate: e.ty, status: 'PROPOSED', polarity: 'POSITIVE', recordedAt: datetime('2026-10-04T05:00:00Z'),
        contentHash: 'sha256:abababababababababababababababababababababababababababababababab', privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z')})
CREATE (a)-[:HAS_SUBJECT]->(x), (a)-[:HAS_OBJECT]->(y)
WITH a, x, y, e
CALL apoc.create.relationship(x, e.ty, apoc.map.merge({relationshipUid: 'hu:rel:ch-s-09-' + e.k, assertionUid: a.uid, recordedFrom: datetime('2026-10-04T05:00:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}, e.x), y) YIELD rel
RETURN count(rel) AS edges;
// CH-S-09a: walnut dataset counted twice as INDEPENDENT_REPLICATION; the analyser-side result has the smaller uid.
// CH-S-09a-control: the same pair with the producer-side result holding the smaller uid.
// CH-S-09b: two analyses of one third-party biobank dataset counted as INDEPENDENT_REPLICATION.
UNWIND [['hu:synthesis:ch-s-09a-walnut-replication', ['hu:study-result:aaa-ch-s-09-reanalysis-rhi', 'hu:study-result:zzz-ch-s-09-walnut-rhi-between']],
        ['hu:synthesis:ch-s-09a-control', ['hu:study-result:aa0-ch-s-09-walnut-rhi-ctrl', 'hu:study-result:aab-ch-s-09-reanalysis-rhi-ctrl']],
        ['hu:synthesis:ch-s-09b-biobank-replication', ['hu:study-result:ch-s-09-c-ldl', 'hu:study-result:ch-s-09-d-ldl']]] AS x
CREATE (s:EvidenceSynthesis:EvidenceAssessment {uid: x[0], id: split(x[0], ':')[2], assessmentType: 'EvidenceSynthesis', methodVersion: 'synthesis-v0.1', status: 'ACCEPTED',
        privacyClass: 'PUBLIC', verdict: 'SUPPORTED', recordedAt: datetime('2026-10-04T05:00:00Z'), createdAt: datetime('2026-10-04T05:00:00Z'), rationale: 'Replicated in two independent studies.'})
WITH s, x UNWIND x[1] AS ru
MATCH (r:StudyResult {uid: ru})
CREATE (s)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r);
// ---- UNDO ----
// CH-S-09 undo
MATCH ()-[r]->() WHERE r.relationshipUid STARTS WITH 'hu:rel:ch-s-09-' DELETE r;
MATCH (n) WHERE n.uid CONTAINS 'ch-s-09' DETACH DELETE n;

// =====================================================================================================
// CH-S-10a post-cutover EVALUATES / LEGACY_EVALUATES writes (run 10b next, then the undo)
// =====================================================================================================
// CH-S-10a: new (post-cutover) writes of the live study edge. (i) Study -EVALUATES-> IngredientMaterial with live
// InterventionArmMetadata; (ii) Study -LEGACY_EVALUATES-> IngredientMaterial written directly today (the stored legacy type
// is read-only in GraphQL but not in Cypher); (iii) control: Study -EVALUATES-> Product.
MATCH (s:Study {uid: 'hu:study:nct03464500-atlas'}), (m:IngredientMaterial {uid: 'hu:material:amazentis-mitopure-as-administered-atlas'})
CREATE (s)-[:EVALUATES {armLabel: 'UA 500 mg', interventionRole: 'EXPERIMENTAL', doseAmount: 500.0, doseUnit: 'mg', confidence: 0.9, mongoResearchRunId: 'ch-s-10-run'}]->(m);
MATCH (s:Study {uid: 'hu:study:nct03283462-energize'}), (m:IngredientMaterial {uid: 'hu:material:amazentis-mitopure-as-administered-atlas'})
CREATE (s)-[:LEGACY_EVALUATES {armLabel: 'UA 1000 mg', doseAmount: 1000.0, doseUnit: 'mg', mongoResearchRunId: 'ch-s-10-run'}]->(m);
MATCH (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (p:Product {uid: 'hu:product:elysium-basis'})
CREATE (s)-[:EVALUATES {armLabel: 'NRPT 1X', doseAmount: 250.0, doseUnit: 'mg', mongoResearchRunId: 'ch-s-10-run'}]->(p);

// =====================================================================================================
// CH-S-10b laundering through operations-file statement 6a
// =====================================================================================================
// CH-S-10b: re-run the final operations file statement 6a (verbatim) after CH-S-10a: today's EVALUATES writes are laundered
// into LEGACY_EVALUATES, indistinguishable from migrated live edges (no recordedFrom on LegacyInterventionArmProperties).
MATCH (a:Study)-[r:EVALUATES]->(b) CREATE (a)-[n:LEGACY_EVALUATES]->(b) SET n = properties(r) DELETE r;
// ---- UNDO ----
// CH-S-10a/b undo
MATCH (:Study)-[r:EVALUATES|LEGACY_EVALUATES]->() WHERE r.mongoResearchRunId = 'ch-s-10-run' DELETE r;

// =====================================================================================================
// CH-S-11 derived SPONSORED_BY / OPERATED_BY with fabricated or wrong-premise citations
// =====================================================================================================
// CH-S-11a: derived SPONSORED_BY written by Cypher citing an assertion uid that does not exist.
MATCH (s:Study {uid: 'hu:study:nct02582593-tnirs-older-adults'}), (o:Organization {uid: 'hu:org:elysium-health-inc'})
CREATE (s)-[:SPONSORED_BY {derivationRule: 'inverse-of:SPONSORS_STUDY@1', derivedFromAssertionUids: ['hu:assertion:ch-s-11-does-not-exist'], derivedAt: datetime('2026-10-04T05:00:00Z'), mongoResearchRunId: 'ch-s-11-run'}]->(o);
// CH-S-11b: derived SPONSORED_BY whose cited premise is an ADVISES_ORGANIZATION assertion about a different subject/object
// (advising never implies sponsorship).
MATCH (s:Study {uid: 'hu:study:nct03816020-nadpark'}), (o:Organization {uid: 'hu:org:segterra'})
CREATE (s)-[:SPONSORED_BY {derivationRule: 'inverse-of:SPONSORS_STUDY@1', derivedFromAssertionUids: ['hu:assertion:affiliations-sinclair-advisor-insidetracker-2011-open'], derivedAt: datetime('2026-10-04T05:00:00Z'), mongoResearchRunId: 'ch-s-11-run'}]->(o);
// CH-S-11c: OPERATED_BY rule-only (no inputs at all) - control for V-W09-11.
MATCH (s:Study {uid: 'hu:study:nct03816020-nadpark'}), (o:Organization {uid: 'hu:org:segterra'})
CREATE (s)-[:OPERATED_BY {derivationRule: 'inverse-of:SERVES_AS_CRO_FOR@1', derivedAt: datetime('2026-10-04T05:00:00Z'), mongoResearchRunId: 'ch-s-11-run'}]->(o);
// ---- UNDO ----
// CH-S-11 undo
MATCH (:Study)-[r:SPONSORED_BY|OPERATED_BY]->() WHERE r.mongoResearchRunId = 'ch-s-11-run' DELETE r;

// =====================================================================================================
// CH-S-12a overlapping RegistrationVersion episodes
// =====================================================================================================
// CH-S-12a: overlapping registry version: v3 of DEMO-001 attached valid from 2026-08-01 (open) while v2 is valid from
// 2026-08-15 (open) in the same current recorded episode.
MATCH (r:TrialRegistration {uid: 'hu:trial-registration:synthetic-demo-001'})
CREATE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:ch-s-12-demo-001-v3', id: 'ch-s-12-demo-001-v3', artifactType: 'RegistrationVersion',
        privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), observedAt: datetime('2026-10-04T05:00:00Z'),
        contentHash: 'sha256:abababababababababababababababababababababababababababababababab', overallStatus: 'ACTIVE_NOT_RECRUITING', registryVersionNumber: 3})
CREATE (r)-[:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:ch-s-12-hrv-v3', validFrom: datetime('2026-08-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE',
        validToBasis: 'UNKNOWN', recordedFrom: datetime('2026-10-04T05:00:00Z')}]->(rv);
// ---- UNDO ----
// CH-S-12a undo
MATCH (n {uid: 'hu:registration-version:ch-s-12-demo-001-v3'}) DETACH DELETE n;

// =====================================================================================================
// CH-S-12b backdated RegistrationVersion episode
// =====================================================================================================
// CH-S-12b (isolated on its own synthetic registration DEMO-002): backdated registry version: recorded from 2020-01-01 although the version was first observed 2026-10-04 (recorded
// time earlier than the observation that produced it), and the version's own observedAt in the future.
CREATE (r:TrialRegistration:Entity {uid: 'hu:trial-registration:ch-s-12-demo-002', id: 'ch-s-12-demo-002', entityType: 'TrialRegistration', privacyClass: 'PUBLIC',
        createdAt: datetime('2026-10-04T05:00:00Z'), registry: 'SYNTHETIC', registrationId: 'DEMO-002'})
CREATE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:ch-s-12-demo-001-v0', id: 'ch-s-12-demo-001-v0', artifactType: 'RegistrationVersion',
        privacyClass: 'PUBLIC', createdAt: datetime('2026-10-04T05:00:00Z'), observedAt: datetime('2027-01-01T00:00:00Z'),
        contentHash: 'sha256:abababababababababababababababababababababababababababababababab', overallStatus: 'NOT_YET_RECRUITING', registryVersionNumber: 0})
CREATE (r)-[:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:ch-s-12-hrv-v0', validFrom: datetime('2015-01-01T00:00:00Z'), validFromPrecision: 'DAY', validFromBasis: 'STATED_BY_SOURCE',
        validTo: datetime('2015-06-01T00:00:00Z'), validToPrecision: 'DAY', validToBasis: 'STATED_BY_SOURCE', recordedFrom: datetime('2020-01-01T00:00:00Z')}]->(rv);
// ---- UNDO ----
// CH-S-12b undo
MATCH (n) WHERE n.uid IN ['hu:registration-version:ch-s-12-demo-001-v0', 'hu:trial-registration:ch-s-12-demo-002'] DETACH DELETE n;

// =====================================================================================================
// CH-S-13 OutcomeDefinition reused across studies
// =====================================================================================================
// CH-S-13: one OutcomeDefinition reused across studies with different instruments. ENERGIZE (hand-grip/FDI endurance) now
// DEFINES the ATLAS peak-power OutcomeDefinition (Biodex), and the ATLAS outcome gets a second, different instrument metric.
MATCH (s:Study {uid: 'hu:study:nct03283462-energize'}), (od:OutcomeDefinition {uid: 'hu:outcome:atlas-power-output-d120'})
CREATE (s)-[:DEFINES_OUTCOME {notes: 'ch-s-13'}]->(od);
// ---- UNDO ----
// CH-S-13 undo
MATCH (:Study {uid: 'hu:study:nct03283462-energize'})-[r:DEFINES_OUTCOME {notes: 'ch-s-13'}]->() DELETE r;

// =====================================================================================================
// CH-S-14 synthesis versions that do not supersede / do not close the older version
// =====================================================================================================
// CH-S-14a: a newer synthesis of the vitamin D claim that does NOT supersede v3: ACCEPTED, later recordedAt, no SUPERSEDES,
// no TRIGGERED_BY -> two current ACCEPTED verdicts (INSUFFICIENT and SUPPORTED) for one claim.
MATCH (c:Claim {uid: 'hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection'}), (a:Assertion {uid: 'hu:assertion:w10-pmid33798465-pooled-or-any-ari'})
CREATE (s:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ch-s-14-vitamin-d-ari-v4-orphan', id: 'ch-s-14-vitamin-d-ari-v4-orphan', assessmentType: 'EvidenceSynthesis',
        methodVersion: 'synthesis-v0.1', status: 'ACCEPTED', privacyClass: 'PUBLIC', verdict: 'SUPPORTED', recordedAt: datetime('2026-10-04T05:00:00Z'),
        createdAt: datetime('2026-10-04T05:00:00Z'), claimText: c.claimText, rationale: 'OR 0.92.'})
CREATE (s)-[:ASSESSES_CLAIM]->(c), (s)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(a);
// CH-S-14b: a newer version that SUPERSEDES v3 but leaves v3 open (recordedTo null) and ACCEPTED.
MATCH (c:Claim {uid: 'hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection'}), (v3:EvidenceSynthesis {uid: 'hu:synthesis:w10-vitamin-d-ari-prevention-v3'})
CREATE (s:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:ch-s-14-vitamin-d-ari-v4-unclosed', id: 'ch-s-14-vitamin-d-ari-v4-unclosed', assessmentType: 'EvidenceSynthesis',
        methodVersion: 'synthesis-v0.1', status: 'ACCEPTED', privacyClass: 'PUBLIC', verdict: 'CONTRADICTED', recordedAt: datetime('2026-10-04T05:01:00Z'),
        createdAt: datetime('2026-10-04T05:01:00Z'), claimText: c.claimText, rationale: 'Re-review.'})
CREATE (s)-[:ASSESSES_CLAIM]->(c), (s)-[:SUPERSEDES {supersessionKind: 'RE_REVIEW', recordedAt: datetime('2026-10-04T05:01:00Z')}]->(v3);
// ---- UNDO ----
// CH-S-14 undo
MATCH (n) WHERE n.uid IN ['hu:synthesis:ch-s-14-vitamin-d-ari-v4-orphan', 'hu:synthesis:ch-s-14-vitamin-d-ari-v4-unclosed'] DETACH DELETE n;

// =====================================================================================================
// CH-S-16 personal data in a shared UseContextProfile
// =====================================================================================================
// CH-S-16: a "non-personal" UseContextProfile that is one person's profile: only allowed keys, but the free-text descriptors
// carry a name, a birth date, a lab value and an embedded private uid (not at the start of the string). It is the use
// context of a shared applicability assessment.
CREATE (p:UseContextProfile:Entity {uid: 'hu:use-profile:ch-s-16-one-person', id: 'ch-s-16-one-person', entityType: 'UseContextProfile', privacyClass: 'PUBLIC',
        createdAt: datetime('2026-10-04T05:00:00Z'), name: 'Use profile',
        populationDescriptor: 'Jane Q. Example, born 1971-03-02, HbA1c 6.1% (user hu:private-user-context:ch-s-16)',
        doseDescriptor: '250 mg/day as she currently takes it', servingsPerDay: 1.0});
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:w10-nct02678611-1x-to-basis-current-v2'}), (p:UseContextProfile {uid: 'hu:use-profile:ch-s-16-one-person'})
CREATE (ea)-[:FOR_USE_CONTEXT]->(p);
// ---- UNDO ----
// CH-S-16 undo
MATCH (n {uid: 'hu:use-profile:ch-s-16-one-person'}) DETACH DELETE n;

// =====================================================================================================
// GraphQL write attempts (CH-S-03b, CH-S-04c, CH-S-10c, CH-S-14c, CH-S-15). Run with
//   node roundtrip.mjs docs/schema/final_biotech_schema_proposal.graphql <bolt.uri> ch-s-gql-ops.json
// The JSON list is reproduced below as comments, one operation per line, with the observed result.
// =====================================================================================================
// CH-S-10c GQL-01 updateStudies connect evaluates (LEGACY_EVALUATES)
//   mutation { updateStudies(where: { uid: { eq: "hu:study:nct03464500-atlas" } }, update: { evaluates: { IngredientMaterial: [{ connect: [{ where: { node: { uid: { eq: "hu:material:amazentis-mitopure-as-administered-atlas" } } } }] }] } }) { studies { uid } } }
//   OBSERVED: REJECTED: Field "evaluates" is not defined by type "StudyUpdateInput".
// CH-S-10c GQL-02 createStudies with evaluates create
//   mutation { createStudies(input: [{ uid: "hu:study:ch-s-gql-02", entityType: "Study", evaluates: { Product: { connect: [{ where: { node: { uid: { eq: "hu:product:elysium-basis" } } } }] } } }]) { studies { uid } } }
//   OBSERVED: REJECTED: Field "evaluates" is not defined by type "StudyCreateInput".
// CH-S-10c GQL-03 updateStudies connect sponsoredBy (derived)
//   mutation { updateStudies(where: { uid: { eq: "hu:study:nct03816020-nadpark" } }, update: { sponsoredBy: [{ connect: [{ where: { node: { uid: { eq: "hu:org:elysium-health-inc" } } } }] }] }) { studies { uid } } }
//   OBSERVED: REJECTED: Field "sponsoredBy" is not defined by type "StudyUpdateInput".
// CH-S-10c GQL-04 updateOrganizations connect sponsorsStudies (derived inverse)
//   mutation { updateOrganizations(where: { uid: { eq: "hu:org:elysium-health-inc" } }, update: { sponsorsStudies: [{ connect: [{ where: { node: { uid: { eq: "hu:study:nct03816020-nadpark" } } } }] }] }) { organizations { uid } } }
//   OBSERVED: REJECTED: Field "sponsorsStudies" is not defined by type "OrganizationUpdateInput". Did you mean "sponsorsContent"?
// CH-S-10c GQL-05 updateStudies set overallStatus (derived cache)
//   mutation { updateStudies(where: { uid: { eq: "hu:study:nct03816020-nadpark" } }, update: { overallStatus: { set: "COMPLETED" } }) { studies { uid overallStatus } } }
//   OBSERVED: REJECTED: Field "overallStatus" is not defined by type "StudyUpdateInput".
// CH-S-10c GQL-05b updateSafetySignals connect reportedInStudies (derived)
//   mutation { updateSafetySignals(where: { uid: { eq: "hu:none" } }, update: { reportedInStudies: [{ connect: [{ where: { node: { uid: { eq: "hu:study:nct03816020-nadpark" } } } }] }] }) { safetySignals { uid } } }
//   OBSERVED: REJECTED: Field "reportedInStudies" is not defined by type "SafetySignalUpdateInput".
// CH-S-04c GQL-06 updateEvidenceApplicabilities set doseMatch (derived flat field)
//   mutation { updateEvidenceApplicabilities(where: { uid: { eq: "hu:applicability:w10-nct02678611-1x-to-basis-current-v2" } }, update: { doseMatch: { set: MATCH } }) { evidenceApplicabilities { uid doseMatch } } }
//   OBSERVED: REJECTED: Field "doseMatch" is not defined by type "EvidenceApplicabilityUpdateInput".
// CH-S-04c GQL-07 createEvidenceApplicabilities ACCEPTED with no dimensions
//   mutation { createEvidenceApplicabilities(input: [{ uid: "hu:applicability:ch-s-gql-07-no-dimensions", assessmentType: "EvidenceApplicability", methodVersion: "applicability-v0.2-candidate", status: ACCEPTED, summary: "Applies.", evidenceTarget: { StudyIntervention: { connect: [{ where: { node: { uid: { eq: "hu:study-intervention:nct02678611-nrpt-2x" } } } }] } }, useTarget: { FormulationVersion: { connect: [{ where: { node: { uid: { eq: "hu:formulation:basis-us-current-2026-07-10" } } } }] } } }]) { evidenceApplicabilities { uid status dimensions { uid } } } }
//   OBSERVED: ACCEPTED by the API
// CH-S-14c GQL-09 createEvidenceSyntheses ACCEPTED newer version without supersedes
//   mutation { createEvidenceSyntheses(input: [{ uid: "hu:synthesis:ch-s-gql-09-vitd-v4", assessmentType: "EvidenceSynthesis", methodVersion: "synthesis-v0.1", status: ACCEPTED, verdict: SUPPORTED, assessesClaim: { connect: [{ where: { node: { uid: { eq: "hu:claim:w10-vitamin-d-prevents-acute-respiratory-infection" } } } }] } }]) { evidenceSyntheses { uid verdict status } } }
//   OBSERVED: ACCEPTED by the API
// CH-S-14c GQL-08 updateEvidenceSyntheses connect supersedes after create (repair path)
//   mutation { updateEvidenceSyntheses(where: { uid: { eq: "hu:synthesis:ch-s-gql-09-vitd-v4" } }, update: { supersedes: [{ connect: [{ where: { node: { uid: { eq: "hu:synthesis:w10-vitamin-d-ari-prevention-v3" } } }, edge: { supersessionKind: RE_REVIEW, recordedAt: "2026-10-04T06:00:00Z" } }] }] }) { evidenceSyntheses { uid } } }
//   OBSERVED: REJECTED: Field "supersedes" is not defined by type "EvidenceSynthesisUpdateInput".
// CH-S-15 GQL-10 updateEvidenceSyntheses set recordedTo backdated on current v3
//   mutation { updateEvidenceSyntheses(where: { uid: { eq: "hu:synthesis:w10-vitamin-d-ari-prevention-v3" } }, update: { recordedTo: { set: "2019-01-01T00:00:00Z" } }) { evidenceSyntheses { uid recordedTo } } }
//   OBSERVED: ACCEPTED by the API
// CH-S-14c GQL-13 updateEvidenceSyntheses set verdict (control)
//   mutation { updateEvidenceSyntheses(where: { uid: { eq: "hu:synthesis:w10-vitamin-d-ari-prevention-v3" } }, update: { verdict: { set: SUPPORTED } }) { evidenceSyntheses { uid verdict } } }
//   OBSERVED: REJECTED: Field "verdict" is not defined by type "EvidenceSynthesisUpdateInput".
// CH-S-03b GQL-11 createInterventionComponents connect usesProductVariant without asReportedName
//   mutation { createInterventionComponents(input: [{ uid: "hu:intervention-component:ch-s-gql-11", stateType: "InterventionComponent", payloadHash: "sha256:abababababababababababababababababababababababababababababababab", usesProductVariant: { connect: [{ where: { node: { uid: { eq: "hu:product-variant:basis-us-capsule-standard" } } }, edge: { relationshipUid: "hu:rel:ch-s-gql-11", assertionUid: "hu:assertion:ch-s-gql-11-missing", validFromBasis: UNKNOWN, validToBasis: UNKNOWN, recordedFrom: "2026-10-04T06:00:00Z" } }] } }]) { interventionComponents { uid } } }
//   OBSERVED: ACCEPTED by the API
// ---- UNDO (Cypher) ----
// CH-S-GQL undo (GraphQL-created nodes and the backdated recordedTo)
MATCH (n) WHERE n.uid IN ['hu:applicability:ch-s-gql-07-no-dimensions', 'hu:synthesis:ch-s-gql-09-vitd-v4', 'hu:intervention-component:ch-s-gql-11'] DETACH DELETE n;
MATCH (s:EvidenceSynthesis {uid: 'hu:synthesis:w10-vitamin-d-ari-prevention-v3'}) REMOVE s.recordedTo;

// =====================================================================================================
// CH-S-17 (observed, no mutation): syntheses with no ASSESSES_CLAIM in the documented load (expect 0 rows; observed 5)
// =====================================================================================================
MATCH (s:EvidenceSynthesis) WHERE NOT EXISTS { MATCH (s)-[:ASSESSES_CLAIM]->() }
RETURN 'CH-S-17' AS check, s.uid AS claimlessSynthesis, s.status AS status;

// =====================================================================================================
// CH-S-18 (observed, no mutation): duplicate arm / intervention identities of one Study after composing W09 fixtures with the
// translated inherited fixture (expect 0 rows; observed 3 arms x 2 identities)
// =====================================================================================================
MATCH (s:Study)-[:HAS_ARM]->(a:StudyArm)
WITH s, toLower(trim(a.name)) AS armName, collect(a.uid) AS arms
WHERE size(arms) > 1
RETURN 'CH-S-18' AS check, s.uid AS study, armName, arms;
