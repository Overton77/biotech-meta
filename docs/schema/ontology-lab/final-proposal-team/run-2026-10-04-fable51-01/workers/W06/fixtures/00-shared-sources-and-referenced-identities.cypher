// =====================================================================================================================
// W06 fixture 00: sources, snapshots, locators (W00 kernel shapes) and other owners' identities referenced by W06
// fixtures 01-05 and 99. Run run-2026-10-04-fable51-01, worker W06 (Opus 5.5). Target Neo4j 5.26 Community.
// Snapshot contentHash values are sha256 over the stored excerpt files in fixtures/excerpts/ (basis
// STORED_EXCERPT_TEXT: the hash proves the stored excerpt, not the publisher's bytes). Retrieval was 2026-10-04 (see
// 03-source-manifest.md). Other owners' nodes carry only the properties W06 queries need; they are references, not
// W06 definitions. Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================================================================

// ---- Sources (W00 Source identities) ----
UNWIND [
  {uid: 'hu:source:fda-cber-casgevy', uri: 'https://www.fda.gov/vaccines-blood-biologics/casgevy', kind: 'REGULATORY_RECORD', title: 'CASGEVY | FDA (CBER product page)'},
  {uid: 'hu:source:fda-casgevy-pi-stn125787', uri: 'https://www.fda.gov/media/174615/download', kind: 'REGULATORY_RECORD', title: 'Package Insert - CASGEVY (STN 125787)'},
  {uid: 'hu:source:fda-oopd-714319', uri: 'https://www.accessdata.fda.gov/scripts/opdlisting/oopd/detailedIndex.cfm?cfgridkey=714319', kind: 'REGULATORY_RECORD', title: 'OOPD record: exagamglogene autotemcel, beta-thalassemia'},
  {uid: 'hu:source:fda-oopd-465514', uri: 'https://www.accessdata.fda.gov/scripts/opdlisting/oopd/detailedIndex.cfm?cfgridkey=465514', kind: 'REGULATORY_RECORD', title: 'OOPD record: edaravone, ALS (Treeway B.V.)'},
  {uid: 'hu:source:fda-nda209176-review-2017', uri: 'https://www.accessdata.fda.gov/drugsatfda_docs/nda/2017/209176orig1s000medr.pdf', kind: 'REGULATORY_RECORD', title: 'NDA 209176 medical review (search extract only)'},
  {uid: 'hu:source:ctgov-nct03745287', uri: 'https://clinicaltrials.gov/study/NCT03745287', kind: 'REGULATORY_RECORD', title: 'ClinicalTrials.gov NCT03745287'},
  {uid: 'hu:source:ctgov-nct06597656', uri: 'https://clinicaltrials.gov/study/NCT06597656', kind: 'REGULATORY_RECORD', title: 'ClinicalTrials.gov NCT06597656 (HORIZON)'},
  {uid: 'hu:source:next-health-tpe', uri: 'https://www.next-health.com/product/therapeutic-plasma-exchange', kind: 'MARKETING_PAGE', title: 'Therapeutic Plasma Exchange | Next Health'},
  {uid: 'hu:source:circulate-health-home', uri: 'https://circulate.health', kind: 'ORGANIZATION_WEBPAGE', title: 'Circulate Health home page (search extract only)'},
  {uid: 'hu:source:geekwire-circulate-2025', uri: 'https://www.geekwire.com/2025/seattle-startup-circulate-health-raises-12m-for-pricey-blood-cleaning-longevity-service', kind: 'PRESS_RELEASE', title: 'GeekWire article on Circulate Health (search extract only; trade press, kind PRESS_RELEASE pending a NEWS kind)'},
  {uid: 'hu:source:icd10pcs-fy2027', uri: 'https://www.cms.gov/medicare/coding-billing/icd-10-codes', kind: 'TERMINOLOGY_RECORD', title: 'ICD-10-PCS FY2027 code set (via ICD-10 Codes MCP)'},
  {uid: 'hu:source:synthetic-practice-protocol', uri: 'https://example.invalid/w06/tpe-practice-protocol', kind: 'ORGANIZATION_WEBPAGE', title: 'SYNTHETIC public practice protocol employing TPE'}
] AS s
MERGE (n:Source:Entity {uid: s.uid})
SET n.entityType = 'Source', n.canonicalUri = s.uri, n.sourceKind = s.kind, n.title = s.title,
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

