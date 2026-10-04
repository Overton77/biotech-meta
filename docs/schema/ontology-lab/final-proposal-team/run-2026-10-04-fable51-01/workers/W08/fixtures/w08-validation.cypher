// W08 validation queries V-W08-01 .. V-W08-11 (proposed; zero rows = valid unless marked informational).
// Run run-2026-10-04-fable51-01, worker W08. Each statement is self-contained (binds its own variables; nothing crosses ';').
// Executed on embedded Neo4j 5.26.31 Community (see 06-fixtures-and-queries.md for expected and observed rows).

// V-W08-01: the instrument of an assay version is an equipment model (ToolOrInstrument or Device), never a platform,
// modality, sensor, method or firmware version (CQ-DX-01; forbidden implication [SAME_TECHNOLOGY_PLATFORM, SAME_INSTRUMENT]).
MATCH (a:AssayVersion)-[:RUNS_ON_INSTRUMENT]->(x)
WHERE NOT (x:ToolOrInstrument OR x:Device)
RETURN a.uid AS assayVersionUid, labels(x) AS targetLabels, x.uid AS targetUid;

// V-W08-02: equipment, platform, sensor, modality and firmware nodes carry no regulatory-status or performance property.
// Clearance/approval live on W13 RegulatoryStatus of a Product; performance is an Assertion (CQ-MF-02, CQ-MF-03).
MATCH (n)
WHERE n:Device OR n:ToolOrInstrument OR n:TechnologyPlatform OR n:Sensor OR n:Modality OR n:FirmwareVersion
WITH n, [k IN keys(n) WHERE toLower(k) IN ['fdacleared', 'fdaapproved', 'approved', 'cleared', 'clearancenumber', 'regulatorystatus',
         'regulatoryauthorizationid', 'statuskind', 'productcode', 'pcccauthorized', 'accuracy', 'accuracypercent', 'sensitivity',
         'specificity', 'medicalgrade', 'performanceclaim', 'validated']] AS forbiddenKeys
WHERE size(forbiddenKeys) > 0
RETURN n.uid AS nodeUid, labels(n) AS nodeLabels, forbiddenKeys;

// V-W08-03: no regulatory status, submission subject, designation or approval attaches to an equipment-model,
// platform, sensor, modality or firmware node (W13 RegulatorySubjectTarget excludes them; 510(k) attaches to a Product).
MATCH (s)-[r]-(x)
WHERE (s:RegulatoryStatus OR s:RegulatorySubmission)
  AND type(r) IN ['STATUS_OF', 'SUBMISSION_ABOUT', 'DESIGNATION_FOR', 'APPROVAL_FOR', 'HAS_REGULATORY_STATUS']
  AND (x:Device OR x:ToolOrInstrument OR x:TechnologyPlatform OR x:Sensor OR x:Modality OR x:FirmwareVersion)
RETURN s.uid AS regulatoryRecordUid, type(r) AS relType, labels(x) AS attachedLabels, x.uid AS attachedUid;

// V-W08-04: every asserted W08 edge is a projection of exactly one matching Assertion (asserted_edge profile; contract A5).
MATCH (x)-[r]->(y)
WHERE type(r) IN ['DEVELOPS_PLATFORM', 'USES_PLATFORM', 'IMPLEMENTS_PLATFORM', 'USES_MODALITY', 'HAS_SENSOR', 'USES_EQUIPMENT', 'EMBODIES_MODEL', 'RUNS_ON_DEVICE']
   OR (type(r) IN ['MEASURES_METRIC', 'PERFORMED_WITH_ASSAY_VERSION'] AND x:Device)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, y, r, a, [v IN [
    CASE WHEN r.assertionUid IS NULL THEN 'NO_ASSERTION_UID' END,
    CASE WHEN r.relationshipUid IS NULL THEN 'NO_RELATIONSHIP_UID' END,
    CASE WHEN r.recordedFrom IS NULL THEN 'NO_RECORDED_FROM' END,
    CASE WHEN r.validFromBasis IS NULL OR r.validToBasis IS NULL THEN 'NO_VALID_TIME_BASIS' END,
    CASE WHEN r.assertionUid IS NOT NULL AND a IS NULL THEN 'ASSERTION_MISSING' END,
    CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } THEN 'SUBJECT_DIFFERS' END,
    CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) } THEN 'OBJECT_DIFFERS' END,
    CASE WHEN a IS NOT NULL AND r.recordedFrom < a.recordedAt THEN 'RECORDED_BEFORE_ASSERTION' END
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN type(r) AS relType, x.uid AS startUid, y.uid AS endUid, violations;

