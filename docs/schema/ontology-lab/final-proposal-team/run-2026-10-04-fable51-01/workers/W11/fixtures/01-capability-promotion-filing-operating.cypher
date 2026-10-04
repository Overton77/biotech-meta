// W11 fixture 01 -- promotional capability vs filing-disclosed capability vs attached operating state;
// planned vs operating vs suspended capability episodes; late arrival and a VALIDITY_BOUNDED correction.
// Run: run-2026-10-04-fable51-01, worker W11 (Opus 5.5). Neo4j 5 Cypher, Community-compatible, no APOC.
// Case (public, NEW_RETRIEVAL 2026-10-04, see ../03-source-manifest.md W11-S01..S05):
//   Natural Alternatives International, Inc. (NAI, Nasdaq NAII, SEC CIK 787253), Carlsbad CA powder facility.
//   - 2021-08-24 press release: purchase closed 2021-08-20; facility "scheduled to be retrofitted" -> PLANNED.
//   - FY2024 10-K (period ended 2024-06-30) Item 2 note (6): "became operational in April 2023; however, it was
//     temporarily closed in October 2023 ... and subsequently reopened in May 2024" -> OPERATING, SUSPENDED, OPERATING.
//   - FY2026 10-K (period ended 2026-06-30): sale of the Carlsbad facility determined; "persistent excess capacity"
//     -> an unattached, forward-looking DISCONTINUED state with capacityBasis NOT_REPORTED.
//   - nai-online.com manufacturing page (marketing): Carlsbad "expanding our capacity to provide high-quality capsule,
//     tablet, and powder supplements" -> promoted OPERATING capability, unattached; one SUPPORT adjudication
//     PARTIALLY_SUPPORTED against the filings (powder blending/packaging only per the 10-Ks).
// Three assertions + one adjudication (brief): A-PROMO (marketing), A-OP2 (filing; projects the attached OPERATING
//   episode), A-EXIT (filing, FY2026). Plus A-PLANNED, A-OP1, A-SUSP and the correction A-PLANNED-B.
// Hashes: snapshots use contentHashBasis SYNTHETIC_FIXTURE (sha256 over the snapshot uid; no page bytes were hashed);
//   quoteHash = sha256 over NFC-WS1(exact); payloadHash = sha256 over the canonical payload JSON written in the comment.
// Binding rule: every statement binds its own nodes by uid; no variable crosses ';'. Every node carries its primary
// label and its archetype label. uid tokens 'process' and 'capability' are W11 proposals (W11-SR-08) except
// 'capability', which is already registered as a fixture token in catalog conventions.uidTypeTokens.

// ---------------------------------------------------------------------------------------------------------------
// Section 1: sources, snapshots, locators
// ---------------------------------------------------------------------------------------------------------------

// status: run
UNWIND [
  {s: 'hu:source:nasdaq-prn-nai-carlsbad-acquisition-2021', uri: 'https://www.nasdaq.com/press-release/natural-alternatives-international-inc.-announces-acquisition-of-manufacturing-and', title: 'NAI Announces Acquisition of Manufacturing and Warehouse Facility (press release, 2021-08-24)', kind: 'PRESS_RELEASE', pub: datetime('2021-08-24T13:15:00Z'), cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:sec-naii-10k-fy2024', uri: 'https://www.sec.gov/Archives/edgar/data/787253/000143774924030208/naii20240630_10k.htm', title: 'Natural Alternatives International, Inc. Form 10-K for fiscal year ended 2024-06-30', kind: 'SECURITIES_FILING', pub: null, cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:sec-naii-10k-fy2025', uri: 'https://www.sec.gov/Archives/edgar/data/787253/000143774925029731/naii20250630_10k.htm', title: 'Natural Alternatives International, Inc. Form 10-K for fiscal year ended 2025-06-30', kind: 'SECURITIES_FILING', pub: null, cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:sec-naii-10k-fy2026', uri: 'https://www.sec.gov/Archives/edgar/data/787253/000143774926031343/naii20260630_10k.htm', title: 'Natural Alternatives International, Inc. Form 10-K for fiscal year ended 2026-06-30', kind: 'SECURITIES_FILING', pub: null, cc: 'PARTIAL_EXCERPT'},
  {s: 'hu:source:nai-online-manufacturing', uri: 'https://www.nai-online.com/our-capabilities/manufacturing', title: 'Manufacturing - Natural Alternatives International', kind: 'MARKETING_PAGE', pub: null, cc: 'PARTIAL_EXCERPT'}
] AS row
MERGE (s:Source:Entity {uid: row.s})
SET s.privacyClass = coalesce(s.privacyClass, 'PUBLIC'), s.canonicalUri = row.uri, s.title = row.title, s.sourceKind = row.kind, s.entityType = 'SOURCE',
    s.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: replace(row.s, 'hu:source:', 'hu:snapshot:') + '-2026-10-04'})
