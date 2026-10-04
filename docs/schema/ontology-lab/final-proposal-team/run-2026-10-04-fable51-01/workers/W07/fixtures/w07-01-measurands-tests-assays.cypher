// W07 fixture 01: biomarker, metrics (LOINC part model), orderable tests, assay versions (run-2026-10-04-fable51-01).
// Real records (2026-10-04): LOINC 4548-4 / 59261-8 part models; Mayo HBA1C (ion-exchange HPLC on Bio-Rad D-100,
// software version not stated); Labcorp 001453 ("Roche Tina Quant", instrument and principle not stated, three accepted
// tube types); Quest 496 (turbidimetric inhibition immunoassay, instrument not stated; LOINC and performing lab hidden
// until a service area is chosen); Everlywell (performing laboratory not named: "Each lab we work with").
// Synthetic: Labs A, B, C (values and dates). Organization, ToolOrInstrument, AnatomicalContext and Identifier nodes are
// other owners' types, written here only as fixture endpoints with their primary + archetype labels.
// Minimal pairs: same LOINC 4548-4 / different AssayVersion (Mayo, Labcorp, Quest, Lab A x2);
//                same test name "Hemoglobin A1c" / different Metric (Labcorp 4548-4 vs synthetic Lab C 59261-8).
// Temporal correction: Lab A switch date corrected 2025-07-01 -> 2025-06-01 (two recorded-time episodes).

// status: run
UNWIND [
  {k: 'mayo-clinic-laboratories', n: 'Mayo Clinic Laboratories'},
  {k: 'labcorp', n: 'Labcorp'},
  {k: 'quest-diagnostics', n: 'Quest Diagnostics'},
  {k: 'everlywell', n: 'Everlywell'},
  {k: 'trudiagnostic', n: 'TruDiagnostic'},
  {k: 'owkin', n: 'Owkin'},
  {k: 'synthetic-lab-a', n: 'Synthetic Lab A'},
  {k: 'synthetic-lab-b', n: 'Synthetic Lab B'},
  {k: 'synthetic-lab-c', n: 'Synthetic Lab C'},
  {k: 'synthetic-lab-m', n: 'Synthetic Methylation Lab M'},
  {k: 'regenstrief-institute', n: 'Regenstrief Institute'}
] AS row
MERGE (o:Organization:Entity {uid: 'hu:org:' + row.k})
SET o.id = row.k, o.name = row.n, o.entityType = 'ORGANIZATION', o.privacyClass = 'PUBLIC', o.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
UNWIND [
  {k: 'bio-rad-d100', n: 'Bio-Rad D-100'},
  {k: 'tosoh-g8', n: 'Tosoh G8'},
  {k: 'roche-cobas-c513', n: 'Roche cobas c513'}
] AS row
MERGE (t:ToolOrInstrument:Entity {uid: 'hu:instrument:' + row.k})
SET t.id = row.k, t.name = row.n, t.entityType = 'TOOL_OR_INSTRUMENT', t.privacyClass = 'PUBLIC', t.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
MERGE (c:AnatomicalContext:Entity {uid: 'hu:anatomical-context:blood'})
SET c.id = 'blood', c.name = 'Blood', c.entityType = 'ANATOMICAL_CONTEXT', c.privacyClass = 'PUBLIC', c.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
MERGE (b:Biomarker:Entity {uid: 'hu:biomarker:hba1c'})
SET b.id = 'hba1c', b.name = 'Glycated hemoglobin (HbA1c)', b.biomarkerKind = 'PROTEIN_MODIFICATION', b.entityType = 'BIOMARKER',
    b.privacyClass = 'PUBLIC', b.maturity = 'PROVISIONAL', b.createdAt = datetime('2026-10-04T01:10:00Z');

// MEASURED_IN_MATRIX: W03's structural relationship, written from W07's Biomarker (CQ-MX-02 seam).
// status: run
MATCH (b:Biomarker {uid: 'hu:biomarker:hba1c'}), (c:AnatomicalContext {uid: 'hu:anatomical-context:blood'})
MERGE (b)-[:MEASURED_IN_MATRIX]->(c);

