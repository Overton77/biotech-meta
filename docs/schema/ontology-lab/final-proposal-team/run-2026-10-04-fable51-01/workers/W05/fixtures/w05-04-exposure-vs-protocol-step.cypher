// =====================================================================================================================
// W05 fixture 04: characterized Exposure versus the same agent in a protocol step (minimal pair).
//  E1  "chronic oral dietary selenium" (EPA IRIS Selenium and Compounds, RfD section I.A): route ORAL, CHRONIC,
//      medium diet, no intensity on the node. EPA's RfD (5E-3 mg/kg/day, NOAEL 0.015, UF 3) is an Assertion whose
//      subject is E1; it is not a property of the Exposure and not a verdict that any protocol is safe.
//  E2  "dietary selenium intake, high-selenium area, adult males" (Yang et al. 1989b as summarized by IRIS):
//      intensity 1438 ug/d ABSOLUTE_PER_DAY, LIFETIME ("based on lifetime exposure").
//  S1  a SYNTHETIC public protocol step "eat two Brazil nuts daily" (W16 types) that USES the base FoodItem.
//  The step and the exposures share an agent path (Brazil nut -> selenium) but no edge connects step and Exposure:
//  a step never establishes a characterized exposure (forbidden implication PROTOCOL_STEP_USES_AGENT ->
//  EXPOSURE_CHARACTERIZED, V-W05-10). Real public facts: EPA IRIS landing page and summary PDF (Firecrawl 2026-10-04).
// =====================================================================================================================

MERGE (a:Agent:Entity {uid: 'hu:agent:w05-curation'})
SET a.entityType = 'Agent', a.name = 'W05 fixture curation (synthetic)', a.agentKind = 'MANUAL_AGENT', a.createdAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC';

MERGE (o:Organization:Entity {uid: 'hu:org:us-epa'})
SET o.entityType = 'Organization', o.name = 'U.S. Environmental Protection Agency', o.createdAt = datetime('2026-10-04T02:00:00Z'), o.privacyClass = 'PUBLIC';

MERGE (s:ChemicalSubstance:Entity {uid: 'hu:substance:selenium'})
SET s.entityType = 'ChemicalSubstance', s.preferredName = 'selenium', s.name = 'selenium', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MERGE (f:FoodItem:IngredientMaterial:Entity {uid: 'hu:material:food-brazil-nut'})
SET f.entityType = 'FoodItem', f.materialKind = 'FOOD', f.name = 'Brazil nut (preparation not specified)', f.createdAt = datetime('2026-10-04T02:00:00Z'), f.privacyClass = 'PUBLIC';

MERGE (s:Source:Entity {uid: 'hu:source:epa-iris-0472-summary'})
SET s.entityType = 'Source', s.canonicalUri = 'https://iris.epa.gov/static/pdfs/0472_summary.pdf', s.sourceKind = 'REGULATORY_RECORD',
    s.publisher = 'U.S. EPA, Integrated Risk Information System', s.createdAt = datetime('2026-10-04T02:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:epa-iris-0472-summary'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:epa-iris-0472-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T01:05:00Z'), sn.observedAt = datetime('2026-10-04T01:05:00Z'),
    sn.publishedAt = datetime('1991-06-01T00:00:00Z'),
    sn.contentHash = 'sha256:39f83269d723fe22bb3bfc1957e5665e4ce69729fd9708ec2e9aa6f5a43570c5', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.captureNote = 'PDF pages 1-6 of 23 parsed; RfD section only', sn.createdAt = datetime('2026-10-04T02:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:epa-iris-0472-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:epa-iris-0472-rfd-table'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION', l.section = 'I.A. Reference Dose for Chronic Oral Exposure (RfD)',
    l.exact = 'Clinical selenosis | NOAEL: 0.015 mg/kg/day | 3 | 1 | 5E-3 mg/kg/day', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:epa-iris-0472-2026-10-04'})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:epa-iris-0472-yang-intakes'})
