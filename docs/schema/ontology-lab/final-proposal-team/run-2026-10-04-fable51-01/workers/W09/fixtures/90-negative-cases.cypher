// =====================================================================================================================
// W09 NEGATIVE cases. DO NOT load into a shared database. Load after fixtures 01-07; each statement reintroduces one
// collapse and the named validator must then return the row(s) listed in 06-fixtures-and-queries.md section 4.
// Every node created here has a uid containing ':neg-' so it can be removed with:
//   MATCH (n) WHERE n.uid CONTAINS ':neg-' DETACH DELETE n
// Edges added between positive nodes carry negativeCase: true and are removed with:
//   MATCH ()-[r]->() WHERE r.negativeCase = true DELETE r
// =====================================================================================================================

// N01 -> V-201 (INV-201; FI USES_INTERVENTION_MATERIAL -> EVALUATES_PRODUCT): legacy Study EVALUATES a current Product.
MATCH (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
MERGE (p:Product:Entity {uid: 'hu:product:neg-elysium-basis'})
  ON CREATE SET p.id = 'neg-elysium-basis', p.entityType = 'Product', p.name = 'Basis', p.createdAt = datetime('2026-10-04T01:30:00Z'), p.privacyClass = 'PUBLIC'
MERGE (s)-[r:EVALUATES {negativeCase: true}]->(p)
  ON CREATE SET r.armLabel = 'NRPT 1X', r.doseText = '250 mg NR + 50 mg PT';

// N02 -> V-201: live StudyArm RECEIVES a ProductVariant (the retired live edge).
MATCH (a:StudyArm {uid: 'hu:arm:nct02678611-nrpt-1x'}), (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
MERGE (a)-[:RECEIVES {negativeCase: true}]->(v);

// N03 -> V-202: an intervention component uses a ProductVariant without asReportedName.
MATCH (v:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:neg-variant-without-name'})
  ON CREATE SET ic.id = 'neg-variant-without-name', ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-neg-1', ic.quantity = 2.0, ic.unitCode = '{capsule}',
                ic.quantityBasis = 'PER_DAY', ic.massBasis = 'UNSPECIFIED', ic.createdAt = datetime('2026-10-04T01:30:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (ic)-[:USES_INTERVENTION_MATERIAL {relationshipUid: 'hu:rel:neg-variant-without-name', assertionUid: 'hu:assertion:neg-none', recordedFrom: datetime('2026-10-04T01:30:00Z'),
                                         validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(v);

// N04 -> V-W09-03: the same component also targets a material (two targets for one component).
MATCH (ic:InterventionComponent {uid: 'hu:intervention-component:neg-variant-without-name'}), (m:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'})
MERGE (ic)-[:USES_INTERVENTION_MATERIAL {relationshipUid: 'hu:rel:neg-two-targets', assertionUid: 'hu:assertion:neg-none', recordedFrom: datetime('2026-10-04T01:30:00Z'),
                                         validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', asReportedName: 'NR'}]->(m);

// N05 -> V-210 (INV-208, R10): registry status and pmid written directly on a Study (live fields).
MERGE (s:Study:Entity {uid: 'hu:study:neg-registry-fields-on-study'})
  ON CREATE SET s.id = 'neg-registry-fields-on-study', s.entityType = 'Study', s.overallStatus = 'COMPLETED', s.hasResults = false, s.pmid = '29184669',
                s.createdAt = datetime('2026-10-04T01:30:00Z'), s.privacyClass = 'PUBLIC';

// N06 -> V-211 and V-211r: a registration version with no observedAt and two owning registrations.
MATCH (r1:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct02678611'}), (r2:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct00938340'})
MERGE (rv:RegistrationVersion:InformationArtifact {uid: 'hu:registration-version:neg-shared-unobserved'})
  ON CREATE SET rv.id = 'neg-shared-unobserved', rv.artifactType = 'RegistrationVersion', rv.overallStatus = 'COMPLETED', rv.createdAt = datetime('2026-10-04T01:30:00Z'), rv.privacyClass = 'PUBLIC'
MERGE (r1)-[:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:neg-shared-1', recordedFrom: datetime('2026-10-04T01:30:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(rv)
MERGE (r2)-[:HAS_REGISTRATION_VERSION {relationshipUid: 'hu:rel:neg-shared-2', recordedFrom: datetime('2026-10-04T01:30:00Z'), validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN'}]->(rv);

// N07 -> V-215 and V-215r (INV-206): a favorable secondary after a null primary entered as CONFIRMATORY.
MATCH (r:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:neg-secondary-as-confirmatory'})
  ON CREATE SET syn.id = 'neg-secondary-as-confirmatory', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.recordedAt = datetime('2026-10-04T01:30:00Z'), syn.createdAt = datetime('2026-10-04T01:30:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r);

// N08 -> V-215r only (frozen V-215 misses it): the same secondary entered as INDEPENDENT_REPLICATION; the SYNTHETIC subgroup as SUPPORTIVE is allowed.
MATCH (r:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'}), (e:StudyResult {uid: 'hu:study-result:energize-endurance-ua-vs-placebo-2m'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:neg-secondary-as-replication'})
  ON CREATE SET syn.id = 'neg-secondary-as-replication', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.recordedAt = datetime('2026-10-04T01:30:00Z'), syn.createdAt = datetime('2026-10-04T01:30:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(e);

// N09 -> V-216 (FI WITHIN_ARM_CHANGE_SIGNIFICANT -> BETWEEN_ARM_EFFECT): the within-arm "+12%" used as INDEPENDENT_REPLICATION.
MATCH (r:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-within-arm'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:neg-within-arm-as-replication'})
  ON CREATE SET syn.id = 'neg-within-arm-as-replication', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.recordedAt = datetime('2026-10-04T01:30:00Z'), syn.createdAt = datetime('2026-10-04T01:30:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r);

// N10 -> V-218 (CQ-ST-07): the two walnut publications (same Study, same Dataset) counted as independent replications.
MATCH (w1:StudyResult {uid: 'hu:study-result:berryman-2013-skins-rhi-within'}), (w2:StudyResult {uid: 'hu:study-result:zhang-2011-postprandial-sera-efflux'})
MERGE (syn:EvidenceSynthesis:EvidenceAssessment {uid: 'hu:synthesis:neg-shared-dataset-as-replication'})
  ON CREATE SET syn.id = 'neg-shared-dataset-as-replication', syn.assessmentType = 'EvidenceSynthesis', syn.methodVersion = 'synthesis-v0.1', syn.status = 'PROPOSED',
                syn.recordedAt = datetime('2026-10-04T01:30:00Z'), syn.createdAt = datetime('2026-10-04T01:30:00Z'), syn.privacyClass = 'PUBLIC'
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(w1)
MERGE (syn)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(w2);

// N11 -> V-217 and V-217r (INV-207; FI "no AEs reported" -> "no events"): a paper with no AE section stored as a zero without method.
MATCH (arm:StudyArm {uid: 'hu:arm:nct00938340-whole'})
MERGE (ae:AdverseEventResult:StudyResult:InformationArtifact {uid: 'hu:study-result:neg-silence-as-zero'})
  ON CREATE SET ae.id = 'neg-silence-as-zero', ae.artifactType = 'AdverseEventResult', ae.analysisKind = 'SAFETY', ae.comparisonKind = 'ARM_DESCRIPTIVE', ae.statisticalConclusion = 'NOT_TESTED',
                ae.eventTerm = 'Any adverse event', ae.seriousness = 'ANY', ae.participantsAffected = 0, ae.eventCount = 0, ae.createdAt = datetime('2026-10-04T01:30:00Z'), ae.privacyClass = 'PUBLIC'
MERGE (ae)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION'}]->(arm);

// N12 -> V-213 (INV-209; FI STATISTICALLY_SIGNIFICANT -> CLINICALLY_MEANINGFUL): meaningfulness stored as a result property.
MATCH (r:StudyResult {uid: 'hu:study-result:atlas-hamstring-ua500-vs-placebo'})
SET r.isClinicallyMeaningful = true;

// N13 -> V-W09-01 (FI NOT_STATISTICALLY_SIGNIFICANT -> NO_EFFECT guard): derived significance contradicts the observed conclusion.
MERGE (r:StudyResult:InformationArtifact {uid: 'hu:study-result:neg-inconsistent-significance'})
  ON CREATE SET r.id = 'neg-inconsistent-significance', r.artifactType = 'StudyResult', r.analysisKind = 'PRIMARY_PRESPECIFIED', r.comparisonKind = 'BETWEEN_ARM',
                r.statisticalConclusion = 'NOT_REPORTED', r.isStatisticallySignificant = false, r.createdAt = datetime('2026-10-04T01:30:00Z'), r.privacyClass = 'PUBLIC';

// N14 -> V-W09-02: a Study cache naming a registration version of another study.
MERGE (s:Study:Entity {uid: 'hu:study:neg-foreign-cache'})
  ON CREATE SET s.id = 'neg-foreign-cache', s.entityType = 'Study', s.overallStatus = 'COMPLETED', s.enrollmentCount = 120,
                s.projectionOfRegistrationVersionUid = 'hu:registration-version:nct02678611-observed-2026-10-04', s.createdAt = datetime('2026-10-04T01:30:00Z'), s.privacyClass = 'PUBLIC';

// N15 -> V-W09-04: a CORRECTS edge with no SourceRevisionEvent behind it.
MATCH (art:Publication {uid: 'hu:publication:pmid-35584623'})
MERGE (n:Publication:InformationArtifact {uid: 'hu:publication:neg-correction-without-event'})
  ON CREATE SET n.id = 'neg-correction-without-event', n.artifactType = 'Publication', n.publicationKind = 'ERRATUM', n.createdAt = datetime('2026-10-04T01:30:00Z'), n.privacyClass = 'PUBLIC'
MERGE (n)-[:CORRECTS {relationshipUid: 'hu:rel:neg-corrects', assertionUid: 'hu:assertion:neg-none', recordedFrom: datetime('2026-10-04T01:30:00Z'), validFromBasis: 'UNKNOWN',
                      validToBasis: 'UNKNOWN', sourceRevisionEventUid: 'hu:source-revision:neg-missing'}]->(art);

// N16 -> V-W09-05 (FI REGISTRY_RESULTS_NOT_POSTED -> RESULTS_UNPUBLISHED): "unpublished" inferred from resultsPosted=false alone.
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-record'})
MERGE (a:Assertion {uid: 'hu:assertion:neg-results-unpublished'})
  ON CREATE SET a.id = 'neg-results-unpublished', a.predicate = 'RESULTS_UNPUBLISHED', a.valueBoolean = true, a.status = 'PROPOSED', a.basisKind = 'CALCULATED',
                a.derivationRule = 'registry.resultsPosted == false', a.recordedAt = datetime('2026-10-04T01:30:00Z'), a.createdAt = datetime('2026-10-04T01:30:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// N17 -> V-W09-06 (FI CORRECTS_SOURCE -> FACT_CEASED): an erratum recorded as a validity ending.
MATCH (old:Assertion {uid: 'hu:assertion:pmid-29184669-reference-20-original'})
MERGE (bad:Assertion {uid: 'hu:assertion:neg-erratum-as-fact-ending'})
  ON CREATE SET bad.id = 'neg-erratum-as-fact-ending', bad.predicate = 'CITES_AS_REFERENCE', bad.status = 'PROPOSED', bad.recordedAt = datetime('2026-10-04T01:30:00Z'),
                bad.validTo = datetime('2018-08-20T00:00:00Z'), bad.validToPrecision = 'DAY', bad.validToBasis = 'STATED_BY_SOURCE', bad.createdAt = datetime('2026-10-04T01:30:00Z'), bad.privacyClass = 'PUBLIC'
MERGE (bad)-[:SUPERSEDES {supersessionKind: 'VALIDITY_BOUNDED', recordedAt: datetime('2026-10-04T01:30:00Z'),
                          sourceRevisionEventUid: 'hu:source-revision:pmid-29184669-author-correction-2018', negativeCase: true}]->(old);

// N18 -> V-W09-07: a stored priority taken from the paper (latest-ingested source) instead of the registry declaration.
MATCH (od:OutcomeDefinition {uid: 'hu:outcome:atlas-isokinetic-strength-d120'})
SET od.priority = 'PRIMARY', od.priorityAssertionUid = 'hu:assertion:atlas-power-priority-paper';

// N19 -> V-W09-08: an AE row attached to two INTERVENTION arms.
MATCH (ae:AdverseEventResult {uid: 'hu:study-result:nct02678611-ae-any-nrpt-1x'}), (a2:StudyArm {uid: 'hu:arm:nct02678611-nrpt-2x'})
MERGE (ae)-[:RESULT_FOR_ARM {armRole: 'INTERVENTION', negativeCase: true}]->(a2);

// N20 -> V-W09-10 (INV-101): an asserted REPORTS_ON edge written without assertionUid/recordedFrom.
MATCH (p:Publication {uid: 'hu:publication:pmid-30155270'}), (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
MERGE (p)-[:REPORTS_ON {relationshipUid: 'hu:rel:neg-bare-reports-on', negativeCase: true}]->(s);

// N21 -> V-W09-11 (D-011, SPONSORS_STUDY -> EXECUTES_STUDY guard): an OPERATED_BY projection written as if asserted from a
// registry "collaborator" listing (collaborator is not CRO), carrying assertionUid and no derivation.
MATCH (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
MERGE (o:Organization:Entity {uid: 'hu:org:neg-kgk-science'})
  ON CREATE SET o.id = 'neg-kgk-science', o.entityType = 'Organization', o.name = 'KGK Science Inc.', o.createdAt = datetime('2026-10-04T01:30:00Z'), o.privacyClass = 'PUBLIC'
MERGE (s)-[:OPERATED_BY {assertionUid: 'hu:assertion:neg-collaborator-listing', negativeCase: true}]->(o);

// N22 -> V-012 (baseline): a Study collapsed with its Publication.
MERGE (n:Study:Publication:Entity {uid: 'hu:study:neg-study-is-publication'})
  ON CREATE SET n.id = 'neg-study-is-publication', n.entityType = 'Study', n.createdAt = datetime('2026-10-04T01:30:00Z'), n.privacyClass = 'PUBLIC';

// N23 -> V-221 and V-221r (true positive under both): an EXPERIMENTAL supplement component with an amount but no mass basis.
MATCH (arm:StudyArm {uid: 'hu:arm:atlas-ua-500'})
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:neg-missing-mass-basis'})
  ON CREATE SET si.id = 'neg-missing-mass-basis', si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-neg-si', si.createdAt = datetime('2026-10-04T01:30:00Z'), si.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: 'hu:intervention-component:neg-missing-mass-basis'})
  ON CREATE SET ic.id = 'neg-missing-mass-basis', ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-neg-ic', ic.quantity = 500.0, ic.unitCode = 'mg/d',
                ic.quantityBasis = 'PER_DAY', ic.quantityStatus = 'REPORTED', ic.createdAt = datetime('2026-10-04T01:30:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (arm)-[:ASSIGNS_INTERVENTION {relationshipUid: 'hu:rel:neg-assign', assertionUid: 'hu:assertion:neg-none', recordedFrom: datetime('2026-10-04T01:30:00Z'),
                                    validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', negativeCase: true}]->(si)
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic);
