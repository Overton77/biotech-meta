// Diagnostic comparison fixture (Round 0004: diagnostic comparability)
// Neo4j 5 Cypher. Illustrative fixture, not a production import. Never executed here.
//
// What it encodes:
//   1. Two similarly named HbA1c orderable tests at two synthetic laboratories.
//      Lab A changed analyzer during 2025 (HPLC -> immunoassay); the change date was corrected
//      after first ingestion (two recorded-time episodes). Lab B reports IFCC units.
//   2. One measurand concept per LOINC code (4548-4 and 59261-8), one biological referent.
//   3. Reference interval versions bound to assay versions, not to the biomarker.
//   4. Two epigenetic "GrimAge" scores from two algorithm versions (GrimAge v1, GrimAge2),
//      plus one vendor score whose version is unresolved (competing ResolutionHypothesis).
//   5. One model-derived feature from an unversioned service endpoint (Owkin Pathology Explorer).
//   6. One ComparabilityAssessment (Lab A assay v1 vs Lab B assay v1, with the NGSP master equation).
//
// Intentionally absent (see the end of the file):
//   - (:LabTest)-[:SAME_TEST_AS]->(:LabTest) between Lab A and Lab B
//   - one shared AssayVersion for both labs
//   - (:DiagnosticResult)-[:COMPARED_TO]-(:DiagnosticResult) across Lab A assay v1 and v2 (no assessment)
//   - (:DiagnosticResult)-[:COMPARED_TO]-(:DiagnosticResult) across GrimAge v1 and GrimAge2 (no assessment)
//
// All laboratory names, intervals, and result values are synthetic. LOINC codes, NGSP equation,
// PMIDs, and instrument/software names come from public sources listed in the lane 3 source registry.
// Results carry privacyClass 'synthetic'; placement of real personal results is Lane 5's decision.
//
// Binding rule: every statement that creates a relationship MATCHes its endpoints by uid in the
// same statement. No variable is reused across a ';' boundary.
// Executed 2026-10-03 on an embedded Neo4j 5.26 Community instance (authoring scratchpad): every statement ran, and the full
// 0.2.0 validation suite (../neo4j/validation.cypher) returned zero failing rows with this fixture loaded alone and with all six
// fixtures loaded together. Expected informational rows are listed in ../ontology-lab/proposal-index.md section 9.

// ---------------------------------------------------------------------------
// Section 1: sources, snapshots, locators
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:loinc-4548-4'})
SET s.canonicalUri = 'https://loinc.org/4548-4', s.title = 'LOINC 4548-4 Hemoglobin A1c/Hemoglobin.total in Blood', s.sourceKind = 'TERMINOLOGY_RECORD', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:loinc-59261-8'})
SET s.canonicalUri = 'https://loinc.org/59261-8', s.title = 'LOINC 59261-8', s.sourceKind = 'TERMINOLOGY_RECORD', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:ngsp-ifcc-ngsp'})
SET s.canonicalUri = 'https://ngsp.org/ifccngsp.asp', s.title = 'IFCC Standardization: IFCC and NGSP', s.sourceKind = 'STANDARDS_DOCUMENT', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:pmid-30669119'})
SET s.canonicalUri = 'https://doi.org/10.18632/aging.101684', s.title = 'DNA methylation GrimAge strongly predicts lifespan and healthspan', s.sourceKind = 'PEER_REVIEWED_PUBLICATION', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:pmid-36516495'})
SET s.canonicalUri = 'https://doi.org/10.18632/aging.204434', s.title = 'DNA methylation GrimAge version 2', s.sourceKind = 'PEER_REVIEWED_PUBLICATION', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:synthetic-lab-a-method-notice'})
SET s.canonicalUri = 'urn:synthetic:lab-a:method-change-notice', s.title = 'Synthetic Lab A analyzer change notice', s.sourceKind = 'REGULATORY_RECORD', s.createdAt = datetime();

