// W07 fixture 02: reference interval versions (run-2026-10-04-fable51-01).
// Real wording (2026-10-04): Mayo HBA1C "Reference Values" prints a reference interval AND ADA decision limits in one
// field; Labcorp 001453 prints 4.8-5.6 % plus prediabetes/diabetes/glycemic-control limits, and its 2018 sample report
// prints "Diabetes: >6.4" where the 2026 test menu prints ">=6.5%"; Quest 496 prints a one-sided "<5.7 %" and says
// "Interpretative ranges are based on ADA guidelines". No real source states an EP28 derivation kind, so real intervals
// carry derivationKind NOT_REPORTED (requested value ADOPTED_FROM_GUIDELINE: W07-SR-06).
// Synthetic Lab A: interval change on the SAME assay version (a2 -> a3 on 2026-01-01); results keep the interval
// printed at report time (fixture 04).

// status: run
UNWIND [
  {k: 'mayo-hba1c-ri', av: 'mayo-hba1c-biorad-d100', m: 'hba1c-mfr-bld', lo: 4.0, hi: 5.6, los: 'REPORTED', his: 'REPORTED', loi: null, hii: null, u: '%', txt: '4.0-5.6%', kind: 'REFERENCE_INTERVAL', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'mayo-hba1c-reference-values'},
  {k: 'mayo-hba1c-prediabetes', av: 'mayo-hba1c-biorad-d100', m: 'hba1c-mfr-bld', lo: 5.7, hi: 6.4, los: 'REPORTED', his: 'REPORTED', loi: true, hii: true, u: '%', txt: '> or =18 years: Increased risk for diabetes (prediabetes): 5.7-6.4%', kind: 'DECISION_LIMIT', der: 'NOT_REPORTED', amin: 18.0, ptxt: '> or =18 years', ef: null, et: null, loc: 'mayo-hba1c-reference-values'},
  {k: 'mayo-hba1c-diabetes', av: 'mayo-hba1c-biorad-d100', m: 'hba1c-mfr-bld', lo: 6.5, hi: null, los: 'REPORTED', his: 'NOT_APPLICABLE', loi: true, hii: null, u: '%', txt: 'Diabetes: > or =6.5%', kind: 'DECISION_LIMIT', der: 'NOT_REPORTED', amin: 18.0, ptxt: '> or =18 years', ef: null, et: null, loc: 'mayo-hba1c-reference-values'},
  {k: 'labcorp-001453-ri', av: 'labcorp-001453-tina-quant', m: 'hba1c-mfr-bld', lo: 4.8, hi: 5.6, los: 'REPORTED', his: 'REPORTED', loi: null, hii: null, u: '%', txt: 'Hemoglobin (Hb) A1c: 4.8% to 5.6%', kind: 'REFERENCE_INTERVAL', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'labcorp-001453-reference-range'},
  {k: 'labcorp-001453-diabetes-menu', av: 'labcorp-001453-tina-quant', m: 'hba1c-mfr-bld', lo: 6.5, hi: null, los: 'REPORTED', his: 'NOT_APPLICABLE', loi: true, hii: null, u: '%', txt: 'Diabetes: >=6.5%', kind: 'DECISION_LIMIT', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'labcorp-001453-reference-range'},
  {k: 'labcorp-001453-diabetes-sample-report', av: 'labcorp-001453-tina-quant', m: 'hba1c-mfr-bld', lo: 6.4, hi: null, los: 'REPORTED', his: 'NOT_APPLICABLE', loi: false, hii: null, u: '%', txt: 'Diabetes: >6.4', kind: 'DECISION_LIMIT', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'labcorp-001453-sample-report-row'},
  {k: 'labcorp-001453-glycemic-target', av: 'labcorp-001453-tina-quant', m: 'hba1c-mfr-bld', lo: null, hi: 7.0, los: 'NOT_APPLICABLE', his: 'REPORTED', loi: null, hii: false, u: '%', txt: 'Glycemic control for adults with diabetes: <7.0%', kind: 'GUIDELINE_TARGET', der: 'NOT_REPORTED', amin: null, ptxt: 'adults with diabetes', ef: null, et: null, loc: 'labcorp-001453-reference-range'},
  {k: 'quest-496-range', av: 'quest-496-tinia', m: 'hba1c-mfr-bld', lo: null, hi: 5.7, los: 'NOT_APPLICABLE', his: 'REPORTED', loi: null, hii: false, u: '%', txt: '<5.7 %', kind: 'DECISION_LIMIT', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'quest-496-reference-range'},
  {k: 'synthetic-lab-a-hba1c-a1-adult', av: 'synthetic-lab-a-hba1c-tosoh-g8-5-24', m: 'hba1c-mfr-bld', lo: 4.0, hi: 5.6, los: 'REPORTED', his: 'REPORTED', loi: true, hii: true, u: '%', txt: '4.0 - 5.6 %', kind: 'REFERENCE_INTERVAL', der: 'ADOPTED_FROM_MANUFACTURER', amin: 18.0, ptxt: 'adults', ef: null, et: '2025-06-01T00:00:00Z', loc: 'synthetic-lab-a-notice-v2-body'},
  {k: 'synthetic-lab-a-hba1c-a2-adult', av: 'synthetic-lab-a-hba1c-cobas-c513', m: 'hba1c-mfr-bld', lo: 4.1, hi: 5.7, los: 'REPORTED', his: 'REPORTED', loi: true, hii: true, u: '%', txt: '4.1 - 5.7 %', kind: 'REFERENCE_INTERVAL', der: 'TRANSFERRED', amin: 18.0, ptxt: 'adults', ef: '2025-06-01T00:00:00Z', et: '2026-01-01T00:00:00Z', loc: 'synthetic-lab-a-notice-v2-body'},
  {k: 'synthetic-lab-a-hba1c-a3-adult', av: 'synthetic-lab-a-hba1c-cobas-c513', m: 'hba1c-mfr-bld', lo: 4.0, hi: 5.6, los: 'REPORTED', his: 'REPORTED', loi: true, hii: true, u: '%', txt: '4.0 - 5.6 %', kind: 'REFERENCE_INTERVAL', der: 'VERIFIED', amin: 18.0, ptxt: 'adults', ef: '2026-01-01T00:00:00Z', et: null, loc: 'synthetic-lab-a-interval-notice-body'},
  {k: 'synthetic-lab-b-hba1c-b1-adult', av: 'synthetic-lab-b-hba1c-cobas-c513-ifcc', m: 'hba1c-ifcc-sfr-bld', lo: 20.0, hi: 38.0, los: 'REPORTED', his: 'REPORTED', loi: true, hii: true, u: 'mmol/mol', txt: '20 - 38 mmol/mol', kind: 'REFERENCE_INTERVAL', der: 'VERIFIED', amin: 18.0, ptxt: 'adults', ef: null, et: null, loc: 'synthetic-reports-body'},
  {k: 'synthetic-lab-c-hba1c-c1', av: 'synthetic-lab-c-hba1c-ifcc', m: 'hba1c-ifcc-sfr-bld', lo: 20.0, hi: 41.0, los: 'REPORTED', his: 'REPORTED', loi: null, hii: null, u: 'mmol/mol', txt: '20-41', kind: 'REFERENCE_INTERVAL', der: 'NOT_REPORTED', amin: null, ptxt: null, ef: null, et: null, loc: 'synthetic-lab-c-menu-row'}
] AS row
MATCH (av:AssayVersion {uid: 'hu:assay-version:' + row.av}), (m:Metric {uid: 'hu:metric:' + row.m})
MERGE (ri:ReferenceIntervalVersion:VersionedState {uid: 'hu:ri-version:' + row.k})
SET ri.id = row.k, ri.lowerBound = row.lo, ri.upperBound = row.hi, ri.lowerBoundStatus = row.los, ri.upperBoundStatus = row.his,
    ri.lowerBoundInclusive = row.loi, ri.upperBoundInclusive = row.hii, ri.unitCode = row.u, ri.intervalText = row.txt,
    ri.intervalKind = row.kind, ri.derivationKind = row.der, ri.ageMinYears = row.amin, ri.partitionText = row.ptxt,
    ri.effectiveFrom = CASE WHEN row.ef IS NULL THEN null ELSE datetime(row.ef) END,
    ri.effectiveTo = CASE WHEN row.et IS NULL THEN null ELSE datetime(row.et) END,
    ri.stateType = 'REFERENCE_INTERVAL_VERSION', ri.payloadHash = 'synthetic:hu:ri-version:' + row.k,
    ri.privacyClass = 'PUBLIC', ri.maturity = 'PROVISIONAL', ri.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ri)-[:FOR_ASSAY_VERSION]->(av)
MERGE (ri)-[:FOR_METRIC]->(m);
