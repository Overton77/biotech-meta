// W04 fixture 03 -- label declaration vs calculated active moiety vs measured result (CQ-PF-01, INV-006, INV-307, V-011, V-330).
// Public part (NEW_RETRIEVAL 2026-10-04): Tru Niagen 300mg Supplement Facts text panel "NIAGEN® (nicotinamide riboside chloride) | 300mg | †"
//   with "†Daily Value (DV) not established"; PubChem PUG REST computed properties: CID 90480033 C11H15ClN2O5 MW 290.70 (charge 0),
//   CID 439924 C11H15N2O5+ MW 255.25 (charge +1). Calculation: 300 mg x 255.25 / 290.70 = 263.42 mg NR cation per serving (CALCULATED).
// Synthetic part (SYNTHETIC_FIXTURE): a lot assay result (309 mg NR chloride per capsule). No real certificate of analysis was fetched.
// Self-contained: re-MERGEs the Tru Niagen nodes of fixture 02 by uid (ON CREATE only), so it loads alone or after fixture 02.

MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'})
ON CREATE SET v.name = 'Tru Niagen 300mg, 1 vegetarian capsule per serving', v.entityType = 'ProductVariant', v.dosageForm = 'CAPSULE', v.jurisdiction = 'US', v.privacyClass = 'PUBLIC', v.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (niagen:IngredientMaterial:Entity {uid: 'hu:material:chromadex-niagen'})
ON CREATE SET niagen.name = 'NIAGEN (nicotinamide riboside chloride)', niagen.entityType = 'IngredientMaterial', niagen.privacyClass = 'PUBLIC', niagen.createdAt = datetime('2026-10-04T01:00:00Z');

MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'})
ON CREATE SET fv.stateType = 'FormulationVersion', fv.jurisdiction = 'US', fv.privacyClass = 'PUBLIC', fv.createdAt = datetime('2026-10-04T01:00:00Z'),
    fv.payloadHash = 'sha256:aac78da63b06ef61895ba020b39dc2d06bf9d4db9cae15013d33f3147efef8d3';

MERGE (c:IngredientComponent:VersionedState {uid: 'hu:component:tru-niagen-300mg-niagen'})
ON CREATE SET c.stateType = 'IngredientComponent', c.role = 'DIETARY_INGREDIENT', c.labelOrder = 1, c.quantity = 300.0, c.unitCode = 'mg', c.quantityBasis = 'PER_SERVING',
    c.massBasis = 'SALT_FORM', c.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', c.declaredAs = 'NIAGEN® (nicotinamide riboside chloride)', c.isDietaryIngredient = true,
    c.payloadHash = 'sha256:8322d17f88257e752feeefd0b9d3c0ac6c900e2abbf9de04f12c02a354112cab',
    c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T01:00:00Z');

MATCH (fv:FormulationVersion {uid: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03'}), (c:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'})
MERGE (fv)-[hc:HAS_INGREDIENT_COMPONENT]->(c) ON CREATE SET hc.orderIndex = 1;

MERGE (s:Source:Entity {uid: 'hu:source:truniagen-300mg-product-page'})
ON CREATE SET s.canonicalUri = 'https://www.truniagen.com/products/tru-niagen-300mg', s.title = 'Tru Niagen 300mg product page', s.sourceKind = 'MANUFACTURER_LABEL_PAGE', s.entityType = 'Source', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T00:57:00Z');

MERGE (sn:LabelSnapshot:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:truniagen-300mg-page-2026-10-04'})
ON CREATE SET sn.artifactType = 'LabelSnapshot', sn.canonicalUri = 'https://www.truniagen.com/products/tru-niagen-300mg', sn.observedAt = datetime('2026-10-04T00:57:00Z'), sn.retrievedAt = datetime('2026-10-04T00:57:00Z'),
    sn.contentHash = 'sha256:116a0bd7e4172613c97145bc3ef62bbac666c4ee3a521d9971226e5c8653a898',
    sn.contentHashBasis = 'STORED_EXCERPT_TEXT', sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.jurisdiction = 'US', sn.language = 'en', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T00:57:00Z');

MATCH (s:Source {uid: 'hu:source:truniagen-300mg-product-page'}), (sn:SourceSnapshot {uid: 'hu:snapshot:truniagen-300mg-page-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-sf-niagen-line'})
ON CREATE SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = 'NIAGEN® (nicotinamide riboside chloride) | 300mg',
    l.quoteHash = 'sha256:a7e6b185e39c542e3d2447a21cd03e3f89800d4dfdf8fa090ced1f6e6060346a', l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T00:57:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l)
