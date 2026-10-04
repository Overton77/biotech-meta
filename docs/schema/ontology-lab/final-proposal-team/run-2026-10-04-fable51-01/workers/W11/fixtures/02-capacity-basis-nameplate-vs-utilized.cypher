// W11 fixture 02 -- capacity basis: NAMEPLATE (issuer filing, area unit) vs UTILIZED (third-party filing, rate)
// vs PLANNED expansion; a utilization claim is not attached without adjudication. Run: run-2026-10-04-fable51-01, W11.
// Case (public, NEW_RETRIEVAL 2026-10-04, ../03-source-manifest.md W11-S06, W11-S07):
//   - Cyanotech Corporation Form 10-K, fiscal year ended 2002-03-31 (SEC CIK 768408), Item 1/2: "68 large oval culture
//     ponds, 1 media recycling lake and 17 smaller auxiliary culture ponds totaling approximately 200,000 square meters,
//     all of which are currently available for production" (NAMEPLATE, unit m2: capacity measured as cultivation area,
//     not as output); "we ultimately plan to use this new property to construct a larger astaxanthin production
//     facility and additional culture ponds" (PLANNED, no target date stated).
//   - Schedule 13D filed in 2018 by Meridian (an investor, not the issuer), exhibit text: "July 2018 - approximately half
//     of astaxanthin ponds empty", from aerial imagery (UTILIZED about 50 %, scope astaxanthin ponds only). Kept as an
//     ACCEPTED capture with no attachment: a third party's inference from imagery is not adjudicated here.
// Distinctions exercised: capacity unit (m2 vs %); basis NAMEPLATE vs UTILIZED; the 2002 nameplate and the 2018
// utilization are 16 years apart and never combined into a utilization ratio by the schema.
// Same conventions as fixture 01 (SYNTHETIC_FIXTURE snapshot hashes; NFC-WS1 quote hashes; payload JSON in comments).

// status: run
UNWIND [
  {s: 'hu:source:sec-cyan-10k-fy2002', uri: 'https://www.sec.gov/Archives/edgar/data/768408/000091205702025816/a2083228z10-k.htm', title: 'Cyanotech Corporation Form 10-K for fiscal year ended 2002-03-31', kind: 'SECURITIES_FILING', ch: 'sha256:c111f83e9a5c7089bd6e611b967eab11761d48845daa369629df544768a1da7d'},
  {s: 'hu:source:sec-meridian-sc13d-cyan-2018', uri: 'https://www.sec.gov/Archives/edgar/data/768408/000144586618001193/meridian_sc13d.htm', title: 'Schedule 13D (Meridian) regarding Cyanotech Corporation, 2018', kind: 'SECURITIES_FILING', ch: 'sha256:a0854d32d57975d94eb2bb6ffc4713367110d938cbe732d3e8a44d1c6954f66a'}
] AS row
MERGE (s:Source:Entity {uid: row.s})
SET s.privacyClass = coalesce(s.privacyClass, 'PUBLIC'), s.id = coalesce(s.id, split(s.uid, ':')[2]), s.canonicalUri = row.uri, s.title = row.title, s.sourceKind = row.kind, s.entityType = 'SOURCE', s.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: replace(row.s, 'hu:source:', 'hu:snapshot:') + '-2026-10-04'})
SET sn.privacyClass = coalesce(sn.privacyClass, 'PUBLIC'), sn.id = coalesce(sn.id, split(sn.uid, ':')[2]), sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = row.uri, sn.retrievedAt = datetime('2026-10-04T00:58:00Z'),
    sn.observedAt = datetime('2026-10-04T00:58:00Z'), sn.contentHash = row.ch, sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

