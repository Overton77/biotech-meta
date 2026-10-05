// W07 fixture 00: sources, snapshots and locators for the diagnostics fixtures (run-2026-10-04-fable51-01).
// Real public records retrieved 2026-10-04 by W07 (NEW_RETRIEVAL) and inherited repository citations (INHERITED) are
// recorded as Source -> SourceSnapshot -> SourceLocator. No bytes were hashed: every snapshot carries
// contentHashBasis 'SYNTHETIC_FIXTURE' with 'synthetic:<uid>' (catalog conventions). Synthetic labs use urn:synthetic.
// Every statement binds its own nodes by uid; no variable crosses ';'. Labels: primary label + archetype label.

// status: run (embedded Neo4j 5.26.31 Community, 2026-10-04)
UNWIND [
  {k: 'loinc-4548-4', uri: 'https://loinc.org/4548-4', t: 'LOINC 4548-4 Hemoglobin A1c/Hemoglobin.total in Blood', sk: 'TERMINOLOGY_RECORD'},
  {k: 'loinc-59261-8', uri: 'https://loinc.org/59261-8', t: 'LOINC 59261-8 Hemoglobin A1c/Hemoglobin.total standardized per IFCC-RMP for CDT in Blood', sk: 'TERMINOLOGY_RECORD'},
  {k: 'mayo-hba1c-test-definition', uri: 'https://www.mayocliniclabs.com/test-catalog/download-setup?format=pdf&unit_code=82080', t: 'Mayo Clinic Laboratories Test Definition HBA1C', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'labcorp-001453', uri: 'https://www.labcorp.com/tests/001453/hemoglobin-hb-a1c', t: 'Labcorp test 001453 Hemoglobin (Hb) A1c', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'labcorp-001453-sample-report', uri: 'https://files.labcorp.com/testmenu-d8/sample_reports/001453.pdf', t: 'Labcorp sample report 001453', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'quest-496', uri: 'https://testdirectory.questdiagnostics.com/test/test-detail/496/hemoglobin-a1c', t: 'Quest Diagnostics test 496 Hemoglobin A1c', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'everlywell-hba1c', uri: 'https://www.everlywell.com/products/hba1c/', t: 'Everlywell Hemoglobin A1c (HbA1c) Test', sk: 'MARKETING_PAGE'},
  {k: 'trudiagnostic-array-platforms', uri: 'https://www.trudiagnostic.com/our-array-platforms', t: 'TruDiagnostic Our Array Platforms', sk: 'MARKETING_PAGE'},
  {k: 'dunedinpace-r-description', uri: 'https://raw.githubusercontent.com/danbelsky/DunedinPACE/main/DESCRIPTION', t: 'DunedinPACE R package DESCRIPTION', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'pmid-35029144', uri: 'https://doi.org/10.7554/eLife.73420', t: 'DunedinPACE, a DNA methylation biomarker of the pace of aging', sk: 'PEER_REVIEWED_PUBLICATION'},
  {k: 'pmid-30669119', uri: 'https://doi.org/10.18632/aging.101684', t: 'DNA methylation GrimAge strongly predicts lifespan and healthspan', sk: 'PEER_REVIEWED_PUBLICATION'},
  {k: 'pmid-36516495', uri: 'https://doi.org/10.18632/aging.204434', t: 'DNA methylation GrimAge version 2', sk: 'PEER_REVIEWED_PUBLICATION'},
  {k: 'pmid-36277076', uri: 'https://doi.org/10.1038/s43587-022-00248-2', t: 'A computational solution for bolstering reliability of epigenetic clocks', sk: 'PEER_REVIEWED_PUBLICATION'},
  {k: 'clsi-ep28', uri: 'https://clsi.org/shop/standards/ep28/', t: 'CLSI EP28-A3c Defining, Establishing, and Verifying Reference Intervals in the Clinical Laboratory', sk: 'STANDARDS_DOCUMENT'},
  {k: 'ngsp-ifcc-ngsp', uri: 'https://ngsp.org/ifccngsp.asp', t: 'IFCC Standardization: IFCC and NGSP', sk: 'STANDARDS_DOCUMENT'},
  {k: 'owkin-pathology-explorer', uri: 'mcp://owkin/pathology_explorer', t: 'Owkin Pathology Explorer MCP service', sk: 'MODEL_SERVICE'},
  {k: 'synthetic-lab-a-method-notice', uri: 'urn:synthetic:lab-a:method-change-notice', t: 'Synthetic Lab A analyzer change notice', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'synthetic-lab-a-interval-notice', uri: 'urn:synthetic:lab-a:reference-interval-notice', t: 'Synthetic Lab A reference interval change notice', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'synthetic-lab-c-test-menu', uri: 'urn:synthetic:lab-c:test-menu', t: 'Synthetic Lab C (UK-style) test menu', sk: 'ORGANIZATION_WEBPAGE'},
  {k: 'synthetic-reports', uri: 'urn:synthetic:w07:result-reports', t: 'Synthetic result reports (W07 fixtures)', sk: 'ORGANIZATION_WEBPAGE'}
] AS row
MERGE (s:Source:Entity {uid: 'hu:source:' + row.k})
SET s.id = row.k, s.entityType = 'SOURCE', s.canonicalUri = row.uri, s.title = row.t, s.sourceKind = row.sk,
    s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T01:10:00Z');

