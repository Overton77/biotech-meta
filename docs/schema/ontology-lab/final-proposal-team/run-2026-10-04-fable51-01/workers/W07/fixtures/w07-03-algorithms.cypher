// W07 fixture 03: algorithms and algorithm versions (run-2026-10-04-fable51-01).
// Real records: GrimAge v1 (PMID 30669119) and GrimAge2 (PMID 36516495) (inherited); DunedinPACE R package DESCRIPTION
// "Version: 0.99.0", "for methylation data generated from either the Illumina 450K array or the Illumina EPIC array"
// (retrieved 2026-10-04); TruDiagnostic MSA "Suite of custom algorithms trained directly on our arrays ... DunedinPACE:
// Speed of aging" (retrieved 2026-10-04; no vendor version string on the page); Owkin Pathology Explorer help text,
// identical on 2026-10-03 and 2026-10-04, no model version, no area unit.
// Minimal pairs: same family / different AlgorithmVersion (GrimAge v1 vs GrimAge2; DunedinPACE 0.99.0 vs TruDiagnostic
// MSA implementation; Owkin endpoint pinned 2026-10-03 vs 2026-10-04, both SERVICE_ENDPOINT_UNVERSIONED).

// status: run
UNWIND [
  {k: 'grimage', n: 'GrimAge'},
  {k: 'dunedinpace', n: 'DunedinPACE'},
  {k: 'owkin-he-cell-detection', n: 'Owkin H&E cell detection model (Pathology Explorer)'}
] AS row
MERGE (al:Algorithm:Entity {uid: 'hu:algorithm:' + row.k})
SET al.id = row.k, al.name = row.n, al.entityType = 'ALGORITHM', al.privacyClass = 'PUBLIC', al.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
UNWIND [
  {k: 'dnam-grimage-years', n: 'DNAm GrimAge, years', u: 'a', us: 'REPORTED', d: null},
  {k: 'dnam-grimage2-years', n: 'DNAm GrimAge2, years', u: 'a', us: 'REPORTED', d: null},
  {k: 'dunedinpace-pace', n: 'DunedinPACE, years of biological aging per chronological year', u: 'a/a', us: 'REPORTED', d: 'Pace of aging; not an age (PMID 35029144).'},
  {k: 'trudiagnostic-dunedinpace-msa-pace', n: 'TruDiagnostic DunedinPACE (MSA), pace of aging', u: null, us: 'NOT_REPORTED', d: 'Vendor output named DunedinPACE; unit not stated on the platform page.'},
  {k: 'owkin-density-lymphocytes-in-tumor', n: 'density_lymphocytes_in_tumor', u: null, us: 'NOT_REPORTED', d: 'Density of lymphocytes cells in the tumor region of the slide.'}
] AS row
MERGE (m:Metric:Entity {uid: 'hu:metric:' + row.k})
SET m.id = row.k, m.name = row.n, m.metricKind = CASE WHEN row.k STARTS WITH 'owkin' THEN 'MODEL_FEATURE' ELSE 'ALGORITHM_OUTPUT' END,
    m.canonicalUnitCode = row.u, m.unitStatus = row.us, m.definitionText = row.d, m.entityType = 'METRIC', m.privacyClass = 'PUBLIC',
    m.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
UNWIND [
  {k: 'grimage-v1-lu-2019', al: 'grimage', n: 'DNAm GrimAge (Lu 2019)', vl: '1', vb: 'PUBLICATION_VERSION', ok: 'AGE_ESTIMATE', u: 'a', tp: null, ra: null, out: 'dnam-grimage-years'},
  {k: 'grimage2-lu-2022', al: 'grimage', n: 'DNAm GrimAge version 2 (Lu 2022)', vl: '2', vb: 'PUBLICATION_VERSION', ok: 'AGE_ESTIMATE', u: 'a', tp: 'trained on individuals aged between 40 and 92', ra: null, out: 'dnam-grimage2-years'},
  {k: 'dunedinpace-r-0-99-0', al: 'dunedinpace', n: 'DunedinPACE R package 0.99.0 (Belsky 2022 eLife Age45 score)', vl: '0.99.0', vb: 'VENDOR_VERSION_STRING', ok: 'PACE', u: 'a/a', tp: 'Dunedin Study, trained on 3 waves of collection (26, 38, and 45)', ra: null, out: 'dunedinpace-pace'},
  {k: 'trudiagnostic-dunedinpace-msa', al: 'dunedinpace', n: 'TruDiagnostic DunedinPACE trained on the MSA array', vl: null, vb: 'UNKNOWN', ok: 'PACE', u: null, tp: null, ra: null, out: 'trudiagnostic-dunedinpace-msa-pace'},
  {k: 'owkin-he-cell-detection-endpoint-2026-10-03', al: 'owkin-he-cell-detection', n: 'Owkin cell detection as served on 2026-10-03', vl: null, vb: 'SERVICE_ENDPOINT_UNVERSIONED', ok: 'FEATURE_MEASURE', u: null, tp: 'curated pancancer dataset covering 6 indications and more than 100k annotated nuclei (service help text)', ra: '2026-10-03T00:00:00Z', out: 'owkin-density-lymphocytes-in-tumor'},
  {k: 'owkin-he-cell-detection-endpoint-2026-10-04', al: 'owkin-he-cell-detection', n: 'Owkin cell detection as served on 2026-10-04', vl: null, vb: 'SERVICE_ENDPOINT_UNVERSIONED', ok: 'FEATURE_MEASURE', u: null, tp: 'curated pancancer dataset covering 6 indications and more than 100k annotated nuclei (service help text)', ra: '2026-10-04T01:04:00Z', out: 'owkin-density-lymphocytes-in-tumor'}
] AS row
MATCH (al:Algorithm {uid: 'hu:algorithm:' + row.al}), (m:Metric {uid: 'hu:metric:' + row.out})
MERGE (v:AlgorithmVersion:VersionedState {uid: 'hu:algorithm-version:' + row.k})
SET v.id = row.k, v.name = row.n, v.versionLabel = row.vl, v.versionBasis = row.vb, v.outputKind = row.ok, v.outputUnitCode = row.u,
    v.trainingPopulationText = row.tp, v.retrievedAt = CASE WHEN row.ra IS NULL THEN null ELSE datetime(row.ra) END,
    v.stateType = 'ALGORITHM_VERSION', v.payloadHash = 'synthetic:hu:algorithm-version:' + row.k, v.privacyClass = 'PUBLIC',
    v.maturity = 'PROVISIONAL', v.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (v)-[:VERSION_OF_ALGORITHM]->(al)