// ---- Snapshots (immutable captures) ----
UNWIND [
  {uid: 'hu:snapshot:fda-cber-casgevy-20261004', src: 'hu:source:fda-cber-casgevy', at: '2026-10-04T00:57:00Z', pub: '2026-07-02T00:00:00Z', hash: 'sha256:9cc149de82bf314c95adde28bb78ad0660fb1534b1c80a364d301e90bc5d7801', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:fda-casgevy-pi-20261004', src: 'hu:source:fda-casgevy-pi-stn125787', at: '2026-10-04T00:58:00Z', pub: '2026-07-01T00:00:00Z', hash: 'sha256:f079071292e35a0c4de0d327320458b364e80f0def6d19243c0a2d54abcead74', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:fda-oopd-714319-20261004', src: 'hu:source:fda-oopd-714319', at: '2026-10-04T00:59:00Z', pub: null, hash: 'sha256:d30dbf65385355d8ddcf7fafb7c0423c3e28fd6643c6ae2352ec2556fa6d3db6', basis: 'STORED_EXCERPT_TEXT', comp: 'COMPLETE'},
  {uid: 'hu:snapshot:fda-oopd-465514-20261004', src: 'hu:source:fda-oopd-465514', at: '2026-10-04T01:00:00Z', pub: null, hash: 'sha256:5f36fac79ff1652c0aca38c3e05c201c459701c5c898ff5ad54829a416b963d7', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:fda-nda209176-search-20261004', src: 'hu:source:fda-nda209176-review-2017', at: '2026-10-04T01:01:00Z', pub: null, hash: 'sha256:fd4e79b0a75cad19168233349ed1e6038457cb4c81d450e7cebcec54c8d05d21', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:ctgov-nct03745287-20261004', src: 'hu:source:ctgov-nct03745287', at: '2026-10-04T01:05:00Z', pub: null, hash: 'sha256:c4ca8eeab23a8b3831002eb317a5a478c608e85bbda0d639ae8b5c5f2573da10', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:ctgov-nct06597656-20261004', src: 'hu:source:ctgov-nct06597656', at: '2026-10-04T01:04:00Z', pub: null, hash: 'sha256:c4ca8eeab23a8b3831002eb317a5a478c608e85bbda0d639ae8b5c5f2573da10', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:next-health-tpe-20261004', src: 'hu:source:next-health-tpe', at: '2026-10-04T01:02:00Z', pub: null, hash: 'sha256:695a81ff06428f3a0c4ea52e6537a8e0fb1640f72ae44bfc795cf061fd4a6cf8', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:circulate-search-20261004', src: 'hu:source:circulate-health-home', at: '2026-10-04T01:02:00Z', pub: null, hash: 'sha256:10e6a6a321aa254ba092f08fdf7de51659ca2f41b1495a83f17974792b67e852', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:geekwire-search-20261004', src: 'hu:source:geekwire-circulate-2025', at: '2026-10-04T01:02:00Z', pub: null, hash: 'sha256:10e6a6a321aa254ba092f08fdf7de51659ca2f41b1495a83f17974792b67e852', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:icd10pcs-6A55-20261004', src: 'hu:source:icd10pcs-fy2027', at: '2026-10-04T01:08:00Z', pub: null, hash: 'sha256:46a83bc99dd93fb1cc4db2881000f5b07d79eeac723554d5dc01264476b2616c', basis: 'STORED_EXCERPT_TEXT', comp: 'PARTIAL_EXCERPT'},
  {uid: 'hu:snapshot:synthetic-practice-protocol', src: 'hu:source:synthetic-practice-protocol', at: '2026-10-04T01:10:00Z', pub: null, hash: 'synthetic:hu:snapshot:synthetic-practice-protocol', basis: 'SYNTHETIC_FIXTURE', comp: 'COMPLETE'}
] AS s
MERGE (n:SourceSnapshot:InformationArtifact {uid: s.uid})
SET n.artifactType = 'SourceSnapshot', n.retrievedAt = datetime(s.at), n.observedAt = datetime(s.at),
    n.publishedAt = CASE WHEN s.pub IS NULL THEN null ELSE datetime(s.pub) END,
    n.contentHash = s.hash, n.contentHashBasis = s.basis, n.captureCompleteness = s.comp,
    n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  ['hu:source:fda-cber-casgevy', 'hu:snapshot:fda-cber-casgevy-20261004'],
  ['hu:source:fda-casgevy-pi-stn125787', 'hu:snapshot:fda-casgevy-pi-20261004'],
  ['hu:source:fda-oopd-714319', 'hu:snapshot:fda-oopd-714319-20261004'],
  ['hu:source:fda-oopd-465514', 'hu:snapshot:fda-oopd-465514-20261004'],
  ['hu:source:fda-nda209176-review-2017', 'hu:snapshot:fda-nda209176-search-20261004'],
  ['hu:source:ctgov-nct03745287', 'hu:snapshot:ctgov-nct03745287-20261004'],
  ['hu:source:ctgov-nct06597656', 'hu:snapshot:ctgov-nct06597656-20261004'],
  ['hu:source:next-health-tpe', 'hu:snapshot:next-health-tpe-20261004'],
  ['hu:source:circulate-health-home', 'hu:snapshot:circulate-search-20261004'],
  ['hu:source:geekwire-circulate-2025', 'hu:snapshot:geekwire-search-20261004'],
  ['hu:source:icd10pcs-fy2027', 'hu:snapshot:icd10pcs-6A55-20261004'],
  ['hu:source:synthetic-practice-protocol', 'hu:snapshot:synthetic-practice-protocol']
] AS p
MATCH (s:Source {uid: p[0]}), (n:SourceSnapshot {uid: p[1]})
MERGE (s)-[:HAS_SNAPSHOT]->(n);

