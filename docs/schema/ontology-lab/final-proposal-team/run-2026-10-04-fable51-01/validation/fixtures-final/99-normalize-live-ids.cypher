// Migration backfill M-01 (final proposal): nodes written by Cypher must carry the live projection identity and timestamps
// the GraphQL layer treats as non-null (id: ID! and createdAt/updatedAt), per contract B2 and INV-106 (id = opaque uid segment).
// Stored-id aliases: Document.documentId, DocumentTextVersion.documentTextVersionId, Segmentation.segmentationId, Chunk.chunkId.
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND NOT n:Document AND NOT n:DocumentTextVersion AND NOT n:Segmentation AND NOT n:Chunk AND n.id IS NULL
SET n.id = last(split(n.uid, ':'));
MATCH (n:Document) WHERE n.uid IS NOT NULL AND n.documentId IS NULL SET n.documentId = last(split(n.uid, ':'));
MATCH (n:DocumentTextVersion) WHERE n.uid IS NOT NULL AND n.documentTextVersionId IS NULL SET n.documentTextVersionId = last(split(n.uid, ':'));
MATCH (n:Segmentation) WHERE n.uid IS NOT NULL AND n.segmentationId IS NULL SET n.segmentationId = last(split(n.uid, ':'));
MATCH (n:Chunk) WHERE n.uid IS NOT NULL AND n.chunkId IS NULL SET n.chunkId = last(split(n.uid, ':'));
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND n.createdAt IS NULL SET n.createdAt = datetime('2026-10-04T00:00:00Z');
MATCH (n) WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND n.updatedAt IS NULL SET n.updatedAt = n.createdAt;
// MR-10: privacyClass stored exactly as the GraphQL enum
MATCH (n) WHERE n.privacyClass IN ['public','internal'] SET n.privacyClass = toUpper(n.privacyClass);

// V-W00-16: ApplicabilityDimension nodes use the registered token (W10); references were resolved before this statement runs.
MATCH (d:ApplicabilityDimension) WHERE d.uid STARTS WITH 'hu:applicability:' SET d.uid = replace(d.uid, 'hu:applicability:', 'hu:applicability-dimension:'), d.id = split(d.uid, ':')[-1];

// V-503r backfill (W00-R-37; M-07): an asserted edge inherits validity basis and precision from its authorizing assertion; an edge with
// no bound carries basis UNKNOWN; a bounded edge with no stated basis anywhere is recorded as STATED_BY_SOURCE at DAY precision (the
// fixture literal's precision), which V-503r accepts and the audit trail (notes) records.
MATCH (x)-[r]->(y) WHERE r.assertionUid IS NOT NULL OR r.relationshipUid IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
SET r.validFromBasis = coalesce(r.validFromBasis, a.validFromBasis, CASE WHEN r.validFrom IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END),
    r.validToBasis   = coalesce(r.validToBasis,   a.validToBasis,   CASE WHEN r.validTo   IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END),
    r.validFromPrecision = CASE WHEN r.validFrom IS NULL THEN r.validFromPrecision ELSE coalesce(r.validFromPrecision, a.validFromPrecision, 'DAY') END,
    r.validToPrecision   = CASE WHEN r.validTo   IS NULL THEN r.validToPrecision   ELSE coalesce(r.validToPrecision,   a.validToPrecision,   'DAY') END;

// CH-K-19 fixture repairs (translated 0.2.0 set only; GraphQL non-null contract): asserted edges get a relationshipUid, assessments a
// recordedAt (their createdAt or reviewedAt), 'FINAL' assessment status becomes ACCEPTED (not an AssessmentStatus value), and
// VersionedStates without payloadHash get a fixture hash. Live data goes through the ingestion service instead (M-08).
MATCH ()-[r]->() WHERE r.assertionUid IS NOT NULL AND r.relationshipUid IS NULL SET r.relationshipUid = 'hu:rel:' + toLower(type(r)) + '-' + replace(split(r.assertionUid, ':')[-1], '/', '-');
MATCH (n:EvidenceAssessment) WHERE n.recordedAt IS NULL SET n.recordedAt = coalesce(n.reviewedAt, n.createdAt, datetime('2026-10-03T12:00:00Z'));
MATCH (n:EvidenceAssessment) WHERE n.status = 'FINAL' SET n.status = 'ACCEPTED';
MATCH (n:VersionedState) WHERE n.payloadHash IS NULL SET n.payloadHash = 'sha256:fixture-' + coalesce(n.id, split(n.uid, ':')[-1]);

