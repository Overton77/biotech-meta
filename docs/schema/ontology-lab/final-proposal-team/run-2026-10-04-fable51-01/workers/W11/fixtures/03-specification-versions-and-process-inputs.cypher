// W11 fixture 03 -- specification version change WITHOUT material identity change; compendial monograph is a separate
// specification; specification owner is not the process performer; process inputs: an IngredientMaterial under its
// own uid (nicotinamide) and non-ingredient chemical inputs carried by ChemicalSubstance (CL-005: no ProcessMaterial).
// Run: run-2026-10-04-fable51-01, W11. Reuses uids of ../../../../../../examples/filing-vs-capability.cypher
// (hu:material:niagen-nrc, hu:material:niagen-nrc-pharmaceutical-grade, hu:org:niagen-bioscience-inc) so both load together.
// Cases (NEW_RETRIEVAL 2026-10-04, ../03-source-manifest.md W11-S08..S10):
//   - GRN 000635 notifier dossier (Spherix Consulting for ChromaDex, dated 2015-12-21, hosted by FDA): Table 2
//     "Specifications and Batch Analyses for Commercial Batches of Niagen": purity 95-102 wt% by HPLC; water <=1%;
//     acetone <=3000 ppm; methanol <=740 ppm (the PDF text layer shows the comparator glyph as '~' or '::so'; read as <=,
//     Table 14 of the same dossier prints 'NMT1%' for water). Figures 2-3: two-step synthesis and reagents.
//   - EFSA Journal 2019;17(8):5775, Table 2 "Specifications of the NF" as proposed by the applicant: NRC >=90 wt%
//     (set "to account for the degradation ... over the course of shelf-life"), water <=2.0 %, acetone <=5,000 mg/kg,
//     methanol <=1,000 mg/kg (captured via a third-party-hosted copy, SEARCH_EXTRACT; official page fetch failed).
//   - Niagen Bioscience press release 2026-04-09: USP NRCl dietary supplement monograph published, "expected to be
//     codified and enforced in October 2026"; monograph text is licensed (criteria not captured).
// SpecificationCriterion nodes and the CRITERION_OF_SPECIFICATION edge are W12's (name requested, W11-SR-03); fields
// thresholdUpper and limitStage are W11 requests to W12 (W11-SR-03). They are written here so the payload digest of a
// SpecificationVersion can be demonstrated; W12's final names replace them at merge.

// ---------------------------------------------------------------------------------------------------------------
// Section 1: sources, snapshots, locators
// ---------------------------------------------------------------------------------------------------------------

// status: run
UNWIND [
  {s: 'hu:source:fda-grn-000635-notice-pdf', uri: 'https://www.fda.gov/files/food/published/GRAS-Notice-000635--Nicotinamide-riboside-chloride.pdf', title: 'GRAS Notice 635: Nicotinamide riboside chloride (notifier dossier, 2015-12-21)', kind: 'REGULATORY_RECORD', ch: 'sha256:0ead0bfb7a4013593d5cf1a1a958d1efad825532ee027a0b7b36765ef89674c5', pub: datetime('2015-12-21T00:00:00Z')},
  {s: 'hu:source:efsa-journal-2019-5775', uri: 'https://doi.org/10.2903/j.efsa.2019.5775', title: 'EFSA NDA Panel: Safety of nicotinamide riboside chloride as a novel food (EFSA Journal 2019;17(8):5775)', kind: 'REGULATORY_RECORD', ch: 'sha256:047859f6deb3cf0300f56617674199a48eff0a72282b677cd6601c4c36c5c275', pub: datetime('2019-08-01T00:00:00Z')},
  {s: 'hu:source:niagen-investors-usp-monograph-2026', uri: 'https://investors.niagenbioscience.com/news/news-details/2026/Niagen-Bioscience-Collaborates-with-USP-to-Establish-First-Ever-USP-Monograph-for-Nicotinamide-Riboside-Chloride-NRCl-the-Patented-Form-in-Niagen/default.aspx', title: 'Niagen Bioscience Collaborates with USP to Establish First-Ever USP Monograph for NRCl (press release, 2026-04-09)', kind: 'PRESS_RELEASE', ch: 'sha256:82a362c5ce4b5475ba802f4d29f35a5e9c21ccce2d1b536f7601c7f31157ff37', pub: datetime('2026-04-09T12:32:00Z')}
] AS row
MERGE (s:Source:Entity {uid: row.s})
SET s.privacyClass = coalesce(s.privacyClass, 'PUBLIC'), s.id = coalesce(s.id, split(s.uid, ':')[2]), s.canonicalUri = row.uri, s.title = row.title, s.sourceKind = row.kind, s.entityType = 'SOURCE', s.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn:SourceSnapshot:InformationArtifact {uid: replace(row.s, 'hu:source:', 'hu:snapshot:') + '-2026-10-04'})
SET sn.privacyClass = coalesce(sn.privacyClass, 'PUBLIC'), sn.id = coalesce(sn.id, split(sn.uid, ':')[2]), sn.artifactType = 'SOURCE_SNAPSHOT', sn.canonicalUri = row.uri, sn.publishedAt = row.pub, sn.retrievedAt = datetime('2026-10-04T00:58:00Z'),
    sn.observedAt = datetime('2026-10-04T00:58:00Z'), sn.contentHash = row.ch, sn.contentHashBasis = 'SYNTHETIC_FIXTURE',
    sn.captureCompleteness = 'PARTIAL_EXCERPT', sn.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (s)-[:HAS_SNAPSHOT]->(sn);