// ---- Locators (TEXT_QUOTE carry exact + quoteHash under NFC-WS1; SECTION / WHOLE_SNAPSHOT are coarse, V-401b) ----
UNWIND [
  {uid: 'hu:locator:casgevy-pi-gene-therapy', snap: 'hu:snapshot:fda-casgevy-pi-20261004', kind: 'TEXT_QUOTE', exact: 'CASGEVY is an autologous genome edited hematopoietic stem cell-based gene therapy', qh: 'sha256:c170d7cd27c2f67c7b75333a6b49f9433bf312d855dc05b4863a90748c777643', section: '1 INDICATIONS AND USAGE'},
  {uid: 'hu:locator:casgevy-pi-cellular-gene-therapy', snap: 'hu:snapshot:fda-casgevy-pi-20261004', kind: 'TEXT_QUOTE', exact: 'CASGEVY (exagamglogene autotemcel) is a cellular gene therapy consisting of autologous CD34+ HSCs edited by CRISPR/Cas9-technology', qh: 'sha256:b860025b156c6eacfa8c98aaf319551f8188b058f4c71ae64fec14a29a4d4545', section: '11 DESCRIPTION'},
  {uid: 'hu:locator:casgevy-pi-apheresis', snap: 'hu:snapshot:fda-casgevy-pi-20261004', kind: 'TEXT_QUOTE', exact: "CASGEVY is prepared from the patient's own HSCs, which are obtained via apheresis procedure(s).", qh: 'sha256:111f7a075af33cd78f90a1beb090a3e60a073e84a50903157c96a8ed6dbec982', section: '11 DESCRIPTION'},
  {uid: 'hu:locator:casgevy-pi-header', snap: 'hu:snapshot:fda-casgevy-pi-20261004', kind: 'TEXT_QUOTE', exact: 'CASGEVY (exagamglogene autotemcel), suspension for intravenous infusion', qh: 'sha256:eb4728b1e1a71d763cc8a5a29d9e58c4afe1206d2ceeb2138493c9b06ce52c40', section: 'Highlights header'},
  {uid: 'hu:locator:fda-cber-casgevy-header', snap: 'hu:snapshot:fda-cber-casgevy-20261004', kind: 'SECTION', exact: null, qh: null, section: 'Header: STN, Proper Name, Tradename, Manufacturer'},
  {uid: 'hu:locator:fda-cber-casgevy-indication', snap: 'hu:snapshot:fda-cber-casgevy-20261004', kind: 'SECTION', exact: null, qh: null, section: 'Indication'},
  {uid: 'hu:locator:oopd-714319-record', snap: 'hu:snapshot:fda-oopd-714319-20261004', kind: 'WHOLE_SNAPSHOT', exact: null, qh: null, section: null},
  {uid: 'hu:locator:oopd-465514-record', snap: 'hu:snapshot:fda-oopd-465514-20261004', kind: 'WHOLE_SNAPSHOT', exact: null, qh: null, section: null},
  {uid: 'hu:locator:nda209176-search-description', snap: 'hu:snapshot:fda-nda209176-search-20261004', kind: 'SECTION', exact: null, qh: null, section: 'search result description (not the PDF)'},
  {uid: 'hu:locator:ctgov-nct03745287-interventions', snap: 'hu:snapshot:ctgov-nct03745287-20261004', kind: 'SECTION', exact: null, qh: null, section: 'Arms and Interventions'},
  {uid: 'hu:locator:ctgov-nct06597656-interventions', snap: 'hu:snapshot:ctgov-nct06597656-20261004', kind: 'SECTION', exact: null, qh: null, section: 'Arms and Interventions'},
  {uid: 'hu:locator:ctgov-nct06597656-title', snap: 'hu:snapshot:ctgov-nct06597656-20261004', kind: 'TEXT_QUOTE', exact: 'Following Therapeutic Plasma Exchange (Plasmapheresis)', qh: 'sha256:4d55f1d3235564820408468fd958fd20c1a7af196cf98c3acfdbffc88cfe461b', section: 'Brief Title'},
  {uid: 'hu:locator:next-health-tpe-definition', snap: 'hu:snapshot:next-health-tpe-20261004', kind: 'TEXT_QUOTE', exact: 'Therapeutic plasma exchange (TPE) is a cutting-edge medical service', qh: 'sha256:c2a408428865bf4ac1114f6f57580bc4fff27fbc8cfcf30de175de6aa771f919', section: 'What is a Therapeutic Plasma Exchange?'},
  {uid: 'hu:locator:next-health-tpe-price', snap: 'hu:snapshot:next-health-tpe-20261004', kind: 'TEXT_QUOTE', exact: 'At Next Health, Therapeutic Plasma Exchange costs $10,000.', qh: 'sha256:4417455f4677ca7d8304d56fca094dbf566e5b07ee3a78457f99c473bdfc8586', section: 'FAQ'},
  {uid: 'hu:locator:next-health-tpe-includes-tests', snap: 'hu:snapshot:next-health-tpe-20261004', kind: 'TEXT_QUOTE', exact: 'Therapeutic Plasma Exchange at Next Health includes a Baseline Test and a Total Tox Burden Test before each session.', qh: 'sha256:942c139c9a0e2c8f1a6bc0819e84cb5d4b822c4aad88eaf7e7a65fde2b0507aa', section: 'What is a Therapeutic Plasma Exchange?'},
  {uid: 'hu:locator:circulate-search-snippet', snap: 'hu:snapshot:circulate-search-20261004', kind: 'SECTION', exact: null, qh: null, section: 'search snippet (page not opened)'},
  {uid: 'hu:locator:geekwire-search-snippet', snap: 'hu:snapshot:geekwire-search-20261004', kind: 'SECTION', exact: null, qh: null, section: 'search snippet (page not opened)'},
  {uid: 'hu:locator:icd10pcs-6A55', snap: 'hu:snapshot:icd10pcs-6A55-20261004', kind: 'WHOLE_SNAPSHOT', exact: null, qh: null, section: null},
  {uid: 'hu:locator:synthetic-practice-protocol-step', snap: 'hu:snapshot:synthetic-practice-protocol', kind: 'SECTION', exact: null, qh: null, section: 'Step 3 (SYNTHETIC)'}
] AS l
MATCH (snap:SourceSnapshot {uid: l.snap})
MERGE (loc:SourceLocator:InformationArtifact {uid: l.uid})
SET loc.artifactType = 'SourceLocator', loc.selectorKind = l.kind, loc.exact = l.exact, loc.quoteHash = l.qh,
    loc.normalizationVersion = CASE WHEN l.exact IS NULL THEN null ELSE 'NFC-WS1' END, loc.section = l.section,
    loc.uri = snap.uid, loc.privacyClass = 'PUBLIC', loc.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// ---- Referenced identities owned by other workers (minimal properties) ----