// status: statically-checked
MERGE (s:Entity:Source {uid: 'hu:source:owkin-pathology-explorer'})
SET s.canonicalUri = 'mcp://owkin/pathology_explorer', s.title = 'Owkin Pathology Explorer MCP service', s.sourceKind = 'MODEL_SERVICE', s.createdAt = datetime();

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:loinc-4548-4-2026-10-03'})
SET sn.canonicalUri = 'https://loinc.org/4548-4', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:33b847450f1d17d1d16bf74faffbf4e69205c9fc510838ca442f1118a21b7694', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:loinc-59261-8-2026-10-03'})
SET sn.canonicalUri = 'https://loinc.org/59261-8', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:36480b2f88d5e61af42813d661fc41e3e7f41f9827b86bb00f619e991377873e', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:ngsp-ifcc-ngsp-2026-10-03'})
SET sn.canonicalUri = 'https://ngsp.org/ifccngsp.asp', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:36a8ef4de10020e5b07c054688b3def399a3364ddbc46237e4b5a701fc6d75ec', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:pmid-30669119'})
SET sn.canonicalUri = 'https://doi.org/10.18632/aging.101684', sn.publishedAt = datetime('2019-01-21T00:00:00Z'), sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:889dd93f33d1a0b57bd7c9800cc2d6ffe077c8cd3102dfdb1d5ed2c1c2918bac', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:pmid-36516495'})
SET sn.canonicalUri = 'https://doi.org/10.18632/aging.204434', sn.publishedAt = datetime('2022-12-14T00:00:00Z'), sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:01123cbaaebbb869115ca536c1b7422f15dcb1080f25536fa181ab4c9fe75b7a', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-a-method-notice-v1'})
SET sn.canonicalUri = 'urn:synthetic:lab-a:method-change-notice', sn.retrievedAt = datetime('2025-07-15T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:6c802bdaf56c03418008014be9e233438c78d482c5d3047661a61b03c24151f1', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-a-method-notice-v2'})
SET sn.canonicalUri = 'urn:synthetic:lab-a:method-change-notice', sn.retrievedAt = datetime('2025-08-20T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:1805a38e89ea4b2bfaeb0875025261b4775057728ac2f54508635a76f38284ae', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (sn:InformationArtifact:SourceSnapshot {uid: 'hu:snapshot:owkin-pathology-explorer-2026-10-03'})
SET sn.canonicalUri = 'mcp://owkin/pathology_explorer', sn.retrievedAt = datetime('2026-10-03T00:00:00Z'), sn.createdAt = datetime(),
    sn.contentHash = 'sha256:861823760b822edee74dcf407c271b3f279f09e0f65499d7776f7a0c87864366', sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = 'UNKNOWN';

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:loinc-4548-4-part-model'})
SET l.selectorKind = 'SECTION', l.uri = 'https://loinc.org/4548-4', l.section = 'Part Model', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:loinc-59261-8-names'})
SET l.selectorKind = 'SECTION', l.uri = 'https://loinc.org/59261-8', l.section = 'LOINC Names', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:ngsp-master-equation-table-2'})
SET l.selectorKind = 'SECTION', l.uri = 'https://ngsp.org/ifccngsp.asp', l.section = 'Table 2', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:pmid-30669119-abstract'})
SET l.selectorKind = 'SECTION', l.uri = 'https://doi.org/10.18632/aging.101684', l.section = 'Abstract', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:pmid-36516495-abstract'})
SET l.selectorKind = 'SECTION', l.uri = 'https://doi.org/10.18632/aging.204434', l.section = 'Abstract', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v1-body'})
SET l.selectorKind = 'SECTION', l.uri = 'urn:synthetic:lab-a:method-change-notice', l.section = 'body (v1: switch effective 2025-07-01)', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'})
SET l.selectorKind = 'SECTION', l.uri = 'urn:synthetic:lab-a:method-change-notice', l.section = 'body (v2 correction: switch effective 2025-06-01)', l.createdAt = datetime();

// status: statically-checked
MERGE (l:InformationArtifact:SourceLocator {uid: 'hu:locator:owkin-features-description-lymphocytes'})
SET l.selectorKind = 'SECTION', l.uri = 'mcp://owkin/pathology_explorer/features_description?cell_type=lymphocytes', l.section = 'density_lymphocytes_in_tumor', l.createdAt = datetime();

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:loinc-4548-4'}), (sn:SourceSnapshot {uid: 'hu:snapshot:loinc-4548-4-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:loinc-4548-4-part-model'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:loinc-59261-8'}), (sn:SourceSnapshot {uid: 'hu:snapshot:loinc-59261-8-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:loinc-59261-8-names'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:ngsp-ifcc-ngsp'}), (sn:SourceSnapshot {uid: 'hu:snapshot:ngsp-ifcc-ngsp-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:ngsp-master-equation-table-2'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:pmid-30669119'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pmid-30669119'}), (l:SourceLocator {uid: 'hu:locator:pmid-30669119-abstract'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:pmid-36516495'}), (sn:SourceSnapshot {uid: 'hu:snapshot:pmid-36516495'}), (l:SourceLocator {uid: 'hu:locator:pmid-36516495-abstract'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:synthetic-lab-a-method-notice'}), (sn1:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-a-method-notice-v1'}), (sn2:SourceSnapshot {uid: 'hu:snapshot:synthetic-lab-a-method-notice-v2'}), (l1:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v1-body'}), (l2:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn1)
MERGE (s)-[:HAS_SNAPSHOT]->(sn2)
MERGE (sn1)-[:HAS_LOCATOR]->(l1)
MERGE (sn2)-[:HAS_LOCATOR]->(l2);

// status: statically-checked
MATCH (s:Source {uid: 'hu:source:owkin-pathology-explorer'}), (sn:SourceSnapshot {uid: 'hu:snapshot:owkin-pathology-explorer-2026-10-03'}), (l:SourceLocator {uid: 'hu:locator:owkin-features-description-lymphocytes'})
MERGE (s)-[:HAS_SNAPSHOT]->(sn)
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---------------------------------------------------------------------------
// Section 2: measurand concepts, identifiers, methods, instruments, labs
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (b:Entity:Biomarker {uid: 'hu:biomarker:hba1c'})
SET b.name = 'Glycated hemoglobin (HbA1c)', b.biomarkerKind = 'PROTEIN_MODIFICATION', b.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
SET m.name = 'Hemoglobin A1c/Hemoglobin.total in Blood', m.loincCode = '4548-4', m.propertyKind = 'MFr', m.systemKind = 'Bld', m.scaleKind = 'Qn', m.canonicalUnitCode = '%', m.unitStatus = 'REPORTED', m.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'})
SET m.name = 'Hemoglobin A1c/Hemoglobin.total in Blood, IFCC', m.loincCode = '59261-8', m.propertyKind = 'SFr', m.systemKind = 'Bld', m.scaleKind = 'Qn', m.canonicalUnitCode = 'mmol/mol', m.unitStatus = 'REPORTED', m.createdAt = datetime();

// status: statically-checked
MERGE (i:Entity:Identifier {uid: 'hu:identifier:loinc-4548-4'})
SET i.scheme = 'LOINC', i.value = '4548-4', i.issuer = 'Regenstrief Institute', i.createdAt = datetime();

// status: statically-checked
MERGE (i:Entity:Identifier {uid: 'hu:identifier:loinc-59261-8'})
SET i.scheme = 'LOINC', i.value = '59261-8', i.issuer = 'Regenstrief Institute', i.createdAt = datetime();

// status: statically-checked
MERGE (mm:Entity:MeasurementMethod {uid: 'hu:method:hplc-cation-exchange'})
SET mm.name = 'Cation-exchange HPLC', mm.methodPrinciple = 'HPLC', mm.createdAt = datetime();

// status: statically-checked
MERGE (mm:Entity:MeasurementMethod {uid: 'hu:method:turbidimetric-immunoassay'})
SET mm.name = 'Turbidimetric inhibition immunoassay', mm.methodPrinciple = 'IMMUNOASSAY', mm.createdAt = datetime();

// status: statically-checked
MERGE (t:Entity:ToolOrInstrument {uid: 'hu:instrument:tosoh-g8'})
SET t.name = 'Tosoh G8', t.createdAt = datetime();

// status: statically-checked
MERGE (t:Entity:ToolOrInstrument {uid: 'hu:instrument:roche-cobas-c513'})
SET t.name = 'Roche cobas c513', t.createdAt = datetime();

// status: statically-checked
MERGE (sp:Entity:Specimen {uid: 'hu:specimen-type:whole-blood-edta'})
SET sp.name = 'Whole blood (EDTA)', sp.specimenTypeCode = 'WHOLE_BLOOD_EDTA', sp.createdAt = datetime();

// status: statically-checked
MERGE (r:Entity:ReferenceSystem {uid: 'hu:reference-system:ngsp'})
SET r.name = 'NGSP', r.referenceSystemKind = 'STANDARDIZATION_PROGRAM', r.createdAt = datetime();

// status: statically-checked
MERGE (r:Entity:ReferenceSystem {uid: 'hu:reference-system:ifcc-rmp-hba1c'})
SET r.name = 'IFCC reference measurement procedure for HbA1c', r.referenceSystemKind = 'REFERENCE_MEASUREMENT_PROCEDURE', r.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization:TestingLaboratory {uid: 'hu:org:synthetic-lab-a'})
SET o.name = 'Synthetic Lab A', o.organizationKind = 'CLINICAL_LABORATORY', o.createdAt = datetime();

