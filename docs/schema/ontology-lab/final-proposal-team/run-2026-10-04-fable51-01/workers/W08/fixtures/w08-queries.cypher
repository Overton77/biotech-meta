// W08 competency-question queries (run against fixtures 1-3; expected rows in 06-fixtures-and-queries.md).
// Each statement is self-contained. Parameters are inlined as literals so the file runs without a parameter map.

// Q-W08-01 (CQ-DX-01, CQ-DX-C03): for each assay version, the instrument model and the platform class it implements, kept apart.
MATCH (a:AssayVersion)-[:RUNS_ON_INSTRUMENT]->(i)
WHERE a.uid STARTS WITH 'hu:assay-version:synthetic-lab-c-'
OPTIONAL MATCH (i)-[ip:IMPLEMENTS_PLATFORM]->(p:TechnologyPlatform)
WHERE ip.recordedTo IS NULL
OPTIONAL MATCH (a)-[:USES_METHOD]->(m:MeasurementMethod)
RETURN a.uid AS assayVersion, a.assayKitIdentifier AS kit, m.name AS methodPrinciple,
       head([l IN labels(i) WHERE l IN ['ToolOrInstrument', 'Device']]) AS instrumentKind, i.name AS instrumentModel,
       collect(p.name) AS platforms
ORDER BY assayVersion;