// status: run
UNWIND [
  {l: 'hu:locator:cyan-10k-fy2002-ponds-available', sn: 'hu:snapshot:sec-cyan-10k-fy2002-2026-10-04',
   exact: '68 large oval culture ponds, 1 media recycling lake and 17 smaller auxiliary culture ponds totaling approximately 200,000 square meters, all of which are currently available for production.',
   qh: 'sha256:e44f26b56bb98ec199abddeacd8f5573047e9bcdd0cb95396823feebba72811f'},
  {l: 'hu:locator:cyan-10k-fy2002-planned-expansion', sn: 'hu:snapshot:sec-cyan-10k-fy2002-2026-10-04',
   exact: 'Subject to available funds, we ultimately plan to use this new property to construct a larger astaxanthin production facility and additional culture ponds that would use the PhytoDome CCS technology.',
   qh: 'sha256:91be17c06c5d45dbf8518ebb8a8bf7dd6eae5ca7673d53e44294048c2c6d6572'},
  {l: 'hu:locator:meridian-sc13d-july-2018-ponds', sn: 'hu:snapshot:sec-meridian-sc13d-cyan-2018-2026-10-04',
   exact: 'July 2018 – approximately half of astaxanthin ponds empty',
   qh: 'sha256:f425fd616dcfab568156aeae7ef649c3bb2366253f9d8020524e32d0ea12f96e'}
] AS row
MATCH (sn:SourceSnapshot {uid: row.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: row.l})
SET l.privacyClass = coalesce(l.privacyClass, 'PUBLIC'), l.id = coalesce(l.id, split(l.uid, ':')[2]), l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact, l.quoteHash = row.qh,
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// status: run
MERGE (o:Organization:LegalEntity:Entity {uid: 'hu:org:cyanotech-corporation'})
SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.id = coalesce(o.id, split(o.uid, ':')[2]), o.name = 'Cyanotech', o.legalName = 'Cyanotech Corporation', o.entityType = 'ORGANIZATION', o.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
MERGE (o:Organization:Entity {uid: 'hu:org:meridian-13d-reporting-person'})
SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.id = coalesce(o.id, split(o.uid, ':')[2]), o.name = 'Meridian (Schedule 13D reporting person for Cyanotech, 2018)', o.entityType = 'ORGANIZATION', o.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
MERGE (f:Facility:Entity {uid: 'hu:facility:cyanotech-kona-host-park'})
SET f.privacyClass = coalesce(f.privacyClass, 'PUBLIC'), f.id = coalesce(f.id, split(f.uid, ':')[2]), f.name = 'Cyanotech microalgae production facility, HOST Park, Kailua-Kona, Hawaii', f.entityType = 'FACILITY',
    f.city = 'Kailua-Kona', f.region = 'HI', f.country = 'US', f.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
UNWIND [
  ['hu:process:cyanotech-open-pond-microalgae-cultivation', 'Open-pond microalgae cultivation (Spirulina and Haematococcus)', 'CULTIVATION'],
  ['hu:process:cyanotech-astaxanthin-open-pond-cultivation', 'Haematococcus astaxanthin batch cultivation in culture ponds', 'CULTIVATION'],
  ['hu:process:cyanotech-phytodome-closed-culture-as-planned', 'Astaxanthin production in PhytoDome closed culture system (as planned, FY2002)', 'CULTIVATION']
] AS p
MERGE (pr:ManufacturingProcess:Entity {uid: p[0]})
SET pr.privacyClass = coalesce(pr.privacyClass, 'PUBLIC'), pr.id = coalesce(pr.id, split(pr.uid, ':')[2]), pr.name = p[1], pr.processKind = p[2], pr.entityType = 'MANUFACTURING_PROCESS', pr.createdAt = datetime('2026-10-04T01:05:00Z');

// payloads (payloadHash input):
// N: {"stage":"OPERATING","capacityValue":200000,"capacityUnitCode":"m2","capacityBasis":"NAMEPLATE","capacityVerbatim":"totaling approximately 200,000 square meters, all of which are currently available for production","targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:cyanotech-open-pond-microalgae-cultivation","forMaterialUid":null}
// P: {"stage":"PLANNED","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":null,"targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:cyanotech-phytodome-closed-culture-as-planned","forMaterialUid":null}
// U: {"stage":"OPERATING","capacityValue":50,"capacityUnitCode":"%","capacityBasis":"UTILIZED","capacityVerbatim":"approximately half of astaxanthin ponds empty","targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:cyanotech-astaxanthin-open-pond-cultivation","forMaterialUid":null}
// status: run
UNWIND [
  {c: 'hu:capability:cyanotech-kona-ponds-nameplate-fy2002', stage: 'OPERATING', v: 200000.0, u: 'm2', b: 'NAMEPLATE', verb: 'totaling approximately 200,000 square meters, all of which are currently available for production', pr: 'hu:process:cyanotech-open-pond-microalgae-cultivation',
   ph: 'sha256:3bfa97aa65efe489e884ad7fd8f74259101df221d6343df9ccf03cfa427ab198}'},
  {c: 'hu:capability:cyanotech-phytodome-planned-fy2002', stage: 'PLANNED', v: null, u: null, b: 'NOT_REPORTED', verb: null, pr: 'hu:process:cyanotech-phytodome-closed-culture-as-planned',
   ph: 'sha256:3ccfb5965a2b06ac1e07a83394507f0a6dd49b4c3fbd11860a8c9503e100a0c7}'},
  {c: 'hu:capability:cyanotech-astaxanthin-ponds-utilized-2018-07-per-meridian', stage: 'OPERATING', v: 50.0, u: '%', b: 'UTILIZED', verb: 'approximately half of astaxanthin ponds empty', pr: 'hu:process:cyanotech-astaxanthin-open-pond-cultivation',
   ph: 'sha256:5cfdc5db0dadb0f924fb7da67cc6ca022421845a4bb6e1988aeef67fea7627b5}'}
] AS row
MATCH (pr:ManufacturingProcess {uid: row.pr})
MERGE (c:ManufacturingCapability:VersionedState {uid: row.c})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.id = coalesce(c.id, split(c.uid, ':')[2]), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = row.stage, c.capacityValue = row.v, c.capacityUnitCode = row.u,
    c.capacityBasis = row.b, c.capacityVerbatim = row.verb, c.payloadHash = row.ph, c.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (c)-[:CAPABILITY_FOR_PROCESS]->(pr);