UNWIND [
  {uid: 'hu:org:vertex-pharmaceuticals', name: 'Vertex Pharmaceuticals Incorporated', labels: 'Organization'},
  {uid: 'hu:org:sarepta-therapeutics', name: 'Sarepta Therapeutics, Inc.', labels: 'Organization'},
  {uid: 'hu:org:treeway-bv', name: 'Treeway B.V.', labels: 'Organization'},
  {uid: 'hu:org:next-health', name: 'Next Health', labels: 'Organization'},
  {uid: 'hu:org:circulate-health', name: 'Circulate Health', labels: 'Organization'},
  {uid: 'hu:org:geekwire', name: 'GeekWire', labels: 'Organization'}
] AS o
MERGE (n:Organization:Entity {uid: o.uid})
SET n.entityType = 'Organization', n.name = o.name, n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (n:RegulatoryAgency:Organization:Entity {uid: 'hu:org:us-fda'})
SET n.entityType = 'RegulatoryAgency', n.name = 'U.S. Food and Drug Administration', n.jurisdiction = 'US', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {uid: 'hu:condition:sickle-cell-disease', name: 'sickle cell disease'},
  {uid: 'hu:condition:transfusion-dependent-beta-thalassemia', name: 'transfusion-dependent beta-thalassemia'},
  {uid: 'hu:condition:beta-thalassemia', name: 'beta-thalassemia'},
  {uid: 'hu:condition:duchenne-muscular-dystrophy', name: 'Duchenne muscular dystrophy'},
  {uid: 'hu:condition:amyotrophic-lateral-sclerosis', name: 'amyotrophic lateral sclerosis'}
] AS c
MERGE (n:Condition:Entity {uid: c.uid})
SET n.entityType = 'Condition', n.name = c.name, n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {uid: 'hu:product:casgevy', name: 'CASGEVY'},
  {uid: 'hu:product:radicava', name: 'RADICAVA'},
  {uid: 'hu:product:treeway-edaravone-investigational', name: 'Treeway edaravone (investigational product; product name not captured)'}
] AS p
MERGE (n:Product:Entity {uid: p.uid})
SET n.entityType = 'Product', n.name = p.name, n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (n:ChemicalSubstance:Entity {uid: 'hu:substance:edaravone'})
SET n.entityType = 'ChemicalSubstance', n.name = 'edaravone', n.privacyClass = 'PUBLIC', n.createdAt = datetime('2026-10-04T02:00:00Z');
