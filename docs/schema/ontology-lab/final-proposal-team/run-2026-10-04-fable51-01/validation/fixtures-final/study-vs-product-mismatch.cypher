// =============================================================================
// Fixture: study-vs-product mismatch (rounds 0002 and 0003, Lane 2)
// Neo4j 5 Cypher. Illustrative fixture using public sources; not a production
// import. No Neo4j instance was available: nothing here has been executed.
//
// What it encodes
//   1. The same substance (nicotinamide riboside, NR) studied as different
//      materials, forms, doses, and co-ingredients:
//      - NCT02678611 / PMID 29184669: NRPT ("commercially known as Basis"),
//        250 mg NR + 50 mg pterostilbene/day (1X), 8 weeks, ages 60-80. The NR
//        material supplier at trial time is UNRESOLVED (Author Correction
//        PMID 30155270: product provided by Elysium; C&EN 2018 reports
//        ChromaDex's statement that it supplied Elysium's NR until mid-2016).
//      - NCT02712593 / PMID 31278280: NIAGEN (crystal form of NR chloride),
//        100/300/1000 mg/day, 8 weeks, overweight adults.
//   2. EvidenceApplicability assessments with explicit identity and dose
//      dimensions, including the trap: NIAGEN trial evidence -> Basis.
//   3. Outcome ontology: whole-blood NAD+ (biomarker, not surrogate) vs LDL-C
//      (safety biomarker here; FDA-listed surrogate only in a lipid-lowering
//      drug context of use).
//   4. Registry vs publication: resultsPosted=false while results are
//      published; publication correction.
//   5. Adverse events with collection method (reported zero vs not reported).
//   6. Mechanism steps: measured vs hypothesized, blood vs muscle compartment,
//      and an EXPOSURE dimension for ingredient-mechanism -> formulation.
//   7. A versioned evidence synthesis with TRIGGERED_BY.
//
// INTENTIONALLY ABSENT (validation section returns rows if added):
//   (:Study {uid:'hu:study:nct02678611-basis-nrpt'})-[:EVALUATES]->(:Product {uid:'hu:product:elysium-basis'})
//   (:Study {uid:'hu:study:nct02712593-niagen'})-[:EVALUATES]->(:Product {uid:'hu:product:tru-niagen'})
//   (:IngredientMaterial {uid:'hu:material:nct02678611-nr-as-supplied'}) merged with NR-E or NIAGEN
//   (:Product {uid:'hu:product:elysium-basis'})-[:CONTAINS]->(:IngredientMaterial {uid:'hu:material:nct02678611-nr-as-supplied'})
//   Any mechanism projection (AFFECTS_MECHANISM / MODULATES) from a HYPOTHESIS assertion
//   (:Organization {uid:'hu:org:elysium-health-inc'})-[:SUPPLIES_INGREDIENT_MATERIAL]->(trial NR material)
//
// Composes with examples/elysium-basis.cypher: shared uids are MERGEd with
// ON CREATE SET so that loading either file first is safe.
// Every statement MATCHes or MERGEs each node it links; no variable crosses a ';'.
// =============================================================================
// Executed 2026-10-03 on an embedded Neo4j 5.26 Community instance (authoring scratchpad): every statement ran, and the full
// 0.2.0 validation suite (../neo4j/validation.cypher) returned zero failing rows with this fixture loaded alone and with all six
// fixtures loaded together. Expected informational rows are listed in ../ontology-lab/proposal-index.md section 9.


// ---------------------------------------------------------------------------
// 1. Organizations, products, materials, substances, forms
// ---------------------------------------------------------------------------

// status: statically-checked
UNWIND [
  {uid: 'hu:org:elysium-health-inc', name: 'Elysium Health', legalName: 'Elysium Health, Inc.'},
  {uid: 'hu:org:chromadex-inc', name: 'ChromaDex', legalName: 'ChromaDex, Inc.'},
  {uid: 'hu:org:kgk-science-inc', name: 'KGK Science', legalName: 'KGK Science Inc.'}
] AS o
MERGE (n:Entity:Organization:LegalEntity {uid: o.uid})
ON CREATE SET n.name = o.name, n.legalName = o.legalName, n.entityType = 'Organization', n.createdAt = datetime();