// Snapshots. retrievedAt = W07 retrieval (2026-10-04) for NEW_RETRIEVAL; 2026-10-03 for inherited lane-3 captures.
// status: run
UNWIND [
  {k: 'loinc-4548-4-2026-10-04', src: 'loinc-4548-4', r: '2026-10-04T00:55:30Z', p: null, c: 'COMPLETE'},
  {k: 'loinc-59261-8-2026-10-04', src: 'loinc-59261-8', r: '2026-10-04T00:55:50Z', p: null, c: 'COMPLETE'},
  {k: 'mayo-hba1c-test-definition-2026-10-04', src: 'mayo-hba1c-test-definition', r: '2026-10-04T00:56:30Z', p: null, c: 'COMPLETE'},
  {k: 'labcorp-001453-2026-10-04', src: 'labcorp-001453', r: '2026-10-04T00:57:00Z', p: null, c: 'COMPLETE'},
  {k: 'labcorp-001453-sample-report-2026-10-04', src: 'labcorp-001453-sample-report', r: '2026-10-04T00:57:30Z', p: null, c: 'COMPLETE'},
  {k: 'quest-496-2026-10-04', src: 'quest-496', r: '2026-10-04T00:58:00Z', p: null, c: 'PARTIAL_EXCERPT'},
  {k: 'everlywell-hba1c-2026-10-04', src: 'everlywell-hba1c', r: '2026-10-04T01:03:00Z', p: null, c: 'PARTIAL_EXCERPT'},
  {k: 'trudiagnostic-array-platforms-2026-10-04', src: 'trudiagnostic-array-platforms', r: '2026-10-04T00:59:30Z', p: null, c: 'COMPLETE'},
  {k: 'dunedinpace-r-description-2026-10-04', src: 'dunedinpace-r-description', r: '2026-10-04T01:00:30Z', p: null, c: 'COMPLETE'},
  {k: 'pmid-35029144', src: 'pmid-35029144', r: '2026-10-03T00:00:00Z', p: '2022-01-14T00:00:00Z', c: 'UNKNOWN'},
  {k: 'pmid-30669119', src: 'pmid-30669119', r: '2026-10-03T00:00:00Z', p: '2019-01-21T00:00:00Z', c: 'UNKNOWN'},
  {k: 'pmid-36516495', src: 'pmid-36516495', r: '2026-10-03T00:00:00Z', p: '2022-12-14T00:00:00Z', c: 'UNKNOWN'},
  {k: 'pmid-36277076', src: 'pmid-36277076', r: '2026-10-03T00:00:00Z', p: '2022-07-15T00:00:00Z', c: 'UNKNOWN'},
  {k: 'clsi-ep28-2026-10-04', src: 'clsi-ep28', r: '2026-10-04T01:02:00Z', p: '2010-10-19T00:00:00Z', c: 'PARTIAL_EXCERPT'},
  {k: 'ngsp-ifcc-ngsp-2026-10-03', src: 'ngsp-ifcc-ngsp', r: '2026-10-03T00:00:00Z', p: null, c: 'UNKNOWN'},
  {k: 'owkin-pathology-explorer-2026-10-03', src: 'owkin-pathology-explorer', r: '2026-10-03T00:00:00Z', p: null, c: 'UNKNOWN'},
  {k: 'owkin-pathology-explorer-2026-10-04', src: 'owkin-pathology-explorer', r: '2026-10-04T01:04:00Z', p: null, c: 'COMPLETE'},
  {k: 'synthetic-lab-a-method-notice-v1', src: 'synthetic-lab-a-method-notice', r: '2025-07-15T00:00:00Z', p: null, c: 'COMPLETE'},
  {k: 'synthetic-lab-a-method-notice-v2', src: 'synthetic-lab-a-method-notice', r: '2025-08-20T00:00:00Z', p: null, c: 'COMPLETE'},
  {k: 'synthetic-lab-a-interval-notice-v1', src: 'synthetic-lab-a-interval-notice', r: '2026-01-05T00:00:00Z', p: null, c: 'COMPLETE'},
  {k: 'synthetic-lab-c-test-menu-v1', src: 'synthetic-lab-c-test-menu', r: '2026-10-04T00:00:00Z', p: null, c: 'COMPLETE'},
  {k: 'synthetic-reports-v1', src: 'synthetic-reports', r: '2026-10-04T00:00:00Z', p: null, c: 'COMPLETE'}
] AS row
MATCH (s:Source {uid: 'hu:source:' + row.src})
MERGE (sn:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:' + row.k})
SET sn.id = row.k, sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = s.canonicalUri,
    sn.retrievedAt = datetime(row.r), sn.observedAt = datetime(row.r),
    sn.publishedAt = CASE WHEN row.p IS NULL THEN null ELSE datetime(row.p) END,
    sn.contentHash = 'synthetic:hu:snapshot:' + row.k, sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = row.c, sn.privacyClass = 'PUBLIC', sn.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

// Locators: SECTION locators with the exact field read (quote text in `exact` where the field is short).
// status: run
UNWIND [
  {k: 'loinc-4548-4-part-model', sn: 'loinc-4548-4-2026-10-04', sec: 'Part Model', ex: 'Property MFr; Time Pt; System Bld; Scale Qn; Method NULL'},
  {k: 'loinc-4548-4-mapping-guidance', sn: 'loinc-4548-4-2026-10-04', sec: 'Reference Information / Mapping Guidance', ex: 'All three protocols produce different numeric values.'},
  {k: 'loinc-59261-8-names', sn: 'loinc-59261-8-2026-10-04', sec: 'LOINC Names / Part Model', ex: 'Hemoglobin A1c/Hemoglobin.total^^standardized per IFCC-RMP for CDT:SFr:Pt:Bld:Qn:'},
  {k: 'mayo-hba1c-method-description', sn: 'mayo-hba1c-test-definition-2026-10-04', sec: 'Performance / Method Description', ex: 'The D-100 hemoglobin A1c (HbA1c) test utilizes principles of ion-exchange high-performance liquid chromatography.'},
  {k: 'mayo-hba1c-reference-values', sn: 'mayo-hba1c-test-definition-2026-10-04', sec: 'Reference Values', ex: '4.0-5.6%'},
  {k: 'mayo-hba1c-loinc', sn: 'mayo-hba1c-test-definition-2026-10-04', sec: 'LOINC Information', ex: 'HBA1C | Hemoglobin A1c, B | 4548-4'},
  {k: 'labcorp-001453-methodology', sn: 'labcorp-001453-2026-10-04', sec: 'Test Details / Methodology', ex: 'Roche Tina Quant'},
  {k: 'labcorp-001453-reference-range', sn: 'labcorp-001453-2026-10-04', sec: 'Specimen Requirements / Reference Range', ex: 'Hemoglobin (Hb) A1c: 4.8% to 5.6%'},
  {k: 'labcorp-001453-loinc-map', sn: 'labcorp-001453-2026-10-04', sec: 'LOINC Map', ex: '001453 | Hemoglobin A1c | 4548-4 | 001481 | Hemoglobin A1c | % | 4548-4'},
  {k: 'labcorp-001453-sample-report-row', sn: 'labcorp-001453-sample-report-2026-10-04', sec: 'Ordered Items (page 1)', ex: 'Hemoglobin A1c 4.9 % 4.8 - 5.6 01'},
  {k: 'quest-496-methodology', sn: 'quest-496-2026-10-04', sec: 'Details / Methodology', ex: 'Turbidimetric Inhibition Immunoassay'},
  {k: 'quest-496-reference-range', sn: 'quest-496-2026-10-04', sec: 'Reference range(s)', ex: '<5.7 %'},
  {k: 'everlywell-hba1c-labs', sn: 'everlywell-hba1c-2026-10-04', sec: 'CLIA-certified laboratories', ex: 'Each lab we work with is CLIA-certified'},
  {k: 'trudiagnostic-msa-clocks', sn: 'trudiagnostic-array-platforms-2026-10-04', sec: 'Methylation Screening Array (MSA) / Biological Clocks', ex: 'Suite of custom algorithms trained directly on our arrays'},
  {k: 'dunedinpace-r-version', sn: 'dunedinpace-r-description-2026-10-04', sec: 'DESCRIPTION fields Version, Description', ex: 'Version: 0.99.0'},
  {k: 'pmid-35029144-abstract', sn: 'pmid-35029144', sec: 'Abstract', ex: null},
  {k: 'pmid-30669119-abstract', sn: 'pmid-30669119', sec: 'Abstract', ex: null},
  {k: 'pmid-36516495-abstract', sn: 'pmid-36516495', sec: 'Abstract', ex: null},
  {k: 'pmid-36277076-abstract', sn: 'pmid-36277076', sec: 'Abstract', ex: 'technical noise produces deviations up to 9 years between replicates'},
  {k: 'clsi-ep28-foreword', sn: 'clsi-ep28-2026-10-04', sec: 'Foreword (free sample PDF)', ex: 'collecting as few as 20 samples from qualified reference individuals'},
  {k: 'ngsp-master-equation-table-2', sn: 'ngsp-ifcc-ngsp-2026-10-03', sec: 'Table 2', ex: 'NGSP = (0.09148 * IFCC) + 2.152'},
  {k: 'owkin-help-2026-10-03', sn: 'owkin-pathology-explorer-2026-10-03', sec: 'pathology_explorer_help', ex: null},
  {k: 'owkin-help-2026-10-04', sn: 'owkin-pathology-explorer-2026-10-04', sec: 'pathology_explorer_help', ex: 'The preprint is available at https://arxiv.org/abs/2508.09926.'},
  {k: 'synthetic-lab-a-notice-v1-body', sn: 'synthetic-lab-a-method-notice-v1', sec: 'body (v1: switch effective 2025-07-01)', ex: null},
  {k: 'synthetic-lab-a-notice-v2-body', sn: 'synthetic-lab-a-method-notice-v2', sec: 'body (v2 correction: switch effective 2025-06-01)', ex: null},
  {k: 'synthetic-lab-a-interval-notice-body', sn: 'synthetic-lab-a-interval-notice-v1', sec: 'body (new interval 4.0-5.6 % verified, effective 2026-01-01)', ex: null},
  {k: 'synthetic-lab-c-menu-row', sn: 'synthetic-lab-c-test-menu-v1', sec: 'Hemoglobin A1c row (mmol/mol)', ex: null},
  {k: 'synthetic-reports-body', sn: 'synthetic-reports-v1', sec: 'whole report set', ex: null}
] AS row
MATCH (sn:SourceSnapshot {uid: 'hu:snapshot:' + row.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: 'hu:locator:' + row.k})
SET l.id = row.k, l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'SECTION', l.section = row.sec, l.exact = row.ex,
    l.uri = sn.canonicalUri, l.snapshotUid = sn.uid, l.privacyClass = 'PUBLIC', l.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);