SET sn.privacyClass = coalesce(sn.privacyClass, 'PUBLIC'), sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = row.uri, sn.publishedAt = row.pub,
    sn.retrievedAt = datetime('2026-10-04T00:58:00Z'), sn.observedAt = datetime('2026-10-04T00:58:00Z'),
    sn.contentHashBasis = 'SYNTHETIC_FIXTURE', sn.captureCompleteness = row.cc,
    sn.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

// SYNTHETIC_FIXTURE content hashes (sha256 over the snapshot uid string).
// status: run
UNWIND [
  ['hu:snapshot:nasdaq-prn-nai-carlsbad-acquisition-2021-2026-10-04', 'sha256:52c3eb325274b91afa023ef138f02dc9e6f5fe634daf9040428a2b77d2e33b31'],
  ['hu:snapshot:sec-naii-10k-fy2024-2026-10-04', 'sha256:1427ab3032c0720a6d4d0a7f785e53ed3036947349235d0acb0067afcfc59624'],
  ['hu:snapshot:sec-naii-10k-fy2025-2026-10-04', 'sha256:5aa19c8d3eeb83941770da8662c7e8a7f13f11ceeba9c431a37475df722514e9'],
  ['hu:snapshot:sec-naii-10k-fy2026-2026-10-04', 'sha256:acec47f609e9b145dbd68979e7ed8239a883c2044d4f32defae10fc64ef53aaf'],
  ['hu:snapshot:nai-online-manufacturing-2026-10-04', 'sha256:018306e4601b65354611512712086114783e8c3baf5ca5983b4faeb51d190bd8']
] AS p
MATCH (sn:SourceSnapshot {uid: p[0]})
SET sn.contentHash = p[1];

// status: run
UNWIND [
  {l: 'hu:locator:prn-nai-2021-closed-aug-20', sn: 'hu:snapshot:nasdaq-prn-nai-carlsbad-acquisition-2021-2026-10-04',
   exact: 'today announced the purchase of a 54,154 ft2 manufacturing and warehouse facility in Carlsbad, CA in a transaction that closed on August 20, 2021.',
   qh: 'sha256:d00325879c2d0273f251ecfeda18a6fc3bd509efdebc56e708cbccefaabb9d3f'},
  {l: 'hu:locator:prn-nai-2021-scheduled-retrofit', sn: 'hu:snapshot:nasdaq-prn-nai-carlsbad-acquisition-2021-2026-10-04',
   exact: 'This facility is scheduled to be retrofitted to become a dedicated high volume powder blending and packaging facility.',
   qh: 'sha256:7219812f25ef987f491cd5c432971ade7daf9e46bfa9f6cf12ac799e78033d44'},
  {l: 'hu:locator:naii-10k-fy2024-carlsbad-note-6', sn: 'hu:snapshot:sec-naii-10k-fy2024-2026-10-04',
   exact: 'This facility became operational in April 2023; however, it was temporarily closed in October 2023 due to a significant reduction in customer orders and subsequently reopened in May 2024 to meet current capacity needs.',
   qh: 'sha256:04b94f1c8dfcadb25732d3f5fc5fd668d89c060be1126a0ad593016bee14e859'},
  {l: 'hu:locator:naii-10k-fy2025-carlsbad-powder', sn: 'hu:snapshot:sec-naii-10k-fy2025-2026-10-04',
   exact: 'In August 2021, NAI acquired a new manufacturing and warehouse facility in Carlsbad, California and retrofitted the facility to become a dedicated high-volume powder blending and packaging facility while also providing additional raw material storage capacity.',
   qh: 'sha256:71949bd98e10147b51a8329527b6379381edb95e148b6aeaa0ecb0af2a85e4aa'},
  {l: 'hu:locator:naii-10k-fy2026-carlsbad-sale', sn: 'hu:snapshot:sec-naii-10k-fy2026-2026-10-04',
   exact: 'management has determined the sale of our Carlsbad, California manufacturing facility is in the best interests of the Company and its stockholders.',
   qh: 'sha256:4d108bba31bedf31d29ec9bfb857154ecde3dd7514d305bdf929f476f69da02a'},
  {l: 'hu:locator:naii-10k-fy2026-excess-capacity', sn: 'hu:snapshot:sec-naii-10k-fy2026-2026-10-04',
   exact: 'reduce persistent excess capacity in our contract manufacturing segment',
   qh: 'sha256:a86602463c2ca2dffc16dbec82638c082852b008ff0e53e2d1c8f2a2d1784ec6'},
  {l: 'hu:locator:nai-online-manufacturing-carlsbad', sn: 'hu:snapshot:nai-online-manufacturing-2026-10-04',
   exact: 'In addition to our full-service manufacturing facilities in Vista, California, and Manno, Switzerland, we have added our new facility in Carlsbad, California, expanding our capacity to provide high-quality capsule, tablet, and powder supplements for an international audience.',
   qh: 'sha256:99a55d130e03e05726dba27cc67b21afaeccc6a7fc148cde4ebb7d59caf4923a'}
] AS row
MATCH (sn:SourceSnapshot {uid: row.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: row.l})
SET l.privacyClass = coalesce(l.privacyClass, 'PUBLIC'), l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact, l.quoteHash = row.qh,
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---------------------------------------------------------------------------------------------------------------
// Section 2: actors, facility, process (W01 / W11 identities)
// ---------------------------------------------------------------------------------------------------------------