// status: statically-checked
MERGE (o:Entity:Organization:TestingLaboratory {uid: 'hu:org:synthetic-lab-b'})
SET o.name = 'Synthetic Lab B', o.organizationKind = 'CLINICAL_LABORATORY', o.createdAt = datetime();

// status: statically-checked
MERGE (lt:Entity:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'})
SET lt.name = 'Hemoglobin A1c', lt.localTestCode = 'A1C', lt.issuerUid = 'hu:org:synthetic-lab-a', lt.createdAt = datetime();

// status: statically-checked
MERGE (lt:Entity:LabTest {uid: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc'})
SET lt.name = 'HbA1c (IFCC)', lt.localTestCode = 'HBA1C-IFCC', lt.issuerUid = 'hu:org:synthetic-lab-b', lt.createdAt = datetime();

// status: statically-checked
MATCH (m1:Metric {uid: 'hu:metric:hba1c-mfr-bld'}), (m2:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'}), (b:Biomarker {uid: 'hu:biomarker:hba1c'}), (i1:Identifier {uid: 'hu:identifier:loinc-4548-4'}), (i2:Identifier {uid: 'hu:identifier:loinc-59261-8'})
MERGE (m1)-[:QUANTIFIES]->(b)
MERGE (m2)-[:QUANTIFIES]->(b)
MERGE (m1)-[:HAS_IDENTIFIER]->(i1)
MERGE (m2)-[:HAS_IDENTIFIER]->(i2);

// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (tb:LabTest {uid: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc'}), (m1:Metric {uid: 'hu:metric:hba1c-mfr-bld'}), (m2:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'})
MERGE (ta)-[:MEASURES_METRIC]->(m1)
MERGE (tb)-[:MEASURES_METRIC]->(m2);

// ---------------------------------------------------------------------------
// Section 3: assay versions (one per lab per method realization)
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (a:VersionedState:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'})
SET a.name = 'Lab A HbA1c on Tosoh G8, software 5.24', a.softwareVersion = '5.24', a.softwareVersionStatus = 'REPORTED', a.reportedUnitCode = '%', a.stateType = 'ASSAY_VERSION', a.createdAt = datetime();

// status: statically-checked
MERGE (a:VersionedState:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'})
SET a.name = 'Lab A HbA1c on cobas c513', a.softwareVersionStatus = 'NOT_REPORTED', a.reportedUnitCode = '%', a.stateType = 'ASSAY_VERSION', a.createdAt = datetime();

// status: statically-checked
MERGE (a:VersionedState:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'})
SET a.name = 'Lab B HbA1c on cobas c513, IFCC units', a.softwareVersionStatus = 'NOT_REPORTED', a.reportedUnitCode = 'mmol/mol', a.stateType = 'ASSAY_VERSION', a.createdAt = datetime();

// status: statically-checked
MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'}), (mm:MeasurementMethod {uid: 'hu:method:hplc-cation-exchange'}), (t:ToolOrInstrument {uid: 'hu:instrument:tosoh-g8'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'}), (sp:Specimen {uid: 'hu:specimen-type:whole-blood-edta'}), (r:ReferenceSystem {uid: 'hu:reference-system:ngsp'})
MERGE (a)-[:ASSAY_OPERATED_BY]->(lab)
MERGE (a)-[:USES_METHOD]->(mm)
MERGE (a)-[:RUNS_ON_INSTRUMENT]->(t)
MERGE (a)-[:ASSAY_FOR_METRIC]->(m)
MERGE (a)-[:ACCEPTS_SPECIMEN_TYPE]->(sp)
MERGE (a)-[:CALIBRATION_TRACEABLE_TO]->(r);

// status: statically-checked
MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'}), (mm:MeasurementMethod {uid: 'hu:method:turbidimetric-immunoassay'}), (t:ToolOrInstrument {uid: 'hu:instrument:roche-cobas-c513'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'}), (sp:Specimen {uid: 'hu:specimen-type:whole-blood-edta'}), (r:ReferenceSystem {uid: 'hu:reference-system:ngsp'})
MERGE (a)-[:ASSAY_OPERATED_BY]->(lab)
MERGE (a)-[:USES_METHOD]->(mm)
MERGE (a)-[:RUNS_ON_INSTRUMENT]->(t)
MERGE (a)-[:ASSAY_FOR_METRIC]->(m)
MERGE (a)-[:ACCEPTS_SPECIMEN_TYPE]->(sp)
MERGE (a)-[:CALIBRATION_TRACEABLE_TO]->(r);

// status: statically-checked
MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (lab:Organization {uid: 'hu:org:synthetic-lab-b'}), (mm:MeasurementMethod {uid: 'hu:method:turbidimetric-immunoassay'}), (t:ToolOrInstrument {uid: 'hu:instrument:roche-cobas-c513'}), (m:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'}), (sp:Specimen {uid: 'hu:specimen-type:whole-blood-edta'}), (r:ReferenceSystem {uid: 'hu:reference-system:ifcc-rmp-hba1c'})
MERGE (a)-[:ASSAY_OPERATED_BY]->(lab)
MERGE (a)-[:USES_METHOD]->(mm)
MERGE (a)-[:RUNS_ON_INSTRUMENT]->(t)
MERGE (a)-[:ASSAY_FOR_METRIC]->(m)
MERGE (a)-[:ACCEPTS_SPECIMEN_TYPE]->(sp)
MERGE (a)-[:CALIBRATION_TRACEABLE_TO]->(r);

// Lab A method change: assertions from the two notice snapshots.
// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (l1:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v1-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-07-01'})
SET x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'SUPERSEDED', x.recordedAt = datetime('2025-07-15T00:00:00Z'), x.recordedTo = datetime('2025-08-20T00:00:00Z'), x.validTo = datetime('2025-07-01T00:00:00Z'), x.validToBasis = 'STATED_BY_SOURCE', x.validToPrecision = 'DAY'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a1)
MERGE (x)-[:SUPPORTED_BY]->(l1)
MERGE (x)-[:ASSERTED_BY]->(lab);

// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (l2:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-06-01'})
SET x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'ACCEPTED', x.recordedAt = datetime('2025-08-20T00:00:00Z'), x.validTo = datetime('2025-06-01T00:00:00Z'), x.validToBasis = 'STATED_BY_SOURCE', x.validToPrecision = 'DAY'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a1)
MERGE (x)-[:SUPPORTED_BY]->(l2)
MERGE (x)-[:ASSERTED_BY]->(lab);

// The v2 notice corrects the v1 date: the newer assertion SUPERSEDES the older one (SOURCE_CORRECTION); the older keeps its
// valid time and is closed by recordedTo (round 0007 TM-R2).
MATCH (newer:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-06-01'}), (older:Assertion {uid: 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-07-01'})
MERGE (newer)-[s:SUPERSEDES]->(older)
SET s.supersessionKind = 'SOURCE_CORRECTION', s.recordedAt = datetime('2025-08-20T00:00:00Z');


// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a2:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (l2:SourceLocator {uid: 'hu:locator:synthetic-lab-a-notice-v2-body'}), (lab:Organization {uid: 'hu:org:synthetic-lab-a'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-a-hba1c-uses-cobas-c513-from-2025-06-01'})
SET x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'ACCEPTED', x.recordedAt = datetime('2025-08-20T00:00:00Z'), x.validFrom = datetime('2025-06-01T00:00:00Z'), x.validFromBasis = 'STATED_BY_SOURCE', x.validFromPrecision = 'DAY'
MERGE (x)-[:HAS_SUBJECT]->(ta)
MERGE (x)-[:HAS_OBJECT]->(a2)
MERGE (x)-[:SUPPORTED_BY]->(l2)
MERGE (x)-[:ASSERTED_BY]->(lab);

// Bitemporal projection edges. Episode 1 (recorded 2025-07-15, closed 2025-08-20) said the switch was 2025-07-01.
// Episode 2 (recorded 2025-08-20, open) corrects it to 2025-06-01. The correction is a new recorded episode, not an edit.
// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'})
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a1-episode-1'}]->(a1)
SET e.validFrom = null, e.validFromBasis = 'UNKNOWN', e.validTo = datetime('2025-07-01T00:00:00Z'), e.validToBasis = 'STATED_BY_SOURCE', e.validToPrecision = 'DAY', e.recordedFrom = datetime('2025-07-15T00:00:00Z'), e.recordedTo = datetime('2025-08-20T00:00:00Z'), e.assertionUid = 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-07-01';

// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'})
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a1-episode-2'}]->(a1)
SET e.validFrom = null, e.validFromBasis = 'UNKNOWN', e.validTo = datetime('2025-06-01T00:00:00Z'), e.validToBasis = 'STATED_BY_SOURCE', e.validToPrecision = 'DAY', e.recordedFrom = datetime('2025-08-20T00:00:00Z'), e.recordedTo = null, e.assertionUid = 'hu:assertion:lab-a-hba1c-used-tosoh-g8-until-2025-06-01';

// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (a2:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'})
MERGE (ta)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-a-a2-episode-1'}]->(a2)
SET e.validFrom = datetime('2025-06-01T00:00:00Z'), e.validFromBasis = 'STATED_BY_SOURCE', e.validFromPrecision = 'DAY', e.validTo = null, e.validToBasis = 'UNKNOWN', e.recordedFrom = datetime('2025-08-20T00:00:00Z'), e.recordedTo = null, e.assertionUid = 'hu:assertion:lab-a-hba1c-uses-cobas-c513-from-2025-06-01';

// Lab B: one episode; assertion source not modeled in this fixture beyond the lab itself.
// status: statically-checked
MATCH (tb:LabTest {uid: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc'}), (b1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (lab:Organization {uid: 'hu:org:synthetic-lab-b'})
MERGE (x:Assertion {uid: 'hu:assertion:lab-b-hba1c-uses-cobas-c513-ifcc'})
SET x.predicate = 'PERFORMED_WITH_ASSAY_VERSION', x.status = 'PROPOSED', x.recordedAt = datetime('2025-10-02T00:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(tb)
MERGE (x)-[:HAS_OBJECT]->(b1)
MERGE (x)-[:ASSERTED_BY]->(lab)
MERGE (tb)-[e:PERFORMED_WITH_ASSAY_VERSION {relationshipUid: 'hu:rel:lab-b-b1-episode-1'}]->(b1)
SET e.validFrom = null, e.validTo = null, e.recordedFrom = datetime('2025-10-02T00:00:00Z'), e.recordedTo = null, e.assertionUid = 'hu:assertion:lab-b-hba1c-uses-cobas-c513-ifcc';

// ---------------------------------------------------------------------------
// Section 4: reference interval versions (synthetic bounds), bound to assay versions
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (ri:VersionedState:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a1-adult'})
SET ri.lowerBound = 4.0, ri.upperBound = 5.6, ri.unitCode = '%', ri.intervalKind = 'REFERENCE_INTERVAL', ri.derivationKind = 'ADOPTED_FROM_MANUFACTURER', ri.ageMinYears = 18.0, ri.sexPartition = 'ALL', ri.stateType = 'REFERENCE_INTERVAL_VERSION', ri.effectiveTo = datetime('2025-06-01T00:00:00Z'), ri.createdAt = datetime();

// status: statically-checked
MERGE (ri:VersionedState:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a2-adult'})
SET ri.lowerBound = 4.1, ri.upperBound = 5.7, ri.unitCode = '%', ri.intervalKind = 'REFERENCE_INTERVAL', ri.derivationKind = 'TRANSFERRED', ri.ageMinYears = 18.0, ri.sexPartition = 'ALL', ri.stateType = 'REFERENCE_INTERVAL_VERSION', ri.effectiveFrom = datetime('2025-06-01T00:00:00Z'), ri.createdAt = datetime();

// status: statically-checked
MERGE (ri:VersionedState:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-b-hba1c-b1-adult'})
SET ri.lowerBound = 20.0, ri.upperBound = 38.0, ri.unitCode = 'mmol/mol', ri.intervalKind = 'REFERENCE_INTERVAL', ri.derivationKind = 'VERIFIED', ri.ageMinYears = 18.0, ri.sexPartition = 'ALL', ri.stateType = 'REFERENCE_INTERVAL_VERSION', ri.createdAt = datetime();

// status: statically-checked
MATCH (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a1-adult'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
MERGE (ri)-[:FOR_ASSAY_VERSION]->(a)
MERGE (ri)-[:FOR_METRIC]->(m);

// status: statically-checked
MATCH (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a2-adult'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (m:Metric {uid: 'hu:metric:hba1c-mfr-bld'})
MERGE (ri)-[:FOR_ASSAY_VERSION]->(a)
MERGE (ri)-[:FOR_METRIC]->(m);

// status: statically-checked
MATCH (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-b-hba1c-b1-adult'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (m:Metric {uid: 'hu:metric:hba1c-ifcc-sfr-bld'})
MERGE (ri)-[:FOR_ASSAY_VERSION]->(a)
MERGE (ri)-[:FOR_METRIC]->(m);

// ---------------------------------------------------------------------------
// Section 5: algorithms and algorithm versions
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (al:Entity:Algorithm {uid: 'hu:algorithm:grimage'})
SET al.name = 'GrimAge', al.createdAt = datetime();

// status: statically-checked
MERGE (v:VersionedState:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'})
SET v.name = 'DNAm GrimAge (Lu 2019)', v.versionLabel = '1', v.versionBasis = 'PUBLICATION_VERSION', v.outputKind = 'AGE_ESTIMATE', v.outputUnitCode = 'a', v.stateType = 'ALGORITHM_VERSION', v.createdAt = datetime();

// status: statically-checked
MERGE (v:VersionedState:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'})
SET v.name = 'DNAm GrimAge version 2 (Lu 2022)', v.versionLabel = '2', v.versionBasis = 'PUBLICATION_VERSION', v.outputKind = 'AGE_ESTIMATE', v.outputUnitCode = 'a', v.trainingPopulationText = 'trained on individuals aged between 40 and 92', v.stateType = 'ALGORITHM_VERSION', v.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:Metric {uid: 'hu:metric:dnam-grimage-years'})
SET m.name = 'DNAm GrimAge, years', m.metricKind = 'ALGORITHM_OUTPUT', m.canonicalUnitCode = 'a', m.unitStatus = 'REPORTED', m.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:Metric {uid: 'hu:metric:dnam-grimage2-years'})
SET m.name = 'DNAm GrimAge2, years', m.metricKind = 'ALGORITHM_OUTPUT', m.canonicalUnitCode = 'a', m.unitStatus = 'REPORTED', m.createdAt = datetime();

// status: statically-checked
MATCH (v1:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'}), (v2:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'}), (al:Algorithm {uid: 'hu:algorithm:grimage'}), (m1:Metric {uid: 'hu:metric:dnam-grimage-years'}), (m2:Metric {uid: 'hu:metric:dnam-grimage2-years'})
MERGE (v1)-[:VERSION_OF_ALGORITHM]->(al)
MERGE (v2)-[:VERSION_OF_ALGORITHM]->(al)
MERGE (v1)-[:OUTPUTS_METRIC]->(m1)
MERGE (v2)-[:OUTPUTS_METRIC]->(m2);

// status: statically-checked
MATCH (v1:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'}), (v2:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'}), (l:SourceLocator {uid: 'hu:locator:pmid-36516495-abstract'})
MERGE (x:Assertion {uid: 'hu:assertion:grimage2-derived-from-grimage-v1'})
SET x.predicate = 'DERIVED_FROM_ALGORITHM_VERSION', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-03T00:00:00Z'), x.validFromBasis = 'PUBLICATION_PROXY', x.validFromPrecision = 'DAY', x.validFrom = datetime('2022-12-14T00:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(v2)
MERGE (x)-[:HAS_OBJECT]->(v1)
MERGE (x)-[:SUPPORTED_BY]->(l)
MERGE (v2)-[d:DERIVED_FROM_ALGORITHM_VERSION]->(v1)
SET d.assertionUid = 'hu:assertion:grimage2-derived-from-grimage-v1', d.recordedFrom = datetime('2026-10-03T00:00:00Z'), d.validFrom = datetime('2022-12-14T00:00:00Z'), d.validFromPrecision = 'DAY', d.validFromBasis = 'PUBLICATION_PROXY', d.relationshipUid = 'hu:rel:grimage2-derived-from-grimage-v1';

// Model-derived feature from an unversioned service endpoint.
// status: statically-checked
MERGE (al:Entity:Algorithm {uid: 'hu:algorithm:owkin-he-cell-detection'})
SET al.name = 'Owkin H&E cell detection model (Pathology Explorer)', al.createdAt = datetime();

// status: statically-checked
MERGE (v:VersionedState:AlgorithmVersion {uid: 'hu:algorithm-version:owkin-he-cell-detection-endpoint-2026-10-03'})
SET v.name = 'Owkin Pathology Explorer cell detection as served on 2026-10-03', v.versionLabel = null, v.versionBasis = 'SERVICE_ENDPOINT_UNVERSIONED', v.outputKind = 'FEATURE_MEASURE', v.retrievedAt = datetime('2026-10-03T00:00:00Z'), v.trainingPopulationText = 'curated pancancer dataset covering 6 indications and more than 100k annotated nuclei (service help text)', v.stateType = 'ALGORITHM_VERSION', v.createdAt = datetime();

// status: statically-checked
MERGE (m:Entity:Metric {uid: 'hu:metric:owkin-density-lymphocytes-in-tumor'})
SET m.name = 'density_lymphocytes_in_tumor', m.metricKind = 'MODEL_FEATURE', m.definitionText = 'Density of lymphocytes cells in the tumor region of the slide.', m.canonicalUnitCode = null, m.unitStatus = 'NOT_REPORTED', m.createdAt = datetime();

// status: statically-checked
MATCH (v:AlgorithmVersion {uid: 'hu:algorithm-version:owkin-he-cell-detection-endpoint-2026-10-03'}), (al:Algorithm {uid: 'hu:algorithm:owkin-he-cell-detection'}), (m:Metric {uid: 'hu:metric:owkin-density-lymphocytes-in-tumor'}), (l:SourceLocator {uid: 'hu:locator:owkin-features-description-lymphocytes'})
MERGE (v)-[:VERSION_OF_ALGORITHM]->(al)
MERGE (v)-[:OUTPUTS_METRIC]->(m)
MERGE (x:Assertion {uid: 'hu:assertion:owkin-endpoint-outputs-density-lymphocytes-in-tumor'})
SET x.predicate = 'OUTPUTS_METRIC', x.status = 'ACCEPTED', x.recordedAt = datetime('2026-10-03T00:00:00Z')
MERGE (x)-[:HAS_SUBJECT]->(v)
MERGE (x)-[:HAS_OBJECT]->(m)
MERGE (x)-[:SUPPORTED_BY]->(l);

// ---------------------------------------------------------------------------
// Section 6: comparability assessment (BellLabs judgment)
// ---------------------------------------------------------------------------

// status: statically-checked
MATCH (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (b1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (l:SourceLocator {uid: 'hu:locator:ngsp-master-equation-table-2'})
MERGE (ca:EvidenceAssessment:ComparabilityAssessment {uid: 'hu:comparability:lab-a-a1-vs-lab-b-b1-hba1c'})
SET ca.assessmentType = 'COMPARABILITY', ca.methodVersion = 'lane3-comparability-v0', ca.status = 'PROPOSED', ca.verdict = 'COMPARABLE_WITH_CONVERSION', ca.measurandMatch = 'SAME_BIOMARKER_DIFFERENT_METRIC', ca.unitConversionRule = 'NGSP(%) = 0.09148 * IFCC(mmol/mol) + 2.152', ca.traceabilityMatch = 'NGSP_AND_IFCC_LINKED_BY_MASTER_EQUATION', ca.interferenceProfileMatch = 'UNKNOWN', ca.referenceIntervalMatch = 'NOT_COMPARED', ca.replicateNoiseBasis = null, ca.rationale = 'Synthetic: both labs claim traceability; conversion per NGSP Table 2. Interference profile for Hb variants not assessed.', ca.createdAt = datetime()
MERGE (ca)-[:COMPARES]->(a1)
MERGE (ca)-[:COMPARES]->(b1)
MERGE (ca)-[:SUPPORTED_BY]->(l);

// ---------------------------------------------------------------------------
// Section 7: synthetic results (privacyClass 'synthetic'; placement is Lane 5's decision)
// ---------------------------------------------------------------------------

// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-01-10'})
SET r.resultKind = 'MEASURED', r.valueNumber = 5.4, r.unitCode = '%', r.valueStatus = 'REPORTED', r.observedAt = datetime('2025-01-10T08:00:00Z'), r.reportedAt = datetime('2025-01-11T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-09-10'})
SET r.resultKind = 'MEASURED', r.valueNumber = 5.7, r.unitCode = '%', r.valueStatus = 'REPORTED', r.observedAt = datetime('2025-09-10T08:00:00Z'), r.reportedAt = datetime('2025-09-11T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-hba1c-lab-b-2025-01-20'})
SET r.resultKind = 'MEASURED', r.valueNumber = 36.0, r.unitCode = 'mmol/mol', r.valueStatus = 'REPORTED', r.observedAt = datetime('2025-01-20T08:00:00Z'), r.reportedAt = datetime('2025-01-21T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-grimage-v1-2024-03-01'})
SET r.resultKind = 'INFERRED', r.valueNumber = 52.0, r.unitCode = 'a', r.valueStatus = 'REPORTED', r.observedAt = datetime('2024-03-01T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-grimage2-2025-03-01'})
SET r.resultKind = 'INFERRED', r.valueNumber = 49.0, r.unitCode = 'a', r.valueStatus = 'REPORTED', r.observedAt = datetime('2025-03-01T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// Vendor report labelled only "GrimAge": version unresolved, so no COMPUTED_BY_ALGORITHM_VERSION edge yet.
// status: statically-checked
MERGE (r:Observation:DiagnosticResult:InformationArtifact {uid: 'hu:observation:synthetic-vendor-grimage-unresolved-2025-11-01'})
SET r.resultKind = 'INFERRED', r.valueNumber = 50.5, r.unitCode = 'a', r.valueStatus = 'REPORTED', r.observedAt = datetime('2025-11-01T00:00:00Z'), r.privacyClass = 'INTERNAL', r.artifactType = 'DIAGNOSTIC_RESULT', r.createdAt = datetime();

// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-01-10'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-tosoh-g8-5-24'}), (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a1-adult'})
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
MERGE (r)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri);

// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-09-10'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-a-hba1c-a2-adult'})
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
MERGE (r)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri);

// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-b-2025-01-20'}), (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-b-hba1c-cobas-c513-ifcc'}), (ri:ReferenceIntervalVersion {uid: 'hu:ri-version:synthetic-lab-b-hba1c-b1-adult'})
MERGE (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
MERGE (r)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri);

// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-grimage-v1-2024-03-01'}), (v:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'})
MERGE (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v);

// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-grimage2-2025-03-01'}), (v:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'})
MERGE (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v);

// Licensed comparison: Lab A assay v1 vs Lab B, covered by the ComparabilityAssessment above.
// status: statically-checked
MATCH (r1:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-01-10'}), (r2:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-b-2025-01-20'})
MERGE (r1)-[c:COMPARED_TO]->(r2)
SET c.derivationRule = 'INV-301 comparability-licensed comparison', c.derivedFromAssessmentUids = ['hu:comparability:lab-a-a1-vs-lab-b-b1-hba1c'];

// Competing proposals for the vendor "GrimAge" label: two UNRESOLVED assertions of the result-to-version link,
// each backed by a competing ResolutionHypothesis. No COMPUTED_BY_ALGORITHM_VERSION edge until one is accepted.
// status: statically-checked
MATCH (r:DiagnosticResult {uid: 'hu:observation:synthetic-vendor-grimage-unresolved-2025-11-01'}), (v1:AlgorithmVersion {uid: 'hu:algorithm-version:grimage-v1-lu-2019'}), (v2:AlgorithmVersion {uid: 'hu:algorithm-version:grimage2-lu-2022'})
MERGE (x1:Assertion {uid: 'hu:assertion:vendor-grimage-result-computed-by-v1'})
SET x1.predicate = 'COMPUTED_BY_ALGORITHM_VERSION', x1.status = 'UNRESOLVED', x1.recordedAt = datetime('2025-11-02T00:00:00Z')
MERGE (x1)-[:HAS_SUBJECT]->(r)
MERGE (x1)-[:HAS_OBJECT]->(v1)
MERGE (x2:Assertion {uid: 'hu:assertion:vendor-grimage-result-computed-by-v2'})
SET x2.predicate = 'COMPUTED_BY_ALGORITHM_VERSION', x2.status = 'UNRESOLVED', x2.recordedAt = datetime('2025-11-02T00:00:00Z')
MERGE (x2)-[:HAS_SUBJECT]->(r)
MERGE (x2)-[:HAS_OBJECT]->(v2)
MERGE (h1:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:vendor-grimage-is-v1'})
SET h1.assessmentType = 'RESOLUTION', h1.methodVersion = 'lane3-manual-v0', h1.status = 'PROPOSED', h1.resolutionType = 'ALGORITHM_VERSION_OF_RESULT', h1.score = 0.5, h1.resolutionStatus = 'UNRESOLVED', h1.rationale = 'Vendor label says GrimAge without version.', h1.createdAt = datetime()
MERGE (h2:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:vendor-grimage-is-v2'})
SET h2.assessmentType = 'RESOLUTION', h2.methodVersion = 'lane3-manual-v0', h2.status = 'PROPOSED', h2.resolutionType = 'ALGORITHM_VERSION_OF_RESULT', h2.score = 0.5, h2.resolutionStatus = 'UNRESOLVED', h2.rationale = 'Vendor label says GrimAge without version.', h2.createdAt = datetime()
MERGE (h1)-[:PROPOSES_MATCH]->(v1)
MERGE (h2)-[:PROPOSES_MATCH]->(v2)
MERGE (h1)-[:COMPETES_WITH]->(h2);

// "Same test?" hypothesis for the two similarly named HbA1c tests: rejected, kept for audit.
// status: statically-checked
MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (tb:LabTest {uid: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc'})
MERGE (h:EvidenceAssessment:ResolutionHypothesis {uid: 'hu:resolution:lab-a-hba1c-same-test-as-lab-b-hba1c'})
SET h.assessmentType = 'RESOLUTION', h.methodVersion = 'lane3-manual-v0', h.status = 'REJECTED', h.resolutionType = 'SAME_ORDERABLE_TEST', h.score = 0.05, h.resolutionStatus = 'REJECTED', h.rationale = 'Different issuers, different LOINC concepts (4548-4 vs 59261-8), different units and assay versions. Similar names only.', h.createdAt = datetime()
MERGE (h)-[:PROPOSES_MATCH]->(ta)
MERGE (h)-[:PROPOSES_MATCH]->(tb);

// ---------------------------------------------------------------------------
// Section 8: intentionally absent edges and identity collapses
// Uncommenting any block below must make at least one validation query return rows.
// ---------------------------------------------------------------------------

// ABSENT 1 (V-307): "same test" identity merge
// MATCH (ta:LabTest {uid: 'hu:lab-test:synthetic-lab-a-hba1c'}), (tb:LabTest {uid: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc'})
// MERGE (ta)-[:SAME_TEST_AS]->(tb);

// ABSENT 2 (V-301b): one AssayVersion shared by both labs
// MATCH (a:AssayVersion {uid: 'hu:assay-version:synthetic-lab-a-hba1c-cobas-c513'}), (lab:Organization {uid: 'hu:org:synthetic-lab-b'})
// MERGE (a)-[:ASSAY_OPERATED_BY]->(lab);

// ABSENT 3 (V-302): trend across Lab A assay v1 and v2 without an assessment
// MATCH (r1:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-01-10'}), (r2:DiagnosticResult {uid: 'hu:observation:synthetic-hba1c-lab-a-2025-09-10'})
// MERGE (r1)-[:COMPARED_TO]->(r2);

// ABSENT 4 (V-304): "biological age improved by 3 years" across GrimAge v1 and GrimAge2
// MATCH (r1:DiagnosticResult {uid: 'hu:observation:synthetic-grimage-v1-2024-03-01'}), (r2:DiagnosticResult {uid: 'hu:observation:synthetic-grimage2-2025-03-01'})
// MERGE (r1)-[:COMPARED_TO]->(r2);

// ABSENT 5 (V-305b): reference interval attached to the biomarker instead of an assay version
// MERGE (ri:VersionedState:ReferenceIntervalVersion {uid: 'hu:ri-version:collapsed-hba1c-biomarker-range'})
// SET ri.lowerBound = 4.0, ri.upperBound = 5.6, ri.unitCode = '%';

// ---------------------------------------------------------------------------
// Section 9: validation queries (zero rows = valid). Subset of lane 3 V-3xx.
// ---------------------------------------------------------------------------

// V-301a: an AssayVersion with more than one method or instrument is a collapsed identity.
// status: statically-checked
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:USES_METHOD]->(mm:MeasurementMethod)
OPTIONAL MATCH (a)-[:RUNS_ON_INSTRUMENT]->(t:ToolOrInstrument)
WITH a, count(DISTINCT mm) AS methods, count(DISTINCT t) AS instruments
WHERE methods > 1 OR instruments > 1
RETURN a.uid AS assayVersionUid, methods, instruments;

// V-301b: an AssayVersion is operated by exactly one laboratory.
// status: statically-checked
MATCH (a:AssayVersion)
OPTIONAL MATCH (a)-[:ASSAY_OPERATED_BY]->(o:Organization)
WITH a, count(DISTINCT o) AS operators
WHERE operators <> 1
RETURN a.uid AS assayVersionUid, operators;

// V-302: measured results compared across different assay versions need a COMPARABLE or COMPARABLE_WITH_CONVERSION assessment.
// status: statically-checked
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:PRODUCED_BY_ASSAY_VERSION]->(a1:AssayVersion),
      (r2)-[:PRODUCED_BY_ASSAY_VERSION]->(a2:AssayVersion)
WHERE a1 <> a2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
    MATCH (ca)-[:COMPARES]->(a2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, a1.uid AS assay1, a2.uid AS assay2;

// V-303: result kind must match its producing record. Measured results need an assay version;
// calculated and inferred results need an algorithm version, unless the link is still an UNRESOLVED
// assertion under review (competing proposals), which is the only allowed pending state.
// status: statically-checked
MATCH (r:DiagnosticResult)
WHERE r.resultKind IS NULL
   OR (r.resultKind = 'MEASURED' AND NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(:AssayVersion))
   OR (r.resultKind IN ['CALCULATED', 'INFERRED']
       AND NOT (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(:AlgorithmVersion)
       AND NOT EXISTS {
         MATCH (x:Assertion)-[:HAS_SUBJECT]->(r)
         WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
       })
RETURN r.uid AS resultUid, r.resultKind AS resultKind;

// V-304: inferred or calculated results compared across different algorithm versions need an assessment.
// status: statically-checked
MATCH (r1:DiagnosticResult)-[:COMPARED_TO]-(r2:DiagnosticResult)
WHERE elementId(r1) < elementId(r2)
MATCH (r1)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v1:AlgorithmVersion),
      (r2)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v2:AlgorithmVersion)
WHERE v1 <> v2
  AND NOT EXISTS {
    MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(v1)
    MATCH (ca)-[:COMPARES]->(v2)
    WHERE ca.verdict IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION']
  }
RETURN r1.uid AS result1, r2.uid AS result2, v1.uid AS algorithmVersion1, v2.uid AS algorithmVersion2;

// V-305b: every reference interval version belongs to an assay version.
// status: statically-checked
MATCH (ri:ReferenceIntervalVersion)
WHERE NOT (ri)-[:FOR_ASSAY_VERSION]->(:AssayVersion)
RETURN ri.uid AS intervalWithoutAssayVersion;

// V-306: a result is interpreted with an interval of its own assay version.
// status: statically-checked
MATCH (r:DiagnosticResult)-[:INTERPRETED_WITH_REFERENCE_INTERVAL_VERSION]->(ri:ReferenceIntervalVersion)-[:FOR_ASSAY_VERSION]->(a:AssayVersion)
WHERE NOT (r)-[:PRODUCED_BY_ASSAY_VERSION]->(a)
RETURN r.uid AS resultUid, ri.uid AS intervalUid, a.uid AS intervalAssayVersion;

// V-307: no "same test" identity merge without an accepted resolution projection.
// status: statically-checked
MATCH (t1:LabTest)-[s:SAME_TEST_AS]-(t2:LabTest)
WHERE elementId(t1) < elementId(t2)
  AND s.projectionOfAssertionUid IS NULL
RETURN t1.uid AS labTest1, t2.uid AS labTest2;

// V-308: every algorithm version states its version basis.
// status: statically-checked
MATCH (v:AlgorithmVersion)
WHERE v.versionBasis IS NULL
   OR NOT v.versionBasis IN ['VENDOR_VERSION_STRING', 'PUBLICATION_VERSION', 'SERVICE_ENDPOINT_UNVERSIONED', 'UNKNOWN']
RETURN v.uid AS algorithmVersionUid, v.versionBasis AS versionBasis;

// V-312: results from an unversioned service endpoint never enter a comparison.
// status: statically-checked
MATCH (r:DiagnosticResult)-[:COMPARED_TO]-(:DiagnosticResult)
MATCH (r)-[:COMPUTED_BY_ALGORITHM_VERSION]->(v:AlgorithmVersion)
WHERE v.versionBasis = 'SERVICE_ENDPOINT_UNVERSIONED'
RETURN DISTINCT r.uid AS resultUid, v.uid AS algorithmVersionUid;

// Expected result of this fixture as written: zero rows from every query above.
// Review queue (not a validation failure): unresolved result-to-version links.
// status: statically-checked
MATCH (x:Assertion)-[:HAS_SUBJECT]->(r:DiagnosticResult)
WHERE x.predicate = 'COMPUTED_BY_ALGORITHM_VERSION' AND x.status = 'UNRESOLVED'
MATCH (x)-[:HAS_OBJECT]->(v:AlgorithmVersion)
RETURN r.uid AS resultUid, collect(v.uid) AS candidateVersions;


// ---------------------------------------------------------------------------
// Assertions behind terminology and lab-catalog edges
// Asserted edges are projections of assertions (catalog 0.2.0 asserted_edge profile). The record-derived facts below were
// created as bare edges by the lane; each now has its authorizing assertion, cited to the registry, publication or page
// snapshot it was read from, and the edge carries assertionUid, recordedFrom and relationshipUid.
// status: statically-checked, executed
UNWIND [
  {pred: 'HAS_IDENTIFIER', s: 'hu:metric:hba1c-mfr-bld', o: 'hu:identifier:loinc-4548-4', loc: 'hu:locator:loinc-4548-4-part-model'},
  {pred: 'HAS_IDENTIFIER', s: 'hu:metric:hba1c-ifcc-sfr-bld', o: 'hu:identifier:loinc-59261-8', loc: 'hu:locator:loinc-59261-8-names'},
  {pred: 'MEASURES_METRIC', s: 'hu:lab-test:synthetic-lab-a-hba1c', o: 'hu:metric:hba1c-mfr-bld', loc: 'hu:locator:synthetic-lab-a-notice-v2-body'},
  {pred: 'MEASURES_METRIC', s: 'hu:lab-test:synthetic-lab-b-hba1c-ifcc', o: 'hu:metric:hba1c-ifcc-sfr-bld', loc: 'hu:locator:ngsp-master-equation-table-2'}
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
MERGE (j:EvidenceAssessment:Adjudication {uid: 'hu:adjudication:diagnostic-comparison-capture-fidelity-policy-2026-10-04'})
ON CREATE SET j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'fixture-capture-policy-1', j.status = 'FINAL',
    j.rationale = 'Fixture capture policy: the recorded propositions match the cited spans as read by the authoring lane.',
    j.reviewedAt = datetime('2026-10-04T00:00:00Z'), j.recordedAt = datetime('2026-10-04T00:00:00Z'), j.createdAt = datetime('2026-10-04T00:00:00Z'),
    j.privacyClass = 'INTERNAL'
MERGE (j)-[:EVALUATES]->(a);