MERGE (l2:SourceLocator:InformationArtifact {uid: 'hu:locator:truniagen-300mg-sf-dv-footnote'})
ON CREATE SET l2.artifactType = 'SourceLocator', l2.uri = s.canonicalUri, l2.selectorKind = 'TEXT_QUOTE', l2.exact = '†Daily Value (DV) not established',
    l2.quoteHash = 'sha256:de94df948a44053996ed24113855c9e40358edb60b5bb1c118c3f1da3757e04b', l2.normalizationVersion = 'NFC-WS1', l2.privacyClass = 'PUBLIC', l2.createdAt = datetime('2026-10-04T00:57:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l2);

// ---- 1. DECLARED: the label declaration and its quantity declaration (InformationArtifacts, verbatim) ----
MATCH (sn:LabelSnapshot {uid: 'hu:snapshot:truniagen-300mg-page-2026-10-04'})
MERGE (d:LabelDeclaration:InformationArtifact {uid: 'hu:label-declaration:tru-niagen-300mg-2026-10-04-niagen'})
SET d.artifactType = 'LabelDeclaration', d.verbatimText = 'NIAGEN® (nicotinamide riboside chloride) 300mg †', d.declarationKind = 'OTHER_DIETARY_INGREDIENT', d.panelOrder = 1,
    d.contentHash = 'sha256:6b99d8d9c00a1ac7d2e32a746c61acd115a00205212bf9943b1a5273a1cbe7c4', d.observedAt = datetime('2026-10-04T00:57:00Z'), d.privacyClass = 'PUBLIC', d.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (q:QuantityDeclaration:InformationArtifact {uid: 'hu:quantity-declaration:tru-niagen-300mg-2026-10-04-niagen'})
SET q.artifactType = 'QuantityDeclaration', q.value = 300.0, q.unitCode = 'mg', q.quantityBasis = 'PER_SERVING', q.dailyValuePercent = null, q.dailyValueStatus = 'NOT_APPLICABLE',
    q.amountReferent = 'LISTED_INGREDIENT_AS_LISTED', q.amountReferentUid = 'hu:material:chromadex-niagen', q.observedAt = datetime('2026-10-04T00:57:00Z'), q.privacyClass = 'PUBLIC', q.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (d2:LabelDeclaration:InformationArtifact {uid: 'hu:label-declaration:tru-niagen-300mg-2026-10-04-other-ingredients'})
SET d2.artifactType = 'LabelDeclaration', d2.verbatimText = 'Other Ingredients: Microcrystalline Cellulose, Hypromellose (Vegetarian Capsule), Vegetable Magnesium Stearate',
    d2.declarationKind = 'OTHER_INGREDIENT', d2.panelOrder = 2, d2.observedAt = datetime('2026-10-04T00:57:00Z'), d2.privacyClass = 'PUBLIC', d2.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn)-[h1:HAS_DECLARATION]->(d) SET h1.orderIndex = 1
MERGE (sn)-[h2:HAS_DECLARATION]->(d2) SET h2.orderIndex = 2
MERGE (d)-[hq:HAS_QUANTITY_DECLARATION]->(q);

// ---- substances (W02 identities) and the PubChem record ----
UNWIND [
  {u: 'hu:substance:nicotinamide-riboside-chloride', n: 'Nicotinamide riboside chloride', f: 'C11H15ClN2O5', cid: '90480033'},
  {u: 'hu:substance:nicotinamide-riboside-cation', n: 'Nicotinamide riboside (cation)', f: 'C11H15N2O5+', cid: '439924'}
] AS r
MERGE (x:ChemicalSubstance:Entity {uid: r.u})
SET x.preferredName = r.n, x.name = r.n, x.molecularFormula = r.f, x.pubchemCid = r.cid, x.entityType = 'ChemicalSubstance', x.privacyClass = 'PUBLIC', x.createdAt = datetime('2026-10-04T01:05:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:pubchem-pug-nr-and-nrcl-properties'})
SET s.canonicalUri = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/nicotinamide%20riboside%20chloride/property/MolecularFormula,MolecularWeight,Charge/JSON',
    s.title = 'PubChem PUG REST computed properties (NR chloride CID 90480033; NR cation CID 439924)', s.sourceKind = 'TERMINOLOGY_RECORD', s.entityType = 'Source', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T00:59:00Z');