SET l.artifactType = 'SourceLocator', l.uri = sn.canonicalUri, l.selectorKind = 'SECTION', l.section = 'I.A.2 principal and supporting studies',
    l.exact = 'The daily average Se intakes, based on lifetime exposure, 70, 195 and 1438 ug for adult males', l.createdAt = datetime('2026-10-04T02:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---- E1: characterization without intensity ----
MATCH (se:ChemicalSubstance {uid: 'hu:substance:selenium'})
MERGE (e:Exposure:Entity {uid: 'hu:exposure:selenium-oral-chronic-dietary'})
SET e.entityType = 'Exposure', e.name = 'Selenium, chronic oral (dietary) exposure', e.setting = 'DIETARY', e.route = 'ORAL', e.mediumText = 'diet',
    e.durationCategory = 'CHRONIC', e.durationText = 'Reference Dose for Chronic Oral Exposure', e.durationIso = NULL,
    e.intensityValue = NULL, e.intensityUnitCode = NULL, e.intensityBasis = NULL,
    e.characterizationHash = 'sha256:synthetic-exposure-tuple-e1', e.createdAt = datetime('2026-10-04T02:00:00Z'), e.privacyClass = 'PUBLIC'
MERGE (e)-[r:HAS_EXPOSURE_AGENT]->(se)
SET r.orderIndex = 0;

// ---- E2: characterization with intensity (study population summarized by IRIS) ----
MATCH (se:ChemicalSubstance {uid: 'hu:substance:selenium'})
MERGE (e:Exposure:Entity {uid: 'hu:exposure:selenium-dietary-high-se-area-adult-male-1438ugd'})
SET e.entityType = 'Exposure', e.name = 'Selenium dietary intake, high-selenium area of China, adult males (Yang 1989b)', e.setting = 'DIETARY', e.route = 'ORAL',
    e.mediumText = 'diet (area with unusually high environmental selenium)', e.durationCategory = 'LIFETIME', e.durationText = 'based on lifetime exposure',
    e.intensityValue = 1438.0, e.intensityUnitCode = 'ug/d', e.intensityBasis = 'ABSOLUTE_PER_DAY',
    e.intensityText = 'daily average Se intake 1438 ug for adult males in the high-selenium area',
    e.characterizationHash = 'sha256:synthetic-exposure-tuple-e2', e.createdAt = datetime('2026-10-04T02:00:00Z'), e.privacyClass = 'PUBLIC'
MERGE (e)-[r:HAS_EXPOSURE_AGENT]->(se)
SET r.orderIndex = 0;

// ---- statements about the exposures (Assertions, not node properties) ----
MATCH (e:Exposure {uid: 'hu:exposure:selenium-oral-chronic-dietary'}), (o:Organization {uid: 'hu:org:us-epa'}), (l:SourceLocator {uid: 'hu:locator:epa-iris-0472-rfd-table'})
MERGE (a:Assertion {uid: 'hu:assertion:epa-iris-selenium-oral-rfd'})
SET a.predicate = 'HAS_REFERENCE_DOSE', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CALCULATED',
    a.derivationRule = 'IRIS RfD = NOAEL 0.015 mg/kg/day / UF 3 x MF 1', a.predicateClass = 'QUANTITY',
    a.valueNumber = 0.005, a.unitCode = 'mg/kg/d', a.quantityBasis = 'PER_KG_BODY_WEIGHT_PER_DAY', a.jurisdiction = 'US',
    a.validFrom = datetime('1991-06-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-c01'
MERGE (a)-[:HAS_SUBJECT]->(e) MERGE (a)-[:ASSERTED_BY]->(o) MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (e:Exposure {uid: 'hu:exposure:selenium-dietary-high-se-area-adult-male-1438ugd'}), (o:Organization {uid: 'hu:org:us-epa'}), (l:SourceLocator {uid: 'hu:locator:epa-iris-0472-yang-intakes'})
MERGE (a:Assertion {uid: 'hu:assertion:epa-iris-yang-high-se-intake-reported'})
SET a.predicate = 'CHARACTERIZES_EXPOSURE_IN_POPULATION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.valueString = 'approximately 400 individuals living in an area of China with unusually high environmental concentrations of selenium',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'sha256:synthetic-w05-c02'
MERGE (a)-[:HAS_SUBJECT]->(e) MERGE (a)-[:ASSERTED_BY]->(o) MERGE (a)-[:SUPPORTED_BY]->(l);

// ---- S1: synthetic public protocol step using the same agent path (W16 types) ----
MERGE (p:Protocol:Entity {uid: 'hu:protocol:synthetic-brazil-nut-daily'})
SET p.entityType = 'Protocol', p.name = 'Synthetic: two Brazil nuts a day', p.protocolType = 'NUTRITION', p.createdAt = datetime('2026-10-04T02:00:00Z'), p.privacyClass = 'PUBLIC';

MATCH (p:Protocol {uid: 'hu:protocol:synthetic-brazil-nut-daily'})
MERGE (ed:ProtocolEdition:VersionedState {uid: 'hu:protocol-edition:synthetic-brazil-nut-daily-e1'})
SET ed.stateType = 'ProtocolEdition', ed.editionLabel = 'e1', ed.payloadHash = 'sha256:synthetic-w05-ed1', ed.createdAt = datetime('2026-10-04T02:00:00Z'), ed.privacyClass = 'PUBLIC'
MERGE (p)-[r:HAS_PROTOCOL_EDITION]->(ed)
SET r.relationshipUid = 'hu:rel:hpe-synthetic-brazil-nut-e1', r.assertionUid = 'hu:assertion:synthetic-brazil-nut-edition-e1',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (ed:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-brazil-nut-daily-e1'}), (f:FoodItem {uid: 'hu:material:food-brazil-nut'})
MERGE (st:ProtocolStep:Entity {uid: 'hu:protocol-step:synthetic-brazil-nut-daily-eat-two'})
SET st.entityType = 'ProtocolStep', st.stepKey = 'eat-brazil-nuts', st.stepKind = 'CONSUME', st.requirementLevel = 'ESSENTIAL', st.requirementBasis = 'STATED_BY_SOURCE',
    st.scheduleText = 'two nuts every day', st.notReportedFields = ['durationIso', 'preparation'], st.payloadHash = 'sha256:synthetic-w05-st1', st.createdAt = datetime('2026-10-04T02:00:00Z'), st.privacyClass = 'PUBLIC'
MERGE (ed)-[h:HAS_PROTOCOL_STEP]->(st)
SET h.orderIndex = 0
MERGE (st)-[u:USES]->(f)
SET u.dose = 2.0, u.doseUnitCode = '{nut}', u.quantityBasis = 'PER_DAY', u.verbatimDoseText = 'two Brazil nuts';

MERGE (s:Source:Entity {uid: 'hu:source:synthetic-w05-brazil-nut-protocol-page'})
SET s.entityType = 'Source', s.canonicalUri = 'https://protocols.example.invalid/brazil-nut-daily', s.sourceKind = 'ORGANIZATION_WEBPAGE', s.privacyClass = 'PUBLIC',
    s.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w05-brazil-nut-protocol-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.retrievedAt = datetime('2026-10-04T02:00:00Z'), sn.observedAt = datetime('2026-10-04T02:00:00Z'),
    sn.contentHash = 'synthetic:hu:snapshot:synthetic-w05-brazil-nut-protocol-2026-10-04', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE',
    sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w05-brazil-nut-protocol-whole'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'WHOLE_SNAPSHOT', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (p:Protocol {uid: 'hu:protocol:synthetic-brazil-nut-daily'}), (ed:ProtocolEdition {uid: 'hu:protocol-edition:synthetic-brazil-nut-daily-e1'}), (ag:Agent {uid: 'hu:agent:w05-curation'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-w05-brazil-nut-protocol-whole'})
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-brazil-nut-edition-e1'})
SET a.predicate = 'HAS_PROTOCOL_EDITION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CITED_FROM_PRIOR_WORK',
    a.recordedAt = datetime('2026-10-04T02:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'synthetic:hu:assertion:synthetic-brazil-nut-edition-e1'
MERGE (a)-[:HAS_SUBJECT]->(p) MERGE (a)-[:HAS_OBJECT]->(ed) MERGE (a)-[:ASSERTED_BY]->(ag) MERGE (a)-[:SUPPORTED_BY]->(l);