// status: statically-checked
MERGE (basis:Entity:Product {uid: 'hu:product:elysium-basis'})
ON CREATE SET basis.name = 'Basis', basis.productKind = 'DIETARY_SUPPLEMENT', basis.entityType = 'Product', basis.createdAt = datetime()
MERGE (basisVariant:Entity:ProductVariant {uid: 'hu:product-variant:basis-us-capsule-standard'})
ON CREATE SET basisVariant.name = 'Basis - US capsules', basisVariant.jurisdiction = 'US', basisVariant.dosageForm = 'CAPSULE', basisVariant.entityType = 'ProductVariant', basisVariant.createdAt = datetime()
MERGE (basisForm:VersionedState:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'})
ON CREATE SET basisForm.versionName = 'Basis current US label observed 2026-07-10', basisForm.jurisdiction = 'US', basisForm.stateType = 'FormulationVersion', basisForm.createdAt = datetime()
MERGE (nrComp:VersionedState:IngredientComponent {uid: 'hu:component:basis-current-nr-e'})
ON CREATE SET nrComp.role = 'DIETARY_INGREDIENT', nrComp.labelOrder = 1, nrComp.quantity = 250.0, nrComp.unitCode = 'mg', nrComp.quantityBasis = 'PER_SERVING', nrComp.declaredAs = 'Elysium NR (Nicotinamide Riboside Chloride)', nrComp.stateType = 'IngredientComponent', nrComp.createdAt = datetime()
MERGE (ptComp:VersionedState:IngredientComponent {uid: 'hu:component:basis-current-pt'})
ON CREATE SET ptComp.role = 'DIETARY_INGREDIENT', ptComp.labelOrder = 2, ptComp.quantity = 50.0, ptComp.unitCode = 'mg', ptComp.quantityBasis = 'PER_SERVING', ptComp.declaredAs = 'PT (Pterostilbene)', ptComp.stateType = 'IngredientComponent', ptComp.createdAt = datetime()
// Mass basis requested from Lane 3 for IngredientComponent; the label names the salt.
SET nrComp.massBasis = 'SALT_FORM', ptComp.massBasis = 'MATERIAL_AS_IS'
MERGE (truNiagen:Entity:Product {uid: 'hu:product:tru-niagen'})
ON CREATE SET truNiagen.name = 'Tru Niagen', truNiagen.productKind = 'DIETARY_SUPPLEMENT', truNiagen.entityType = 'Product', truNiagen.createdAt = datetime()
MERGE (tn300:Entity:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
ON CREATE SET tn300.name = 'Tru Niagen 300mg, 1 vegetarian capsule per serving', tn300.jurisdiction = 'US', tn300.dosageForm = 'CAPSULE', tn300.strengthDescriptor = '300 mg NIAGEN per capsule', tn300.entityType = 'ProductVariant', tn300.createdAt = datetime()
MERGE (tnForm:VersionedState:FormulationVersion {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'})
ON CREATE SET tnForm.versionName = 'Tru Niagen 300mg label observed 2026-10-03', tnForm.jurisdiction = 'US', tnForm.stateType = 'FormulationVersion', tnForm.createdAt = datetime()
MERGE (tnComp:VersionedState:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'})
ON CREATE SET tnComp.role = 'DIETARY_INGREDIENT', tnComp.labelOrder = 1, tnComp.quantity = 300.0, tnComp.unitCode = 'mg', tnComp.quantityBasis = 'PER_SERVING', tnComp.massBasis = 'SALT_FORM', tnComp.declaredAs = 'NIAGEN (nicotinamide riboside chloride)', tnComp.stateType = 'IngredientComponent', tnComp.createdAt = datetime()
MERGE (basisForm)-[:HAS_INGREDIENT_COMPONENT]->(nrComp)
MERGE (basisForm)-[:HAS_INGREDIENT_COMPONENT]->(ptComp)
MERGE (tnForm)-[:HAS_INGREDIENT_COMPONENT]->(tnComp);

// Materials, substances, chemical form.
// status: statically-checked
MERGE (nrE:Entity:IngredientMaterial:BrandedIngredientMaterial {uid: 'hu:material:elysium-nr-e'})
ON CREATE SET nrE.name = 'Elysium NR-E', nrE.brandName = 'NR-E', nrE.materialKind = 'BRANDED_CHEMICAL_MATERIAL', nrE.entityType = 'IngredientMaterial', nrE.createdAt = datetime()
MERGE (niagen:Entity:IngredientMaterial:BrandedIngredientMaterial {uid: 'hu:material:chromadex-niagen'})
ON CREATE SET niagen.name = 'NIAGEN', niagen.brandName = 'NIAGEN', niagen.materialKind = 'BRANDED_CHEMICAL_MATERIAL', niagen.entityType = 'IngredientMaterial', niagen.createdAt = datetime()
MERGE (trialNr:Entity:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'})
ON CREATE SET trialNr.name = 'NR as administered in NCT02678611 (supplier unresolved)', trialNr.materialKind = 'UNRESOLVED_MATERIAL', trialNr.entityType = 'IngredientMaterial', trialNr.createdAt = datetime()
MERGE (trialPt:Entity:IngredientMaterial {uid: 'hu:material:nct02678611-pt-as-supplied'})
ON CREATE SET trialPt.name = 'Pterostilbene as administered in NCT02678611 (supplier unresolved)', trialPt.materialKind = 'UNRESOLVED_MATERIAL', trialPt.entityType = 'IngredientMaterial', trialPt.createdAt = datetime()
MERGE (curPt:Entity:IngredientMaterial {uid: 'hu:material:pterostilbene-unspecified-current-basis'})
ON CREATE SET curPt.name = 'PT (Pterostilbene) - current Basis material unresolved', curPt.materialKind = 'CHEMICALLY_DEFINED_MATERIAL', curPt.entityType = 'IngredientMaterial', curPt.createdAt = datetime()
MERGE (elhNr:Entity:IngredientMaterial {uid: 'hu:material:elhassan-2019-nr-as-supplied'})
ON CREATE SET elhNr.name = 'NR as administered in Elhassan et al. 2019 (material unresolved)', elhNr.materialKind = 'UNRESOLVED_MATERIAL', elhNr.entityType = 'IngredientMaterial', elhNr.createdAt = datetime()
MERGE (nrc:Entity:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
ON CREATE SET nrc.preferredName = 'Nicotinamide riboside chloride', nrc.entityType = 'ChemicalSubstance', nrc.createdAt = datetime()
MERGE (pts:Entity:ChemicalSubstance {uid: 'hu:substance:pterostilbene'})
ON CREATE SET pts.preferredName = 'Pterostilbene', pts.entityType = 'ChemicalSubstance', pts.createdAt = datetime()
MERGE (crystal:Entity:ChemicalForm {uid: 'hu:form:nr-chloride-crystal-niagen'})
ON CREATE SET crystal.formKind = 'CRYSTAL_FORM', crystal.grade = 'NIAGEN specification (version unknown)', crystal.entityType = 'ChemicalForm', crystal.createdAt = datetime()
MERGE (crystal)-[:FORM_OF_SUBSTANCE]->(nrc);


// ---------------------------------------------------------------------------
// 2. Sources, snapshots, locators
// ---------------------------------------------------------------------------

// status: statically-checked
UNWIND [
  {src: 'hu:source:ctgov-nct02678611', uri: 'https://clinicaltrials.gov/study/NCT02678611', title: 'ClinicalTrials.gov NCT02678611', kind: 'TRIAL_REGISTRY_RECORD', snap: 'hu:snapshot:ctgov-nct02678611-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:ctgov-nct02678611-outcomes', section: 'Outcome Measures (current version)'},
  {src: 'hu:source:ctgov-nct02678611', uri: 'https://clinicaltrials.gov/study/NCT02678611', title: 'ClinicalTrials.gov NCT02678611', kind: 'TRIAL_REGISTRY_RECORD', snap: 'hu:snapshot:ctgov-nct02678611-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:ctgov-nct02678611-status', section: 'Study Status; Results (has_results false); Locations'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-methods-intervention', section: 'Methods: Intervention'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-results-trial-overview', section: 'Results: Trial overview'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-results-nad', section: 'Results: NRPT increases NAD+'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-results-adverse-events', section: 'Results: Adverse events'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-results-lipids', section: 'Results: NRPT and lipids'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-introduction-sirtuins', section: 'Introduction: NRPT predicted to support metabolic health via sirtuins'},
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', title: 'Dellinger et al. 2017 npj Aging Mech Dis 3:17 (PMID 29184669)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc5701244-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid29184669-discussion-major-endpoint', section: 'Discussion: "The major efficacy endpoint of the trial was NAD+ concentration"'},
  {src: 'hu:source:doi-10.1038-s41514-018-0027-1', uri: 'https://doi.org/10.1038/s41514-018-0027-1', title: 'Author Correction (PMID 30155270)', kind: 'PUBLISHED_CORRECTION', snap: 'hu:snapshot:pmc6102308-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid30155270-intervention-source', section: 'Correction to Methods: Intervention (source of investigational product)'},
  {src: 'hu:source:cen-2018-niagen-feud', uri: 'https://cen.acs.org/business/consumer-products/Firms-feud-over-Niagen-purported/96/i33', title: 'C&EN: Firms feud over purported age-fighting molecule', kind: 'TRADE_PRESS', snap: 'hu:snapshot:cen-2018-niagen-feud-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:cen-2018-supply-until-mid-2016', section: 'Paragraph: "Until mid-2016, ChromaDex sold Elysium all the NR ... according to ChromaDex"'},
  {src: 'hu:source:ctgov-nct02678611', uri: 'https://clinicaltrials.gov/study/NCT02678611', title: 'ClinicalTrials.gov NCT02678611', kind: 'TRIAL_REGISTRY_RECORD', snap: 'hu:snapshot:ctgov-nct02678611-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:ctgov-nct02678611-eligibility', section: 'Eligibility Criteria'},
  {src: 'hu:source:ctgov-nct02712593', uri: 'https://clinicaltrials.gov/study/NCT02712593', title: 'ClinicalTrials.gov NCT02712593', kind: 'TRIAL_REGISTRY_RECORD', snap: 'hu:snapshot:ctgov-nct02712593-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:ctgov-nct02712593-arms', section: 'Arms and Interventions; Outcome Measures'},
  {src: 'hu:source:ctgov-nct02712593', uri: 'https://clinicaltrials.gov/study/NCT02712593', title: 'ClinicalTrials.gov NCT02712593', kind: 'TRIAL_REGISTRY_RECORD', snap: 'hu:snapshot:ctgov-nct02712593-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:ctgov-nct02712593-eligibility', section: 'Eligibility Criteria (age 40-60, BMI 25-30)'},
  {src: 'hu:source:fda-surrogate-endpoint-table', uri: 'https://www.fda.gov/drugs/development-resources/table-surrogate-endpoints-were-basis-drug-approval-or-licensure', title: 'FDA Table of Surrogate Endpoints That Were the Basis of Drug Approval or Licensure', kind: 'REGULATORY_REFERENCE_TABLE', snap: 'hu:snapshot:fda-surrogate-table-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:fda-surrogate-table-hypercholesterolemia-ldl-c', section: 'Adult table row: Hypercholesterolemia / Serum LDL cholesterol / Traditional / Lipid-lowering'},
  {src: 'hu:source:doi-10.1038-s41598-019-46120-z', uri: 'https://doi.org/10.1038/s41598-019-46120-z', title: 'Conze et al. 2019 Sci Rep 9:9772 (PMID 31278280)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmid31278280-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid31278280-abstract', section: 'Abstract'},
  {src: 'hu:source:elysium-basis-supplement-facts', uri: 'https://www.elysiumhealth.com/pages/basis-supplement-facts', title: 'Basis Supplement Facts', kind: 'MANUFACTURER_LABEL_PAGE', snap: 'hu:snapshot:elysium-basis-label-2026-07-10', at: '2026-07-10T00:00:00Z', loc: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10', section: 'Supplement Facts'},
  {src: 'hu:source:truniagen-300mg-product-page', uri: 'https://www.truniagen.com/products/tru-niagen-300mg', title: 'Tru Niagen 300mg product page', kind: 'MANUFACTURER_PRODUCT_PAGE', snap: 'hu:snapshot:truniagen-300mg-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:truniagen-300mg-supplement-facts', section: 'Supplement Facts'},
  {src: 'hu:source:doi-10.1016-j.celrep.2019.07.043', uri: 'https://doi.org/10.1016/j.celrep.2019.07.043', title: 'Elhassan et al. 2019 Cell Rep 28:1717 (PMID 31412242)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc6702140-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid31412242-abstract', section: 'Abstract'},
  {src: 'hu:source:doi-10.1016-j.celrep.2019.07.043', uri: 'https://doi.org/10.1016/j.celrep.2019.07.043', title: 'Elhassan et al. 2019 Cell Rep 28:1717 (PMID 31412242)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmc6702140-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid31412242-results-figure3', section: 'Results and Figure 3: mitochondrial bioenergetics and acetylation unaltered'},
  {src: 'hu:source:doi-10.1126-science.aaf2693', uri: 'https://doi.org/10.1126/science.aaf2693', title: 'Zhang et al. 2016 Science 352:1436 (PMID 27127236)', kind: 'PEER_REVIEWED_PUBLICATION', snap: 'hu:snapshot:pmid27127236-2026-10-03', at: '2026-10-03T00:00:00Z', loc: 'hu:locator:pmid27127236-abstract', section: 'Abstract'}
] AS s
MERGE (src:Entity:Source {uid: s.src})
ON CREATE SET src.canonicalUri = s.uri, src.title = s.title, src.sourceKind = s.kind, src.entityType = 'Source', src.createdAt = datetime()
MERGE (snap:InformationArtifact:SourceSnapshot {uid: s.snap})
ON CREATE SET snap.canonicalUri = s.uri, snap.retrievedAt = datetime(s.at), snap.observedAt = datetime(s.at), snap.artifactType = 'SourceSnapshot', snap.createdAt = datetime(),
              snap.contentHash = 'synthetic:' + s.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'UNKNOWN'
MERGE (loc:InformationArtifact:SourceLocator {uid: s.loc})
ON CREATE SET loc.uri = s.uri, loc.section = s.section, loc.selectorKind = CASE WHEN s.section IS NULL THEN 'WHOLE_SNAPSHOT' ELSE 'SECTION' END, loc.artifactType = 'SourceLocator', loc.createdAt = datetime()
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);


// ---------------------------------------------------------------------------
// 3. Studies, registrations, publications, arms, interventions, components
// ---------------------------------------------------------------------------

// Basis/NRPT study. Registry facts live on RegistrationVersion, not on Study.
// status: statically-checked
MATCH (elysium:Organization {uid: 'hu:org:elysium-health-inc'}),
      (regLoc:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-status'})
MERGE (study:Entity:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
ON CREATE SET study.title = 'Repeat-dose NRPT in healthy adults aged 60 to 80', study.studyKind = 'INTERVENTIONAL_RCT', study.entityType = 'Study', study.createdAt = datetime()
MERGE (reg:Entity:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct02678611'})
ON CREATE SET reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT02678611', reg.entityType = 'TrialRegistration', reg.createdAt = datetime()
MERGE (rv:InformationArtifact:RegistrationVersion {uid: 'hu:registration-version:nct02678611-observed-2026-10-03'})
ON CREATE SET rv.observedAt = datetime('2026-10-03T00:00:00Z'),
              rv.versionDate = null,                 // registry version date not retrievable in session: unknown, not ingestion time
              rv.overallStatus = 'COMPLETED',
              rv.enrollmentCount = 120,
              rv.enrollmentCountType = null,         // not returned by the tool: notReported, not ESTIMATED
              rv.resultsPosted = false,              // "no results section on the registry as observed"; NOT "no results exist"
              rv.startDate = '2016-01', rv.startDateType = null,
              rv.primaryCompletionDate = '2016-07',
              rv.studyType = 'INTERVENTIONAL', rv.phase = 'PHASE1',
              rv.siteCountries = ['CA'],
              rv.artifactType = 'RegistrationVersion', rv.createdAt = datetime()
MERGE (study)-[:REGISTERED_AS]->(reg)
MERGE (reg)-[hrv:HAS_REGISTRATION_VERSION]->(rv)
ON CREATE SET hrv.relationshipUid = 'hu:rel:' + split(rv.uid, ':')[2], hrv.recordedFrom = datetime('2026-10-03T00:00:00Z'), hrv.validFromBasis = 'OBSERVATION_ONLY', hrv.validToBasis = 'UNKNOWN'
MERGE (aSponsor:Assertion {uid: 'hu:assertion:elysium-sponsors-nct02678611'})
ON CREATE SET aSponsor.predicate = 'SPONSORS_STUDY', aSponsor.status = 'ACCEPTED', aSponsor.polarity = 'POSITIVE', aSponsor.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (aSponsor)-[:HAS_SUBJECT]->(elysium)
MERGE (aSponsor)-[:HAS_OBJECT]->(study)
MERGE (aSponsor)-[:SUPPORTED_BY]->(regLoc);

// Publications: article and its Author Correction; dataset available on request.
// status: statically-checked
MATCH (study:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
MERGE (pub:InformationArtifact:Publication {uid: 'hu:publication:pmid-29184669'})
ON CREATE SET pub.title = 'Repeat dose NRPT (nicotinamide riboside and pterostilbene) increases NAD+ levels in humans safely and sustainably', pub.doi = '10.1038/s41514-017-0016-9', pub.pmid = '29184669', pub.publishedAt = date('2017-11-24'), pub.publicationKind = 'ARTICLE', pub.artifactType = 'Publication', pub.createdAt = datetime()
MERGE (corr:InformationArtifact:Publication {uid: 'hu:publication:pmid-30155270'})
ON CREATE SET corr.title = 'Author Correction: Repeat dose NRPT ...', corr.doi = '10.1038/s41514-018-0027-1', corr.pmid = '30155270', corr.publishedAt = date('2018-08-20'), corr.publicationKind = 'AUTHOR_CORRECTION', corr.artifactType = 'Publication', corr.createdAt = datetime()
MERGE (pub)-[:REPORTS_ON]->(study)
MERGE (corr)-[:CORRECTS]->(pub)
MERGE (ds:Entity:Dataset {uid: 'hu:dataset:nct02678611-participant-data'})
ON CREATE SET ds.name = 'NCT02678611 participant-level data', ds.datasetKind = 'TRIAL_PARTICIPANT_DATA', ds.accessLevel = 'ON_REQUEST', ds.entityType = 'Dataset', ds.createdAt = datetime()
MERGE (study)-[:PRODUCED_DATASET]->(ds)
MERGE (pub)-[:ANALYZES_DATASET {analysisRole: 'PRIMARY_REPORT'}]->(ds);

// Arms, interventions, components (per paper Methods and Results).
// status: statically-checked
MATCH (study:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
UNWIND [
  {arm: 'hu:arm:nct02678611-placebo', armName: 'Placebo', armType: 'PLACEBO_COMPARATOR', si: 'hu:intervention:nct02678611-placebo', siName: 'Placebo capsules x4 daily'},
  {arm: 'hu:arm:nct02678611-nrpt-1x', armName: 'NRPT 1X', armType: 'EXPERIMENTAL', si: 'hu:intervention:nct02678611-nrpt-1x', siName: 'NRPT 1X: 2 NRPT capsules + 2 placebo capsules daily'},
  {arm: 'hu:arm:nct02678611-nrpt-2x', armName: 'NRPT 2X', armType: 'EXPERIMENTAL', si: 'hu:intervention:nct02678611-nrpt-2x', siName: 'NRPT 2X: 4 NRPT capsules daily'}
] AS r
MERGE (arm:VersionedState:StudyArm {uid: r.arm})
ON CREATE SET arm.name = r.armName, arm.armType = r.armType, arm.plannedSize = 40, arm.stateType = 'StudyArm', arm.createdAt = datetime()
MERGE (si:VersionedState:StudyIntervention {uid: r.si})
ON CREATE SET si.name = r.siName, si.route = 'ORAL', si.dosageForm = 'CAPSULE', si.dosesPerDay = 1, si.schedule = 'once daily at breakfast', si.durationIso = 'P8W', si.stateType = 'StudyIntervention', si.createdAt = datetime()
MERGE (study)-[:HAS_ARM]->(arm)
MERGE (ai:Assertion {uid: r.si + '-assigned-assertion'})
ON CREATE SET ai.predicate = 'ASSIGNS_INTERVENTION', ai.status = 'ACCEPTED', ai.polarity = 'POSITIVE', ai.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (ai)-[:HAS_SUBJECT]->(arm)
MERGE (ai)-[:HAS_OBJECT]->(si)
WITH study, arm, si, ai
MATCH (armLoc:SourceLocator {uid: 'hu:locator:ctgov-nct02712593-arms'})
MERGE (ai)-[:SUPPORTED_BY]->(armLoc)
MERGE (arm)-[asg:ASSIGNS_INTERVENTION]->(si)
ON CREATE SET asg.assertionUid = ai.uid, asg.recordedFrom = ai.recordedAt, asg.relationshipUid = 'hu:rel:' + split(ai.uid, ':')[2];

// status: statically-checked
UNWIND [
  {si: 'hu:intervention:nct02678611-nrpt-1x', ic: 'hu:intervention-component:nct02678611-1x-nr', mat: 'hu:material:nct02678611-nr-as-supplied', qty: 250.0, txt: '250 mg of NR (2 capsules x 125 mg)'},
  {si: 'hu:intervention:nct02678611-nrpt-1x', ic: 'hu:intervention-component:nct02678611-1x-pt', mat: 'hu:material:nct02678611-pt-as-supplied', qty: 50.0, txt: '50 mg of PT (2 capsules x 25 mg)'},
  {si: 'hu:intervention:nct02678611-nrpt-2x', ic: 'hu:intervention-component:nct02678611-2x-nr', mat: 'hu:material:nct02678611-nr-as-supplied', qty: 500.0, txt: '500 mg of NR (4 capsules x 125 mg)'},
  {si: 'hu:intervention:nct02678611-nrpt-2x', ic: 'hu:intervention-component:nct02678611-2x-pt', mat: 'hu:material:nct02678611-pt-as-supplied', qty: 100.0, txt: '100 mg of PT (4 capsules x 25 mg)'}
] AS c
MATCH (si:StudyIntervention {uid: c.si}),
      (mat:IngredientMaterial {uid: c.mat}),
      (loc:SourceLocator {uid: 'hu:locator:pmid29184669-methods-intervention'})
MERGE (ic:VersionedState:InterventionComponent {uid: c.ic})
ON CREATE SET ic.quantity = c.qty, ic.unitCode = 'mg/d', ic.quantityBasis = 'PER_DAY',
              ic.massBasis = 'UNSPECIFIED',          // paper says "NR", not salt vs cation mass
              ic.verbatimDoseText = c.txt, ic.stateType = 'InterventionComponent', ic.createdAt = datetime()
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:' + substring(c.ic, 26) + '-uses-material'})
ON CREATE SET a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ic)
MERGE (a)-[:HAS_OBJECT]->(mat)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(mat)
ON CREATE SET u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2];

// Who provided the investigational product (correction) vs who says it supplied the NR (C&EN).
// PROVIDES_INVESTIGATIONAL_PRODUCT does not imply SUPPLIES_INGREDIENT_MATERIAL (FI-202).
// status: statically-checked
MATCH (elysium:Organization {uid: 'hu:org:elysium-health-inc'}),
      (chromadex:Organization {uid: 'hu:org:chromadex-inc'}),
      (si1:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'}),
      (si2:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-2x'}),
      (trialNr:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'}),
      (niagen:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (nrE:IngredientMaterial {uid: 'hu:material:elysium-nr-e'}),
      (corrLoc:SourceLocator {uid: 'hu:locator:pmid30155270-intervention-source'}),
      (cenLoc:SourceLocator {uid: 'hu:locator:cen-2018-supply-until-mid-2016'})
MERGE (aProv1:Assertion {uid: 'hu:assertion:elysium-provides-nct02678611-nrpt-1x'})
ON CREATE SET aProv1.predicate = 'PROVIDES_INVESTIGATIONAL_PRODUCT', aProv1.status = 'ACCEPTED', aProv1.polarity = 'POSITIVE', aProv1.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (aProv1)-[:HAS_SUBJECT]->(elysium)
MERGE (aProv1)-[:HAS_OBJECT]->(si1)
MERGE (aProv1)-[:SUPPORTED_BY]->(corrLoc)
MERGE (aProv2:Assertion {uid: 'hu:assertion:elysium-provides-nct02678611-nrpt-2x'})
ON CREATE SET aProv2.predicate = 'PROVIDES_INVESTIGATIONAL_PRODUCT', aProv2.status = 'ACCEPTED', aProv2.polarity = 'POSITIVE', aProv2.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (aProv2)-[:HAS_SUBJECT]->(elysium)
MERGE (aProv2)-[:HAS_OBJECT]->(si2)
MERGE (aProv2)-[:SUPPORTED_BY]->(corrLoc)
// ChromaDex's attributed statement: supplier of Elysium's NR until mid-2016 (trial ran Jan-Jul 2016).
MERGE (aSup:Assertion {uid: 'hu:assertion:chromadex-says-supplied-elysium-nr-until-mid-2016'})
ON CREATE SET aSup.predicate = 'SUPPLIES_INGREDIENT_MATERIAL', aSup.status = 'ACCEPTED', aSup.polarity = 'POSITIVE',   // ACCEPTED = accurately captured; its truth is contested by the competing hypotheses below (0.2.0 status semantics)
              aSup.validFrom = null, aSup.validFromBasis = 'UNKNOWN', aSup.validTo = datetime('2016-07-01T00:00:00Z'), aSup.validToPrecision = 'MONTH', aSup.validToBasis = 'STATED_BY_SOURCE',
              aSup.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (aSup)-[:HAS_SUBJECT]->(chromadex)
MERGE (aSup)-[:HAS_OBJECT]->(elysium)
MERGE (aSup)-[:ASSERTED_BY]->(chromadex)
MERGE (aSup)-[:SUPPORTED_BY]->(cenLoc)
// Competing identity hypotheses for the trial NR material. Neither is accepted; no merge.
MERGE (h1:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:nct02678611-nr-is-chromadex-niagen'})
ON CREATE SET h1.resolutionType = 'MATERIAL_IDENTITY', h1.resolutionStatus = 'UNRESOLVED', h1.score = null, h1.rationale = 'Trial ran Jan-Jul 2016; ChromaDex states it supplied Elysium NR until mid-2016 (attributed, disputed). Lot-level supply to the trial not established.', h1.assessmentType = 'ResolutionHypothesis', h1.methodVersion = 'resolution-v0.1', h1.status = 'PROPOSED', h1.createdAt = datetime()
MERGE (h2:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:nct02678611-nr-is-elysium-nr-e'})
ON CREATE SET h2.resolutionType = 'MATERIAL_IDENTITY', h2.resolutionStatus = 'UNRESOLVED', h2.score = null, h2.rationale = 'Current Basis label names Elysium NR; no source ties NR-E to 2016 trial lots.', h2.assessmentType = 'ResolutionHypothesis', h2.methodVersion = 'resolution-v0.1', h2.status = 'PROPOSED', h2.createdAt = datetime()
MERGE (h1)-[:PROPOSES_MATCH]->(trialNr)
MERGE (h1)-[:PROPOSES_MATCH]->(niagen)
MERGE (h2)-[:PROPOSES_MATCH]->(trialNr)
MERGE (h2)-[:PROPOSES_MATCH]->(nrE)
MERGE (h1)-[:COMPETES_WITH]->(h2)
MERGE (h1)-[:SUPPORTED_BY]->(cenLoc);

// "commercially known as Basis": a naming assertion about the intervention, not an EVALUATES edge.
// status: statically-checked
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'}),
      (loc:SourceLocator {uid: 'hu:locator:pmid29184669-results-trial-overview'})
MERGE (a:Assertion {uid: 'hu:assertion:nct02678611-nrpt-administered-as-basis'})
ON CREATE SET a.predicate = 'ADMINISTERED_AS_COMMERCIAL_PRODUCT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueString = 'Basis', a.asReportedName = 'NRPT (commercially known as Basis)', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(si)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// Conze / NIAGEN study (300 mg arm only).
// status: statically-checked
MATCH (niagen:IngredientMaterial {uid: 'hu:material:chromadex-niagen'}),
      (crystal:ChemicalForm {uid: 'hu:form:nr-chloride-crystal-niagen'}),
      (armLoc:SourceLocator {uid: 'hu:locator:ctgov-nct02712593-arms'}),
      (absLoc:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (study:Entity:Study {uid: 'hu:study:nct02712593-niagen'})
ON CREATE SET study.title = 'Repeat-dose NIAGEN in healthy overweight adults', study.studyKind = 'INTERVENTIONAL_RCT', study.entityType = 'Study', study.createdAt = datetime()
MERGE (reg:Entity:TrialRegistration {uid: 'hu:trial-registration:ctgov-nct02712593'})
ON CREATE SET reg.registry = 'ClinicalTrials.gov', reg.registrationId = 'NCT02712593', reg.entityType = 'TrialRegistration', reg.createdAt = datetime()
MERGE (rv:InformationArtifact:RegistrationVersion {uid: 'hu:registration-version:nct02712593-observed-2026-10-03'})
ON CREATE SET rv.observedAt = datetime('2026-10-03T00:00:00Z'), rv.overallStatus = 'COMPLETED', rv.enrollmentCount = 140, rv.resultsPosted = false, rv.studyType = 'INTERVENTIONAL', rv.phase = 'PHASE2', rv.siteCountries = ['CA'], rv.artifactType = 'RegistrationVersion', rv.createdAt = datetime()
MERGE (study)-[:REGISTERED_AS]->(reg)
MERGE (reg)-[hrv:HAS_REGISTRATION_VERSION]->(rv)
ON CREATE SET hrv.relationshipUid = 'hu:rel:' + split(rv.uid, ':')[2], hrv.recordedFrom = datetime('2026-10-03T00:00:00Z'), hrv.validFromBasis = 'OBSERVATION_ONLY', hrv.validToBasis = 'UNKNOWN'
MERGE (pub:InformationArtifact:Publication {uid: 'hu:publication:pmid-31278280'})
ON CREATE SET pub.title = 'Safety and Metabolism of Long-term Administration of NIAGEN (Nicotinamide Riboside Chloride) ...', pub.doi = '10.1038/s41598-019-46120-z', pub.pmid = '31278280', pub.publishedAt = date('2019-07-05'), pub.publicationKind = 'ARTICLE', pub.artifactType = 'Publication', pub.createdAt = datetime()
MERGE (pub)-[:REPORTS_ON]->(study)
MERGE (arm:VersionedState:StudyArm {uid: 'hu:arm:nct02712593-niagen-300'})
ON CREATE SET arm.name = 'Niagen 300', arm.armType = 'EXPERIMENTAL', arm.stateType = 'StudyArm', arm.createdAt = datetime()
MERGE (si:VersionedState:StudyIntervention {uid: 'hu:intervention:nct02712593-niagen-300'})
ON CREATE SET si.name = 'NIAGEN 300 mg/day', si.route = 'ORAL', si.dosageForm = null, si.durationIso = 'P8W', si.dosesPerDay = null, si.stateType = 'StudyIntervention', si.createdAt = datetime()
MERGE (ic:VersionedState:InterventionComponent {uid: 'hu:intervention-component:nct02712593-300-nr'})
ON CREATE SET ic.quantity = 300.0, ic.unitCode = 'mg/d', ic.quantityBasis = 'PER_DAY', ic.massBasis = 'UNSPECIFIED', ic.verbatimDoseText = '300 mg NR', ic.stateType = 'InterventionComponent', ic.createdAt = datetime()
MERGE (study)-[:HAS_ARM]->(arm)
MERGE (ai:Assertion {uid: 'hu:assertion:nct02712593-niagen-300-arm-assigned'})
ON CREATE SET ai.predicate = 'ASSIGNS_INTERVENTION', ai.status = 'ACCEPTED', ai.polarity = 'POSITIVE', ai.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (ai)-[:HAS_SUBJECT]->(arm)
MERGE (ai)-[:HAS_OBJECT]->(si)
MERGE (arm)-[asg:ASSIGNS_INTERVENTION]->(si)
ON CREATE SET asg.assertionUid = ai.uid, asg.recordedFrom = ai.recordedAt, asg.relationshipUid = 'hu:rel:nct02712593-niagen-300-arm-assigned'
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:nct02712593-300-nr-uses-niagen'})
ON CREATE SET a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ic)
MERGE (a)-[:HAS_OBJECT]->(niagen)
MERGE (a)-[:SUPPORTED_BY]->(armLoc)
MERGE (a)-[:SUPPORTED_BY]->(absLoc)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(niagen)
ON CREATE SET u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2]
MERGE (niagen)-[:HAS_CHEMICAL_FORM]->(crystal);

MATCH (ai:Assertion {uid: 'hu:assertion:nct02712593-niagen-300-arm-assigned'}), (loc:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (ai)-[:SUPPORTED_BY]->(loc);

// Current product composition edges (asserted; projected with assertion uid).
// status: statically-checked
UNWIND [
  {comp: 'hu:component:basis-current-nr-e', mat: 'hu:material:elysium-nr-e', loc: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10', a: 'hu:assertion:basis-current-nr-component-uses-nr-e'},
  {comp: 'hu:component:basis-current-pt', mat: 'hu:material:pterostilbene-unspecified-current-basis', loc: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10', a: 'hu:assertion:basis-current-pt-component-uses-pt'},
  {comp: 'hu:component:tru-niagen-300mg-niagen', mat: 'hu:material:chromadex-niagen', loc: 'hu:locator:truniagen-300mg-supplement-facts', a: 'hu:assertion:tru-niagen-300mg-component-uses-niagen'}
] AS r
MATCH (comp:IngredientComponent {uid: r.comp}), (mat:IngredientMaterial {uid: r.mat}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
ON CREATE SET a.predicate = 'USES_MATERIAL', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(comp)
MERGE (a)-[:HAS_OBJECT]->(mat)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (comp)-[u:USES_MATERIAL]->(mat)
ON CREATE SET u.assertionUid = a.uid, u.recordedFrom = a.recordedAt, u.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2];

// status: statically-checked
UNWIND [
  {p: 'hu:product:elysium-basis', v: 'hu:product-variant:basis-us-capsule-standard', f: 'hu:formulation:basis-us-current-2026-07-10', loc: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'},
  {p: 'hu:product:tru-niagen', v: 'hu:product-variant:tru-niagen-300mg-us-capsule', f: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03', loc: 'hu:locator:truniagen-300mg-supplement-facts'}
] AS r
MATCH (p:Product {uid: r.p}), (v:ProductVariant {uid: r.v}), (f:FormulationVersion {uid: r.f}), (loc:SourceLocator {uid: r.loc})
MERGE (av:Assertion {uid: r.v + '-has-variant-assertion'})
ON CREATE SET av.predicate = 'HAS_VARIANT', av.status = 'ACCEPTED', av.polarity = 'POSITIVE', av.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (av)-[:HAS_SUBJECT]->(p)
MERGE (av)-[:HAS_OBJECT]->(v)
MERGE (av)-[:SUPPORTED_BY]->(loc)
MERGE (af:Assertion {uid: r.f + '-of-variant-assertion'})
ON CREATE SET af.predicate = 'HAS_FORMULATION_VERSION', af.status = 'ACCEPTED', af.polarity = 'POSITIVE', af.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (af)-[:HAS_SUBJECT]->(v)
MERGE (af)-[:HAS_OBJECT]->(f)
MERGE (af)-[:SUPPORTED_BY]->(loc)
MERGE (p)-[hv:HAS_VARIANT]->(v) ON CREATE SET hv.assertionUid = av.uid, hv.recordedFrom = av.recordedAt, hv.relationshipUid = 'hu:rel:' + split(av.uid, ':')[2]
MERGE (v)-[hf:HAS_FORMULATION_VERSION]->(f) ON CREATE SET hf.assertionUid = af.uid, hf.recordedFrom = af.recordedAt, hf.relationshipUid = 'hu:rel:' + split(af.uid, ':')[2];


// ---------------------------------------------------------------------------
// 4. Outcomes, priority claims, results, adverse events, endpoint classes
// ---------------------------------------------------------------------------

// status: statically-checked
MATCH (study:Study {uid: 'hu:study:nct02678611-basis-nrpt'})
UNWIND [
  {uid: 'hu:outcome:nct02678611-nad-whole-blood', name: 'Whole-blood NAD+ (LC-MS/MS)', kind: 'BIOMARKER', tp: 'day 30, day 60', bm: 'hu:biomarker:nad-plus-whole-blood', bmName: 'NAD+ in whole blood', matrix: 'hu:anatomical-context:whole-blood', mName: 'whole blood'},
  {uid: 'hu:outcome:nct02678611-ldl-c', name: 'LDL cholesterol', kind: 'BIOMARKER', tp: 'day 30, day 60', bm: 'hu:biomarker:ldl-c-serum', bmName: 'LDL cholesterol in serum', matrix: 'hu:anatomical-context:serum', mName: 'serum'},
  {uid: 'hu:outcome:nct02678611-blood-pressure', name: 'Blood pressure', kind: 'BIOMARKER', tp: '8 weeks', bm: 'hu:biomarker:blood-pressure-brachial', bmName: 'Brachial blood pressure', matrix: 'hu:anatomical-context:systemic-circulation', mName: 'systemic circulation (brachial artery)'}
] AS o
MERGE (od:VersionedState:OutcomeDefinition {uid: o.uid})
ON CREATE SET od.name = o.name, od.measureKind = o.kind, od.timepoint = o.tp, od.stateType = 'OutcomeDefinition', od.createdAt = datetime()
MERGE (bm:Entity:Biomarker {uid: o.bm})
ON CREATE SET bm.name = o.bmName, bm.entityType = 'Biomarker', bm.createdAt = datetime()
MERGE (mx:Entity:AnatomicalContext {uid: o.matrix})
ON CREATE SET mx.name = o.mName, mx.contextKind = 'SPECIMEN_MATRIX', mx.entityType = 'AnatomicalContext', mx.createdAt = datetime()
MERGE (study)-[:DEFINES_OUTCOME]->(od)
MERGE (od)-[:MEASURES_BIOMARKER]->(bm)
MERGE (bm)-[:MEASURED_IN_MATRIX]->(mx);

// Priority is a per-source assertion: registry says SECONDARY, Discussion says "major efficacy endpoint".
// status: statically-checked
UNWIND [
  {a: 'hu:assertion:nct02678611-nad-priority-registry', od: 'hu:outcome:nct02678611-nad-whole-blood', v: 'SECONDARY', loc: 'hu:locator:ctgov-nct02678611-outcomes'},
  {a: 'hu:assertion:nct02678611-nad-priority-paper-discussion', od: 'hu:outcome:nct02678611-nad-whole-blood', v: 'PRIMARY', loc: 'hu:locator:pmid29184669-discussion-major-endpoint'},
  {a: 'hu:assertion:nct02678611-bp-priority-registry', od: 'hu:outcome:nct02678611-blood-pressure', v: 'PRIMARY', loc: 'hu:locator:ctgov-nct02678611-outcomes'}
] AS r
MATCH (od:OutcomeDefinition {uid: r.od}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
ON CREATE SET a.predicate = 'DECLARES_OUTCOME_PRIORITY', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.valueString = r.v, a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(od)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// Results. Within-arm vs between-arm is explicit.
// status: statically-checked
UNWIND [
  {uid: 'hu:study-result:nct02678611-nad-1x-d30', od: 'hu:outcome:nct02678611-nad-whole-blood', arm: 'hu:arm:nct02678611-nrpt-1x', est: 40.0, unit: '%', q: 'APPROXIMATE', ak: 'SECONDARY_PRESPECIFIED', ck: 'WITHIN_ARM_CHANGE', sc: 'SIGNIFICANT_FAVORABLE', ap: 'PER_PROTOCOL', loc: 'hu:locator:pmid29184669-results-nad'},
  {uid: 'hu:study-result:nct02678611-ldl-1x-vs-placebo-d60', od: 'hu:outcome:nct02678611-ldl-c', arm: 'hu:arm:nct02678611-nrpt-1x', est: 3.5, unit: '%', q: 'APPROXIMATE', ak: 'SECONDARY_PRESPECIFIED', ck: 'BETWEEN_ARM', sc: 'NOT_REPORTED', ap: 'INTENTION_TO_TREAT', loc: 'hu:locator:pmid29184669-results-lipids'}
] AS r
MATCH (od:OutcomeDefinition {uid: r.od}), (arm:StudyArm {uid: r.arm}), (loc:SourceLocator {uid: r.loc})
MERGE (res:InformationArtifact:StudyResult {uid: r.uid})
ON CREATE SET res.resultKind = 'PERCENT_CHANGE', res.estimate = r.est, res.unitCode = r.unit, res.estimateQualifier = r.q,
              res.analysisKind = r.ak, res.comparisonKind = r.ck, res.statisticalConclusion = r.sc,
              res.analysisPopulation = r.ap, res.multiplicityAdjusted = null,
              res.artifactType = 'StudyResult', res.createdAt = datetime()
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:RESULT_FOR_ARM]->(arm)
MERGE (res)-[:SUPPORTED_BY]->(loc);

// Comparator arm for the between-arm LDL result.
// status: statically-checked
MATCH (res:StudyResult {uid: 'hu:study-result:nct02678611-ldl-1x-vs-placebo-d60'}),
      (placebo:StudyArm {uid: 'hu:arm:nct02678611-placebo'})
MERGE (res)-[:RESULT_FOR_ARM {armRole: 'COMPARATOR'}]->(placebo);

// Adverse events: reported counts with collection method; zero serious AEs is a reported zero.
// status: statically-checked
UNWIND [
  {uid: 'hu:study-result:nct02678611-ae-any-placebo', arm: 'hu:arm:nct02678611-placebo', term: 'Any adverse event', ser: 'ANY', aff: 13, ev: 18},
  {uid: 'hu:study-result:nct02678611-ae-any-1x', arm: 'hu:arm:nct02678611-nrpt-1x', term: 'Any adverse event', ser: 'ANY', aff: 15, ev: 25},
  {uid: 'hu:study-result:nct02678611-ae-any-2x', arm: 'hu:arm:nct02678611-nrpt-2x', term: 'Any adverse event', ser: 'ANY', aff: 17, ev: 23},
  {uid: 'hu:study-result:nct02678611-sae-placebo', arm: 'hu:arm:nct02678611-placebo', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0},
  {uid: 'hu:study-result:nct02678611-sae-1x', arm: 'hu:arm:nct02678611-nrpt-1x', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0},
  {uid: 'hu:study-result:nct02678611-sae-2x', arm: 'hu:arm:nct02678611-nrpt-2x', term: 'Serious adverse event', ser: 'SERIOUS', aff: 0, ev: 0}
] AS r
MATCH (arm:StudyArm {uid: r.arm}), (loc:SourceLocator {uid: 'hu:locator:pmid29184669-results-adverse-events'})
MERGE (ae:InformationArtifact:StudyResult:AdverseEventResult {uid: r.uid})
ON CREATE SET ae.resultKind = 'ADVERSE_EVENT_COUNT', ae.eventTerm = r.term, ae.eventTermCode = null, ae.seriousness = r.ser,
              ae.participantsAffected = r.aff, ae.eventCount = r.ev, ae.participantsAtRisk = null,   // arm denominators not extracted
              ae.collectionMethod = 'SYSTEMATIC', ae.relatednessAssessor = 'INVESTIGATOR',
              ae.analysisKind = 'SAFETY', ae.comparisonKind = 'ARM_DESCRIPTIVE', ae.statisticalConclusion = 'NOT_TESTED',
              ae.artifactType = 'StudyResult', ae.createdAt = datetime()
MERGE (ae)-[:RESULT_FOR_ARM]->(arm)
MERGE (ae)-[:SUPPORTED_BY]->(loc);

// Conze result: 300 mg arm, +51% whole-blood NAD+.
// status: statically-checked
MATCH (study:Study {uid: 'hu:study:nct02712593-niagen'}),
      (arm:StudyArm {uid: 'hu:arm:nct02712593-niagen-300'}),
      (bm:Biomarker {uid: 'hu:biomarker:nad-plus-whole-blood'}),
      (loc:SourceLocator {uid: 'hu:locator:pmid31278280-abstract'})
MERGE (od:VersionedState:OutcomeDefinition {uid: 'hu:outcome-definition:nct02712593-nad-whole-blood'})
ON CREATE SET od.name = 'Whole-blood NAD+', od.measureKind = 'BIOMARKER', od.stateType = 'OutcomeDefinition', od.createdAt = datetime()
MERGE (study)-[:DEFINES_OUTCOME]->(od)
MERGE (od)-[:MEASURES_BIOMARKER]->(bm)
MERGE (res:InformationArtifact:StudyResult {uid: 'hu:study-result:nct02712593-nad-300'})
ON CREATE SET res.resultKind = 'PERCENT_CHANGE', res.estimate = 51.0, res.unitCode = '%', res.analysisKind = 'SECONDARY_PRESPECIFIED', res.comparisonKind = 'WITHIN_ARM_CHANGE', res.statisticalConclusion = 'SIGNIFICANT_FAVORABLE', res.artifactType = 'StudyResult', res.createdAt = datetime()
MERGE (res)-[:RESULT_FOR]->(od)
MERGE (res)-[:RESULT_FOR_ARM]->(arm)
MERGE (res)-[:SUPPORTED_BY]->(loc);

// Endpoint classifications (BellLabs assessments, context-of-use bound).
// A general context-of-use classification (FDA table row) is CLASSIFIES_BIOMARKER;
// a study-specific classification is CLASSIFIES_OUTCOME and points to the nearest context.
// status: statically-checked
MATCH (ldl:Biomarker {uid: 'hu:biomarker:ldl-c-serum'}),
      (fdaLoc:SourceLocator {uid: 'hu:locator:fda-surrogate-table-hypercholesterolemia-ldl-c'})
MERGE (ctx:EvidenceAssessment:EndpointClassification {uid: 'hu:endpoint-classification:ldl-c-fda-hypercholesterolemia-lipid-lowering'})
ON CREATE SET ctx.endpointClass = 'SURROGATE_ENDPOINT', ctx.biomarkerCategory = null, ctx.surrogateValidationLevel = 'VALIDATED',
              ctx.contextDiseaseOrUse = 'Hypercholesterolemia',
              ctx.contextPopulation = 'Patients with heterozygous familial and nonfamilial hypercholesterolemia',
              ctx.contextInterventionMechanism = 'Lipid-lowering', ctx.contextApprovalType = 'TRADITIONAL',
              ctx.rationale = 'FDA lists serum LDL-C as the basis of traditional approval in this context.',
              ctx.assessmentType = 'EndpointClassification', ctx.methodVersion = 'endpoint-class-v0.1', ctx.status = 'PROPOSED',
              ctx.recordedAt = datetime('2026-10-03T00:00:00Z'), ctx.createdAt = datetime()
MERGE (ctx)-[:CLASSIFIES_BIOMARKER]->(ldl)
MERGE (ctx)-[:SUPPORTED_BY]->(fdaLoc);

// status: statically-checked
UNWIND [
  {uid: 'hu:endpoint-classification:nct02678611-nad-whole-blood', od: 'hu:outcome:nct02678611-nad-whole-blood', cat: 'PHARMACODYNAMIC_RESPONSE', cm: 'NONE', near: null,
   rat: 'No context of use in which whole-blood NAD+ predicts a clinical outcome was found in the case packet.', loc: 'hu:locator:pmid29184669-results-nad'},
  {uid: 'hu:endpoint-classification:nct02678611-ldl-c', od: 'hu:outcome:nct02678611-ldl-c', cat: 'SAFETY', cm: 'PARTIAL', near: 'hu:endpoint-classification:ldl-c-fda-hypercholesterolemia-lipid-lowering',
   rat: 'NRPT is not a lipid-lowering intervention and the population was healthy; surrogate status does not transfer. LDL-C is a safety biomarker in this study.', loc: 'hu:locator:pmid29184669-results-lipids'}
] AS r
MATCH (od:OutcomeDefinition {uid: r.od}), (loc:SourceLocator {uid: r.loc})
MERGE (ec:EvidenceAssessment:EndpointClassification {uid: r.uid})
ON CREATE SET ec.endpointClass = 'BIOMARKER_NOT_SURROGATE', ec.biomarkerCategory = r.cat, ec.surrogateValidationLevel = 'NOT_ESTABLISHED',
              ec.contextMatch = r.cm, ec.rationale = r.rat,
              ec.assessmentType = 'EndpointClassification', ec.methodVersion = 'endpoint-class-v0.1', ec.status = 'PROPOSED',
              ec.recordedAt = datetime('2026-10-03T00:00:00Z'), ec.createdAt = datetime()
MERGE (ec)-[:CLASSIFIES_OUTCOME]->(od)
MERGE (ec)-[:SUPPORTED_BY]->(loc)
WITH ec, r
MATCH (nearCtx:EndpointClassification {uid: r.near})
MERGE (ec)-[:COMPARED_WITH_CONTEXT]->(nearCtx);


// ---------------------------------------------------------------------------
// 5. Evidence applicability: identity and dose dimensions explicit
// ---------------------------------------------------------------------------

// 5a. Basis trial 1X arm -> current Basis formulation.
// status: statically-checked
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'}),
      (target:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}),
      (res:StudyResult {uid: 'hu:study-result:nct02678611-nad-1x-d30'})
MERGE (ea:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:nct02678611-1x-to-basis-current'})
ON CREATE SET ea.assessmentType = 'EvidenceApplicability', ea.methodVersion = 'applicability-v0.1', ea.status = 'PROPOSED',
              ea.overallScore = null, ea.summary = 'Same declared actives and nominal amounts; trial NR material and mass basis unresolved; 8-week biomarker evidence only.',
              ea.recordedAt = datetime('2026-10-03T00:00:00Z'), ea.createdAt = datetime()
MERGE (ea)-[:HAS_EVIDENCE_TARGET]->(si)
MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(target)
MERGE (ea)-[:BASED_ON_EVIDENCE]->(res);

// status: statically-checked
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:nct02678611-1x-to-basis-current'})
UNWIND [
  {dim: 'MATERIAL_IDENTITY', cls: 'CATEGORICAL', verdict: 'UNKNOWN', identityLevel: 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED', ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: null, tCat: null,
   missing: ['supplier and specification of NR administered in NCT02678611', 'pterostilbene material administered in NCT02678611', 'whether NR-E existed or matched trial NR in 2016'],
   rat: 'Competing resolution hypotheses (ChromaDex NIAGEN vs Elysium NR-E); correction states only that Elysium provided the investigational product.',
   locs: ['hu:locator:pmid30155270-intervention-source', 'hu:locator:cen-2018-supply-until-mid-2016', 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {dim: 'ACTIVE_COMPOSITION', cls: 'CATEGORICAL', verdict: 'MATCH', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'SAME_ACTIVES', tCat: 'SAME_ACTIVES', missing: [],
   rat: 'Both declare NR and pterostilbene as the two actives.', locs: ['hu:locator:pmid29184669-methods-intervention', 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {dim: 'DOSE', cls: 'CONTINUOUS', verdict: 'PARTIAL', identityLevel: null, ev: 250.0, tv: 250.0, unit: 'mg', eqb: 'PER_DAY', tqb: 'PER_SERVING', emb: 'UNSPECIFIED', tmb: 'SALT_FORM', ratio: null, evCat: null, tCat: null,
   missing: ['mass basis of "NR" in the paper (salt vs cation)', 'label servings per day'],
   rat: 'Nominal amounts equal; ratio withheld because quantity basis (per day vs per serving) and mass basis (unspecified vs salt) differ.',
   locs: ['hu:locator:pmid29184669-methods-intervention', 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {dim: 'DOSAGE_FORM', cls: 'CATEGORICAL', verdict: 'PARTIAL', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'CAPSULE', tCat: 'CAPSULE',
   missing: ['current capsule strength and excipients'], rat: 'Trial: gelatin capsules of 125 mg NR + 25 mg PT with MCC, silicon dioxide, magnesium stearate; current capsule composition beyond actives not captured.',
   locs: ['hu:locator:pmid29184669-methods-intervention']},
  {dim: 'ROUTE', cls: 'CATEGORICAL', verdict: 'MATCH', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'ORAL', tCat: 'ORAL', missing: [], rat: 'Oral in both.', locs: ['hu:locator:pmid29184669-results-trial-overview']},
  {dim: 'SCHEDULE', cls: 'CONTINUOUS', verdict: 'UNKNOWN', identityLevel: null, ev: 1.0, tv: null, unit: '/d', eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'ONCE_DAILY_WITH_BREAKFAST', tCat: null,
   missing: ['label directions for use'], rat: 'Label directions not captured in the 2026-07-10 snapshot.', locs: ['hu:locator:pmid29184669-results-trial-overview']},
  {dim: 'DURATION', cls: 'CONTINUOUS', verdict: 'PARTIAL', identityLevel: null, ev: 56.0, tv: null, unit: 'd', eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: null, tCat: 'OPEN_ENDED',
   missing: [], rat: 'Studied 8 weeks plus 30-day follow-up; product is sold for open-ended daily use.', locs: ['hu:locator:pmid29184669-results-trial-overview']},
  {dim: 'POPULATION', cls: 'CATEGORICAL', verdict: 'PARTIAL', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'OVERLAPS', tCat: 'ADULTS_GENERAL',
   missing: [], rat: 'Healthy adults 60-80, BMI 18-35; excluded lipid-lowering drug users and B3 supplement users.', locs: ['hu:locator:ctgov-nct02678611-eligibility']},
  {dim: 'COMPARATOR', cls: 'CATEGORICAL', verdict: 'MATCH', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'PLACEBO', tCat: 'NO_TREATMENT', missing: [], rat: 'Placebo comparator matches a take-or-not decision.', locs: ['hu:locator:pmid29184669-methods-intervention']},
  {dim: 'OUTCOME_RELEVANCE', cls: 'CATEGORICAL', verdict: 'PARTIAL', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: 'BIOMARKER_NOT_SURROGATE', tCat: null,
   missing: [], rat: 'Main favorable finding is a pharmacodynamic biomarker; see endpoint classification.', locs: ['hu:locator:pmid29184669-results-nad']},
  {dim: 'STUDY_DESIGN_AND_QUALITY', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {dim: 'BACKGROUND_CONTEXT', cls: 'EXPLANATION_ONLY', verdict: 'NOT_SCORED', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: null, tCat: null, missing: [],
   rat: 'Participants avoided B3 supplements and multivitamins; consumers may not.', locs: []},
  {dim: 'RECENCY_AND_CORRECTIONS', cls: 'EXPLANATION_ONLY', verdict: 'NOT_SCORED', identityLevel: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, ratio: null, evCat: null, tCat: null, missing: [],
   rat: 'Author Correction (2018) added the product source; registry lists 1 site, paper reports 3; registry has no posted results.', locs: []}
] AS d
MERGE (dim:EvidenceAssessment:ApplicabilityDimension {uid: ea.uid + '-' + toLower(d.dim)})
ON CREATE SET dim.dimension = d.dim, dim.dimensionClass = d.cls, dim.verdict = d.verdict, dim.identityLevel = d.identityLevel,
              dim.evidenceValue = d.ev, dim.targetValue = d.tv, dim.unitCode = d.unit,
              dim.evidenceQuantityBasis = d.eqb, dim.targetQuantityBasis = d.tqb,
              dim.evidenceMassBasis = d.emb, dim.targetMassBasis = d.tmb, dim.ratio = d.ratio,
              dim.evidenceCategory = d.evCat, dim.targetCategory = d.tCat,
              dim.missingFacts = d.missing, dim.rationale = d.rat,
              dim.assessmentType = 'ApplicabilityDimension', dim.methodVersion = ea.methodVersion, dim.status = 'PROPOSED', dim.createdAt = datetime()
MERGE (ea)-[:HAS_DIMENSION]->(dim)
WITH dim, d
UNWIND d.locs AS locUid
MATCH (loc:SourceLocator {uid: locUid})
MERGE (dim)-[:SUPPORTED_BY]->(loc);

// 5b. NIAGEN 300 mg arm -> Tru Niagen 300mg (same branded material, spec version unknown).
// 5c. NIAGEN 300 mg arm -> current Basis (the trap: same substance, different material, extra active).
// status: statically-checked
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02712593-niagen-300'}),
      (tn:FormulationVersion {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'}),
      (bf:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}),
      (res:StudyResult {uid: 'hu:study-result:nct02712593-nad-300'})
MERGE (eaTn:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:nct02712593-300-to-tru-niagen-300'})
ON CREATE SET eaTn.assessmentType = 'EvidenceApplicability', eaTn.methodVersion = 'applicability-v0.1', eaTn.status = 'PROPOSED', eaTn.overallScore = null,
              eaTn.summary = 'Same branded material and nominal daily amount; specification version at trial time and mass basis unresolved.', eaTn.recordedAt = datetime('2026-10-03T00:00:00Z'), eaTn.createdAt = datetime()
MERGE (eaTn)-[:HAS_EVIDENCE_TARGET]->(si)
MERGE (eaTn)-[:ASSESSES_APPLICABILITY_TO]->(tn)
MERGE (eaTn)-[:BASED_ON_EVIDENCE]->(res)
MERGE (eaB:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:nct02712593-300-to-basis-current'})
ON CREATE SET eaB.assessmentType = 'EvidenceApplicability', eaB.methodVersion = 'applicability-v0.1', eaB.status = 'PROPOSED', eaB.overallScore = null,
              eaB.summary = 'Same substance only: different branded material; Basis adds pterostilbene.', eaB.recordedAt = datetime('2026-10-03T00:00:00Z'), eaB.createdAt = datetime()
MERGE (eaB)-[:HAS_EVIDENCE_TARGET]->(si)
MERGE (eaB)-[:ASSESSES_APPLICABILITY_TO]->(bf)
MERGE (eaB)-[:BASED_ON_EVIDENCE]->(res);

// status: statically-checked
UNWIND [
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'MATERIAL_IDENTITY', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: 'SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED', ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: ['NIAGEN specification version used in 2016-2017 lots'], rat: 'Both name NIAGEN.', locs: ['hu:locator:pmid31278280-abstract', 'hu:locator:truniagen-300mg-supplement-facts']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'ACTIVE_COMPOSITION', cls: 'CATEGORICAL', verdict: 'MATCH', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'SAME_ACTIVES', tCat: 'SAME_ACTIVES', missing: [], rat: 'Single active in both.', locs: ['hu:locator:truniagen-300mg-supplement-facts']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'DOSE', cls: 'CONTINUOUS', verdict: 'PARTIAL', il: null, ev: 300.0, tv: 300.0, unit: 'mg', eqb: 'PER_DAY', tqb: 'PER_SERVING', emb: 'UNSPECIFIED', tmb: 'SALT_FORM', evCat: null, tCat: null, missing: ['mass basis of "300 mg NR" in the paper', 'label servings per day'], rat: 'Nominal match; bases differ so ratio withheld.', locs: ['hu:locator:pmid31278280-abstract', 'hu:locator:truniagen-300mg-supplement-facts']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'DOSAGE_FORM', cls: 'CATEGORICAL', verdict: 'UNKNOWN', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: 'CAPSULE', missing: ['trial dosage form'], rat: 'Trial dosage form not extracted.', locs: ['hu:locator:ctgov-nct02712593-arms']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'ROUTE', cls: 'CATEGORICAL', verdict: 'MATCH', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'ORAL', tCat: 'ORAL', missing: [], rat: 'Oral.', locs: ['hu:locator:pmid31278280-abstract']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'SCHEDULE', cls: 'CONTINUOUS', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'DURATION', cls: 'CONTINUOUS', verdict: 'PARTIAL', il: null, ev: 56.0, tv: null, unit: 'd', eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: 'OPEN_ENDED', missing: [], rat: '8 weeks studied.', locs: ['hu:locator:pmid31278280-abstract']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'POPULATION', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'OVERLAPS', tCat: 'ADULTS_GENERAL', missing: [], rat: 'Overweight healthy adults 40-60 per registry.', locs: ['hu:locator:ctgov-nct02712593-eligibility']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'COMPARATOR', cls: 'CATEGORICAL', verdict: 'MATCH', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'PLACEBO', tCat: 'NO_TREATMENT', missing: [], rat: 'Placebo.', locs: ['hu:locator:ctgov-nct02712593-arms']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'OUTCOME_RELEVANCE', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'BIOMARKER_NOT_SURROGATE', tCat: null, missing: [], rat: 'Whole-blood NAD+.', locs: ['hu:locator:pmid31278280-abstract']},
  {ea: 'hu:applicability:nct02712593-300-to-tru-niagen-300', dim: 'STUDY_DESIGN_AND_QUALITY', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'MATERIAL_IDENTITY', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: 'SAME_SUBSTANCE_SAME_FORM_DIFFERENT_MATERIAL', ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: ['whether NR-E and NIAGEN share chemical form and specification'], rat: 'NIAGEN vs Elysium NR-E: same declared substance (NR chloride), different named materials.', locs: ['hu:locator:pmid31278280-abstract', 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'ACTIVE_COMPOSITION', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'EVIDENCE_SUBSET_OF_TARGET', tCat: 'NR_PLUS_PTEROSTILBENE', missing: [], rat: 'Basis adds pterostilbene, not studied in this trial.', locs: ['hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'DOSE', cls: 'CONTINUOUS', verdict: 'PARTIAL', il: null, ev: 300.0, tv: 250.0, unit: 'mg', eqb: 'PER_DAY', tqb: 'PER_SERVING', emb: 'UNSPECIFIED', tmb: 'SALT_FORM', evCat: null, tCat: null, missing: ['mass basis of "300 mg NR"', 'Basis servings per day'], rat: 'Nominal amounts differ; ratio withheld.', locs: ['hu:locator:pmid31278280-abstract', 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10']},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'DOSAGE_FORM', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'ROUTE', cls: 'CATEGORICAL', verdict: 'MATCH', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: 'ORAL', tCat: 'ORAL', missing: [], rat: 'Oral.', locs: ['hu:locator:pmid31278280-abstract']},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'SCHEDULE', cls: 'CONTINUOUS', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'DURATION', cls: 'CONTINUOUS', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'POPULATION', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'COMPARATOR', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'OUTCOME_RELEVANCE', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []},
  {ea: 'hu:applicability:nct02712593-300-to-basis-current', dim: 'STUDY_DESIGN_AND_QUALITY', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, ev: null, tv: null, unit: null, eqb: null, tqb: null, emb: null, tmb: null, evCat: null, tCat: null, missing: [], rat: null, locs: []}
] AS d
MATCH (ea:EvidenceApplicability {uid: d.ea})
MERGE (dim:EvidenceAssessment:ApplicabilityDimension {uid: d.ea + '-' + toLower(d.dim)})
ON CREATE SET dim.dimension = d.dim, dim.dimensionClass = d.cls, dim.verdict = d.verdict, dim.identityLevel = d.il,
              dim.evidenceValue = d.ev, dim.targetValue = d.tv, dim.unitCode = d.unit,
              dim.evidenceQuantityBasis = d.eqb, dim.targetQuantityBasis = d.tqb,
              dim.evidenceMassBasis = d.emb, dim.targetMassBasis = d.tmb, dim.ratio = null,
              dim.evidenceCategory = d.evCat, dim.targetCategory = d.tCat,
              dim.missingFacts = d.missing, dim.rationale = d.rat,
              dim.assessmentType = 'ApplicabilityDimension', dim.methodVersion = ea.methodVersion, dim.status = 'PROPOSED', dim.createdAt = datetime()
MERGE (ea)-[:HAS_DIMENSION]->(dim)
WITH dim, d
UNWIND d.locs AS locUid
MATCH (loc:SourceLocator {uid: locUid})
MERGE (dim)-[:SUPPORTED_BY]->(loc);


// ---------------------------------------------------------------------------
// 6. Mechanism steps: measured vs hypothesized; compartment-specific measurands
// ---------------------------------------------------------------------------

// status: statically-checked
UNWIND [
  {uid: 'hu:species:homo-sapiens', name: 'Homo sapiens', taxon: '9606'},
  {uid: 'hu:species:mus-musculus', name: 'Mus musculus', taxon: '10090'}
] AS s
MERGE (sp:Entity:Species {uid: s.uid})
ON CREATE SET sp.scientificName = s.name, sp.ncbiTaxonomyId = s.taxon, sp.entityType = 'Species', sp.createdAt = datetime();

// status: statically-checked
MERGE (muscle:Entity:AnatomicalContext {uid: 'hu:anatomical-context:skeletal-muscle'})
ON CREATE SET muscle.name = 'skeletal muscle', muscle.contextKind = 'TISSUE', muscle.entityType = 'AnatomicalContext', muscle.createdAt = datetime()
MERGE (musc:Entity:AnatomicalContext {uid: 'hu:anatomical-context:muscle-stem-cell'})
ON CREATE SET musc.name = 'muscle stem cell', musc.contextKind = 'CELL_TYPE', musc.entityType = 'AnatomicalContext', musc.createdAt = datetime()
MERGE (naad:Entity:Biomarker {uid: 'hu:biomarker:naad-skeletal-muscle'})
ON CREATE SET naad.name = 'Nicotinic acid adenine dinucleotide (NAAD) in skeletal muscle', naad.entityType = 'Biomarker', naad.createdAt = datetime()
MERGE (naad)-[:MEASURED_IN_MATRIX]->(muscle)
MERGE (sirt:Entity:MolecularEntity {uid: 'hu:molecular-entity:sirtuin-deacetylase-family'})
ON CREATE SET sirt.name = 'Sirtuin deacetylases (SIRT1-7)', sirt.entityKind = 'PROTEIN_FAMILY', sirt.entityType = 'MolecularEntity', sirt.createdAt = datetime()
MERGE (mito:Entity:Mechanism {uid: 'hu:mechanism:mitochondrial-oxidative-function'})
ON CREATE SET mito.name = 'Mitochondrial oxidative function', mito.entityType = 'Mechanism', mito.createdAt = datetime()
MERGE (zhNr:Entity:IngredientMaterial {uid: 'hu:material:zhang-2016-nr-as-supplied'})
ON CREATE SET zhNr.name = 'NR as administered in Zhang et al. 2016 (material and dose not extracted)', zhNr.materialKind = 'UNRESOLVED_MATERIAL', zhNr.entityType = 'IngredientMaterial', zhNr.createdAt = datetime();

// Contexts. The Basis arm context reuses the StudyArm (no duplicated exposure fields).
// status: statically-checked
MATCH (human:Species {uid: 'hu:species:homo-sapiens'}),
      (mouse:Species {uid: 'hu:species:mus-musculus'}),
      (blood:AnatomicalContext {uid: 'hu:anatomical-context:whole-blood'}),
      (muscle:AnatomicalContext {uid: 'hu:anatomical-context:skeletal-muscle'}),
      (musc:AnatomicalContext {uid: 'hu:anatomical-context:muscle-stem-cell'}),
      (arm1x:StudyArm {uid: 'hu:arm:nct02678611-nrpt-1x'}),
      (trialNr:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'}),
      (elhNr:IngredientMaterial {uid: 'hu:material:elhassan-2019-nr-as-supplied'}),
      (zhNr:IngredientMaterial {uid: 'hu:material:zhang-2016-nr-as-supplied'})
MERGE (cBasis:Occurrence:MechanismEvidenceContext {uid: 'hu:mech-context:nct02678611-1x-whole-blood'})
ON CREATE SET cBasis.setting = 'HUMAN_INTERVENTIONAL', cBasis.occurrenceType = 'MechanismEvidenceContext', cBasis.createdAt = datetime()
MERGE (cBasis)-[:IN_SPECIES]->(human)
MERGE (cBasis)-[:MEASURED_IN]->(blood)
MERGE (cBasis)-[:EXPOSED_TO]->(trialNr)
MERGE (cBasis)-[:IN_STUDY_ARM]->(arm1x)
MERGE (cElh:Occurrence:MechanismEvidenceContext {uid: 'hu:mech-context:elhassan-2019-nr-1g-21d-muscle'})
ON CREATE SET cElh.setting = 'HUMAN_INTERVENTIONAL', cElh.modelDescriptor = 'aged men, randomized placebo-controlled crossover',
              cElh.sexScope = 'MALE', cElh.sampleSize = 12,
              cElh.exposureAmount = 1000.0, cElh.exposureUnit = 'mg/d', cElh.exposureBasis = 'ABSOLUTE_PER_DAY',
              cElh.route = 'ORAL', cElh.exposureDurationIso = 'P21D',
              cElh.occurrenceType = 'MechanismEvidenceContext', cElh.createdAt = datetime()
MERGE (cElh)-[:IN_SPECIES]->(human)
MERGE (cElh)-[:MEASURED_IN]->(muscle)
MERGE (cElh)-[:EXPOSED_TO]->(elhNr)
MERGE (cZh:Occurrence:MechanismEvidenceContext {uid: 'hu:mech-context:zhang-2016-nr-aged-mice-musc'})
ON CREATE SET cZh.setting = 'IN_VIVO_MAMMAL', cZh.modelDescriptor = 'aged mice',
              cZh.exposureAmount = null, cZh.exposureUnit = null, cZh.exposureBasis = null,   // not extracted in session: unknown, not zero
              cZh.exposureStatus = 'NOT_EXTRACTED',
              cZh.occurrenceType = 'MechanismEvidenceContext', cZh.createdAt = datetime()
MERGE (cZh)-[:IN_SPECIES]->(mouse)
MERGE (cZh)-[:MEASURED_IN]->(musc)
MERGE (cZh)-[:EXPOSED_TO]->(zhNr);

// Step assertions with basisKind (KCR-3a).
// status: statically-checked
UNWIND [
  {a: 'hu:assertion:nct02678611-nrpt-1x-increases-nad-whole-blood', subj: 'hu:intervention:nct02678611-nrpt-1x', obj: 'hu:biomarker:nad-plus-whole-blood', pred: 'INCREASES_LEVEL_OF', pol: 'POSITIVE', basis: 'DIRECT_MEASUREMENT', ctx: 'hu:mech-context:nct02678611-1x-whole-blood', loc: 'hu:locator:pmid29184669-results-nad'},
  {a: 'hu:assertion:basis-paper-nr-supports-sirtuin-activity', subj: 'hu:material:nct02678611-nr-as-supplied', obj: 'hu:molecular-entity:sirtuin-deacetylase-family', pred: 'INCREASES_ACTIVITY_OF', pol: 'POSITIVE', basis: 'HYPOTHESIS', ctx: null, loc: 'hu:locator:pmid29184669-introduction-sirtuins'},
  {a: 'hu:assertion:elhassan-nr-increases-naad-muscle', subj: 'hu:material:elhassan-2019-nr-as-supplied', obj: 'hu:biomarker:naad-skeletal-muscle', pred: 'INCREASES_LEVEL_OF', pol: 'POSITIVE', basis: 'DIRECT_MEASUREMENT', ctx: 'hu:mech-context:elhassan-2019-nr-1g-21d-muscle', loc: 'hu:locator:pmid31412242-abstract'},
  {a: 'hu:assertion:elhassan-nr-sirtuin-proxy-no-change-muscle', subj: 'hu:material:elhassan-2019-nr-as-supplied', obj: 'hu:molecular-entity:sirtuin-deacetylase-family', pred: 'INCREASES_ACTIVITY_OF', pol: 'NEGATIVE', basis: 'DIRECT_MEASUREMENT', ctx: 'hu:mech-context:elhassan-2019-nr-1g-21d-muscle', loc: 'hu:locator:pmid31412242-results-figure3'},
  {a: 'hu:assertion:elhassan-nr-mito-function-no-change-muscle', subj: 'hu:material:elhassan-2019-nr-as-supplied', obj: 'hu:mechanism:mitochondrial-oxidative-function', pred: 'IMPROVES', pol: 'NEGATIVE', basis: 'DIRECT_MEASUREMENT', ctx: 'hu:mech-context:elhassan-2019-nr-1g-21d-muscle', loc: 'hu:locator:pmid31412242-results-figure3'},
  {a: 'hu:assertion:zhang-nr-improves-mito-function-aged-mice', subj: 'hu:material:zhang-2016-nr-as-supplied', obj: 'hu:mechanism:mitochondrial-oxidative-function', pred: 'IMPROVES', pol: 'POSITIVE', basis: 'DIRECT_MEASUREMENT', ctx: 'hu:mech-context:zhang-2016-nr-aged-mice-musc', loc: 'hu:locator:pmid27127236-abstract'}
] AS r
MATCH (s {uid: r.subj}), (o {uid: r.obj}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
ON CREATE SET a.predicate = r.pred, a.predicateClass = 'MECHANISM', a.polarity = r.pol, a.basisKind = r.basis,
              a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(loc)
WITH a, r
MATCH (ctx:MechanismEvidenceContext {uid: r.ctx})
MERGE (a)-[:OBSERVED_IN_CONTEXT]->(ctx);
// Note: the HYPOTHESIS row has ctx null; the trailing MATCH drops only that row's
// context link, after the assertion and its SUPPORTED_BY were already merged.

// Ingredient-mechanism -> formulation: EXPOSURE dimension needs human exposure evidence for the target material.
// status: statically-checked
MATCH (a:Assertion {uid: 'hu:assertion:elhassan-nr-increases-naad-muscle'}),
      (target:FormulationVersion {uid: 'hu:formulation:basis-us-current-2026-07-10'}),
      (absLoc:SourceLocator {uid: 'hu:locator:pmid31412242-abstract'}),
      (labelLoc:SourceLocator {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
MERGE (ea:EvidenceAssessment:EvidenceApplicability {uid: 'hu:applicability:elhassan-muscle-naad-to-basis-current'})
ON CREATE SET ea.assessmentType = 'EvidenceApplicability', ea.methodVersion = 'applicability-v0.1', ea.status = 'PROPOSED', ea.overallScore = null,
              ea.summary = 'Muscle NAD+ metabolome rose at 1 g/day NR for 21 days; Basis declares 250 mg NR chloride per serving; no human muscle exposure evidence for the Basis material or dose.',
              ea.recordedAt = datetime('2026-10-03T00:00:00Z'), ea.createdAt = datetime()
MERGE (ea)-[:HAS_EVIDENCE_TARGET]->(a)
MERGE (ea)-[:ASSESSES_APPLICABILITY_TO]->(target)
MERGE (dExp:EvidenceAssessment:ApplicabilityDimension {uid: 'hu:applicability:elhassan-muscle-naad-to-basis-current-exposure'})
ON CREATE SET dExp.dimension = 'EXPOSURE', dExp.dimensionClass = 'CONTINUOUS', dExp.verdict = 'UNKNOWN',
              dExp.evidenceValue = 1000.0, dExp.targetValue = 250.0, dExp.unitCode = 'mg',
              dExp.evidenceQuantityBasis = 'PER_DAY', dExp.targetQuantityBasis = 'PER_SERVING',
              dExp.evidenceMassBasis = 'UNSPECIFIED', dExp.targetMassBasis = 'SALT_FORM', dExp.ratio = null,
              dExp.missingFacts = ['human muscle exposure data for Elysium NR-E at the Basis dose', 'servings per day', 'mass basis of the 1 g dose'],
              dExp.rationale = 'Fourfold nominal difference before basis alignment; no linked human exposure result for the target material.',
              dExp.assessmentType = 'ApplicabilityDimension', dExp.methodVersion = 'applicability-v0.1', dExp.status = 'PROPOSED', dExp.createdAt = datetime()
MERGE (ea)-[:HAS_DIMENSION]->(dExp)
MERGE (dExp)-[:SUPPORTED_BY]->(absLoc)
MERGE (dExp)-[:SUPPORTED_BY]->(labelLoc);

// status: statically-checked
MATCH (ea:EvidenceApplicability {uid: 'hu:applicability:elhassan-muscle-naad-to-basis-current'})
UNWIND [
  {dim: 'MATERIAL_IDENTITY', cls: 'CATEGORICAL', verdict: 'UNKNOWN', il: 'SAME_SUBSTANCE_MATERIAL_UNRESOLVED', missing: ['NR material used by Elhassan et al.'], rat: 'Material not extracted.', locs: ['hu:locator:pmid31412242-abstract']},
  {dim: 'ROUTE', cls: 'CATEGORICAL', verdict: 'MATCH', il: null, missing: [], rat: 'Oral.', locs: ['hu:locator:pmid31412242-abstract']},
  {dim: 'DURATION', cls: 'CONTINUOUS', verdict: 'PARTIAL', il: null, missing: [], rat: '21 days studied.', locs: ['hu:locator:pmid31412242-abstract']},
  {dim: 'POPULATION', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: null, missing: [], rat: '12 aged men.', locs: ['hu:locator:pmid31412242-abstract']},
  {dim: 'OUTCOME_RELEVANCE', cls: 'CATEGORICAL', verdict: 'PARTIAL', il: null, missing: [], rat: 'Tissue metabolome change; bioenergetics unchanged.', locs: ['hu:locator:pmid31412242-results-figure3']},
  {dim: 'STUDY_DESIGN_AND_QUALITY', cls: 'CATEGORICAL', verdict: 'NOT_ASSESSED', il: null, missing: [], rat: null, locs: []}
] AS d
MERGE (dim:EvidenceAssessment:ApplicabilityDimension {uid: ea.uid + '-' + toLower(d.dim)})
ON CREATE SET dim.dimension = d.dim, dim.dimensionClass = d.cls, dim.verdict = d.verdict, dim.identityLevel = d.il,
              dim.missingFacts = d.missing, dim.rationale = d.rat,
              dim.assessmentType = 'ApplicabilityDimension', dim.methodVersion = ea.methodVersion, dim.status = 'PROPOSED', dim.createdAt = datetime()
MERGE (ea)-[:HAS_DIMENSION]->(dim)
WITH dim, d
UNWIND d.locs AS locUid
MATCH (loc:SourceLocator {uid: locUid})
MERGE (dim)-[:SUPPORTED_BY]->(loc);


// ---------------------------------------------------------------------------
// 7. Versioned synthesis: what changed the picture, by which criterion
// ---------------------------------------------------------------------------

// status: statically-checked
MATCH (zh:Assertion {uid: 'hu:assertion:zhang-nr-improves-mito-function-aged-mice'}),
      (elh:Assertion {uid: 'hu:assertion:elhassan-nr-mito-function-no-change-muscle'}),
      (elhPub:SourceLocator {uid: 'hu:locator:pmid31412242-results-figure3'})
MERGE (v1:EvidenceAssessment:EvidenceSynthesis {uid: 'hu:synthesis:nr-muscle-mito-function-older-humans-v1'})
ON CREATE SET v1.claimText = 'Oral NR improves skeletal muscle mitochondrial function in older humans',
              v1.verdict = 'INSUFFICIENT', v1.evidenceCutoff = date('2019-05-31'),
              v1.recordedAt = datetime('2026-10-03T12:00:00Z'),   // illustrative recorded time for the example
              v1.assessmentType = 'EvidenceSynthesis', v1.methodVersion = 'synthesis-v0.1', v1.status = 'ACCEPTED', v1.createdAt = datetime()
MERGE (v1)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(zh)
MERGE (v2:EvidenceAssessment:EvidenceSynthesis {uid: 'hu:synthesis:nr-muscle-mito-function-older-humans-v2'})
ON CREATE SET v2.claimText = 'Oral NR improves skeletal muscle mitochondrial function in older humans',
              v2.verdict = 'INSUFFICIENT', v2.evidenceCutoff = date('2019-08-31'),
              v2.recordedAt = datetime('2026-10-03T12:30:00Z'),
              v2.rationale = 'Verdict label unchanged; first human direct measurement (1 g/day, 21 days, 12 aged men) found respiration, citrate synthase, and mtDNA unchanged. Small and short; weakens, does not refute.',
              v2.assessmentType = 'EvidenceSynthesis', v2.methodVersion = 'synthesis-v0.1', v2.status = 'ACCEPTED', v2.createdAt = datetime()
MERGE (v2)-[:INCLUDES_RESULT {inputRole: 'SUPPORTIVE'}]->(zh)
MERGE (v2)-[:INCLUDES_RESULT {inputRole: 'CONTRADICTING'}]->(elh)
MERGE (v2)-[:SUPERSEDES]->(v1)
MERGE (v2)-[:TRIGGERED_BY {criterionCode: 'HUMAN_DIRECT_MEASUREMENT_NULL', effectOnVerdict: 'WEAKENED', evidencePublishedAt: date('2019-08-13')}]->(elh)
MERGE (v2)-[:SUPPORTED_BY]->(elhPub);


// ---------------------------------------------------------------------------
// NEGATIVE TEST (do not run against a shared database). Each statement below
// reintroduces a collapse; the matching validation query must then return rows.
// ---------------------------------------------------------------------------
// status: statically-checked
// MATCH (s:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (p:Product {uid: 'hu:product:elysium-basis'})
// MERGE (s)-[:EVALUATES]->(p);                                                   // -> F-1 returns a row
//
// MATCH (d:ApplicabilityDimension {uid: 'hu:applicability:nct02712593-300-to-basis-current-material_identity'})
// SET d.verdict = 'MATCH', d.identityLevel = 'SAME_BRANDED_MATERIAL_SAME_SPEC';   // -> F-2 returns a row
//
// MATCH (p:Product {uid: 'hu:product:elysium-basis'}), (m:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'})
// MERGE (p)-[:CONTAINS]->(m);                                                    // -> F-3 returns a row
//
// MATCH (m:IngredientMaterial {uid: 'hu:material:nct02678611-pt-as-supplied'}), (s:MolecularEntity {uid: 'hu:molecular-entity:sirtuin-deacetylase-family'})
// MERGE (m)-[:AFFECTS_MECHANISM {projectionOfAssertionUid: 'hu:assertion:basis-paper-nr-supports-sirtuin-activity'}]->(s);   // -> F-5 returns a row
//
// MATCH (e:Organization {uid: 'hu:org:elysium-health-inc'}), (m:IngredientMaterial {uid: 'hu:material:nct02678611-nr-as-supplied'})
// MERGE (e)-[:SUPPLIES_INGREDIENT_MATERIAL]->(m);                                // -> F-6 returns a row


// ===========================================================================
// VALIDATION (fixture-specific). Each returns zero rows on this fixture.
// General invariants are in lanes/lane2/validation.cypher (V-2xx).
// ===========================================================================

// F-1: no direct edge from study-side records to commercial identities (R2, FI-201).
// status: statically-checked
MATCH (s)-[r]->(p)
WHERE (s:Study OR s:StudyArm OR s:StudyResult OR s:Publication OR s:StudyIntervention)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion)
RETURN s.uid AS studySide, type(r) AS rel, p.uid AS commercialTarget;

// F-2: MATERIAL_IDENTITY at branded-material level or higher requires the same material node
// on both sides (INV-008: no identity from shared substance or name).
// status: statically-checked
MATCH (ea:EvidenceApplicability)-[:HAS_DIMENSION]->(d:ApplicabilityDimension {dimension: 'MATERIAL_IDENTITY'})
WHERE d.identityLevel IN ['SAME_LOT', 'SAME_FORMULATION_VERSION', 'SAME_BRANDED_MATERIAL_SAME_SPEC', 'SAME_BRANDED_MATERIAL_SPEC_UNRESOLVED']
  AND NOT EXISTS {
    MATCH (ea)-[:HAS_EVIDENCE_TARGET]->(:StudyIntervention)-[:HAS_INTERVENTION_COMPONENT]->(:InterventionComponent)-[:USES_INTERVENTION_MATERIAL]->(m:IngredientMaterial),
          (ea)-[:ASSESSES_APPLICABILITY_TO]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(m)
  }
RETURN ea.uid AS assessment, d.identityLevel AS claimedLevel;

// F-3: trial-time material is not composition of the current product (derived CONTAINS must
// regenerate from a FormulationVersion path).
// status: statically-checked
MATCH (p)-[c:CONTAINS]->(m:IngredientMaterial)
WHERE (p:Product OR p:ProductVariant)
  AND NOT EXISTS {
    MATCH (p)-[:HAS_VARIANT*0..1]->(:ProductVariant)-[:HAS_FORMULATION_VERSION]->(:FormulationVersion)-[:HAS_INGREDIENT_COMPONENT]->(:IngredientComponent)-[:USES_MATERIAL]->(m)
  }
RETURN p.uid AS product, m.uid AS materialNotInAnyFormulation;

// F-4: competing material hypotheses must keep two distinct candidate nodes until one is
// ACCEPTED; a node merge (e.g. trial NR merged into NR-E) leaves a hypothesis with one target.
// status: statically-checked
MATCH (h:ResolutionHypothesis {resolutionType: 'MATERIAL_IDENTITY'})-[:PROPOSES_MATCH]->(m)
WITH h, collect(DISTINCT m) AS candidates
WHERE h.resolutionStatus <> 'ACCEPTED' AND size(candidates) < 2
RETURN h.uid AS hypothesisWithCollapsedCandidates;

// F-5: mechanism projections only from ACCEPTED DIRECT_MEASUREMENT assertions (M5, V-233).
// status: statically-checked
MATCH (x)-[r:AFFECTS_MECHANISM|MODULATES|APPLIES_TO_SPECIES|INFLUENCES_OUTCOME]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.projectionOfAssertionUid})
WITH x, r, y, a
WHERE a IS NULL OR a.basisKind <> 'DIRECT_MEASUREMENT' OR a.status <> 'ACCEPTED'
RETURN x.uid AS fromUid, type(r) AS rel, y.uid AS toUid, a.basisKind AS projectedBasis;

// F-6: PROVIDES_INVESTIGATIONAL_PRODUCT does not imply supplying the ingredient material (FI-202).
// status: statically-checked
MATCH (o:Organization)-[s:SUPPLIES_INGREDIENT_MATERIAL]->(m)
WHERE s.projectionOfAssertionUid IS NULL
RETURN o.uid AS organization, m.uid AS material;

// F-7: a level-change step's measured compartment must equal the measurand's matrix (M1, FI-301).
// status: statically-checked
MATCH (a:Assertion {predicate: 'INCREASES_LEVEL_OF'})-[:HAS_OBJECT]->(b:Biomarker)-[:MEASURED_IN_MATRIX]->(mx:AnatomicalContext),
      (a)-[:OBSERVED_IN_CONTEXT]->(:MechanismEvidenceContext)-[:MEASURED_IN]->(ctxSite:AnatomicalContext)
WHERE ctxSite.uid <> mx.uid
RETURN a.uid AS assertion, b.uid AS measurand, ctxSite.uid AS measuredSite;

// F-8: registry "no posted results" is not "no results" (FI-203). Informational: expected rows
// list studies with resultsPosted=false that nonetheless have a results publication.
// status: statically-checked (informational, rows expected: NCT02678611, NCT02712593)
MATCH (s:Study)-[:REGISTERED_AS]->(:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv:RegistrationVersion {resultsPosted: false}),
      (pub:Publication {publicationKind: 'ARTICLE'})-[:REPORTS_ON]->(s)
RETURN s.uid AS study, rv.observedAt AS registryObservedAt, pub.pmid AS resultsPublication;

// F-9: Study identity nodes carry no registry status or publication ids (R10).
// status: statically-checked
MATCH (s:Study)
WHERE s.overallStatus IS NOT NULL OR s.hasResults IS NOT NULL OR s.pmid IS NOT NULL OR s.doi IS NOT NULL OR s.evidenceLevel IS NOT NULL
RETURN s.uid AS studyWithRegistryOrAssessmentFields;


// ---------------------------------------------------------------------------
// Assertions behind registry, publication and material-form edges
// Asserted edges are projections of assertions (catalog 0.2.0 asserted_edge profile). The record-derived facts below were
// created as bare edges by the lane; each now has its authorizing assertion, cited to the registry, publication or page
// snapshot it was read from, and the edge carries assertionUid, recordedFrom and relationshipUid.
// status: statically-checked, executed
UNWIND [
  {pred: 'REGISTERED_AS', s: 'hu:study:nct02678611-basis-nrpt', o: 'hu:trial-registration:ctgov-nct02678611', loc: 'hu:locator:ctgov-nct02678611-status'},
  {pred: 'REGISTERED_AS', s: 'hu:study:nct02712593-niagen', o: 'hu:trial-registration:ctgov-nct02712593', loc: 'hu:locator:ctgov-nct02712593-arms'},
  {pred: 'REPORTS_ON', s: 'hu:publication:pmid-29184669', o: 'hu:study:nct02678611-basis-nrpt', loc: 'hu:locator:pmid29184669-results-trial-overview'},
  {pred: 'REPORTS_ON', s: 'hu:publication:pmid-31278280', o: 'hu:study:nct02712593-niagen', loc: 'hu:locator:pmid31278280-abstract'},
  {pred: 'PRODUCED_DATASET', s: 'hu:study:nct02678611-basis-nrpt', o: 'hu:dataset:nct02678611-participant-data', loc: 'hu:locator:pmid29184669-results-trial-overview'},
  {pred: 'ANALYZES_DATASET', s: 'hu:publication:pmid-29184669', o: 'hu:dataset:nct02678611-participant-data', loc: 'hu:locator:pmid29184669-results-trial-overview'},
  {pred: 'CORRECTS', s: 'hu:publication:pmid-30155270', o: 'hu:publication:pmid-29184669', loc: 'hu:locator:pmid30155270-intervention-source'},
  {pred: 'FORM_OF_SUBSTANCE', s: 'hu:form:nr-chloride-crystal-niagen', o: 'hu:substance:nicotinamide-riboside-chloride', loc: 'hu:locator:pmid31278280-abstract'},
  {pred: 'HAS_CHEMICAL_FORM', s: 'hu:material:chromadex-niagen', o: 'hu:form:nr-chloride-crystal-niagen', loc: 'hu:locator:pmid31278280-abstract'}
] AS row
MATCH (s {uid: row.s}), (o {uid: row.o}), (l:SourceLocator {uid: row.loc})
MERGE (a:Assertion {uid: 'hu:assertion:' + toLower(replace(row.pred, '_', '-')) + '-' + split(row.s, ':')[2] + '-' + split(row.o, ':')[2]})
ON CREATE SET a.predicate = row.pred, a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-03T00:00:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
WITH row, s, o, a
MATCH (s)-[r]->(o) WHERE type(r) = row.pred
SET r.assertionUid = a.uid, r.recordedFrom = a.recordedAt, r.relationshipUid = 'hu:rel:' + split(a.uid, ':')[2];

// ---------------------------------------------------------------------------
// Capture-fidelity acceptance (catalog 0.2.0, INV-103). Every ACCEPTED, REJECTED or DISPUTED status is a projection of a
// CAPTURE_FIDELITY adjudication. This fixture records one policy adjudication (reviewerType POLICY) covering the captured
// assertions it created; it says nothing about whether any proposition is true (that is a SUPPORT adjudication).
// status: statically-checked, executed
MATCH (a:Assertion)
WHERE a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:study-vs-product-mismatch-capture-fidelity-policy-2026-10-04'})
ON CREATE SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1', j.status = 'FINAL',
    j.rationale = 'Fixture capture policy: the recorded propositions match the cited spans as read by the authoring lane.',
    j.reviewedAt = datetime('2026-10-04T00:00:00Z'), j.recordedAt = datetime('2026-10-04T00:00:00Z'), j.createdAt = datetime('2026-10-04T00:00:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