MATCH (s:Source {uid: 'hu:source:pubchem-pug-nr-and-nrcl-properties'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubchem-nr-nrcl-mw-2026-10-04'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.observedAt = datetime('2026-10-04T00:59:00Z'), sn.retrievedAt = datetime('2026-10-04T00:59:00Z'),
    sn.contentHash = 'sha256:a6d9fe726f519db24bf6543d29552dc1ce0db4a62088f186f5cf5f8452a97605', sn.contentHashBasis = 'STORED_EXCERPT_TEXT',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T00:59:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:pubchem-mw-nrcl-and-nr'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'TEXT_QUOTE', l.exact = 'CID 90480033 C11H15ClN2O5 MolecularWeight 290.70 Charge 0 | CID 439924 C11H15N2O5+ MolecularWeight 255.25 Charge 1',
    l.quoteHash = 'sha256:a6d9fe726f519db24bf6543d29552dc1ce0db4a62088f186f5cf5f8452a97605', l.normalizationVersion = 'NFC-WS1', l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T00:59:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// Asserted inputs: the label identifies NIAGEN; NIAGEN realizes NR chloride; NR chloride has active moiety NR cation; the variant has the FV.
UNWIND [
  {a: 'hu:assertion:tn300-declaration-identifies-niagen', p: 'DECLARATION_IDENTIFIES_MATERIAL', s: 'hu:label-declaration:tru-niagen-300mg-2026-10-04-niagen', o: 'hu:material:chromadex-niagen', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', ab: 'MANUFACTURER_CLAIM'},
  {a: 'hu:assertion:niagen-realizes-nr-chloride', p: 'REALIZES_SUBSTANCE', s: 'hu:material:chromadex-niagen', o: 'hu:substance:nicotinamide-riboside-chloride', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', ab: 'MANUFACTURER_CLAIM'},
  {a: 'hu:assertion:nr-chloride-active-moiety-nr-cation', p: 'HAS_ACTIVE_MOIETY', s: 'hu:substance:nicotinamide-riboside-chloride', o: 'hu:substance:nicotinamide-riboside-cation', loc: 'hu:locator:pubchem-mw-nrcl-and-nr', ab: 'UNSTATED'},
  {a: 'hu:assertion:tru-niagen-300-has-fv', p: 'HAS_FORMULATION_VERSION', s: 'hu:product-variant:tru-niagen-300mg-us-capsule', o: 'hu:formulation:tru-niagen-300mg-observed-2026-10-03', loc: 'hu:locator:truniagen-300mg-sf-niagen-line', ab: 'MANUFACTURER_CLAIM'}
] AS r
MATCH (s {uid: r.s}), (o {uid: r.o}), (loc:SourceLocator {uid: r.loc})
MERGE (a:Assertion {uid: r.a})
ON CREATE SET a.predicate = r.p, a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:06:00Z'), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN',
    a.assertionBasis = r.ab, a.speechAct = 'STATES', a.contentHash = 'synthetic:' + r.a, a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:06:00Z')
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(loc);

MATCH (a:Assertion {uid: 'hu:assertion:tn300-declaration-identifies-niagen'}), (d:LabelDeclaration {uid: 'hu:label-declaration:tru-niagen-300mg-2026-10-04-niagen'}), (m:IngredientMaterial {uid: 'hu:material:chromadex-niagen'})
MERGE (d)-[e:DECLARATION_IDENTIFIES_MATERIAL {relationshipUid: 'hu:rel:tn300-declaration-identifies-niagen'}]->(m)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = a.validFromBasis, e.validToBasis = a.validToBasis;

// ---- 2. CALCULATED: active-moiety amount as a BellLabs CALCULATED literal Assertion (KCR-L3-001). Never a declaration. ----
MERGE (ag:Agent:Entity {uid: 'hu:agent:w04-active-moiety-calculator'})
SET ag.name = 'BellLabs active-moiety mass calculator (fixture)', ag.agentKind = 'COMPUTATIONAL_MODEL', ag.entityType = 'Agent', ag.privacyClass = 'INTERNAL', ag.createdAt = datetime('2026-10-04T01:07:00Z');

MATCH (c:IngredientComponent {uid: 'hu:component:tru-niagen-300mg-niagen'}), (ag:Agent {uid: 'hu:agent:w04-active-moiety-calculator'}),
      (inFv:Assertion {uid: 'hu:assertion:tru-niagen-300-has-fv'}), (inMoiety:Assertion {uid: 'hu:assertion:nr-chloride-active-moiety-nr-cation'}),
      (l1:SourceLocator {uid: 'hu:locator:truniagen-300mg-sf-niagen-line'}), (l2:SourceLocator {uid: 'hu:locator:pubchem-mw-nrcl-and-nr'})
MERGE (a:Assertion {uid: 'hu:assertion:tn300-component-nr-cation-amount-calculated'})
SET a.predicate = 'ACTIVE_MOIETY_AMOUNT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'CALCULATED', a.predicateClass = 'QUANTITY',
    a.valueNumber = 263.42, a.unitCode = 'mg', a.quantityBasis = 'PER_SERVING',
    a.derivationRule = 'active-moiety-mass-v1: amount_moiety = amount_listed_salt x MW(moiety) / MW(salt); MW(NR cation, CID 439924) = 255.25, MW(NR chloride, CID 90480033) = 290.70 (PubChem PUG REST, retrieved 2026-10-04); 300 x 255.25 / 290.70 = 263.42 mg; rounded to 0.01 mg',
    a.recordedAt = datetime('2026-10-04T01:08:00Z'), a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.contentHash = 'sha256:7513e998ed21447edadadaa7ba23fe181184e5236cd2337b9eb26effe785ab69',
    a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T01:08:00Z')
MERGE (a)-[:HAS_SUBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(inFv)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(inMoiety)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2);

// ---- 3. MEASURED (SYNTHETIC): a lot and an assay result; a MeasuredResult is never a LabelDeclaration (V-011) ----
MERGE (lot:ProductLot:Entity {uid: 'hu:lot:w04-syn-tn300-lot-0001'})
SET lot.lotCode = 'SYN-0001 (synthetic)', lot.entityType = 'ProductLot', lot.privacyClass = 'PUBLIC', lot.createdAt = datetime('2026-10-04T01:09:00Z');

MATCH (lot:ProductLot {uid: 'hu:lot:w04-syn-tn300-lot-0001'}), (v:ProductVariant {uid: 'hu:product-variant:tru-niagen-300mg-us-capsule'}), (nrcl:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside-chloride'})
MERGE (lot)-[lo:LOT_OF {relationshipUid: 'hu:rel:w04-syn-lot-0001-lot-of'}]->(v)
SET lo.assertionUid = 'hu:assertion:w04-syn-lot-0001-lot-of', lo.recordedFrom = datetime('2026-10-04T01:09:00Z'), lo.validFromBasis = 'UNKNOWN', lo.validToBasis = 'UNKNOWN'
MERGE (al:Assertion {uid: 'hu:assertion:w04-syn-lot-0001-lot-of'})
SET al.predicate = 'LOT_OF', al.status = 'PROPOSED', al.polarity = 'POSITIVE', al.recordedAt = datetime('2026-10-04T01:09:00Z'), al.contentHash = 'synthetic:lot-of', al.privacyClass = 'PUBLIC', al.createdAt = datetime('2026-10-04T01:09:00Z')
MERGE (al)-[:HAS_SUBJECT]->(lot)
MERGE (al)-[:HAS_OBJECT]->(v)
MERGE (ex:TestExecution:Occurrence {uid: 'hu:test-execution:w04-syn-tn300-lot-0001-hplc'})
SET ex.occurrenceType = 'TestExecution', ex.executedAt = datetime('2026-09-01T00:00:00Z'), ex.status = 'COMPLETED', ex.privacyClass = 'PUBLIC', ex.createdAt = datetime('2026-10-04T01:09:00Z')
MERGE (r:MeasuredResult:InformationArtifact {uid: 'hu:result:w04-syn-tn300-lot-0001-nrcl'})
SET r.artifactType = 'MeasuredResult', r.analyte = 'nicotinamide riboside chloride', r.analyteUid = nrcl.uid, r.value = 309.0, r.unitCode = 'mg', r.basisNote = 'per capsule (synthetic)',
    r.uncertainty = 6.0, r.qualifier = null, r.privacyClass = 'PUBLIC', r.createdAt = datetime('2026-10-04T01:09:00Z')
MERGE (ex)-[:PRODUCED_RESULT]->(r);

MATCH (a:Assertion)
WHERE a.uid IN ['hu:assertion:tn300-declaration-identifies-niagen', 'hu:assertion:niagen-realizes-nr-chloride', 'hu:assertion:nr-chloride-active-moiety-nr-cation',
                'hu:assertion:tru-niagen-300-has-fv', 'hu:assertion:tn300-component-nr-cation-amount-calculated']
WITH collect(a) AS as
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w04-03-capture-fidelity-policy'})
SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED', j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1',
    j.status = 'ACCEPTED', j.reviewedAt = datetime('2026-10-04T02:00:00Z'), j.recordedAt = datetime('2026-10-04T02:00:00Z'), j.createdAt = datetime('2026-10-04T02:00:00Z'), j.privacyClass = 'INTERNAL'
WITH j, as UNWIND as AS a MERGE (j)-[:EVALUATES]->(a);