// status: run
MERGE (o:Organization:LegalEntity:Entity {uid: 'hu:org:natural-alternatives-international-inc'})
SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.name = 'Natural Alternatives International', o.legalName = 'Natural Alternatives International, Inc.',
    o.entityType = 'ORGANIZATION', o.organizationKind = 'COMPANY', o.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
MERGE (f:Facility:Entity {uid: 'hu:facility:nai-carlsbad-powder-facility'})
SET f.privacyClass = coalesce(f.privacyClass, 'PUBLIC'), f.name = 'NAI Carlsbad, CA powder filling, packaging, distribution and storage facility', f.entityType = 'FACILITY',
    f.city = 'Carlsbad', f.region = 'CA', f.country = 'US', f.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
MERGE (p:ManufacturingProcess:Entity {uid: 'hu:process:nai-carlsbad-powder-blending-and-packaging'})
SET p.privacyClass = coalesce(p.privacyClass, 'PUBLIC'), p.name = 'High-volume powder blending and packaging (NAI Carlsbad)', p.entityType = 'MANUFACTURING_PROCESS',
    p.processKind = 'BLENDING', p.createdAt = datetime('2026-10-04T01:05:00Z');

// The promoted scope names capsule and tablet supplements, which no captured filing places at Carlsbad.
// status: run
MERGE (p:ManufacturingProcess:Entity {uid: 'hu:process:nai-capsule-tablet-powder-supplement-manufacturing-as-promoted'})
SET p.privacyClass = coalesce(p.privacyClass, 'PUBLIC'), p.name = 'Capsule, tablet and powder supplement manufacturing (as promoted)', p.entityType = 'MANUFACTURING_PROCESS',
    p.processKind = 'DOSAGE_FORM_MANUFACTURING', p.createdAt = datetime('2026-10-04T01:05:00Z');

// ---------------------------------------------------------------------------------------------------------------
// Section 3: capability states (immutable payloads). Payload JSON in each comment is the payloadHash input.
// ---------------------------------------------------------------------------------------------------------------

// payload {"stage":"PLANNED","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":null,"targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:nai-carlsbad-powder-blending-and-packaging","forMaterialUid":null}
// status: run
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:nai-carlsbad-powder-planned-2021'})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'PLANNED', c.capacityBasis = 'NOT_REPORTED',
    c.payloadHash = 'sha256:80e91a970f55466fc2937404aab26cdcc73d62480368c8946a4e08ac5e100e69}',
    c.createdAt = datetime('2026-10-04T01:10:00Z');