// Metrics: LOINC part model as published (2026-10-04). 59261-8's component carries the adjustment
// "standardized per IFCC-RMP for CDT" (LP310257-3) in the fully specified name; recorded verbatim.
// status: run
UNWIND [
  {k: 'hba1c-mfr-bld', n: 'Hemoglobin A1c/Hemoglobin.total in Blood', loinc: '4548-4', p: 'MFr', sy: 'Bld', sc: 'Qn', u: '%', us: 'REPORTED', kind: 'MEASURAND', d: 'Hemoglobin A1c/Hemoglobin.total:MFr:Pt:Bld:Qn: (Method NULL)'},
  {k: 'hba1c-ifcc-sfr-bld', n: 'Hemoglobin A1c/Hemoglobin.total standardized per IFCC-RMP for CDT in Blood', loinc: '59261-8', p: 'SFr', sy: 'Bld', sc: 'Qn', u: 'mmol/mol', us: 'REPORTED', kind: 'MEASURAND', d: 'Hemoglobin A1c/Hemoglobin.total^^standardized per IFCC-RMP for CDT:SFr:Pt:Bld:Qn: (Example units not listed on the page; mmol/mol from the term description)'},
  {k: 'dnam-beta-msa', n: 'DNA methylation beta values, Infinium MSA probes', loinc: null, p: null, sy: null, sc: null, u: null, us: 'NOT_APPLICABLE', kind: 'MEASURAND', d: 'Per-CpG methylation beta values from the Illumina Methylation Screening Array (input to vendor clocks).'},
  {k: 'dnam-beta-epic', n: 'DNA methylation beta values, Infinium EPIC probes', loinc: null, p: null, sy: null, sc: null, u: null, us: 'NOT_APPLICABLE', kind: 'MEASURAND', d: 'Per-CpG methylation beta values from Illumina 450K/EPIC arrays.'}
] AS row
MERGE (m:Metric:Entity {uid: 'hu:metric:' + row.k})
SET m.id = row.k, m.name = row.n, m.loincCode = row.loinc, m.propertyKind = row.p, m.systemKind = row.sy, m.scaleKind = row.sc,
    m.canonicalUnitCode = row.u, m.unitStatus = row.us, m.metricKind = row.kind, m.definitionText = row.d,
    m.entityType = 'METRIC', m.privacyClass = 'PUBLIC', m.maturity = 'PROVISIONAL', m.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