MERGE (v)-[:OUTPUTS_METRIC]->(m);

// Asserted algorithm edges (DERIVED_FROM_ALGORITHM_VERSION, COMPATIBLE_WITH_ASSAY_VERSION, REQUIRES_INPUT_METRIC).
// The TruDiagnostic -> 0.99.0 derivation is BellLabs' reading of "custom algorithms trained directly on our arrays"
// plus the family name: PROPOSED, no asserter (the vendor does not name the version it derived from).
// status: run
UNWIND [
  {k: 'grimage2-derived-from-grimage-v1', pred: 'DERIVED_FROM_ALGORITHM_VERSION', s: 'hu:algorithm-version:grimage2-lu-2022', o: 'hu:algorithm-version:grimage-v1-lu-2019', loc: 'pmid-36516495-abstract', st: 'ACCEPTED', by: null},
  {k: 'trudx-msa-derived-from-dunedinpace-0-99-0', pred: 'DERIVED_FROM_ALGORITHM_VERSION', s: 'hu:algorithm-version:trudiagnostic-dunedinpace-msa', o: 'hu:algorithm-version:dunedinpace-r-0-99-0', loc: 'trudiagnostic-msa-clocks', st: 'PROPOSED', by: null},
  {k: 'dunedinpace-0-99-0-compatible-with-epic', pred: 'COMPATIBLE_WITH_ASSAY_VERSION', s: 'hu:algorithm-version:dunedinpace-r-0-99-0', o: 'hu:assay-version:synthetic-lab-m-epic', loc: 'dunedinpace-r-version', st: 'ACCEPTED', by: null},
  {k: 'trudx-msa-compatible-with-trudx-msa-assay', pred: 'COMPATIBLE_WITH_ASSAY_VERSION', s: 'hu:algorithm-version:trudiagnostic-dunedinpace-msa', o: 'hu:assay-version:trudiagnostic-msa', loc: 'trudiagnostic-msa-clocks', st: 'ACCEPTED', by: 'hu:org:trudiagnostic'},
  {k: 'grimage2-compatible-with-lab-m-epic', pred: 'COMPATIBLE_WITH_ASSAY_VERSION', s: 'hu:algorithm-version:grimage2-lu-2022', o: 'hu:assay-version:synthetic-lab-m-epic', loc: 'synthetic-reports-body', st: 'ACCEPTED', by: 'hu:org:synthetic-lab-m'},
  {k: 'dunedinpace-0-99-0-requires-epic-beta', pred: 'REQUIRES_INPUT_METRIC', s: 'hu:algorithm-version:dunedinpace-r-0-99-0', o: 'hu:metric:dnam-beta-epic', loc: 'dunedinpace-r-version', st: 'ACCEPTED', by: null},
  {k: 'trudx-msa-requires-msa-beta', pred: 'REQUIRES_INPUT_METRIC', s: 'hu:algorithm-version:trudiagnostic-dunedinpace-msa', o: 'hu:metric:dnam-beta-msa', loc: 'trudiagnostic-msa-clocks', st: 'ACCEPTED', by: 'hu:org:trudiagnostic'}
] AS row
MATCH (s {uid: row.s}), (o {uid: row.o}), (l:SourceLocator {uid: 'hu:locator:' + row.loc})
MERGE (a:Assertion {uid: 'hu:assertion:' + row.k})
SET a.id = row.k, a.predicate = row.pred, a.status = row.st, a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.contentHash = 'synthetic:hu:assertion:' + row.k, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
WITH a, s, o, row
OPTIONAL MATCH (by:Organization {uid: row.by})
FOREACH (x IN CASE WHEN by IS NULL THEN [] ELSE [by] END | MERGE (a)-[:ASSERTED_BY]->(x))
WITH a, s, o, row
CALL (a, s, o, row) {
  WITH a, s, o, row WHERE row.pred = 'DERIVED_FROM_ALGORITHM_VERSION'
  MERGE (s)-[e:DERIVED_FROM_ALGORITHM_VERSION {relationshipUid: 'hu:rel:' + row.k}]->(o)
  SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
  RETURN count(*) AS n1
}
CALL (a, s, o, row) {
  WITH a, s, o, row WHERE row.pred = 'COMPATIBLE_WITH_ASSAY_VERSION'
  MERGE (s)-[e:COMPATIBLE_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:' + row.k}]->(o)
  SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
  RETURN count(*) AS n2
}
CALL (a, s, o, row) {
  WITH a, s, o, row WHERE row.pred = 'REQUIRES_INPUT_METRIC'
  MERGE (s)-[e:REQUIRES_INPUT_METRIC {relationshipUid: 'hu:rel:' + row.k}]->(o)
  SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN'
  RETURN count(*) AS n3
}
RETURN row.k, n1, n2, n3;