// Q-W08-02 (CQ-DX-03): may two assay versions share a trend axis? Same platform and kit do not decide it; an assessment does.
MATCH (a1:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-iscan'}), (a2:AssayVersion {uid: 'hu:assay-version:synthetic-lab-c-epic-v2-nextseq550'})
MATCH (a1)-[:RUNS_ON_INSTRUMENT]->(i1), (a2)-[:RUNS_ON_INSTRUMENT]->(i2)
OPTIONAL MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
WHERE EXISTS { MATCH (ca)-[:COMPARES]->(a2) }
RETURN a1.assayKitIdentifier = a2.assayKitIdentifier AS sameKit,
       EXISTS { MATCH (i1)-[:IMPLEMENTS_PLATFORM]->(p)<-[:IMPLEMENTS_PLATFORM]-(i2) } AS samePlatform,
       i1 = i2 AS sameInstrument,
       ca.verdict AS comparabilityVerdict,
       CASE WHEN ca IS NULL THEN 'SEPARATE_SERIES' ELSE ca.verdict END AS trendDecision;

// Q-W08-03 (CQ-DX-09, CQ-DX-C01): which firmware and which assay version produced a WHOOP 4.0 heart-rate value, per firmware.
MATCH (d:Device {uid: 'hu:device:whoop-4-0'})-[e:PERFORMED_WITH_ASSAY_VERSION]->(a:AssayVersion)-[:ASSAY_FOR_METRIC]->(m:Metric)
WHERE e.recordedTo IS NULL
OPTIONAL MATCH (a)-[:RUNS_FIRMWARE_VERSION]->(fv:FirmwareVersion)
RETURN d.name AS device, m.name AS metric, a.uid AS assayVersion, a.softwareVersion AS softwareVersion, fv.versionLabel AS firmware,
       fv.componentLabel AS component, e.validFrom AS validFrom, e.validFromBasis AS validFromBasis
ORDER BY softwareVersion;

// Q-W08-04 (CQ-DX-C01): firmware lineage of a device model with the vendor's release-note statements (believed now).
MATCH (fv:FirmwareVersion)-[:FIRMWARE_VERSION_OF]->(d:Device {uid: 'hu:device:whoop-4-0'})
OPTIONAL MATCH (n:Assertion {predicate: 'RELEASE_NOTE_STATES'})-[:HAS_SUBJECT]->(fv)
WHERE n.recordedTo IS NULL
OPTIONAL MATCH (n)-[:ASSERTED_BY]->(who)
RETURN fv.componentLabel AS component, fv.versionLabel AS version, fv.effectiveFrom AS releasedFrom,
       collect(n.valueString) AS releaseNotes, collect(DISTINCT who.name) AS asserters
ORDER BY component, version;

// Q-W08-05 (CQ-DX-03 minimal pair): the two WHOOP 4.0 heart-rate assay versions differ only in softwareVersion.
MATCH (a1:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-15-3-0'}), (a2:AssayVersion {uid: 'hu:assay-version:whoop-4-0-heart-rate-fw-41-16-1-0'})
MATCH (a1)-[:RUNS_ON_INSTRUMENT]->(d1), (a2)-[:RUNS_ON_INSTRUMENT]->(d2)
OPTIONAL MATCH (ca:ComparabilityAssessment)-[:COMPARES]->(a1)
WHERE EXISTS { MATCH (ca)-[:COMPARES]->(a2) }
RETURN d1 = d2 AS sameDevice, a1.softwareVersion AS before, a2.softwareVersion AS after, a1 = a2 AS sameAssayVersion,
       CASE WHEN ca IS NULL THEN 'SEPARATE_SERIES' ELSE ca.verdict END AS trendDecision;

// Q-W08-06 (CQ-MF-02, CQ-MF-03, CQ-DX-C02): "Is WHOOP MG FDA cleared or approved?" Statuses reachable from the device
// through products that run on it or embody it, with the device's own status count (always 0 by V-W08-03).
MATCH (d:Device {uid: 'hu:device:whoop-mg'})
OPTIONAL MATCH (d)<-[rel:RUNS_ON_DEVICE|EMBODIES_MODEL]-(p:Product)<-[so:STATUS_OF]-(s:RegulatoryStatus)
WHERE so.recordedTo IS NULL
OPTIONAL MATCH (s)-[:RESULTS_FROM_RESPONSE]->(resp:RegulatoryResponse)<-[:SUBMISSION_HAS_RESPONSE]-(sub:RegulatorySubmission)
RETURN d.name AS device, type(rel) AS productLink, p.name AS product, s.statusKind AS statusKind, s.statusKind = 'APPROVAL' AS isApproval,
       s.productCode AS productCode, s.pcccAuthorized AS pcccAuthorized, sub.identifier AS submission, resp.responseKind AS response,
       so.validFrom AS validFrom, so.recordedFrom AS recordedFrom,
       COUNT { (x:RegulatoryStatus)-[:STATUS_OF]->(d) } AS statusesOnDeviceItself;

// Q-W08-07 (CQ-MF-03, V-W08-11): performance statements about the cleared software product, with asserter and basis.
MATCH (a:Assertion)-[:HAS_SUBJECT]->(p:Product {uid: 'hu:product:whoop-ecg-feature'})
WHERE a.predicate STARTS WITH 'REPORTS_'
MATCH (a)-[:ASSERTED_BY]->(who)
MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
RETURN a.predicate AS predicate, a.valueNumber AS value, a.unitCode AS unit, a.description AS qualifiers, who.name AS assertedBy,
       a.assertionBasis AS basis, src.sourceKind AS sourceKind, l.page AS pdfPage
ORDER BY predicate;

// Q-W08-08 (CQ-DX-02): what a device "measures" per its maker versus how results are produced (assay vs unresolved claim).
MATCH (d:Device {uid: 'hu:device:whoop-4-0'})-[mm:MEASURES_METRIC]->(m:Metric)
OPTIONAL MATCH (d)-[:PERFORMED_WITH_ASSAY_VERSION]->(a:AssayVersion)-[:ASSAY_FOR_METRIC]->(m)
RETURN d.name AS device, m.name AS metric, mm.assertionUid AS vendorAssertion, count(DISTINCT a) AS assayVersionsOnRecord;

// Q-W08-09 (CQ-PR-03 support): which equipment facts are missing for a device (no firmware with a release date, no
// assay version with a reported software version, no validFrom on its assay episodes).
MATCH (d:Device)
WHERE d.uid IN ['hu:device:whoop-4-0', 'hu:device:whoop-mg']
RETURN d.name AS device,
       COUNT { (d)<-[:FIRMWARE_VERSION_OF]-(:FirmwareVersion) } AS firmwareVersions,
       COUNT { (d)<-[:FIRMWARE_VERSION_OF]-(fv:FirmwareVersion) WHERE fv.effectiveFrom IS NOT NULL } AS firmwareWithReleaseDate,
       COUNT { (d)-[e:PERFORMED_WITH_ASSAY_VERSION]->() WHERE e.validFrom IS NULL } AS assayEpisodesWithUnknownStart,
       COUNT { (d)-[:PERFORMED_WITH_ASSAY_VERSION]->() } AS assayEpisodes
ORDER BY device;

// Q-W08-10 (CQ-MF-04): use of a platform or equipment is reported with its asserter, never as an operating capability.
MATCH (o:Organization)-[u:USES_EQUIPMENT|USES_PLATFORM]->(x)
OPTIONAL MATCH (a:Assertion {uid: u.assertionUid})-[:ASSERTED_BY]->(who)
RETURN o.name AS organization, type(u) AS relation, x.name AS equipmentOrPlatform, u.isPrimary AS isPrimary, who.name AS assertedBy,
       EXISTS { MATCH (o)-[:HAS_CAPABILITY_STATE]->() } AS hasCapabilityState
ORDER BY equipmentOrPlatform;
