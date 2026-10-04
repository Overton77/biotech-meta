// W02 Substances and materials fixture (fx-91-kernel-quantity-failing-cases) - run run-2026-10-04-fable51-01, worker W02 (Opus 5.5).
// Synthetic-fixture rules: every statement binds its own nodes by uid (no variable crosses ';'); nodes carry the primary
// label and the archetype label; snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid) because
// the real bytes were not hashed (captures were connector extractions). Real-source facts cite the W02 source manifest
// row in comments (M-xx). Uids reuse repo fixture uids where the same identity already exists (elysium-basis.cypher,
// study-vs-product-mismatch.cypher) and use MERGE ... ON CREATE so that loading beside them never overwrites.
// Tokens: material, substance, form/chemical-form, identifier, assertion, source, snapshot, locator, rel, agent,
// resolution, component, study-intervention are registered (catalog 0.2.0); botanical-taxon, microbial-taxon,
// microbial-strain, constituent, nutrient, specification, spec-version are PROPOSED (seam-requests W02-SR-03, W11).
// FAILING-CASE FIXTURE for seam requests W02-SR-01 and W02-SR-02. Under the frozen kernel and V-006 the rows named
// below are EXPECTED; under the proposed rulings they disappear. Load after fx-01 and fx-04.

MERGE (n:Agent:Entity {uid: 'hu:agent:belllabs-w02-quantity-calculator'})
ON CREATE SET n += {name: 'BellLabs quantity calculator (W02 fixture)', agentKind: 'COMPUTATIONAL_MODEL', version: 'w02-active-moiety-mass-v1', entityType: 'Agent', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

// SR-01 case A: one label component (Basis-style 'NR chloride 250 mg', SYNTHETIC uid) yields two calculated amounts:
// NR cation 219.5 mg (rule w02-active-moiety-mass-v1) and a nicotinamide molar-equivalent 105.0 mg (SYNTHETIC
// illustrative rule w02-molar-equivalent-v0, MW nicotinamide 122.12 from PubChem CID 936, M-19; NOT a regulatory niacin-
// equivalent factor). Literal-only assertions (frozen INV-003) have the same subject and predicate; which substance each
// number refers to is recoverable only by walking inputs and fails when both inputs are present. With HAS_OBJECT the
// answer is direct, but V-003 then reports objects + literals = 2.

MERGE (n:IngredientComponent:VersionedState {uid: 'hu:component:synthetic-w02-nrc-250'})
ON CREATE SET n += {role: 'DIETARY_INGREDIENT', quantity: 250.0, unitCode: 'mg', quantityBasis: 'PER_SERVING', massBasis: 'SALT_FORM', amountReferent: 'LISTED_INGREDIENT_AS_LISTED', declaredAs: 'Nicotinamide Riboside Chloride (SYNTHETIC line)', stateType: 'IngredientComponent', payloadHash: 'sha256:f316334e57730772d7c40a724f63a941413625695527563b6862335554aadc18', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:nicotinamide'})
ON CREATE SET n += {name: 'Nicotinamide', preferredName: 'Nicotinamide', molecularFormula: 'C6H6N2O', pubchemCid: '936', inchikey: 'DFPAKSUCGFBDDF-UHFFFAOYSA-N', maturity: 'PROVISIONAL', entityType: 'ChemicalSubstance', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:Source:Entity {uid: 'hu:source:synthetic-w02-supplier-x-coa'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', title: 'SYNTHETIC supplier X technical sheet (fixture only)', sourceKind: 'MARKETING_PAGE', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', retrievedAt: datetime('2026-10-04T00:59:00Z'), observedAt: datetime('2026-10-04T00:59:00Z'), contentHash: 'sha256:812cec4cb030c8505c3b0fbd9e7ff9ffa45d61ff66165d8b2247718d363d54e9', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'COMPLETE', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:synthetic-w02-supplier-x-coa'}), (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
ON CREATE SET n += {uri: 'urn:synthetic:w02:supplier-x-nrc-amorphous', selectorKind: 'WHOLE_SNAPSHOT', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:synthetic-w02-supplier-x-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MERGE (n:IngredientMaterial:Entity {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'})
ON CREATE SET n += {name: 'Supplier X NR chloride, amorphous (SYNTHETIC)', materialKind: 'CHEMICALLY_DEFINED_MATERIAL', maturity: 'CANDIDATE', entityType: 'IngredientMaterial', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'}),
      (o:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'}),
      (l0:SourceLocator {uid: 'hu:locator:synthetic-w02-supplier-x-identity'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr01-synthetic-component-uses-supplier-x'})
ON CREATE SET a += {predicate: 'USES_MATERIAL', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:79c753db391756b39bc1bf672ade7ec09590be7d2cddac07859fc255bc587a7d', polarity: 'POSITIVE', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'}), (y:IngredientMaterial {uid: 'hu:material:synthetic-supplier-x-nrc-amorphous'})
MERGE (x)-[r:USES_MATERIAL]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-sr01-synthetic-component-uses-supplier-x'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-sr01-synthetic-component-uses-supplier-x'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'UNKNOWN'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN');

MATCH (s:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'}),
      (ag {uid: 'hu:agent:belllabs-w02-quantity-calculator'}),
      (in0:Assertion {uid: 'hu:assertion:w02-nrc-has-active-moiety-nr'}),
      (in1:Assertion {uid: 'hu:assertion:w02-nrc-molecular-weight-pubchem'}),
      (in2:Assertion {uid: 'hu:assertion:w02-nr-molecular-weight-pubchem'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr01-calc-nr-cation-literal-only'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:24bd9e26f97edbccb1f00ef3b26ec82ea9be5d926f1f1ead3082072a167abeef', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 219.5, unitCode: 'mg', quantityBasis: 'PER_SERVING', basisKind: 'CALCULATED', derivationRule: 'w02-active-moiety-mass-v1'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in0)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in1)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in2);

MATCH (s:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'}),
      (ag {uid: 'hu:agent:belllabs-w02-quantity-calculator'}),
      (in0:Assertion {uid: 'hu:assertion:w02-nrc-has-active-moiety-nr'}),
      (in1:Assertion {uid: 'hu:assertion:w02-nrc-molecular-weight-pubchem'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr01-calc-nicotinamide-equiv-literal-only'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:7a38514af7efea5ab55c492a9a4c95cb3879a73eabffa57667f8b15338ec16ea', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 105.0, unitCode: 'mg', quantityBasis: 'PER_SERVING', basisKind: 'CALCULATED', derivationRule: 'w02-molar-equivalent-v0 (SYNTHETIC illustrative)'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in0)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in1);

MATCH (s:IngredientComponent {uid: 'hu:component:synthetic-w02-nrc-250'}),
      (o:ChemicalSubstance {uid: 'hu:substance:nicotinamide-riboside'}),
      (ag {uid: 'hu:agent:belllabs-w02-quantity-calculator'}),
      (in0:Assertion {uid: 'hu:assertion:w02-nrc-has-active-moiety-nr'}),
      (in1:Assertion {uid: 'hu:assertion:w02-nrc-molecular-weight-pubchem'}),
      (in2:Assertion {uid: 'hu:assertion:w02-nr-molecular-weight-pubchem'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr01-calc-nr-cation-with-object'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:9d77961e0f6dffebe3380208e9efec6a9c45ed78362c838711c588ddb4f465bf', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'UNKNOWN', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', valueNumber: 219.5, unitCode: 'mg', quantityBasis: 'PER_SERVING', basisKind: 'CALCULATED', derivationRule: 'w02-active-moiety-mass-v1'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:ASSERTED_BY]->(ag)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in0)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in1)
MERGE (a)-[:DERIVED_FROM_ASSERTION]->(in2);

// SR-01 case B: a material-level QUANTITATIVELY_CONTAINS edge carries quantity, unit and basis (V-006), but its authorizing
// assertion cannot (object XOR literal). Rebuilding the edge from its assertion loses the number: the edge is not a
// projection of its assertion. Ph. Eur. Ginkgo standardization as cited by PMC9593214 (M-12): 22.0-27.0% flavonoids
// calculated as flavone glycosides; 5.4-6.6% terpene lactones.
// SR-02: the same statements are ranges. Frozen V-006 requires r.quantity; a BETWEEN statement has quantityLow and
// quantityHigh, so V-006 reports both edges; proposed V-006r accepts comparator BETWEEN with both bounds.

MERGE (n:Source:Entity {uid: 'hu:source:pmc9593214'})
ON CREATE SET n += {canonicalUri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9593214', title: 'Ginkgo biloba leaf extract EGb 761 as a paragon of the product by process concept (PMC9593214)', sourceKind: 'PEER_REVIEWED_PUBLICATION', entityType: 'Source', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MERGE (n:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pmc9593214-search-extract-2026-10-04'})
ON CREATE SET n += {canonicalUri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9593214', retrievedAt: datetime('2026-10-04T01:16:00Z'), observedAt: datetime('2026-10-04T01:16:00Z'), contentHash: 'sha256:42d4cbbc52e7c7272011eef36b3507bc6802d48346e8424bfd5a417cd8b80b29', contentHashBasis: 'SYNTHETIC_FIXTURE', captureCompleteness: 'PARTIAL_EXCERPT', artifactType: 'SourceSnapshot', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (s:Source {uid: 'hu:source:pmc9593214'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pmc9593214-search-extract-2026-10-04'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

MERGE (n:SourceLocator:InformationArtifact {uid: 'hu:locator:pmc9593214-ph-eur-spec'})
ON CREATE SET n += {uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9593214', selectorKind: 'TEXT_QUOTE', exact: 'the final product is adjusted to 22.0%–27.0% ginkgo flavonoids calculated as ginkgo flavone glycosides and 5.4%–6.6% terpene lactones', quoteHash: 'sha256:0056c4a893ad385a9a8553347628928ac4e5a591d794cd5db489856015380ec0', normalizationVersion: 'NFC-WS1', artifactType: 'SourceLocator', createdAt: datetime('2026-10-04T02:00:00Z'), privacyClass: 'PUBLIC'};

MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:pmc9593214-search-extract-2026-10-04'}), (l:SourceLocator {uid: 'hu:locator:pmc9593214-ph-eur-spec'})
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (s:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}),
      (o:Constituent {uid: 'hu:constituent:ginkgo-flavone-glycosides'}),
      (l0:SourceLocator {uid: 'hu:locator:pmc9593214-ph-eur-spec'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr02-ph-eur-10-ginkgo-ginkgo-flavone-glycosides'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:4dbe62d0bbd6b773db8f1bc3032e85147a1765c3841447418ab74d769a4c40d9', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', validFrom: datetime('2020-01-01T00:00:00Z'), validFromPrecision: 'YEAR'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}), (y:Constituent {uid: 'hu:constituent:ginkgo-flavone-glycosides'})
MERGE (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-sr02-ph-eur-10-ginkgo-ginkgo-flavone-glycosides'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-sr02-ph-eur-10-ginkgo-ginkgo-flavone-glycosides'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'STATED_BY_SOURCE'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.validFrom = coalesce(r.validFrom, datetime('2020-01-01T00:00:00Z')), r.validFromPrecision = coalesce(r.validFromPrecision, 'YEAR'), r.quantityLow = coalesce(r.quantityLow, 22.0), r.quantityHigh = coalesce(r.quantityHigh, 27.0), r.comparator = coalesce(r.comparator, 'BETWEEN'), r.unitCode = coalesce(r.unitCode, '%'), r.basis = coalesce(r.basis, 'MASS_FRACTION_W_W'), r.expressedAs = coalesce(r.expressedAs, 'ginkgo flavonoids calculated as ginkgo flavone glycosides'), r.contentStatementKind = coalesce(r.contentStatementKind, 'STANDARDIZATION_CLAIM'), r.verbatimText = coalesce(r.verbatimText, '22.0%-27.0% ginkgo flavonoids calculated as ginkgo flavone glycosides');

MATCH (s:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}),
      (o:Constituent {uid: 'hu:constituent:ginkgo-terpene-lactones'}),
      (l0:SourceLocator {uid: 'hu:locator:pmc9593214-ph-eur-spec'})
MERGE (a:Assertion {uid: 'hu:assertion:w02-sr02-ph-eur-10-ginkgo-ginkgo-terpene-lactones'})
ON CREATE SET a += {predicate: 'QUANTITATIVELY_CONTAINS', status: 'PROPOSED', recordedAt: datetime('2026-10-04T02:00:00Z'), contentHash: 'sha256:5b0f599ceccfee63a726111523410ece0680f6daa14ed066852ba65fba7e6056', polarity: 'POSITIVE', predicateClass: 'QUANTITY', validFromBasis: 'STATED_BY_SOURCE', validToBasis: 'UNKNOWN', privacyClass: 'PUBLIC', validFrom: datetime('2020-01-01T00:00:00Z'), validFromPrecision: 'YEAR'}
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l0);

MATCH (x:BotanicalPreparation {uid: 'hu:material:ginkgo-leaf-dry-extract-refined-quantified-eu-weu'}), (y:Constituent {uid: 'hu:constituent:ginkgo-terpene-lactones'})
MERGE (x)-[r:QUANTITATIVELY_CONTAINS]->(y)
SET r.relationshipUid = coalesce(r.relationshipUid, 'hu:rel:w02-sr02-ph-eur-10-ginkgo-ginkgo-terpene-lactones'), r.assertionUid = coalesce(r.assertionUid, 'hu:assertion:w02-sr02-ph-eur-10-ginkgo-ginkgo-terpene-lactones'), r.recordedFrom = coalesce(r.recordedFrom, datetime('2026-10-04T02:00:00Z')), r.validFromBasis = coalesce(r.validFromBasis, 'STATED_BY_SOURCE'), r.validToBasis = coalesce(r.validToBasis, 'UNKNOWN'), r.validFrom = coalesce(r.validFrom, datetime('2020-01-01T00:00:00Z')), r.validFromPrecision = coalesce(r.validFromPrecision, 'YEAR'), r.quantityLow = coalesce(r.quantityLow, 5.4), r.quantityHigh = coalesce(r.quantityHigh, 6.6), r.comparator = coalesce(r.comparator, 'BETWEEN'), r.unitCode = coalesce(r.unitCode, '%'), r.basis = coalesce(r.basis, 'MASS_FRACTION_W_W'), r.expressedAs = coalesce(r.expressedAs, 'terpene lactones (ginkgolides A, B, C and bilobalide)'), r.contentStatementKind = coalesce(r.contentStatementKind, 'STANDARDIZATION_CLAIM'), r.verbatimText = coalesce(r.verbatimText, '5.4%-6.6% terpene lactones (ginkgolides A, B, C and bilobalide)');
