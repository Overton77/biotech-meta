// =====================================================================================================================
// W05 fixture 06: temporal cases. Load after fixtures 01 and 04.
//  T1 extraction correction: an earlier capture mis-read the IRIS RfD as 0.05 mg/kg/d. The corrected assertion
//     (fixture 04, 0.005) SUPERSEDES it with EXTRACTION_FIX; the wrong assertion keeps its recordedAt and gets
//     recordedTo; valid time is untouched. An as-of query before the fix returns 0.05, after it 0.005.
//  T2 late arrival: a SYNTHETIC second composition record for the same food (a newer analytical dataset, published
//     2025-04, first observed 2026-10-05) adds a second QUANTITATIVELY_CONTAINS assertion and edge. It does not
//     supersede the SR Legacy value (different source, NONEXCLUSIVE composition facts; SR Legacy "will not be updated").
// Every statement binds its own nodes by uid.
// =====================================================================================================================

MATCH (e:Exposure {uid: 'hu:exposure:selenium-oral-chronic-dietary'}), (o:Organization {uid: 'hu:org:us-epa'}), (l:SourceLocator {uid: 'hu:locator:epa-iris-0472-rfd-table'})
MERGE (a:Assertion {uid: 'hu:assertion:epa-iris-selenium-oral-rfd-misextracted'})
SET a.predicate = 'HAS_REFERENCE_DOSE', a.status = 'SUPERSEDED', a.polarity = 'POSITIVE', a.basisKind = 'CALCULATED',
    a.derivationRule = 'IRIS RfD = NOAEL / UF x MF', a.predicateClass = 'QUANTITY',
    a.valueNumber = 0.05, a.unitCode = 'mg/kg/d', a.quantityBasis = 'PER_KG_BODY_WEIGHT_PER_DAY', a.jurisdiction = 'US',
    a.validFrom = datetime('1991-06-01T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
    a.recordedAt = datetime('2026-10-04T01:30:00Z'), a.privacyClass = 'PUBLIC', a.recordedTo = datetime('2026-10-04T02:00:00Z'), a.contentHash = 'sha256:synthetic-w05-t01'
MERGE (a)-[:HAS_SUBJECT]->(e) MERGE (a)-[:ASSERTED_BY]->(o) MERGE (a)-[:SUPPORTED_BY]->(l);

MATCH (good:Assertion {uid: 'hu:assertion:epa-iris-selenium-oral-rfd'}), (bad:Assertion {uid: 'hu:assertion:epa-iris-selenium-oral-rfd-misextracted'})
MERGE (good)-[s:SUPERSEDES]->(bad)
SET s.supersessionKind = 'EXTRACTION_FIX', s.recordedAt = datetime('2026-10-04T02:00:00Z');

MERGE (s:Source:Entity {uid: 'hu:source:synthetic-w05-food-composition-2025'})
SET s.entityType = 'Source', s.canonicalUri = 'https://foodcomposition.example.invalid/records/brazil-nut-dried-2025', s.sourceKind = 'TERMINOLOGY_RECORD',
    s.createdAt = datetime('2026-10-05T09:00:00Z'), s.privacyClass = 'PUBLIC';

MATCH (s:Source {uid: 'hu:source:synthetic-w05-food-composition-2025'})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:synthetic-w05-food-composition-2026-10-05'})
SET sn.artifactType = 'SourceSnapshot', sn.canonicalUri = s.canonicalUri, sn.publishedAt = datetime('2025-04-01T00:00:00Z'),
    sn.retrievedAt = datetime('2026-10-05T09:00:00Z'), sn.observedAt = datetime('2026-10-05T09:00:00Z'),
    sn.contentHash = 'synthetic:hu:snapshot:synthetic-w05-food-composition-2026-10-05', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'COMPLETE',
    sn.createdAt = datetime('2026-10-05T09:00:00Z'), sn.privacyClass = 'PUBLIC'
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:synthetic-w05-food-composition-selenium'})
SET l.artifactType = 'SourceLocator', l.uri = s.canonicalUri, l.selectorKind = 'SECTION', l.section = 'nutrients/selenium', l.fixtureProvenance = 'SYNTHETIC',
    l.createdAt = datetime('2026-10-05T09:00:00Z'), l.privacyClass = 'PUBLIC'
MERGE (sn)-[:HAS_LOCATOR]->(l);

MATCH (f:FoodItem {uid: 'hu:material:food-brazil-nut-dried-unblanched'}), (se:ChemicalSubstance {uid: 'hu:substance:selenium'}),
      (l:SourceLocator {uid: 'hu:locator:synthetic-w05-food-composition-selenium'})
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-2025-brazil-nut-selenium'})
SET a.predicate = 'QUANTITATIVELY_CONTAINS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.basisKind = 'DIRECT_MEASUREMENT', a.predicateClass = 'QUANTITY',
    a.recordedAt = datetime('2026-10-05T09:00:00Z'), a.privacyClass = 'PUBLIC', a.contentHash = 'synthetic:hu:assertion:synthetic-2025-brazil-nut-selenium'
MERGE (a)-[:HAS_SUBJECT]->(f) MERGE (a)-[:HAS_OBJECT]->(se) MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (f)-[r:QUANTITATIVELY_CONTAINS {relationshipUid: 'hu:rel:qc-synthetic-2025-selenium'}]->(se)
SET r.assertionUid = a.uid, r.quantity = 1520.0, r.unitCode = 'ug/hg', r.basis = 'AMOUNT_PER_MASS_OF_MATERIAL',
    r.comparator = 'EQ', r.contentStatementKind = 'TYPICAL_COMPOSITION_REPORTED', r.portionBasis = 'EDIBLE_PORTION', r.valueDerivation = 'ANALYTICAL', r.dataPoints = 6,
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-05T09:00:00Z');