MATCH (m1:Metric {uid: 'hu:metric:hba1c-mfr-bld'}), (m2:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'}), (b:Biomarker {uid: 'hu:biomarker:hba1c'})
MERGE (m1)-[:QUANTIFIES]->(b)
MERGE (m2)-[:QUANTIFIES]->(b);

// status: run
UNWIND [
  {k: 'loinc-4548-4', v: '4548-4'},
  {k: 'loinc-59261-8', v: '59261-8'}
] AS row
MERGE (i:Identifier:Entity {uid: 'hu:identifier:' + row.k})
SET i.id = row.k, i.scheme = 'LOINC', i.value = row.v, i.issuer = 'Regenstrief Institute', i.entityType = 'IDENTIFIER',
    i.privacyClass = 'PUBLIC', i.createdAt = datetime('2026-10-04T01:10:00Z');

// HAS_IDENTIFIER (W00, asserted): assertion + edge in one statement.
// status: run
UNWIND [
  {s: 'hu:metric:hba1c-mfr-bld', o: 'hu:identifier:loinc-4548-4', loc: 'hu:locator:loinc-4548-4-part-model', a: 'has-identifier-hba1c-mfr-bld-loinc-4548-4'},
  {s: 'hu:metric:hba1c-ifcc-sfr-bld', o: 'hu:identifier:loinc-59261-8', loc: 'hu:locator:loinc-59261-8-names', a: 'has-identifier-hba1c-ifcc-sfr-bld-loinc-59261-8'}
] AS row
MATCH (s:Metric {uid: row.s}), (o:Identifier {uid: row.o}), (l:SourceLocator {uid: row.loc}), (by:Organization {uid: 'hu:org:regenstrief-institute'})
MERGE (a:Assertion {uid: 'hu:assertion:' + row.a})
SET a.id = row.a, a.predicate = 'HAS_IDENTIFIER', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY',
    a.recordedAt = datetime('2026-10-04T01:10:00Z'), a.contentHash = 'synthetic:hu:assertion:' + row.a, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(by)
MERGE (s)-[e:HAS_IDENTIFIER {relationshipUid: 'hu:rel:' + row.a}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.isPrimary = true;

// Methods, specimen types, reference systems.
// status: run
UNWIND [
  {k: 'ion-exchange-hplc', n: 'Ion-exchange high-performance liquid chromatography', p: 'HPLC'},
  {k: 'turbidimetric-inhibition-immunoassay', n: 'Turbidimetric inhibition immunoassay', p: 'IMMUNOASSAY'},
  {k: 'methylation-array', n: 'DNA methylation microarray (bisulfite, Infinium chemistry)', p: 'METHYLATION_ARRAY'}
] AS row
MERGE (mm:MeasurementMethod:Entity {uid: 'hu:method:' + row.k})
SET mm.id = row.k, mm.name = row.n, mm.methodPrinciple = row.p, mm.entityType = 'MEASUREMENT_METHOD', mm.privacyClass = 'PUBLIC',
    mm.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
UNWIND [
  {k: 'whole-blood-edta', n: 'Whole blood (EDTA, lavender top)', c: 'WHOLE_BLOOD_EDTA'},
  {k: 'whole-blood-li-heparin', n: 'Whole blood (lithium heparin, green top)', c: 'WHOLE_BLOOD_LITHIUM_HEPARIN'},
  {k: 'whole-blood-naf', n: 'Whole blood (sodium fluoride, gray top)', c: 'WHOLE_BLOOD_SODIUM_FLUORIDE'}
] AS row
MERGE (sp:Specimen:Entity {uid: 'hu:specimen-type:' + row.k})
SET sp.id = row.k, sp.name = row.n, sp.specimenTypeCode = row.c, sp.entityType = 'SPECIMEN', sp.privacyClass = 'PUBLIC',
    sp.createdAt = datetime('2026-10-04T01:10:00Z');

// status: run
UNWIND [
  {k: 'ngsp', n: 'NGSP', kind: 'STANDARDIZATION_PROGRAM'},
  {k: 'ifcc-rmp-hba1c', n: 'IFCC reference measurement procedure for HbA1c', kind: 'REFERENCE_MEASUREMENT_PROCEDURE'}
] AS row
MERGE (r:ReferenceSystem:Entity {uid: 'hu:reference-system:' + row.k})
SET r.id = row.k, r.name = row.n, r.referenceSystemKind = row.kind, r.entityType = 'REFERENCE_SYSTEM', r.privacyClass = 'PUBLIC',
    r.createdAt = datetime('2026-10-04T01:10:00Z');

// Orderable tests. Two are named "Hemoglobin A1c" (Labcorp, synthetic Lab C) and measure different Metrics.
// status: run
UNWIND [
  {k: 'mayo-hba1c', n: 'Hemoglobin A1c, Blood', code: 'HBA1C', iss: 'hu:org:mayo-clinic-laboratories'},
  {k: 'labcorp-001453', n: 'Hemoglobin A1c', code: '001453', iss: 'hu:org:labcorp'},
  {k: 'quest-496', n: 'Hemoglobin A1c', code: '496', iss: 'hu:org:quest-diagnostics'},
  {k: 'everlywell-hba1c', n: 'HbA1c Test', code: null, iss: 'hu:org:everlywell'},
  {k: 'synthetic-lab-a-hba1c', n: 'Hemoglobin A1c', code: 'A1C', iss: 'hu:org:synthetic-lab-a'},
  {k: 'synthetic-lab-b-hba1c-ifcc', n: 'HbA1c (IFCC)', code: 'HBA1C-IFCC', iss: 'hu:org:synthetic-lab-b'},
  {k: 'synthetic-lab-c-hba1c', n: 'Hemoglobin A1c', code: 'HBA1C', iss: 'hu:org:synthetic-lab-c'}
] AS row
MERGE (lt:LabTest:Entity {uid: 'hu:lab-test:' + row.k})
SET lt.id = row.k, lt.name = row.n, lt.localTestCode = row.code, lt.issuerUid = row.iss, lt.entityType = 'LAB_TEST',
    lt.privacyClass = 'PUBLIC', lt.maturity = 'PROVISIONAL', lt.createdAt = datetime('2026-10-04T01:10:00Z');

// MEASURES_METRIC (asserted, MeasurementEdgeProperties). Quest's LOINC is hidden until a service area is chosen, so
// Quest's MEASURES_METRIC is PROPOSED from the methodology/name only and cites the methodology locator.
// status: run
UNWIND [
  {s: 'mayo-hba1c', o: 'hba1c-mfr-bld', loc: 'mayo-hba1c-loinc', by: 'mayo-clinic-laboratories', st: 'ACCEPTED', unit: '%'},
  {s: 'labcorp-001453', o: 'hba1c-mfr-bld', loc: 'labcorp-001453-loinc-map', by: 'labcorp', st: 'ACCEPTED', unit: '%'},
  {s: 'quest-496', o: 'hba1c-mfr-bld', loc: 'quest-496-methodology', by: 'quest-diagnostics', st: 'PROPOSED', unit: '%'},
  {s: 'synthetic-lab-a-hba1c', o: 'hba1c-mfr-bld', loc: 'synthetic-lab-a-notice-v2-body', by: 'synthetic-lab-a', st: 'ACCEPTED', unit: '%'},
  {s: 'synthetic-lab-b-hba1c-ifcc', o: 'hba1c-ifcc-sfr-bld', loc: 'synthetic-reports-body', by: 'synthetic-lab-b', st: 'ACCEPTED', unit: 'mmol/mol'},
  {s: 'synthetic-lab-c-hba1c', o: 'hba1c-ifcc-sfr-bld', loc: 'synthetic-lab-c-menu-row', by: 'synthetic-lab-c', st: 'ACCEPTED', unit: 'mmol/mol'}
] AS row
MATCH (s:LabTest {uid: 'hu:lab-test:' + row.s}), (o:Metric {uid: 'hu:metric:' + row.o}), (l:SourceLocator {uid: 'hu:locator:' + row.loc}), (by:Organization {uid: 'hu:org:' + row.by})
MERGE (a:Assertion {uid: 'hu:assertion:measures-metric-' + row.s + '-' + row.o})
SET a.id = 'measures-metric-' + row.s + '-' + row.o, a.predicate = 'MEASURES_METRIC', a.status = row.st, a.polarity = 'POSITIVE',
    a.recordedAt = datetime('2026-10-04T01:10:00Z'), a.contentHash = 'synthetic:' + a.uid, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(by)
MERGE (s)-[e:MEASURES_METRIC {relationshipUid: 'hu:rel:measures-metric-' + row.s + '-' + row.o}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN', e.unit = row.unit;

// Assay versions. payloadHash is a fixture value over the uid (no canonical payload serializer exists yet).
// status: run
UNWIND [
  {k: 'mayo-hba1c-biorad-d100', n: 'Mayo HBA1C, ion-exchange HPLC on Bio-Rad D-100 (IFU LB0002870revA, 2014)', kit: 'Bio-Rad D-100 HbA1c', sw: null, sws: 'NOT_REPORTED', u: '%'},
  {k: 'labcorp-001453-tina-quant', n: 'Labcorp 001453, Roche Tina Quant (instrument and principle not stated)', kit: 'Roche Tina Quant', sw: null, sws: 'NOT_REPORTED', u: '%'},
  {k: 'quest-496-tinia', n: 'Quest 496, turbidimetric inhibition immunoassay (instrument not stated)', kit: null, sw: null, sws: 'NOT_REPORTED', u: '%'},
  {k: 'synthetic-lab-a-hba1c-tosoh-g8-5-24', n: 'Lab A HbA1c on Tosoh G8, software 5.24', kit: null, sw: '5.24', sws: 'REPORTED', u: '%'},
  {k: 'synthetic-lab-a-hba1c-cobas-c513', n: 'Lab A HbA1c on cobas c513', kit: null, sw: null, sws: 'NOT_REPORTED', u: '%'},
  {k: 'synthetic-lab-b-hba1c-cobas-c513-ifcc', n: 'Lab B HbA1c on cobas c513, IFCC units', kit: null, sw: null, sws: 'NOT_REPORTED', u: 'mmol/mol'},
  {k: 'synthetic-lab-c-hba1c-ifcc', n: 'Lab C HbA1c, IFCC units (method not stated)', kit: null, sw: null, sws: 'NOT_REPORTED', u: 'mmol/mol'},
  {k: 'trudiagnostic-msa', n: 'TruDiagnostic methylation profiling on Infinium Methylation Screening Array', kit: 'Illumina Infinium Methylation Screening Array (MSA)', sw: null, sws: 'NOT_REPORTED', u: null},
  {k: 'synthetic-lab-m-epic', n: 'Lab M methylation profiling on Infinium EPIC', kit: 'Illumina Infinium MethylationEPIC', sw: null, sws: 'NOT_REPORTED', u: null}
] AS row
MERGE (a:AssayVersion:VersionedState {uid: 'hu:assay-version:' + row.k})
SET a.id = row.k, a.name = row.n, a.assayKitIdentifier = row.kit, a.softwareVersion = row.sw, a.softwareVersionStatus = row.sws,
    a.reportedUnitCode = row.u, a.stateType = 'ASSAY_VERSION', a.payloadHash = 'synthetic:hu:assay-version:' + row.k,
    a.privacyClass = 'PUBLIC', a.maturity = 'PROVISIONAL', a.createdAt = datetime('2026-10-04T01:10:00Z');

// Structural payload edges (one statement per assay version; absent fields stay absent, never guessed).
// status: run
UNWIND [
  {a: 'mayo-hba1c-biorad-d100', op: 'mayo-clinic-laboratories', mm: 'ion-exchange-hplc', t: 'bio-rad-d100', ms: ['hba1c-mfr-bld'], sp: ['whole-blood-edta'], rs: []},
  {a: 'labcorp-001453-tina-quant', op: 'labcorp', mm: null, t: null, ms: ['hba1c-mfr-bld'], sp: ['whole-blood-edta', 'whole-blood-li-heparin', 'whole-blood-naf'], rs: []},
  {a: 'quest-496-tinia', op: 'quest-diagnostics', mm: 'turbidimetric-inhibition-immunoassay', t: null, ms: ['hba1c-mfr-bld'], sp: ['whole-blood-edta'], rs: []},
  {a: 'synthetic-lab-a-hba1c-tosoh-g8-5-24', op: 'synthetic-lab-a', mm: 'ion-exchange-hplc', t: 'tosoh-g8', ms: ['hba1c-mfr-bld'], sp: ['whole-blood-edta'], rs: ['ngsp']},
  {a: 'synthetic-lab-a-hba1c-cobas-c513', op: 'synthetic-lab-a', mm: 'turbidimetric-inhibition-immunoassay', t: 'roche-cobas-c513', ms: ['hba1c-mfr-bld'], sp: ['whole-blood-edta'], rs: ['ngsp']},
  {a: 'synthetic-lab-b-hba1c-cobas-c513-ifcc', op: 'synthetic-lab-b', mm: 'turbidimetric-inhibition-immunoassay', t: 'roche-cobas-c513', ms: ['hba1c-ifcc-sfr-bld'], sp: ['whole-blood-edta'], rs: ['ifcc-rmp-hba1c']},
  {a: 'synthetic-lab-c-hba1c-ifcc', op: 'synthetic-lab-c', mm: null, t: null, ms: ['hba1c-ifcc-sfr-bld'], sp: ['whole-blood-edta'], rs: ['ifcc-rmp-hba1c']},
  {a: 'trudiagnostic-msa', op: 'trudiagnostic', mm: 'methylation-array', t: null, ms: ['dnam-beta-msa'], sp: [], rs: []},
  {a: 'synthetic-lab-m-epic', op: 'synthetic-lab-m', mm: 'methylation-array', t: null, ms: ['dnam-beta-epic'], sp: ['whole-blood-edta'], rs: []}
] AS row
MATCH (a:AssayVersion {uid: 'hu:assay-version:' + row.a}), (op:Organization {uid: 'hu:org:' + row.op})
MERGE (a)-[:ASSAY_OPERATED_BY]->(op)
WITH a, row
OPTIONAL MATCH (mm:MeasurementMethod {uid: 'hu:method:' + row.mm})
OPTIONAL MATCH (t:ToolOrInstrument {uid: 'hu:instrument:' + row.t})
FOREACH (x IN CASE WHEN mm IS NULL THEN [] ELSE [mm] END | MERGE (a)-[:USES_METHOD]->(x))
FOREACH (x IN CASE WHEN t IS NULL THEN [] ELSE [t] END | MERGE (a)-[:RUNS_ON_INSTRUMENT]->(x))
WITH a, row
UNWIND row.ms AS mk
MATCH (m:Metric {uid: 'hu:metric:' + mk})
MERGE (a)-[:ASSAY_FOR_METRIC]->(m)
WITH DISTINCT a, row
CALL (a, row) {
  UNWIND row.sp AS sk
  MATCH (sp:Specimen {uid: 'hu:specimen-type:' + sk})
  MERGE (a)-[:ACCEPTS_SPECIMEN_TYPE]->(sp)
  RETURN count(*) AS nsp
}
CALL (a, row) {
  UNWIND row.rs AS rk
  MATCH (r:ReferenceSystem {uid: 'hu:reference-system:' + rk})
  MERGE (a)-[:CALIBRATION_TRACEABLE_TO]->(r)
  RETURN count(*) AS nrs
}
RETURN a.uid, nsp, nrs;

// PERFORMED_WITH_ASSAY_VERSION (asserted, bitemporal). Real labs: valid time unknown (the page states the current
// method only; OBSERVATION_ONLY on the snapshot date would be a guess, so validFrom stays null with basis UNKNOWN).
// status: run
UNWIND [
  {s: 'mayo-hba1c', o: 'mayo-hba1c-biorad-d100', loc: 'mayo-hba1c-method-description', by: 'mayo-clinic-laboratories'},
  {s: 'labcorp-001453', o: 'labcorp-001453-tina-quant', loc: 'labcorp-001453-methodology', by: 'labcorp'},
  {s: 'quest-496', o: 'quest-496-tinia', loc: 'quest-496-methodology', by: 'quest-diagnostics'},
  {s: 'synthetic-lab-b-hba1c-ifcc', o: 'synthetic-lab-b-hba1c-cobas-c513-ifcc', loc: 'synthetic-reports-body', by: 'synthetic-lab-b'},
  {s: 'synthetic-lab-c-hba1c', o: 'synthetic-lab-c-hba1c-ifcc', loc: 'synthetic-lab-c-menu-row', by: 'synthetic-lab-c'}
] AS row
MATCH (s:LabTest {uid: 'hu:lab-test:' + row.s}), (o:AssayVersion {uid: 'hu:assay-version:' + row.o}), (l:SourceLocator {uid: 'hu:locator:' + row.loc}), (by:Organization {uid: 'hu:org:' + row.by})
MERGE (a:Assertion {uid: 'hu:assertion:performed-with-' + row.s})
SET a.id = 'performed-with-' + row.s, a.predicate = 'PERFORMED_WITH_ASSAY_VERSION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
    a.recordedAt = datetime('2026-10-04T01:10:00Z'), a.contentHash = 'synthetic:' + a.uid, a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(s)
MERGE (a)-[:HAS_OBJECT]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(by)
MERGE (s)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:performed-with-' + row.s}]->(o)
SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// Lab A analyzer change with a corrected switch date (inherited round 0004 case). Older assertion SUPERSEDED.
// status: run
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (l1:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v1-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-07-01'})
SET x.id = 'lab-a-hba1c-used-tosoh-g8-until-2025-07-01', x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'SUPERSEDED', x.polarity = 'POSITIVE',
    x.recordedAt = datetime('2025-07-15T00:00:00Z'), x.recordedTo = datetime('2025-08-20T00:00:00Z'),
    x.validTo = datetime('2025-07-01T00:00:00Z'), x.validToBasis = 'STATED_BY_SOURCE', x.validToPrecision = 'DAY',
    x.contentHash = 'synthetic:' + x.uid, x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a1)
MERGE (x)-[:SUPPORTED_BY]->(l1)
MERGE (x)-[:ASSERTED_BY]->(lab)
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a1-episode-1'}]->(a1)
SET e.assertionUid = x.uid, e.validToBasis = 'STATED_BY_SOURCE', e.validTo = x.validTo, e.validToPrecision = 'DAY', e.validFromBasis = 'UNKNOWN',
    e.recordedFrom = x.recordedAt, e.recordedTo = x.recordedTo;

// status: run
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (l2:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-06-01'})
SET x.id = 'lab-a-hba1c-used-tosoh-g8-until-2025-06-01', x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'ACCEPTED', x.polarity = 'POSITIVE',
    x.recordedAt = datetime('2025-08-20T00:00:00Z'), x.validTo = datetime('2025-06-01T00:00:00Z'), x.validToBasis = 'STATED_BY_SOURCE', x.validToPrecision = 'DAY',
    x.contentHash = 'synthetic:' + x.uid, x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a1)
MERGE (x)-[:SUPPORTED_BY]->(l2)
MERGE (x)-[:ASSERTED_BY]->(lab)
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a1-episode-2'}]->(a1)
SET e.assertionUid = x.uid, e.validToBasis = 'STATED_BY_SOURCE', e.validTo = x.validTo, e.validToPrecision = 'DAY', e.validFromBasis = 'UNKNOWN',
    e.recordedFrom = x.recordedAt;

// status: run
MATCH (newer:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-06-01'}), (older:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-07-01'})
MERGE (newer)-[s:SUPERSEDES]->(older)
SET s.supersessionKind = 'SOURCE_CORRECTION', s.recordedAt = datetime('2025-08-20T00:00:00Z');

// status: run
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a2:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (l2:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-uses-cobas-c513-from-2025-06-01'})
SET x.id = 'lab-a-hba1c-uses-cobas-c513-from-2025-06-01', x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'ACCEPTED', x.polarity = 'POSITIVE',
    x.recordedAt = datetime('2025-08-20T00:00:00Z'), x.validFrom = datetime('2025-06-01T00:00:00Z'), x.validFromBasis = 'STATED_BY_SOURCE', x.validFromPrecision = 'DAY',
    x.contentHash = 'synthetic:' + x.uid, x.privacyClass = 'PUBLIC'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a2)
MERGE (x)-[:SUPPORTED_BY]->(l2)
MERGE (x)-[:ASSERTED_BY]->(lab)
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a2-episode-1'}]->(a2)
SET e.assertionUid = x.uid, e.validFrom = x.validFrom, e.validFromBasis = 'STATED_BY_SOURCE', e.validFromPrecision = 'DAY', e.validToBasis = 'UNKNOWN',
    e.recordedFrom = x.recordedAt;