// Issuer filing: NAMEPLATE operating state and a PLANNED expansion, both attached (non-marketing source; INV-305).
// Valid time: the filing describes the state at filing; start unknown -> null bound with OBSERVATION_ONLY basis.
// status: run
UNWIND [
  {a: 'hu:assertion:cyan-10k-fy2002-ponds-nameplate', ch: 'sha256:90fcfad202e7ef5daccb87f61fdd37b217e7a82fbebe009841c28e93b266cfb3', c: 'hu:capability:cyanotech-kona-ponds-nameplate-fy2002', l: 'hu:locator:cyan-10k-fy2002-ponds-available', rel: 'hu:rel:cyan-kona-ponds-nameplate-fy2002'},
  {a: 'hu:assertion:cyan-10k-fy2002-phytodome-planned', ch: 'sha256:826f5ed3a1d1c10b8471e17eba9cd72965e754b9b321f482dcbc61e3d2cea6be', c: 'hu:capability:cyanotech-phytodome-planned-fy2002', l: 'hu:locator:cyan-10k-fy2002-planned-expansion', rel: 'hu:rel:cyan-phytodome-planned-fy2002'}
] AS row
MATCH (f:Facility {uid: 'hu:facility:cyanotech-kona-host-park'}), (c:ManufacturingCapability {uid: row.c}),
      (cy:Organization {uid: 'hu:org:cyanotech-corporation'}), (l:SourceLocator {uid: row.l})
MERGE (a:Assertion {uid: row.a})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER', a.contentHash = row.ch, a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(cy)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: row.rel}]->(c)
SET h.assertionUid = a.uid, h.validFromBasis = 'OBSERVATION_ONLY', h.validToBasis = 'UNKNOWN', h.recordedFrom = datetime('2026-10-04T01:10:00Z');

// Third-party filing: UTILIZED about 50 % of astaxanthin ponds (July 2018), basis INFERRED_FROM_MEASUREMENT (imagery).
// Captured faithfully (ACCEPTED), not attached.
// status: run
MATCH (f:Facility {uid: 'hu:facility:cyanotech-kona-host-park'}), (c:ManufacturingCapability {uid: 'hu:capability:cyanotech-astaxanthin-ponds-utilized-2018-07-per-meridian'}),
      (m:Organization {uid: 'hu:org:meridian-13d-reporting-person'}), (l:SourceLocator {uid: 'hu:locator:meridian-sc13d-july-2018-ponds'})
MERGE (a:Assertion {uid: 'hu:assertion:meridian-sc13d-cyan-astaxanthin-ponds-half-empty-2018-07'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFrom = datetime('2018-07-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validTo = datetime('2018-08-01T00:00:00Z'), a.validToPrecision = 'MONTH', a.validToBasis = 'STATED_BY_SOURCE',
    a.basisKind = 'INFERRED_FROM_MEASUREMENT', a.polarity = 'POSITIVE', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.predicateClass = 'OTHER', a.contentHash = 'sha256:9a8dd3f3e9c6c0b6533106b8bfb8d68087ead32016a971beb89ea19d0b615d40',
    a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(m)
MERGE (a)-[:SUPPORTED_BY]->(l);

// status: run
MATCH (a:Assertion)
WHERE (a.uid STARTS WITH 'hu:assertion:cyan' OR a.uid STARTS WITH 'hu:assertion:meridian')
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w11-f02-capture-fidelity-policy'})
ON CREATE SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.id = coalesce(j.id, split(j.uid, ':')[2]), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w11-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.reviewedAt = datetime('2026-10-04T01:40:00Z'), j.recordedAt = datetime('2026-10-04T01:40:00Z'),
    j.rationale = 'Fixture capture policy: propositions match the cited spans as read by W11.', j.privacyClass = 'INTERNAL',
    j.createdAt = datetime('2026-10-04T01:40:00Z')
MERGE (j)-[:EVALUATES]->(a);