// status: run
UNWIND [
  {l: 'hu:locator:grn-635-table-2-specifications', sn: 'hu:snapshot:fda-grn-000635-notice-pdf-2026-10-04',
   exact: 'Table 2. Specifications and Batch Analyses for Commercial Batches of Niagen',
   qh: 'sha256:55e2d1e45387d2e9531ea44c4c8c9251d244a68c644f52ee95e124c749cc1294'},
  {l: 'hu:locator:grn-635-step-1', sn: 'hu:snapshot:fda-grn-000635-notice-pdf-2026-10-04',
   exact: 'To a solution of D-Ribofuranose tetra-acetate in acetonitrile, gaseous hydrogen chloride is slowly charged.',
   qh: 'sha256:6144584dd36a48f8d0f9a0367ebcc377c360a77eeecb7c0837c23be1717bdb63'},
  {l: 'hu:locator:grn-635-step-1-nicotinamide', sn: 'hu:snapshot:fda-grn-000635-notice-pdf-2026-10-04',
   exact: 'With the reaction confirmed complete, a slurry of nicotinamide in acetonitrile is charged and stirred until the reaction to Nicotinamide-D-Riboside Chloride is complete.',
   qh: 'sha256:9eda8aa62c06515766656fdc47778c97259ea89fbf5abaf5c86157279a4ad8dc'},
  {l: 'hu:locator:grn-635-step-2', sn: 'hu:snapshot:fda-grn-000635-notice-pdf-2026-10-04',
   exact: 'Nicotinamide-beta-riboside triacetate chloride is slurried into methanol and chilled. While maintaining the solution chilled, ammonium hydroxide is slowly added',
   qh: 'sha256:2b573b94fb2ce37374fae8c86788a88ade2b2745248831ceac1f359bace88000'},
  {l: 'hu:locator:grn-635-step-2-mtbe', sn: 'hu:snapshot:fda-grn-000635-notice-pdf-2026-10-04',
   exact: 'The solution is placed under vacuum to strip the excess ammonia then methyl t-butyl ether is charged to precipitate the product.',
   qh: 'sha256:e9b32b71d3d37e37623096681b2189bac0da68e377fa5e8fe90bf340e285ddd2'},
  {l: 'hu:locator:efsa-2019-table-2', sn: 'hu:snapshot:efsa-journal-2019-5775-2026-10-04',
   exact: 'The specifications of the NF as proposed by the applicant are indicated in Table 2.',
   qh: 'sha256:844008013365c5341621b557fca49d546bb87558f23d246a22dd6a42f607d318'},
  {l: 'hu:locator:efsa-2019-shelf-life-spec', sn: 'hu:snapshot:efsa-journal-2019-5775-2026-10-04',
   exact: 'a specification of not less than 90% has been set to account for the degradation of nicotinamide riboside chloride over the course of shelf-life.',
   qh: 'sha256:0856d843a6aac5872433378b4dd2a183b32446333b7bf1d65cf5fd39c4e59035'},
  {l: 'hu:locator:niagen-pr-usp-monograph-enforced-oct-2026', sn: 'hu:snapshot:niagen-investors-usp-monograph-2026-2026-10-04',
   exact: 'The monograph is available in USP’s compendia with a license and is expected to be codified and enforced in October 2026.',
   qh: 'sha256:5044b855908d3642a02435ac6b204944247900f3147a1e53556eb69e9198bcda'}
] AS row
MATCH (sn:SourceSnapshot {uid: row.sn})
MERGE (l:SourceLocator:InformationArtifact {uid: row.l})
SET l.privacyClass = coalesce(l.privacyClass, 'PUBLIC'), l.id = coalesce(l.id, split(l.uid, ':')[2]), l.artifactType = 'SOURCE_LOCATOR', l.selectorKind = 'TEXT_QUOTE', l.exact = row.exact, l.quoteHash = row.qh,
    l.normalizationVersion = 'NFC-WS1', l.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (sn)-[:HAS_LOCATOR]->(l);

