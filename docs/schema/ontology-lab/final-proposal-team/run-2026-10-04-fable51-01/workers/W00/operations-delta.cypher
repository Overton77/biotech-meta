// W00 operations delta (reconciliation pass, run-2026-10-04-fable51-01). Neo4j 5.26 Community syntax; every statement idempotent.
// Applies on top of operations.cypher. Executed on embedded 5.26.31 (results in fixtures/results/operations-delta-run.txt).

// ---- A. Per-label uid and live-id uniqueness for labels registered in this pass (W00-R-01). Refinement specializations (rule T2)
//      are covered by their parent label and get no constraint of their own. Owners may move these into their own operations files.
CREATE CONSTRAINT adverse_effect_uid IF NOT EXISTS FOR (n:AdverseEffect) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT adverse_effect_live_id IF NOT EXISTS FOR (n:AdverseEffect) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT adverse_event_result_uid IF NOT EXISTS FOR (n:AdverseEventResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT adverse_event_result_live_id IF NOT EXISTS FOR (n:AdverseEventResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT affiliate_link_uid IF NOT EXISTS FOR (n:AffiliateLink) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT affiliate_link_live_id IF NOT EXISTS FOR (n:AffiliateLink) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT algorithm_uid IF NOT EXISTS FOR (n:Algorithm) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT algorithm_live_id IF NOT EXISTS FOR (n:Algorithm) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT anatomical_context_uid IF NOT EXISTS FOR (n:AnatomicalContext) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT anatomical_context_live_id IF NOT EXISTS FOR (n:AnatomicalContext) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT biomarker_uid IF NOT EXISTS FOR (n:Biomarker) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT biomarker_live_id IF NOT EXISTS FOR (n:Biomarker) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT botanical_taxon_uid IF NOT EXISTS FOR (n:BotanicalTaxon) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT botanical_taxon_live_id IF NOT EXISTS FOR (n:BotanicalTaxon) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT bundle_uid IF NOT EXISTS FOR (n:Bundle) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT bundle_live_id IF NOT EXISTS FOR (n:Bundle) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT bundle_component_uid IF NOT EXISTS FOR (n:BundleComponent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT bundle_component_live_id IF NOT EXISTS FOR (n:BundleComponent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT certificate_of_analysis_uid IF NOT EXISTS FOR (n:CertificateOfAnalysis) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT certificate_of_analysis_live_id IF NOT EXISTS FOR (n:CertificateOfAnalysis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT certification_listing_uid IF NOT EXISTS FOR (n:CertificationListing) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT certification_listing_live_id IF NOT EXISTS FOR (n:CertificationListing) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT certification_program_uid IF NOT EXISTS FOR (n:CertificationProgram) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT certification_program_live_id IF NOT EXISTS FOR (n:CertificationProgram) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT certification_scope_uid IF NOT EXISTS FOR (n:CertificationScope) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT certification_scope_live_id IF NOT EXISTS FOR (n:CertificationScope) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT cohort_participant_uid IF NOT EXISTS FOR (n:CohortParticipant) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT cohort_participant_live_id IF NOT EXISTS FOR (n:CohortParticipant) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT commerce_match_uid IF NOT EXISTS FOR (n:CommerceMatch) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT commerce_match_live_id IF NOT EXISTS FOR (n:CommerceMatch) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT community_uid IF NOT EXISTS FOR (n:Community) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT community_live_id IF NOT EXISTS FOR (n:Community) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT comparability_assessment_uid IF NOT EXISTS FOR (n:ComparabilityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT comparability_assessment_live_id IF NOT EXISTS FOR (n:ComparabilityAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT condition_uid IF NOT EXISTS FOR (n:Condition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT condition_live_id IF NOT EXISTS FOR (n:Condition) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT conference_uid IF NOT EXISTS FOR (n:Conference) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT conference_live_id IF NOT EXISTS FOR (n:Conference) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT constituent_uid IF NOT EXISTS FOR (n:Constituent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT constituent_live_id IF NOT EXISTS FOR (n:Constituent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT constraint_uid IF NOT EXISTS FOR (n:Constraint) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT constraint_live_id IF NOT EXISTS FOR (n:Constraint) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT dataset_uid IF NOT EXISTS FOR (n:Dataset) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT dataset_live_id IF NOT EXISTS FOR (n:Dataset) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT decision_criterion_uid IF NOT EXISTS FOR (n:DecisionCriterion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT decision_criterion_live_id IF NOT EXISTS FOR (n:DecisionCriterion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT device_uid IF NOT EXISTS FOR (n:Device) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT device_live_id IF NOT EXISTS FOR (n:Device) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT endpoint_classification_uid IF NOT EXISTS FOR (n:EndpointClassification) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT endpoint_classification_live_id IF NOT EXISTS FOR (n:EndpointClassification) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT event_uid IF NOT EXISTS FOR (n:Event) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT event_live_id IF NOT EXISTS FOR (n:Event) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT event_impact_assessment_uid IF NOT EXISTS FOR (n:EventImpactAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT event_impact_assessment_live_id IF NOT EXISTS FOR (n:EventImpactAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT evidence_synthesis_uid IF NOT EXISTS FOR (n:EvidenceSynthesis) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT evidence_synthesis_live_id IF NOT EXISTS FOR (n:EvidenceSynthesis) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT exposure_uid IF NOT EXISTS FOR (n:Exposure) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT exposure_live_id IF NOT EXISTS FOR (n:Exposure) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT figure_panel_uid IF NOT EXISTS FOR (n:FigurePanel) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT figure_panel_live_id IF NOT EXISTS FOR (n:FigurePanel) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT firmware_version_uid IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT firmware_version_live_id IF NOT EXISTS FOR (n:FirmwareVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT functional_goal_uid IF NOT EXISTS FOR (n:FunctionalGoal) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT functional_goal_live_id IF NOT EXISTS FOR (n:FunctionalGoal) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT granted_patent_uid IF NOT EXISTS FOR (n:GrantedPatent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT granted_patent_live_id IF NOT EXISTS FOR (n:GrantedPatent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT graph_view_uid IF NOT EXISTS FOR (n:GraphView) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT graph_view_live_id IF NOT EXISTS FOR (n:GraphView) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT individual_unit_uid IF NOT EXISTS FOR (n:IndividualUnit) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT individual_unit_live_id IF NOT EXISTS FOR (n:IndividualUnit) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT intervention_component_uid IF NOT EXISTS FOR (n:InterventionComponent) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT intervention_component_live_id IF NOT EXISTS FOR (n:InterventionComponent) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT inventory_item_uid IF NOT EXISTS FOR (n:InventoryItem) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT inventory_item_live_id IF NOT EXISTS FOR (n:InventoryItem) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT ip_right_status_uid IF NOT EXISTS FOR (n:IpRightStatus) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT ip_right_status_live_id IF NOT EXISTS FOR (n:IpRightStatus) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT lab_test_uid IF NOT EXISTS FOR (n:LabTest) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT lab_test_live_id IF NOT EXISTS FOR (n:LabTest) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT label_declaration_uid IF NOT EXISTS FOR (n:LabelDeclaration) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT label_declaration_live_id IF NOT EXISTS FOR (n:LabelDeclaration) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT lifestyle_uid IF NOT EXISTS FOR (n:Lifestyle) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT lifestyle_live_id IF NOT EXISTS FOR (n:Lifestyle) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT lot_test_summary_uid IF NOT EXISTS FOR (n:LotTestSummary) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT lot_test_summary_live_id IF NOT EXISTS FOR (n:LotTestSummary) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT manufacturing_capability_uid IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT manufacturing_capability_live_id IF NOT EXISTS FOR (n:ManufacturingCapability) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT manufacturing_process_uid IF NOT EXISTS FOR (n:ManufacturingProcess) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT manufacturing_process_live_id IF NOT EXISTS FOR (n:ManufacturingProcess) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT manufacturing_specification_uid IF NOT EXISTS FOR (n:ManufacturingSpecification) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT manufacturing_specification_live_id IF NOT EXISTS FOR (n:ManufacturingSpecification) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT manufacturing_step_uid IF NOT EXISTS FOR (n:ManufacturingStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT manufacturing_step_live_id IF NOT EXISTS FOR (n:ManufacturingStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT measured_result_uid IF NOT EXISTS FOR (n:MeasuredResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT measured_result_live_id IF NOT EXISTS FOR (n:MeasuredResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT measurement_method_uid IF NOT EXISTS FOR (n:MeasurementMethod) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT measurement_method_live_id IF NOT EXISTS FOR (n:MeasurementMethod) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT measurement_plan_uid IF NOT EXISTS FOR (n:MeasurementPlan) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT measurement_plan_live_id IF NOT EXISTS FOR (n:MeasurementPlan) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT mechanism_uid IF NOT EXISTS FOR (n:Mechanism) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT mechanism_live_id IF NOT EXISTS FOR (n:Mechanism) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT mechanism_evidence_context_uid IF NOT EXISTS FOR (n:MechanismEvidenceContext) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT mechanism_evidence_context_live_id IF NOT EXISTS FOR (n:MechanismEvidenceContext) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_annotation_uid IF NOT EXISTS FOR (n:MediaAnnotation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT media_annotation_live_id IF NOT EXISTS FOR (n:MediaAnnotation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_asset_uid IF NOT EXISTS FOR (n:MediaAsset) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT media_asset_live_id IF NOT EXISTS FOR (n:MediaAsset) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_rights_record_uid IF NOT EXISTS FOR (n:MediaRightsRecord) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT media_rights_record_live_id IF NOT EXISTS FOR (n:MediaRightsRecord) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_suitability_assessment_uid IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT media_suitability_assessment_live_id IF NOT EXISTS FOR (n:MediaSuitabilityAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT media_variant_uid IF NOT EXISTS FOR (n:MediaVariant) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT media_variant_live_id IF NOT EXISTS FOR (n:MediaVariant) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT merchant_listing_uid IF NOT EXISTS FOR (n:MerchantListing) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT merchant_listing_live_id IF NOT EXISTS FOR (n:MerchantListing) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT metric_uid IF NOT EXISTS FOR (n:Metric) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT metric_live_id IF NOT EXISTS FOR (n:Metric) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT microbial_strain_uid IF NOT EXISTS FOR (n:MicrobialStrain) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT microbial_strain_live_id IF NOT EXISTS FOR (n:MicrobialStrain) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT microbial_taxon_uid IF NOT EXISTS FOR (n:MicrobialTaxon) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT microbial_taxon_live_id IF NOT EXISTS FOR (n:MicrobialTaxon) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT modality_uid IF NOT EXISTS FOR (n:Modality) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT modality_live_id IF NOT EXISTS FOR (n:Modality) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT molecular_entity_uid IF NOT EXISTS FOR (n:MolecularEntity) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT molecular_entity_live_id IF NOT EXISTS FOR (n:MolecularEntity) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT narrative_arc_uid IF NOT EXISTS FOR (n:NarrativeArc) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT narrative_arc_live_id IF NOT EXISTS FOR (n:NarrativeArc) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT nutrient_uid IF NOT EXISTS FOR (n:Nutrient) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT nutrient_live_id IF NOT EXISTS FOR (n:Nutrient) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT observation_uid IF NOT EXISTS FOR (n:Observation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT observation_live_id IF NOT EXISTS FOR (n:Observation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT offer_uid IF NOT EXISTS FOR (n:Offer) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT offer_live_id IF NOT EXISTS FOR (n:Offer) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT organization_snapshot_uid IF NOT EXISTS FOR (n:OrganizationSnapshot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT organization_snapshot_live_id IF NOT EXISTS FOR (n:OrganizationSnapshot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT outcome_uid IF NOT EXISTS FOR (n:Outcome) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT outcome_live_id IF NOT EXISTS FOR (n:Outcome) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT outcome_definition_uid IF NOT EXISTS FOR (n:OutcomeDefinition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT outcome_definition_live_id IF NOT EXISTS FOR (n:OutcomeDefinition) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT package_configuration_uid IF NOT EXISTS FOR (n:PackageConfiguration) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT package_configuration_live_id IF NOT EXISTS FOR (n:PackageConfiguration) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT panel_definition_uid IF NOT EXISTS FOR (n:PanelDefinition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT panel_definition_live_id IF NOT EXISTS FOR (n:PanelDefinition) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT pass_fail_interpretation_uid IF NOT EXISTS FOR (n:PassFailInterpretation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT pass_fail_interpretation_live_id IF NOT EXISTS FOR (n:PassFailInterpretation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT patent_application_uid IF NOT EXISTS FOR (n:PatentApplication) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT patent_application_live_id IF NOT EXISTS FOR (n:PatentApplication) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT patent_claim_uid IF NOT EXISTS FOR (n:PatentClaim) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT patent_claim_live_id IF NOT EXISTS FOR (n:PatentClaim) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT patent_family_uid IF NOT EXISTS FOR (n:PatentFamily) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT patent_family_live_id IF NOT EXISTS FOR (n:PatentFamily) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT patent_license_uid IF NOT EXISTS FOR (n:PatentLicense) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT patent_license_live_id IF NOT EXISTS FOR (n:PatentLicense) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT pathway_uid IF NOT EXISTS FOR (n:Pathway) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT pathway_live_id IF NOT EXISTS FOR (n:Pathway) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT platform_uid IF NOT EXISTS FOR (n:Platform) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT platform_live_id IF NOT EXISTS FOR (n:Platform) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT policy_version_uid IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT policy_version_live_id IF NOT EXISTS FOR (n:PolicyVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT price_observation_uid IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT price_observation_live_id IF NOT EXISTS FOR (n:PriceObservation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT procedure_uid IF NOT EXISTS FOR (n:Procedure) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT procedure_live_id IF NOT EXISTS FOR (n:Procedure) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT product_label_region_uid IF NOT EXISTS FOR (n:ProductLabelRegion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT product_label_region_live_id IF NOT EXISTS FOR (n:ProductLabelRegion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT product_lot_uid IF NOT EXISTS FOR (n:ProductLot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT product_lot_live_id IF NOT EXISTS FOR (n:ProductLot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT product_snapshot_uid IF NOT EXISTS FOR (n:ProductSnapshot) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT product_snapshot_live_id IF NOT EXISTS FOR (n:ProductSnapshot) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_adjustment_rule_uid IF NOT EXISTS FOR (n:ProtocolAdjustmentRule) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_adjustment_rule_live_id IF NOT EXISTS FOR (n:ProtocolAdjustmentRule) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_result_uid IF NOT EXISTS FOR (n:ProtocolResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_result_live_id IF NOT EXISTS FOR (n:ProtocolResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_step_uid IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_step_live_id IF NOT EXISTS FOR (n:ProtocolStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT protocol_version_uid IF NOT EXISTS FOR (n:ProtocolVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT protocol_version_live_id IF NOT EXISTS FOR (n:ProtocolVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT quantity_declaration_uid IF NOT EXISTS FOR (n:QuantityDeclaration) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT quantity_declaration_live_id IF NOT EXISTS FOR (n:QuantityDeclaration) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT reference_interval_version_uid IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT reference_interval_version_live_id IF NOT EXISTS FOR (n:ReferenceIntervalVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT reference_range_uid IF NOT EXISTS FOR (n:ReferenceRange) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT reference_range_live_id IF NOT EXISTS FOR (n:ReferenceRange) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT reference_system_uid IF NOT EXISTS FOR (n:ReferenceSystem) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT reference_system_live_id IF NOT EXISTS FOR (n:ReferenceSystem) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT registration_version_uid IF NOT EXISTS FOR (n:RegistrationVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT registration_version_live_id IF NOT EXISTS FOR (n:RegistrationVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_inspection_uid IF NOT EXISTS FOR (n:RegulatoryInspection) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_inspection_live_id IF NOT EXISTS FOR (n:RegulatoryInspection) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_pathway_uid IF NOT EXISTS FOR (n:RegulatoryPathway) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_pathway_live_id IF NOT EXISTS FOR (n:RegulatoryPathway) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_pathway_version_uid IF NOT EXISTS FOR (n:RegulatoryPathwayVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_pathway_version_live_id IF NOT EXISTS FOR (n:RegulatoryPathwayVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_response_uid IF NOT EXISTS FOR (n:RegulatoryResponse) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_response_live_id IF NOT EXISTS FOR (n:RegulatoryResponse) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_step_uid IF NOT EXISTS FOR (n:RegulatoryStep) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_step_live_id IF NOT EXISTS FOR (n:RegulatoryStep) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT regulatory_submission_uid IF NOT EXISTS FOR (n:RegulatorySubmission) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT regulatory_submission_live_id IF NOT EXISTS FOR (n:RegulatorySubmission) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT risk_factor_uid IF NOT EXISTS FOR (n:RiskFactor) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT risk_factor_live_id IF NOT EXISTS FOR (n:RiskFactor) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT safety_signal_uid IF NOT EXISTS FOR (n:SafetySignal) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT safety_signal_live_id IF NOT EXISTS FOR (n:SafetySignal) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT segmentation_uid IF NOT EXISTS FOR (n:Segmentation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT segmentation_live_id IF NOT EXISTS FOR (n:Segmentation) REQUIRE n.segmentationId IS UNIQUE;
CREATE CONSTRAINT sensor_uid IF NOT EXISTS FOR (n:Sensor) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT sensor_live_id IF NOT EXISTS FOR (n:Sensor) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT serving_definition_uid IF NOT EXISTS FOR (n:ServingDefinition) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT serving_definition_live_id IF NOT EXISTS FOR (n:ServingDefinition) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_authority_assessment_uid IF NOT EXISTS FOR (n:SourceAuthorityAssessment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_authority_assessment_live_id IF NOT EXISTS FOR (n:SourceAuthorityAssessment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_coverage_requirement_uid IF NOT EXISTS FOR (n:SourceCoverageRequirement) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_coverage_requirement_live_id IF NOT EXISTS FOR (n:SourceCoverageRequirement) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT source_discovery_record_uid IF NOT EXISTS FOR (n:SourceDiscoveryRecord) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT source_discovery_record_live_id IF NOT EXISTS FOR (n:SourceDiscoveryRecord) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT species_uid IF NOT EXISTS FOR (n:Species) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT species_live_id IF NOT EXISTS FOR (n:Species) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT specification_criterion_uid IF NOT EXISTS FOR (n:SpecificationCriterion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT specification_criterion_live_id IF NOT EXISTS FOR (n:SpecificationCriterion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT specification_version_uid IF NOT EXISTS FOR (n:SpecificationVersion) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT specification_version_live_id IF NOT EXISTS FOR (n:SpecificationVersion) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT specimen_uid IF NOT EXISTS FOR (n:Specimen) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT specimen_live_id IF NOT EXISTS FOR (n:Specimen) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT study_population_uid IF NOT EXISTS FOR (n:StudyPopulation) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_population_live_id IF NOT EXISTS FOR (n:StudyPopulation) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT study_result_uid IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT study_result_live_id IF NOT EXISTS FOR (n:StudyResult) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT subscription_plan_uid IF NOT EXISTS FOR (n:SubscriptionPlan) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT subscription_plan_live_id IF NOT EXISTS FOR (n:SubscriptionPlan) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT target_uid IF NOT EXISTS FOR (n:Target) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT target_live_id IF NOT EXISTS FOR (n:Target) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT technology_platform_uid IF NOT EXISTS FOR (n:TechnologyPlatform) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT technology_platform_live_id IF NOT EXISTS FOR (n:TechnologyPlatform) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT test_execution_uid IF NOT EXISTS FOR (n:TestExecution) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT test_execution_live_id IF NOT EXISTS FOR (n:TestExecution) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT test_method_uid IF NOT EXISTS FOR (n:TestMethod) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT test_method_live_id IF NOT EXISTS FOR (n:TestMethod) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT test_sample_uid IF NOT EXISTS FOR (n:TestSample) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT test_sample_live_id IF NOT EXISTS FOR (n:TestSample) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT tool_or_instrument_uid IF NOT EXISTS FOR (n:ToolOrInstrument) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT tool_or_instrument_live_id IF NOT EXISTS FOR (n:ToolOrInstrument) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT trademark_uid IF NOT EXISTS FOR (n:Trademark) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT trademark_live_id IF NOT EXISTS FOR (n:Trademark) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT treatment_uid IF NOT EXISTS FOR (n:Treatment) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT treatment_live_id IF NOT EXISTS FOR (n:Treatment) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT trial_registration_uid IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT trial_registration_live_id IF NOT EXISTS FOR (n:TrialRegistration) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT use_constraint_uid IF NOT EXISTS FOR (n:UseConstraint) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT use_constraint_live_id IF NOT EXISTS FOR (n:UseConstraint) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT use_context_profile_uid IF NOT EXISTS FOR (n:UseContextProfile) REQUIRE n.uid IS UNIQUE;
CREATE CONSTRAINT use_context_profile_live_id IF NOT EXISTS FOR (n:UseContextProfile) REQUIRE n.id IS UNIQUE;

// ---- B. Relationship-episode identity for the episode and asserted types added to the parameters (W00-R-07, -16, -20, -37).
CREATE CONSTRAINT has_pathway_version_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_PATHWAY_VERSION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX has_pathway_version_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_PATHWAY_VERSION]-() ON (r.assertionUid);
CREATE INDEX has_pathway_version_recorded_from IF NOT EXISTS FOR ()-[r:HAS_PATHWAY_VERSION]-() ON (r.recordedFrom);
CREATE CONSTRAINT has_certification_scope_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_CERTIFICATION_SCOPE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX has_certification_scope_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_CERTIFICATION_SCOPE]-() ON (r.assertionUid);
CREATE INDEX has_certification_scope_recorded_from IF NOT EXISTS FOR ()-[r:HAS_CERTIFICATION_SCOPE]-() ON (r.recordedFrom);
CREATE CONSTRAINT has_capability_state_relationship_uid IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX has_capability_state_assertion_uid IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() ON (r.assertionUid);
CREATE INDEX has_capability_state_recorded_from IF NOT EXISTS FOR ()-[r:HAS_CAPABILITY_STATE]-() ON (r.recordedFrom);
CREATE CONSTRAINT status_of_relationship_uid IF NOT EXISTS FOR ()-[r:STATUS_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX status_of_assertion_uid IF NOT EXISTS FOR ()-[r:STATUS_OF]-() ON (r.assertionUid);
CREATE INDEX status_of_recorded_from IF NOT EXISTS FOR ()-[r:STATUS_OF]-() ON (r.recordedFrom);
CREATE CONSTRAINT ip_status_of_relationship_uid IF NOT EXISTS FOR ()-[r:IP_STATUS_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX ip_status_of_assertion_uid IF NOT EXISTS FOR ()-[r:IP_STATUS_OF]-() ON (r.assertionUid);
CREATE INDEX ip_status_of_recorded_from IF NOT EXISTS FOR ()-[r:IP_STATUS_OF]-() ON (r.recordedFrom);
CREATE CONSTRAINT strain_of_relationship_uid IF NOT EXISTS FOR ()-[r:STRAIN_OF]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX strain_of_assertion_uid IF NOT EXISTS FOR ()-[r:STRAIN_OF]-() ON (r.assertionUid);
CREATE INDEX strain_of_recorded_from IF NOT EXISTS FOR ()-[r:STRAIN_OF]-() ON (r.recordedFrom);
CREATE CONSTRAINT governed_by_specification_relationship_uid IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() REQUIRE r.relationshipUid IS UNIQUE;
CREATE INDEX governed_by_specification_assertion_uid IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() ON (r.assertionUid);
CREATE INDEX governed_by_specification_recorded_from IF NOT EXISTS FOR ()-[r:GOVERNED_BY_SPECIFICATION]-() ON (r.recordedFrom);
// HAS_STATE now also carries the entity state caches (W00-R-16): as-of reads filter on valid time.
CREATE INDEX has_state_valid_from IF NOT EXISTS FOR ()-[r:HAS_STATE]-() ON (r.validFrom);
CREATE INDEX has_state_valid_to IF NOT EXISTS FOR ()-[r:HAS_STATE]-() ON (r.validTo);
// LEGACY_EVALUATES (W00-R-17) is read-only legacy: no uniqueness (legacy edges carry no relationshipUid); no index needed.
// MENTIONS_ENTITY (W00-R-19) is derived and regenerable: no constraint; W20 owns any retrieval index.

// ---- C. Kernel node indexes added by rulings.
CREATE INDEX equivalence_retired_uid IF NOT EXISTS FOR (n:EquivalenceAssessment) ON (n.retiredUid);   // W00-R-11 redirect lookup by held uid
CREATE INDEX equivalence_kind_recorded IF NOT EXISTS FOR (n:EquivalenceAssessment) ON (n.equivalenceKind, n.recordedAt);
CREATE INDEX assertion_stated_as_of IF NOT EXISTS FOR (n:Assertion) ON (n.statedAsOf);   // W00-R-13 point-in-time reads
CREATE INDEX assertion_predicate_class IF NOT EXISTS FOR (n:Assertion) ON (n.predicateClass);   // W00-R-02 V-003r partition
CREATE INDEX source_source_kind IF NOT EXISTS FOR (n:Source) ON (n.sourceKind);   // W00-R-08 V-W00-17, V-324r kind filters
// source_locator_quote_hash (W20-SR-07) already exists in operations.cypher; unchanged.

// ---- D. Migrations (run once, in batches; each is idempotent because it only matches the legacy shape).
// D1 (W00-R-16): entity state caches leave HAS_SNAPSHOT for HAS_STATE. Authorizing assertions are back-filled by the ingestion
//     service; until then V-101r reports the migrated episodes (assertionUid null), which is the intended work queue.
MATCH (x)-[r:HAS_SNAPSHOT]->(y) WHERE NOT (x:Source AND y:SourceSnapshot)
CALL (x, r, y) {
  CREATE (x)-[n:HAS_STATE]->(y)
  SET n = properties(r), n.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:' + randomUUID()),
      n.recordedFrom = coalesce(r.recordedFrom, y.createdAt, datetime.transaction()),
      n.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), n.validToBasis = coalesce(r.validToBasis, 'UNKNOWN')
  DELETE r
} IN TRANSACTIONS OF 1000 ROWS;
// D2 (W00-R-17): legacy study edges leave EVALUATES.
MATCH (x)-[r:EVALUATES]->(y) WHERE NOT (x:Adjudication AND y:Assertion)
CALL (x, r, y) { CREATE (x)-[n:LEGACY_EVALUATES]->(y) SET n = properties(r) DELETE r } IN TRANSACTIONS OF 1000 ROWS;
// D3 (W00-R-19): entity-level retrieval links leave MENTIONS.
MATCH (x)-[r:MENTIONS]->(y) WHERE NOT (x:SourceLocator AND y:Mention)
CALL (x, r, y) { CREATE (x)-[n:MENTIONS_ENTITY]->(y) SET n = properties(r), n.derivationRule = coalesce(r.derivationRule, 'legacy-mentions-v0') DELETE r } IN TRANSACTIONS OF 1000 ROWS;
// D3b (W00-R-23): chunk-overlap edges leave OCCURS_IN_SEGMENT (kept for the W21 structural ClaimOccurrence -> EpisodeSegment edge).
MATCH (x:Chunk)-[r:OCCURS_IN_SEGMENT]->(y)
CALL (x, r, y) { CREATE (x)-[n:CHUNK_IN_SEGMENT]->(y) SET n = properties(r) DELETE r } IN TRANSACTIONS OF 1000 ROWS;
// D4 (W00-R-20): IDENTIFIED_BY becomes HAS_IDENTIFIER (asserted; assertions back-filled as in D1).
MATCH (x)-[r:IDENTIFIED_BY]->(y)
CALL (x, r, y) {
  CREATE (x)-[n:HAS_IDENTIFIER]->(y)
  SET n = properties(r), n.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:' + randomUUID()),
      n.recordedFrom = coalesce(r.recordedFrom, datetime.transaction()),
      n.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), n.validToBasis = coalesce(r.validToBasis, 'UNKNOWN')
  DELETE r
} IN TRANSACTIONS OF 1000 ROWS;
// D5 (W00-R-06): stored privacy classes take the final spelling; private-personal never stays in the shared graph (reported, not rewritten).
MATCH (n) WHERE n.privacyClass IN ['public', 'internal', 'synthetic']
CALL (n) { SET n.privacyClass = CASE n.privacyClass WHEN 'public' THEN 'PUBLIC' ELSE 'INTERNAL' END } IN TRANSACTIONS OF 5000 ROWS;
MATCH ()-[r]->() WHERE r.privacyClass IN ['public', 'internal', 'synthetic']
CALL (r) { SET r.privacyClass = CASE r.privacyClass WHEN 'public' THEN 'PUBLIC' ELSE 'INTERNAL' END } IN TRANSACTIONS OF 5000 ROWS;
// D6 (W00-R-14): a Source node written through the old Source.name keeps its display text under title.
MATCH (s:Source) WHERE s.title IS NULL AND s.name IS NOT NULL
CALL (s) { SET s.title = s.name REMOVE s.name } IN TRANSACTIONS OF 5000 ROWS;