// One OPERATING payload; two episodes point at it (identical payload = identical state).
// payload {"stage":"OPERATING","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":null,"targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:nai-carlsbad-powder-blending-and-packaging","forMaterialUid":null}
// status: run
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:nai-carlsbad-powder-operating'})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'OPERATING', c.capacityBasis = 'NOT_REPORTED',
    c.payloadHash = 'sha256:ccb8e6055e2bbcb0897e6852c26f67bf61099b411f179a7ef1b8a62a32e0ccdf}',
    c.createdAt = datetime('2026-10-04T01:20:00Z');

// payload {"stage":"SUSPENDED","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":"temporarily closed in October 2023 due to a significant reduction in customer orders","targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:nai-carlsbad-powder-blending-and-packaging","forMaterialUid":null}
// status: run
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:nai-carlsbad-powder-suspended-2023'})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'SUSPENDED', c.capacityBasis = 'NOT_REPORTED',
    c.capacityVerbatim = 'temporarily closed in October 2023 due to a significant reduction in customer orders',
    c.payloadHash = 'sha256:915531f70bba4c2c9fbd109dbed8a0f893ee08574f3bcdf5bc038c4be2e20d79}',
    c.createdAt = datetime('2026-10-04T01:20:00Z');

// Forward-looking exit stated in the FY2026 10-K; never attached until a sale or closure is reported.
// payload {"stage":"DISCONTINUED","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":"reduce persistent excess capacity in our contract manufacturing segment","targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:nai-carlsbad-powder-blending-and-packaging","forMaterialUid":null}
// status: run
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:nai-carlsbad-powder-exit-as-planned-fy2026'})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'DISCONTINUED', c.capacityBasis = 'NOT_REPORTED',
    c.capacityVerbatim = 'reduce persistent excess capacity in our contract manufacturing segment',
    c.payloadHash = 'sha256:8e38b1454f2b4dc204344798ef849b467019762528efa4155630648f859af61a}',
    c.createdAt = datetime('2026-10-04T01:20:00Z');

// Promoted OPERATING capability for a broader scope (capsule, tablet, powder); unattached object of A-PROMO.
// payload {"stage":"OPERATING","capacityValue":null,"capacityUnitCode":null,"capacityBasis":"NOT_REPORTED","capacityVerbatim":"expanding our capacity to provide high-quality capsule, tablet, and powder supplements","targetOperationalDate":null,"targetOperationalDatePrecision":null,"forProcessUid":"hu:process:nai-capsule-tablet-powder-supplement-manufacturing-as-promoted","forMaterialUid":null}
// status: run
MERGE (c:ManufacturingCapability:VersionedState {uid: 'hu:capability:nai-carlsbad-as-promoted'})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.stateType = 'MANUFACTURING_CAPABILITY', c.stage = 'OPERATING', c.capacityBasis = 'NOT_REPORTED',
    c.capacityVerbatim = 'expanding our capacity to provide high-quality capsule, tablet, and powder supplements',
    c.payloadHash = 'sha256:89d996a540fc7493b831bd33921f4bf9f661fdbba51ae3022f25ef2994a71af0}',
    c.createdAt = datetime('2026-10-04T01:20:00Z');

// status: run
UNWIND [
  ['hu:capability:nai-carlsbad-powder-planned-2021', 'hu:process:nai-carlsbad-powder-blending-and-packaging'],
  ['hu:capability:nai-carlsbad-powder-operating', 'hu:process:nai-carlsbad-powder-blending-and-packaging'],
  ['hu:capability:nai-carlsbad-powder-suspended-2023', 'hu:process:nai-carlsbad-powder-blending-and-packaging'],
  ['hu:capability:nai-carlsbad-powder-exit-as-planned-fy2026', 'hu:process:nai-carlsbad-powder-blending-and-packaging'],
  ['hu:capability:nai-carlsbad-as-promoted', 'hu:process:nai-capsule-tablet-powder-supplement-manufacturing-as-promoted']
] AS p
MATCH (c:ManufacturingCapability {uid: p[0]}), (pr:ManufacturingProcess {uid: p[1]})
MERGE (c)-[:CAPABILITY_FOR_PROCESS]->(pr);