// ---------------------------------------------------------------------------------------------------------------
// Section 2: identities (W01 organizations; W02 materials and substances, referenced; W11 specs and process)
// ---------------------------------------------------------------------------------------------------------------

// status: run
UNWIND [
  ['hu:org:niagen-bioscience-inc', 'Niagen Bioscience (formerly ChromaDex)'],
  ['hu:org:united-states-pharmacopeia', 'United States Pharmacopeial Convention (USP)']
] AS p
MERGE (o:Organization:Entity {uid: p[0]})
ON CREATE SET o.privacyClass = coalesce(o.privacyClass, 'PUBLIC'), o.id = coalesce(o.id, split(o.uid, ':')[2]), o.name = p[1], o.createdAt = datetime('2026-10-04T01:05:00Z')
SET o.entityType = 'ORGANIZATION';

// Same material uid as the round-0005 fixture; W02 owns the BrandedIngredientMaterial specialization label.
// status: run
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:niagen-nrc'})
ON CREATE SET m.privacyClass = coalesce(m.privacyClass, 'PUBLIC'), m.id = coalesce(m.id, split(m.uid, ':')[2]), m.name = 'Niagen nicotinamide riboside chloride (food and supplement grade)', m.createdAt = datetime('2026-10-04T01:05:00Z')
SET m:BrandedIngredientMaterial, m.entityType = 'INGREDIENT_MATERIAL', m.materialKind = coalesce(m.materialKind, 'CHEMICALLY_DEFINED_MATERIAL');

// Nicotinamide: a dietary-ingredient material identity; the SAME uid is a process input below and a component material
// in a (synthetic) formulation, never a second 'Material' node.
// status: run
MERGE (m:IngredientMaterial:Entity {uid: 'hu:material:nicotinamide-usp-grade'})
SET m.privacyClass = coalesce(m.privacyClass, 'PUBLIC'), m.id = coalesce(m.id, split(m.uid, ':')[2]), m.name = 'Nicotinamide (niacinamide)', m.entityType = 'INGREDIENT_MATERIAL', m.materialKind = 'CHEMICALLY_DEFINED_MATERIAL',
    m.createdAt = datetime('2026-10-04T01:05:00Z');

// Non-ingredient chemical inputs and the isolated intermediate: substance identities (W02 ChemicalSubstance).
// status: run
UNWIND [
  ['hu:substance:d-ribofuranose-tetraacetate', 'D-ribofuranose tetra-acetate'],
  ['hu:substance:acetonitrile', 'Acetonitrile'],
  ['hu:substance:hydrogen-chloride', 'Hydrogen chloride'],
  ['hu:substance:nicotinamide-riboside-triacetate-chloride', 'Nicotinamide-beta-riboside triacetate chloride'],
  ['hu:substance:methanol', 'Methanol'],
  ['hu:substance:ammonium-hydroxide', 'Ammonium hydroxide'],
  ['hu:substance:methyl-tert-butyl-ether', 'Methyl tert-butyl ether'],
  ['hu:substance:acetone', 'Acetone']
] AS p
MERGE (x:ChemicalSubstance:Entity {uid: p[0]})
SET x.privacyClass = coalesce(x.privacyClass, 'PUBLIC'), x.id = coalesce(x.id, split(x.uid, ':')[2]), x.preferredName = p[1], x.name = p[1], x.entityType = 'CHEMICAL_SUBSTANCE', x.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
MERGE (p:ManufacturingProcess:Entity {uid: 'hu:process:nrc-two-step-synthesis-as-described-grn-000635'})
SET p.privacyClass = coalesce(p.privacyClass, 'PUBLIC'), p.id = coalesce(p.id, split(p.uid, ':')[2]), p.name = 'Nicotinamide riboside chloride two-step synthesis (as described in GRN 000635, 2015)', p.entityType = 'MANUFACTURING_PROCESS',
    p.processKind = 'CHEMICAL_SYNTHESIS', p.createdAt = datetime('2026-10-04T01:05:00Z');