// V-W08-05 (candidate FirmwareVersion): an assay version that declares a firmware version keeps the same label in
// softwareVersion and runs on the device that firmware belongs to (CQ-DX-09, CQ-DX-C01).
MATCH (a:AssayVersion)-[:RUNS_FIRMWARE_VERSION]->(fv:FirmwareVersion)
OPTIONAL MATCH (fv)-[:FIRMWARE_VERSION_OF]->(d:Device)
OPTIONAL MATCH (a)-[:RUNS_ON_INSTRUMENT]->(i)
WITH a, fv, collect(DISTINCT d) AS devices, collect(DISTINCT i) AS instruments
WHERE a.softwareVersion IS NULL OR a.softwareVersion <> fv.versionLabel OR NOT any(d IN devices WHERE d IN instruments)
RETURN a.uid AS assayVersionUid, a.softwareVersion AS softwareVersion, fv.versionLabel AS firmwareLabel,
       [d IN devices | d.uid] AS firmwareOf, [i IN instruments | i.uid] AS runsOn;

// V-W08-06 (candidate FirmwareVersion): exactly one FIRMWARE_VERSION_OF per firmware version, at most one
// RUNS_FIRMWARE_VERSION per assay version.
MATCH (fv:FirmwareVersion)
OPTIONAL MATCH (fv)-[:FIRMWARE_VERSION_OF]->(d)
WITH fv, count(d) AS devices
WHERE devices <> 1
RETURN 'FIRMWARE_VERSION_OF' AS check, fv.uid AS uid, devices AS n
UNION ALL
MATCH (a:AssayVersion)-[:RUNS_FIRMWARE_VERSION]->(fv)
WITH a, count(fv) AS n
WHERE n > 1
RETURN 'RUNS_FIRMWARE_VERSION' AS check, a.uid AS uid, n;

// V-W08-07 (informational backfill): an assay version running on a Device with a REPORTED softwareVersion that matches a
// recorded FirmwareVersion of that device but does not declare it.
MATCH (a:AssayVersion)-[:RUNS_ON_INSTRUMENT]->(d:Device)<-[:FIRMWARE_VERSION_OF]-(fv:FirmwareVersion)
WHERE a.softwareVersionStatus = 'REPORTED' AND a.softwareVersion = fv.versionLabel
  AND NOT EXISTS { MATCH (a)-[:RUNS_FIRMWARE_VERSION]->(fv) }
RETURN a.uid AS assayVersionUid, fv.uid AS undeclaredFirmwareUid;

// V-W08-08 (migration): retired live edges in W08 scope must not be written any more.
MATCH (x)-[r]->(y)
WHERE (type(r) = 'MEASURES_METRIC' AND x:Sensor)
   OR (type(r) = 'USES_PLATFORM' AND x:LabTest)
   OR (type(r) = 'USES' AND x:Organization AND y:ToolOrInstrument)
   OR (type(r) = 'IMPLEMENTS' AND y:TechnologyPlatform)
   OR (type(r) = 'CLASSIFIED_AS' AND (y:Device OR y:ToolOrInstrument))
RETURN type(r) AS retiredRelType, labels(x) AS fromLabels, x.uid AS fromUid, y.uid AS toUid;

// V-W08-09: equipment models are model-level and public: no unit-level identifiers or owner references, and no link to a
// private record in either direction (contract A9; complements V-113 .. V-116).
MATCH (n)
WHERE (n:Device OR n:ToolOrInstrument OR n:Sensor OR n:FirmwareVersion)
  AND (any(k IN keys(n) WHERE toLower(k) IN ['serialnumber', 'unitserial', 'imei', 'macaddress', 'owneruid', 'useruid', 'personuid'])
       OR EXISTS { MATCH (n)--(p) WHERE p:PrivateRecord OR p.uid STARTS WITH 'hu:private-' OR p.privacyClass = 'private-personal' })
RETURN n.uid AS equipmentUid, labels(n) AS equipmentLabels;

// V-W08-10 (informational): several equipment-model uids share one display name. Names are never identity; a merge needs an
// accepted EquivalenceAssessment (contract A2).
MATCH (n)
WHERE (n:Device OR n:ToolOrInstrument OR n:TechnologyPlatform) AND n.name IS NOT NULL
WITH head([l IN labels(n) WHERE l IN ['Device', 'ToolOrInstrument', 'TechnologyPlatform']]) AS label, toLower(n.name) AS nameKey, collect(n.uid) AS uids
WHERE size(uids) > 1
RETURN label, nameKey, uids;

// V-W08-11: a performance claim is an attributed Assertion about a product or a measurement procedure, never about a
// device model or platform, and it names its asserter and basis (forbidden implication
// [MANUFACTURER_PERFORMANCE_CLAIM, VALIDATED_PERFORMANCE]).
MATCH (a:Assertion)
WHERE a.predicate IN ['REPORTS_SENSITIVITY', 'REPORTS_SPECIFICITY', 'REPORTS_INCONCLUSIVE_RATE', 'REPORTS_ACCURACY', 'CLAIMS_ACCURACY_IMPROVEMENT']
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(s)
WITH a, collect(s) AS subjects
WHERE size(subjects) <> 1
   OR NOT any(s IN subjects WHERE s:Product OR s:ProductVariant OR s:AssayVersion OR s:AlgorithmVersion)
   OR NOT EXISTS { MATCH (a)-[:ASSERTED_BY]->() }
   OR a.assertionBasis IS NULL
RETURN a.uid AS assertionUid, a.predicate AS predicate, [s IN subjects | labels(s)] AS subjectLabels;