// V-W00-16 fixture repair: an Assertion-family node whose uid token is not registered for its labels (fixture authoring defect) is
// renamed hu:assertion:<token>-<opaque>; edge references (assertionUid, derivedFromAssertionUids) follow. Registered family tokens: assertion, claim-occurrence.
MATCH (a:Assertion) WHERE NOT split(a.uid, ':')[1] IN ["assertion", "claim-occurrence"]
WITH a, a.uid AS old, 'hu:assertion:' + replace(substring(a.uid, 3), ':', '-') AS new
SET a.uid = new, a.id = split(new, ':')[-1]
WITH old, new
OPTIONAL MATCH ()-[r]->() WHERE r.assertionUid = old OR old IN coalesce(r.derivedFromAssertionUids, []) OR r.projectionOfAssertionUid = old
SET r.assertionUid = CASE WHEN r.assertionUid = old THEN new ELSE r.assertionUid END,
    r.projectionOfAssertionUid = CASE WHEN r.projectionOfAssertionUid = old THEN new ELSE r.projectionOfAssertionUid END,
    r.derivedFromAssertionUids = CASE WHEN r.derivedFromAssertionUids IS NULL THEN NULL ELSE [x IN r.derivedFromAssertionUids | CASE WHEN x = old THEN new ELSE x END] END;