// status: run
UNWIND [
  {s: 'hu:process-step:nrc-grn-635-step-1', n: 'Step 1: glycosylation of nicotinamide with D-ribofuranose triacetate chloride', k: 'REACTION', o: 0},
  {s: 'hu:process-step:nrc-grn-635-step-2', n: 'Step 2: deacetylation with ammonium hydroxide in methanol; MTBE precipitation; centrifugation; washes', k: 'DEACETYLATION_OR_DEPROTECTION', o: 1}
] AS row
MATCH (p:ManufacturingProcess {uid: 'hu:process:nrc-two-step-synthesis-as-described-grn-000635'})
MERGE (st:ManufacturingStep:Entity {uid: row.s})
SET st.privacyClass = coalesce(st.privacyClass, 'PUBLIC'), st.id = coalesce(st.id, split(st.uid, ':')[2]), st.name = row.n, st.stepKind = row.k, st.entityType = 'MANUFACTURING_STEP', st.createdAt = datetime('2026-10-04T01:05:00Z')
MERGE (p)-[h:HAS_STEP]->(st)
SET h.orderIndex = row.o;

// status: run
UNWIND [
  {u: 'hu:specification:niagen-ingredient-specification', n: 'Niagen (NRC) ingredient specification', k: 'INGREDIENT_SUPPLIER_SPECIFICATION'},
  {u: 'hu:specification:usp-nicotinamide-riboside-chloride-monograph', n: 'USP Nicotinamide Riboside Chloride dietary supplement monograph', k: 'COMPENDIAL_MONOGRAPH'}
] AS row
MERGE (s:ManufacturingSpecification:Entity {uid: row.u})
SET s.privacyClass = coalesce(s.privacyClass, 'PUBLIC'), s.id = coalesce(s.id, split(s.uid, ':')[2]), s.name = row.n, s.specificationKind = row.k, s.entityType = 'MANUFACTURING_SPECIFICATION', s.createdAt = datetime('2026-10-04T01:05:00Z');

// ---------------------------------------------------------------------------------------------------------------
// Section 3: specification versions (payloadHash over canonical JSON incl. criteriaDigest) and W12 criteria
// ---------------------------------------------------------------------------------------------------------------

// status: run
UNWIND [
  {v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', s: 'hu:specification:niagen-ingredient-specification',
   n: 'Niagen specification as stated in the GRN 000635 dossier (2015-12-21)', cc: 'PARTIAL_EXCERPT', cnt: 4,
   dg: 'sha256:120562d71bc797c19a9341d92cdb34f1c7d29b5312590ef423f29563e1088ffa',
   ph: 'sha256:41860ee3eb39be3fca71d864fba620f512987f9b6d23619ac83c27fecdbd7c30',
   ef: null, efp: null},
  {v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', s: 'hu:specification:niagen-ingredient-specification',
   n: 'Niagen specification as proposed by the applicant to EFSA (EFSA Journal 2019;17(8):5775, Table 2)', cc: 'PARTIAL_EXCERPT', cnt: 4,
   dg: 'sha256:95969c52e84766283c860ff054cbede18cf133e329402fb092da3b48be871813',
   ph: 'sha256:477c82091cddad8f74504b210bb1e64775acb49f19d5de58854dc610ae1080ca',
   ef: null, efp: null},
  {v: 'hu:specification-version:usp-nrcl-monograph-official-2026-10', s: 'hu:specification:usp-nicotinamide-riboside-chloride-monograph',
   n: 'USP NRCl monograph, official October 2026 (as announced)', cc: 'UNKNOWN', cnt: null, dg: null,
   ph: 'sha256:70a7017bebccedac57118c435184dab3b0132431cb395c07e426a94713464519',
   ef: datetime('2026-10-01T00:00:00Z'), efp: 'MONTH'}
] AS row
MATCH (s:ManufacturingSpecification {uid: row.s})
MERGE (v:SpecificationVersion:VersionedState {uid: row.v})
SET v.privacyClass = coalesce(v.privacyClass, 'PUBLIC'), v.id = coalesce(v.id, split(v.uid, ':')[2]), v.name = row.n, v.stateType = 'SPECIFICATION_VERSION', v.payloadHash = row.ph, v.criteriaCaptureCompleteness = row.cc,
    v.criteriaCount = row.cnt, v.criteriaDigest = row.dg, v.effectiveFrom = row.ef, v.effectiveFromPrecision = row.efp,
    v.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (v)-[:VERSION_OF_SPECIFICATION]->(s);