// ---------------------------------------------------------------------------------------------------------------
// Section 4: wave 1 (recorded 2026-10-04T01:10Z) -- only the 2021 press release is ingested. PLANNED from closing.
// ---------------------------------------------------------------------------------------------------------------

// A-PLANNED. Asserter NAI; the press release is the issuer's own statement (not marketing of capability: stage PLANNED).
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-powder-planned-2021'}),
      (nai:Organization {uid: 'hu:org:natural-alternatives-international-inc'}),
      (l1:SourceLocator {uid: 'hu:locator:prn-nai-2021-closed-aug-20'}), (l2:SourceLocator {uid: 'hu:locator:prn-nai-2021-scheduled-retrofit'})
MERGE (a:Assertion {uid: 'hu:assertion:nai-carlsbad-planned-2021'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFrom = datetime('2021-08-20T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM',
    a.predicateClass = 'OTHER', a.contentHash = 'sha256:ac8027a281c5490001c8db442b7b94f8a12011bc17897fa09fb87c851e244a21', a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(nai)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2)
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:nai-carlsbad-planned-2021-e1'}]->(c)
SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = 'DAY', h.validFromBasis = 'STATED_BY_SOURCE',
    h.validToBasis = 'UNKNOWN', h.recordedFrom = datetime('2026-10-04T01:10:00Z');

// ---------------------------------------------------------------------------------------------------------------
// Section 5: wave 2 (recorded 2026-10-04T01:20Z) -- FY2024 10-K arrives late: three past episodes.
// ---------------------------------------------------------------------------------------------------------------

// status: run
UNWIND [
  {a: 'hu:assertion:nai-carlsbad-operating-2023', ch: 'sha256:0cc419334474e2971d99567b51412fe5e286fdab478cc2749cd18d07a06f1720', c: 'hu:capability:nai-carlsbad-powder-operating', vf: datetime('2023-04-01T00:00:00Z'), vt: datetime('2023-10-01T00:00:00Z'), rel: 'hu:rel:nai-carlsbad-operating-2023'},
  {a: 'hu:assertion:nai-carlsbad-suspended-2023', ch: 'sha256:048ef2b0f2ee9220c5b01d02259295a3f57e6accbc9fd37a45493711b44b82cf', c: 'hu:capability:nai-carlsbad-powder-suspended-2023', vf: datetime('2023-10-01T00:00:00Z'), vt: datetime('2024-05-01T00:00:00Z'), rel: 'hu:rel:nai-carlsbad-suspended-2023'},
  {a: 'hu:assertion:nai-carlsbad-operating-2024', ch: 'sha256:2831467d91a24f868d57b874a4383804773225b89c4f34d4d439b7e7ccbf73b2', c: 'hu:capability:nai-carlsbad-powder-operating', vf: datetime('2024-05-01T00:00:00Z'), vt: null, rel: 'hu:rel:nai-carlsbad-operating-2024'}
] AS row
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (c:ManufacturingCapability {uid: row.c}),
      (nai:Organization {uid: 'hu:org:natural-alternatives-international-inc'}), (l:SourceLocator {uid: 'hu:locator:naii-10k-fy2024-carlsbad-note-6'})
MERGE (a:Assertion {uid: row.a})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:20:00Z'),
    a.validFrom = row.vf, a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE',
    a.validTo = row.vt, a.validToPrecision = CASE WHEN row.vt IS NULL THEN null ELSE 'MONTH' END,
    a.validToBasis = CASE WHEN row.vt IS NULL THEN 'UNKNOWN' ELSE 'STATED_BY_SOURCE' END,
    a.polarity = 'POSITIVE', a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER',
    a.contentHash = row.ch, a.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(nai)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (f)-[h:HAS_CAPABILITY_STATE {relationshipUid: row.rel}]->(c)
SET h.assertionUid = a.uid, h.validFrom = a.validFrom, h.validFromPrecision = a.validFromPrecision, h.validFromBasis = a.validFromBasis,
    h.validTo = a.validTo, h.validToPrecision = a.validToPrecision, h.validToBasis = a.validToBasis,
    h.recordedFrom = datetime('2026-10-04T01:20:00Z');

// Correction (VALIDITY_BOUNDED): the PLANNED episode's open end becomes known as April 2023 (inferred from the
// operational start); same content, new assertion; the old assertion and old episode are closed at 01:20Z.
// status: run
MATCH (old:Assertion {uid: 'hu:assertion:nai-carlsbad-planned-2021'}), (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}),
      (c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-powder-planned-2021'}), (nai:Organization {uid: 'hu:org:natural-alternatives-international-inc'}),
      (l1:SourceLocator {uid: 'hu:locator:prn-nai-2021-closed-aug-20'}), (l2:SourceLocator {uid: 'hu:locator:naii-10k-fy2024-carlsbad-note-6'})
MERGE (b:Assertion {uid: 'hu:assertion:nai-carlsbad-planned-2021-bounded'})
SET b.privacyClass = coalesce(b.privacyClass, 'PUBLIC'), b.predicate = 'HAS_CAPABILITY_STATE', b.status = 'ACCEPTED', b.recordedAt = datetime('2026-10-04T01:20:00Z'),
    b.validFrom = old.validFrom, b.validFromPrecision = 'DAY', b.validFromBasis = 'STATED_BY_SOURCE',
    b.validTo = datetime('2023-04-01T00:00:00Z'), b.validToPrecision = 'MONTH', b.validToBasis = 'INFERRED',
    b.derivationRule = 'w11-capability-bound/v1: a PLANNED state of a capability line ends at the stated start of the first OPERATING state of the same line',
    b.polarity = 'POSITIVE', b.speechAct = 'STATES', b.assertionBasis = 'MANUFACTURER_CLAIM', b.predicateClass = 'OTHER',
    b.contentHash = 'sha256:bf01cfc014a2494d97129de47c33453e0ef3beb2cdafc96518b2908a825d03be', b.createdAt = datetime('2026-10-04T01:20:00Z')
SET old.status = 'SUPERSEDED', old.recordedTo = datetime('2026-10-04T01:20:00Z')
MERGE (b)-[:HAS_SUBJECT]->(f)
MERGE (b)-[:HAS_OBJECT]->(c)
MERGE (b)-[:ASSERTED_BY]->(nai)
MERGE (b)-[:SUPPORTED_BY]->(l1)
MERGE (b)-[:SUPPORTED_BY]->(l2)
MERGE (b)-[sx:SUPERSEDES]->(old)
SET sx.supersessionKind = 'VALIDITY_BOUNDED', sx.recordedAt = datetime('2026-10-04T01:20:00Z');

// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'})-[h1:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:nai-carlsbad-planned-2021-e1'}]->(c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-powder-planned-2021'})
SET h1.recordedTo = datetime('2026-10-04T01:20:00Z')
MERGE (f)-[h2:HAS_CAPABILITY_STATE {relationshipUid: 'hu:rel:nai-carlsbad-planned-2021-e2'}]->(c)
SET h2.assertionUid = 'hu:assertion:nai-carlsbad-planned-2021-bounded', h2.validFrom = datetime('2021-08-20T00:00:00Z'),
    h2.validFromPrecision = 'DAY', h2.validFromBasis = 'STATED_BY_SOURCE', h2.validTo = datetime('2023-04-01T00:00:00Z'),
    h2.validToPrecision = 'MONTH', h2.validToBasis = 'INFERRED', h2.recordedFrom = datetime('2026-10-04T01:20:00Z');

// ---------------------------------------------------------------------------------------------------------------
// Section 6: promotional assertion, FY2026 forward-looking exit, and the one SUPPORT adjudication
// ---------------------------------------------------------------------------------------------------------------

// A-PROMO: ACCEPTED means "faithfully captured", not "true" (INV-406). Not attached.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-as-promoted'}),
      (nai:Organization {uid: 'hu:org:natural-alternatives-international-inc'}), (l:SourceLocator {uid: 'hu:locator:nai-online-manufacturing-carlsbad'})
MERGE (a:Assertion {uid: 'hu:assertion:nai-online-promotes-carlsbad-capability'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:20:00Z'),
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER',
    a.contentHash = 'sha256:14b647171569d72d73f87ac03607277ab78b29994a8b78889bd42da4410a39db', a.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(nai)
MERGE (a)-[:SUPPORTED_BY]->(l);

// A-EXIT: forward-looking (statedTense FUTURE), no valid time, never attached until the sale or closure is reported.
// status: run
MATCH (f:Facility {uid: 'hu:facility:nai-carlsbad-powder-facility'}), (c:ManufacturingCapability {uid: 'hu:capability:nai-carlsbad-powder-exit-as-planned-fy2026'}),
      (nai:Organization {uid: 'hu:org:natural-alternatives-international-inc'}),
      (l1:SourceLocator {uid: 'hu:locator:naii-10k-fy2026-carlsbad-sale'}), (l2:SourceLocator {uid: 'hu:locator:naii-10k-fy2026-excess-capacity'})
MERGE (a:Assertion {uid: 'hu:assertion:naii-10k-fy2026-carlsbad-exit-planned'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.predicate = 'HAS_CAPABILITY_STATE', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:20:00Z'),
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.statedTense = 'FUTURE', a.polarity = 'POSITIVE',
    a.speechAct = 'STATES', a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER',
    a.contentHash = 'sha256:18c8e2a5938469db87776ae7985e4b7adf1d7c312b5ae2d5fa5afb69c16666a7', a.createdAt = datetime('2026-10-04T01:20:00Z')
MERGE (a)-[:HAS_SUBJECT]->(f)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:ASSERTED_BY]->(nai)
MERGE (a)-[:SUPPORTED_BY]->(l1)
MERGE (a)-[:SUPPORTED_BY]->(l2);

// The one SUPPORT adjudication: the promotion is PARTIALLY_SUPPORTED (powder blending/packaging operating per the 10-Ks;
// capsule and tablet scope at Carlsbad not supported; FY2026 10-K plans a sale). Not CONTRADICTED: the sentence can be
// read as describing the company's network, which does include capsule/tablet capacity at Vista and Manno.
// status: run
MATCH (a:Assertion {uid: 'hu:assertion:nai-online-promotes-carlsbad-capability'}),
      (l1:SourceLocator {uid: 'hu:locator:naii-10k-fy2025-carlsbad-powder'}), (l2:SourceLocator {uid: 'hu:locator:naii-10k-fy2026-carlsbad-sale'})
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:nai-carlsbad-promotion-support-2026-10-04'})
SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'SUPPORT', j.verdict = 'PARTIALLY_SUPPORTED',
    j.reviewerType = 'AGENT', j.methodVersion = 'w11-capability-adjudication-v0', j.status = 'ACCEPTED',
    j.reviewedAt = datetime('2026-10-04T01:30:00Z'), j.recordedAt = datetime('2026-10-04T01:30:00Z'),
    j.rationale = 'FY2024/FY2025 10-Ks: Carlsbad is a dedicated high-volume powder blending and packaging facility, operational April 2023, closed October 2023, reopened May 2024. No captured filing places capsule or tablet manufacturing at Carlsbad. FY2026 10-K: sale of Carlsbad determined. The promotion supports at most an operating powder capability.',
    j.createdAt = datetime('2026-10-04T01:30:00Z')
MERGE (j)-[:EVALUATES]->(a)
MERGE (j)-[:SUPPORTED_BY]->(l1)
MERGE (j)-[:SUPPORTED_BY]->(l2);

// Capture-fidelity policy adjudication (INV-103, V-110): every ACCEPTED/REJECTED/DISPUTED assertion of this fixture,
// including the SUPERSEDED-at-01:20 history, says nothing about truth.
// status: run
MATCH (a:Assertion)
WHERE a.uid STARTS WITH 'hu:assertion:nai'
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w11-f01-capture-fidelity-policy'})
ON CREATE SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w11-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.reviewedAt = datetime('2026-10-04T01:40:00Z'), j.recordedAt = datetime('2026-10-04T01:40:00Z'),
    j.rationale = 'Fixture capture policy: propositions match the cited spans as read by W11.', j.privacyClass = 'INTERNAL',
    j.createdAt = datetime('2026-10-04T01:40:00Z')
MERGE (j)-[:EVALUATES]->(a);

// ---------------------------------------------------------------------------------------------------------------
// Section 7: NEGATIVE blocks (kept commented; fixtures/04-negative-mutations.cypher applies them in isolation).
// N1 (V-324, V-324r): attach the promoted OPERATING state.
// N2 (V-W11-01, V-W11-03): attach an OPERATING state authorized by the PLANNED assertion, with the planned date copied.
// ---------------------------------------------------------------------------------------------------------------