// Archetype and parent labels for fixture nodes written with the 0.2.0 label set (same statements as operations section 6b).
MATCH (n:Source) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:SourceSnapshot) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:SourceLocator) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:SourceRevisionEvent) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:Adjudication) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ResolutionHypothesis) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:Agent) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Activity) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:Identifier) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:TradeItemIdentifier) WHERE NOT (n:Identifier AND n:Entity) SET n:Identifier:Entity;
MATCH (n:Mention) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:EquivalenceAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:Organization) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:LegalEntity) WHERE NOT (n:Organization AND n:Entity) SET n:Organization:Entity;
MATCH (n:ConsumerBrand) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Facility) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:OrganizationSnapshot) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:Person) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:PseudonymousActor) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:AnonymousActor) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:CohortParticipant) WHERE NOT (n:PseudonymousActor AND n:Entity) SET n:PseudonymousActor:Entity;
MATCH (n:IngredientMaterial) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:BrandedIngredientMaterial) WHERE NOT (n:IngredientMaterial AND n:Entity) SET n:IngredientMaterial:Entity;
MATCH (n:BotanicalPreparation) WHERE NOT (n:IngredientMaterial AND n:Entity) SET n:IngredientMaterial:Entity;
MATCH (n:MicrobialPreparation) WHERE NOT (n:IngredientMaterial AND n:Entity) SET n:IngredientMaterial:Entity;
MATCH (n:MaterialMixture) WHERE NOT (n:IngredientMaterial AND n:Entity) SET n:IngredientMaterial:Entity;
MATCH (n:ChemicalSubstance) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ChemicalForm) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:BotanicalTaxon) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:MicrobialTaxon) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:MicrobialStrain) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Constituent) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Nutrient) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:MechanismEvidenceContext) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:Mechanism) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Pathway) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:MolecularEntity) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Species) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:AnatomicalContext) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Organ) WHERE NOT (n:AnatomicalContext AND n:Entity) SET n:AnatomicalContext:Entity;
MATCH (n:Outcome) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Condition) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:RiskFactor) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Product) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ProductVariant) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:PackageConfiguration) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ProductSnapshot) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:FormulationVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:IngredientComponent) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:LabelSnapshot) WHERE NOT (n:SourceSnapshot AND n:InformationArtifact) SET n:SourceSnapshot:InformationArtifact;
MATCH (n:LabelDeclaration) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:QuantityDeclaration) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:ServingDefinition) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:FoodItem) WHERE NOT (n:IngredientMaterial AND n:Entity) SET n:IngredientMaterial:Entity;
MATCH (n:Exposure) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Lifestyle) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Treatment) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Procedure) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Biomarker) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Metric) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:LabTest) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:PanelDefinition) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:MeasurementMethod) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Specimen) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ReferenceSystem) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Algorithm) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:AssayVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:AlgorithmVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ReferenceIntervalVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ComparabilityAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ReferenceRange) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:TechnologyPlatform) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ToolOrInstrument) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Device) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Modality) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Sensor) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:FirmwareVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:Study) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:TrialRegistration) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:RegistrationVersion) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:ProtocolVersion) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:StudyArm) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:StudyIntervention) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:InterventionComponent) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:StudyPopulation) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:OutcomeDefinition) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:StudyResult) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:AdverseEventResult) WHERE NOT (n:StudyResult AND n:InformationArtifact) SET n:StudyResult:InformationArtifact;
MATCH (n:Publication) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:Dataset) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:EvidenceApplicability) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ApplicabilityDimension) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:UseContextProfile) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:EndpointClassification) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ResultInterpretation) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:EvidenceSynthesis) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:EvidenceStrengthAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ManufacturingSpecification) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:SpecificationVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ManufacturingProcess) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ManufacturingStep) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ManufacturingCapability) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ProductLot) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:TestSample) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:TestExecution) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:TestMethod) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:TestingLaboratory) WHERE NOT (n:Organization AND n:Entity) SET n:Organization:Entity;
MATCH (n:MeasuredResult) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:SpecificationCriterion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:PassFailInterpretation) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:LotTestSummary) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:CertificateOfAnalysis) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:CertificationProgram) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:CertificationListing) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:CertificationScope) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:RegulatoryAgency) WHERE NOT (n:Organization AND n:Entity) SET n:Organization:Entity;
MATCH (n:RegulatoryPathway) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:RegulatoryPathwayVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:RegulatoryStep) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:RegulatorySubmission) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:RegulatoryResponse) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:RegulatoryStatus) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:OrphanDesignation) WHERE NOT (n:RegulatoryStatus AND n:VersionedState) SET n:RegulatoryStatus:VersionedState;
MATCH (n:DrugApproval) WHERE NOT (n:RegulatoryStatus AND n:VersionedState) SET n:RegulatoryStatus:VersionedState;
MATCH (n:RegulatoryInspection) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:PatentFamily) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Trademark) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:PatentApplication) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:GrantedPatent) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:PatentClaim) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:PatentLicense) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:IpRightStatus) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:MerchantListing) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Offer) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:PriceObservation) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:SubscriptionPlan) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:Bundle) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:BundleComponent) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:InventoryItem) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:IndividualUnit) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:AffiliateLink) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:CommerceMatch) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:Protocol) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ProtocolEdition) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:ProtocolStep) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Constraint) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:MeasurementPlan) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ProtocolAdjustmentRule) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Target) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:FunctionalGoal) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Observation) WHERE NOT (n:DiagnosticResult AND n:InformationArtifact) SET n:DiagnosticResult:InformationArtifact;
MATCH (n:ProtocolResult) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:AdverseEffect) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:SafetySignal) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ContraindicationAssertion) WHERE NOT (n:Assertion) SET n:Assertion;
MATCH (n:InteractionAssertion) WHERE NOT (n:Assertion) SET n:Assertion;
MATCH (n:UseConstraint) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Community) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Conference) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Event) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:NarrativeArc) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:EventImpactAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:SourceAuthorityAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:SourceCoverageRequirement) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:SourceDiscoveryRecord) WHERE NOT (n:Activity AND n:Occurrence) SET n:Activity:Occurrence;
MATCH (n:Document) WHERE NOT (n:Source AND n:Entity) SET n:Source:Entity;
MATCH (n:DocumentTextVersion) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:Segmentation) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:Chunk) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:Platform) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Channel) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Series) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:Episode) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:EpisodeSegment) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:Claim) WHERE NOT (n:Entity) SET n:Entity;
MATCH (n:ClaimOccurrence) WHERE NOT (n:Assertion) SET n:Assertion;
MATCH (n:RelationshipAssertion) WHERE NOT (n:Assertion) SET n:Assertion;
MATCH (n:ClaimEvidenceAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:RetellingFidelityAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:ConflictRelevanceAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:MediaAsset) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:MediaVariant) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:MediaAnnotation) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:GraphView) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:FigurePanel) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:ProductLabelRegion) WHERE NOT (n:InformationArtifact) SET n:InformationArtifact;
MATCH (n:MediaSuitabilityAssessment) WHERE NOT (n:EvidenceAssessment) SET n:EvidenceAssessment;
MATCH (n:MediaRightsRecord) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:AnswerRecord) WHERE NOT (n:Occurrence) SET n:Occurrence;
MATCH (n:PolicyVersion) WHERE NOT (n:VersionedState) SET n:VersionedState;
MATCH (n:DecisionCriterion) WHERE NOT (n:Entity) SET n:Entity;