// W12-owned criteria (provisional field names; see header).
// status: run
UNWIND [
  {c: 'hu:specification-criterion:niagen-2015-purity', v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', a: 'nicotinamide riboside chloride (purity)', cmp: 'RANGE_INCLUSIVE', t: 95.0, tu: 102.0, u: '%', m: 'HPLC (99.1-CD-3.0-000591)', ls: 'NOT_STATED', ph: 'sha256:4caa6f49577f5eedb02b2e8a5cbbbd6b62ba2e4aa89e4825fe1af8be945f35f0'},
  {c: 'hu:specification-criterion:niagen-2015-water', v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', a: 'water', cmp: 'LE', t: 1.0, tu: null, u: '%', m: '99.1-CD-6.0-000094', ls: 'NOT_STATED', ph: 'sha256:4ba2ca2606b01b3b31175165bd5e3e619ef51f2391f8dddcba18bffbc27f0f0f'},
  {c: 'hu:specification-criterion:niagen-2015-acetone', v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', a: 'acetone', cmp: 'LE', t: 3000.0, tu: null, u: 'mg/kg', m: '99.1-CD-7.0-000115', ls: 'NOT_STATED', ph: 'sha256:4c486a6a148b968dd00d7d31baf00546ecfd18e53e8a3f2a7abe8c301ce54bb4'},
  {c: 'hu:specification-criterion:niagen-2015-methanol', v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', a: 'methanol', cmp: 'LE', t: 740.0, tu: null, u: 'mg/kg', m: '99.1-CD-7.0-000115', ls: 'NOT_STATED', ph: 'sha256:77151fc37d342ec6b48655896a4bf23641e86af485c72e1d2804c8788a627f15'},
  {c: 'hu:specification-criterion:niagen-2019-nrc', v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', a: 'nicotinamide riboside chloride', cmp: 'GE', t: 90.0, tu: null, u: '%', m: 'HPLC-UV', ls: 'SHELF_LIFE', ph: 'sha256:e1372f6b5b2fc033cbd43d9c3f84a4d35b78768b1d7095e95ae15b539694979f'},
  {c: 'hu:specification-criterion:niagen-2019-water', v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', a: 'water', cmp: 'LE', t: 2.0, tu: null, u: '%', m: 'Karl Fischer titration (USP <921>)', ls: 'NOT_STATED', ph: 'sha256:d509d91e247e73f7168f9d3bed6e3c9f75ab1a604da43d5ddbf24022dadc1857'},
  {c: 'hu:specification-criterion:niagen-2019-acetone', v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', a: 'acetone', cmp: 'LE', t: 5000.0, tu: null, u: 'mg/kg', m: 'GC headspace (USP <467>)', ls: 'NOT_STATED', ph: 'sha256:5a784bb3ec6e91e6aa47a044bc1c588ed5aabc39bba6bdc2e32257c6aa12db41'},
  {c: 'hu:specification-criterion:niagen-2019-methanol', v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', a: 'methanol', cmp: 'LE', t: 1000.0, tu: null, u: 'mg/kg', m: 'GC headspace (USP <467>)', ls: 'NOT_STATED', ph: 'sha256:b0f70192235b60154b0767b25f2016d646ab79c3f0f0fc0cc150a524fa61853b'}
] AS row
MATCH (v:SpecificationVersion {uid: row.v})
MERGE (c:SpecificationCriterion:VersionedState {uid: row.c})
SET c.privacyClass = coalesce(c.privacyClass, 'PUBLIC'), c.id = coalesce(c.id, split(c.uid, ':')[2]), c.stateType = 'SPECIFICATION_CRITERION', c.analyte = row.a, c.comparator = row.cmp, c.threshold = row.t,
    c.thresholdUpper = row.tu, c.unitCode = row.u, c.methodText = row.m, c.limitStage = row.ls, c.payloadHash = row.ph,
    c.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (c)-[:CRITERION_OF_SPECIFICATION]->(v);

// ---------------------------------------------------------------------------------------------------------------
// Section 4: asserted edges (each the projection of exactly one Assertion)
// ---------------------------------------------------------------------------------------------------------------

// GOVERNED_BY_SPECIFICATION: two episodes, one material, two versions of one specification. The start and end of each
// version are not public: bounds null (OBSERVATION_ONLY / UNKNOWN). V-W11-07b lists the POSSIBLE overlap for review;
// V-W11-07 (definite overlap) returns zero rows. Asserter: Niagen Bioscience (applicant/notifier) in both sources.
// status: run
UNWIND [
  {a: 'hu:assertion:niagen-nrc-governed-by-spec-grn-2015', ch: 'sha256:91a95721dd0c713bc1bcbb2367e386f605516062891c1d4d76c30b4aed28d188', v: 'hu:specification-version:niagen-spec-as-stated-grn-000635-2015', l: 'hu:locator:grn-635-table-2-specifications', rel: 'hu:rel:niagen-nrc-governed-by-spec-grn-2015', rs: 'STATES'},
  {a: 'hu:assertion:niagen-nrc-governed-by-spec-efsa-2019', ch: 'sha256:e07086c5790e066ffc20937ca5567159de051535e4691e2ecf79ff3a60611b68', v: 'hu:specification-version:niagen-spec-as-proposed-efsa-2019', l: 'hu:locator:efsa-2019-table-2', rel: 'hu:rel:niagen-nrc-governed-by-spec-efsa-2019', rs: 'REPORTS'}
] AS row
MATCH (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'}), (v:SpecificationVersion {uid: row.v}),
      (o:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: row.l})
MERGE (a:Assertion {uid: row.a})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'GOVERNED_BY_SPECIFICATION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER', a.contentHash = row.ch, a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(m)
MERGE (a)-[:HAS_OBJECT]->(v)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (m)-[g:GOVERNED_BY_SPECIFICATION {relationshipUid: row.rel}]->(v)
SET g.assertionUid = a.uid, g.validFromBasis = 'OBSERVATION_ONLY', g.validToBasis = 'UNKNOWN', g.recordedFrom = datetime('2026-10-04T01:10:00Z');

// Specification ownership is a predicate-only assertion (organizations OWNS_SPECIFICATION); no typed edge.
// status: run
MATCH (o:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (s:ManufacturingSpecification {uid: 'hu:specification:niagen-ingredient-specification'}),
      (l:SourceLocator {uid: 'hu:locator:efsa-2019-table-2'})
MERGE (a:Assertion {uid: 'hu:assertion:niagen-owns-niagen-ingredient-specification'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'OWNS_SPECIFICATION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.predicateClass = 'COMMERCIAL',
    a.contentHash = 'sha256:dfc69a98a4b1d57d42692ea8667bb6559ccc51cf8a52aaead55a8fd0f3facbcf', a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(o)
MERGE (a)-[:HAS_OBJECT]->(s)
MERGE (a)-[:SUPPORTED_BY]->(l);

// PRODUCED_BY_PROCESS: the dossier describes how Niagen NRC is produced. No PERFORMS_PROCESS is asserted for the
// specification owner (the FY2025 10-K names W.R. Grace as single NRC supplier): OWNS_SPECIFICATION never implies it.
// status: run
MATCH (m:IngredientMaterial {uid: 'hu:material:niagen-nrc'}), (p:ManufacturingProcess {uid: 'hu:process:nrc-two-step-synthesis-as-described-grn-000635'}),
      (o:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: 'hu:locator:grn-635-step-1'})
MERGE (a:Assertion {uid: 'hu:assertion:niagen-nrc-produced-by-grn-635-synthesis'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'PRODUCED_BY_PROCESS', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER',
    a.contentHash = 'sha256:cf1567003a8ee09eb8023e9b1d0e9354ddb0f1ec2f89b6d4269c05d17de5b6c6', a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(m)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (m)-[r:PRODUCED_BY_PROCESS {relationshipUid: 'hu:rel:niagen-nrc-produced-by-grn-635-synthesis'}]->(p)
SET r.assertionUid = a.uid, r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:10:00Z');

// INPUTS / OUTPUTS on steps (ProcessIoProperties). Targets: IngredientMaterial (nicotinamide) or ChemicalSubstance.
// status: run
UNWIND [
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-1', x: 'hu:substance:d-ribofuranose-tetraacetate', role: 'STARTING_MATERIAL', rep: 'D-Ribofuranose tetra-acetate', l: 'hu:locator:grn-635-step-1', o: 0},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-1', x: 'hu:substance:acetonitrile', role: 'SOLVENT', rep: 'acetonitrile', l: 'hu:locator:grn-635-step-1', o: 1},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-1', x: 'hu:substance:hydrogen-chloride', role: 'REAGENT', rep: 'gaseous hydrogen chloride', l: 'hu:locator:grn-635-step-1', o: 2},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-1', x: 'hu:material:nicotinamide-usp-grade', role: 'STARTING_MATERIAL', rep: 'nicotinamide', l: 'hu:locator:grn-635-step-1-nicotinamide', o: 3},
  {t: 'OUTPUTS', st: 'hu:process-step:nrc-grn-635-step-1', x: 'hu:substance:nicotinamide-riboside-triacetate-chloride', role: 'INTERMEDIATE', rep: 'Nicotinamide-D-Riboside Chloride (triacetate)', l: 'hu:locator:grn-635-step-1-nicotinamide', o: 0},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-2', x: 'hu:substance:nicotinamide-riboside-triacetate-chloride', role: 'INTERMEDIATE', rep: 'Nicotinamide-beta-riboside triacetate chloride', l: 'hu:locator:grn-635-step-2', o: 0},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-2', x: 'hu:substance:methanol', role: 'SOLVENT', rep: 'methanol', l: 'hu:locator:grn-635-step-2', o: 1},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-2', x: 'hu:substance:ammonium-hydroxide', role: 'REAGENT', rep: 'ammonium hydroxide', l: 'hu:locator:grn-635-step-2', o: 2},
  {t: 'INPUTS',  st: 'hu:process-step:nrc-grn-635-step-2', x: 'hu:substance:methyl-tert-butyl-ether', role: 'PROCESSING_AID', rep: 'methyl t-butyl ether', l: 'hu:locator:grn-635-step-2-mtbe', o: 3}
] AS row
MATCH (st:ManufacturingStep {uid: row.st}), (x {uid: row.x}), (o:Organization {uid: 'hu:org:niagen-bioscience-inc'}), (l:SourceLocator {uid: row.l})
WHERE x:IngredientMaterial OR x:ChemicalSubstance
WITH row, st, x, o, l, 'hu:assertion:' + toLower(row.t) + '-' + split(row.st, ':')[2] + '-' + split(row.x, ':')[2] AS auid
MERGE (a:Assertion {uid: auid})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = row.t, a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.polarity = 'POSITIVE', a.speechAct = 'STATES',
    a.assertionBasis = 'MANUFACTURER_CLAIM', a.predicateClass = 'OTHER', a.contentHash = 'synthetic:' + auid,
    a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:HAS_OBJECT]->(x)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l)
WITH row, st, x, a
CALL (row, st, x, a) {
  WITH row, st, x, a WHERE row.t = 'INPUTS'
  MERGE (st)-[r:INPUTS {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(x)
  SET r.assertionUid = a.uid, r.ioRole = row.role, r.asReportedName = row.rep, r.orderIndex = row.o,
      r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:10:00Z')
  UNION
  WITH row, st, x, a WHERE row.t = 'OUTPUTS'
  MERGE (st)-[r:OUTPUTS {relationshipUid: 'hu:rel:' + split(a.uid, ':')[2]}]->(x)
  SET r.assertionUid = a.uid, r.ioRole = row.role, r.asReportedName = row.rep, r.orderIndex = row.o,
      r.validFromBasis = 'OBSERVATION_ONLY', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:10:00Z')
};

// Same-uid demonstration (W04 shapes, synthetic): nicotinamide as a formulation component material. One node is reached by
// INPUTS (process input) and by USES_MATERIAL (ingredient use); no live 'Material' node exists.
// status: run
MERGE (fv:FormulationVersion:VersionedState {uid: 'hu:formulation:synthetic-b-vitamin-blend-v1'})
SET fv.privacyClass = coalesce(fv.privacyClass, 'PUBLIC'), fv.id = coalesce(fv.id, split(fv.uid, ':')[2]), fv.stateType = 'FORMULATION_VERSION', fv.payloadHash = 'sha256:77eae088cfb632719896d14eab3d29dc03a8700ef32e3aeacb0d30866e101b3b', fv.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (ic:IngredientComponent:VersionedState {uid: 'hu:component:synthetic-b-vitamin-blend-v1-niacinamide'})
SET ic.privacyClass = coalesce(ic.privacyClass, 'PUBLIC'), ic.id = coalesce(ic.id, split(ic.uid, ':')[2]), ic.stateType = 'INGREDIENT_COMPONENT', ic.payloadHash = 'sha256:74e6d1a66d4bc15aefc49c8aaadceba22fef0e38891e211d7b3ca133711b2087', ic.declaredAs = 'Niacinamide',
    ic.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (fv)-[:HAS_INGREDIENT_COMPONENT]->(ic);

// status: run
MATCH (ic:IngredientComponent {uid: 'hu:component:synthetic-b-vitamin-blend-v1-niacinamide'}), (m:IngredientMaterial {uid: 'hu:material:nicotinamide-usp-grade'})
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-niacinamide-component-uses-material'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'USES_MATERIAL', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.contentHash = 'sha256:6de97dddd17f317b36031141ce2495cbd35fb35b389f818d8f97d9408d69bc5a',
    a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(ic)
MERGE (a)-[:HAS_OBJECT]->(m)
MERGE (ic)-[r:USES_MATERIAL {relationshipUid: 'hu:rel:synthetic-niacinamide-component-uses-material'}]->(m)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T01:10:00Z');

// USP monograph: the version exists (effective October 2026 as announced, MONTH precision); NOT linked to niagen-nrc by
// GOVERNED_BY_SPECIFICATION: a monograph governs any NRCl that claims conformance; no conformance assertion was captured.
// The announcement is a press release by the sponsor, so the version is captured without criteria (UNKNOWN).
// status: run
MATCH (v:SpecificationVersion {uid: 'hu:specification-version:usp-nrcl-monograph-official-2026-10'}), (o:Organization {uid: 'hu:org:niagen-bioscience-inc'}),
      (l:SourceLocator {uid: 'hu:locator:niagen-pr-usp-monograph-enforced-oct-2026'})
MERGE (a:Assertion {uid: 'hu:assertion:niagen-pr-usp-monograph-official-oct-2026'})
SET a.privacyClass = coalesce(a.privacyClass, 'PUBLIC'), a.id = coalesce(a.id, split(a.uid, ':')[2]), a.predicate = 'SPECIFICATION_EFFECTIVE_FROM', a.status = 'PROPOSED', a.recordedAt = datetime('2026-10-04T01:10:00Z'),
    a.valueString = 'expected to be codified and enforced in October 2026', a.statedTense = 'FUTURE',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.contentHash = 'sha256:a4c14c16571418194564065d06b369f8e2f4e92fe40783f5501aef9920778e70',
    a.createdAt = datetime('2026-10-04T01:10:00Z')
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:ASSERTED_BY]->(o)
MERGE (a)-[:SUPPORTED_BY]->(l);

// status: run
MATCH (a:Assertion)
WHERE (a.uid STARTS WITH 'hu:assertion:niagen-nrc-governed' OR a.uid STARTS WITH 'hu:assertion:niagen-owns'
       OR a.uid STARTS WITH 'hu:assertion:niagen-nrc-produced' OR a.uid STARTS WITH 'hu:assertion:inputs-nrc'
       OR a.uid STARTS WITH 'hu:assertion:outputs-nrc')
  AND a.status IN ['ACCEPTED', 'REJECTED', 'DISPUTED']
  AND NOT EXISTS { MATCH (:Adjudication {adjudicationKind: 'CAPTURE_FIDELITY'})-[:EVALUATES]->(a) }
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w11-f03-capture-fidelity-policy'})
ON CREATE SET j.privacyClass = coalesce(j.privacyClass, 'PUBLIC'), j.id = coalesce(j.id, split(j.uid, ':')[2]), j.assessmentType = 'ADJUDICATION', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
    j.reviewerType = 'POLICY', j.methodVersion = 'w11-fixture-capture-policy-1', j.status = 'ACCEPTED',
    j.reviewedAt = datetime('2026-10-04T01:40:00Z'), j.recordedAt = datetime('2026-10-04T01:40:00Z'),
    j.rationale = 'Fixture capture policy: propositions match the cited spans as read by W11.', j.privacyClass = 'INTERNAL',
    j.createdAt = datetime('2026-10-04T01:40:00Z')
MERGE (j)-[:EVALUATES]->(a);
