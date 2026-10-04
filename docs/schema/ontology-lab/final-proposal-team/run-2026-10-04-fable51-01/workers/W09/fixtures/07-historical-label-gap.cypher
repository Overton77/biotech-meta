// =====================================================================================================================
// W09 fixture 07: historical label gap (CQ-ID-02 qualified, CQ-ID-01). The NRPT trial ran 2016-01 .. 2016-07 (registry
// start/primary completion, MONTH precision). The only Basis label known to the graph was observed 2026-07-10 (INHERITED
// uids from examples/elysium-basis.cypher and study-vs-product-mismatch.cypher; not re-retrieved). Its formulation has an
// UNKNOWN start, so "which formulation applied during administration" is answered OVERLAP_START_UNKNOWN, never "the
// current one" and never "none". The paper's "commercially known as Basis" is a literal ADMINISTERED_AS_COMMERCIAL_PRODUCT
// assertion on the intervention; no edge joins study-side records to the product (INV-201).
// Minimal pair (SYNTHETIC): a variant whose formulation start is stated (2015-06) covers the window if still true.
// Expected: QS-W09-09 -> Basis: OVERLAP_START_UNKNOWN; synthetic: COVERS_INTERVAL_IF_STILL_TRUE. V-201 0 rows.
// =====================================================================================================================

// 1. Study conduct period as an assertion (registry dates; STATED_BY_SOURCE at MONTH precision).
MATCH (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (loc:SourceLocator {uid: 'hu:locator:ctgov-nct02678611-2026-10-04-record'})
MERGE (a:Assertion {uid: 'hu:assertion:nct02678611-conducted-during'})
  ON CREATE SET a.id = 'nct02678611-conducted-during', a.predicate = 'STUDY_CONDUCTED_DURING', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.validFrom = datetime('2016-01-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE',
                a.validTo = datetime('2016-07-01T00:00:00Z'), a.validToPrecision = 'MONTH', a.validToBasis = 'STATED_BY_SOURCE',
                a.recordedAt = datetime('2026-10-04T01:20:00Z'), a.contentHash = 'sha256:synthetic-nct02678611-conducted-during', a.createdAt = datetime('2026-10-04T01:20:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(st)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 2. "commercially known as Basis": literal naming assertion on the intervention (the paper's abstract wording).
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'})
MERGE (loc:SourceLocator:InformationArtifact {uid: 'hu:locator:pubmed-29184669-abstract-commercially-known'})
  ON CREATE SET loc.id = 'pubmed-29184669-abstract-commercially-known', loc.artifactType = 'SourceLocator', loc.uri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/',
                loc.selectorKind = 'TEXT_QUOTE', loc.exact = 'a repeat dose of NRPT (commercially known as Basis)', loc.createdAt = datetime('2026-10-04T01:20:00Z'), loc.privacyClass = 'PUBLIC'
MERGE (src:Source:Entity {uid: 'hu:source:pubmed-29184669'})
  ON CREATE SET src.id = 'pubmed-29184669', src.entityType = 'Source', src.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/', src.createdAt = datetime('2026-10-04T01:20:00Z'), src.privacyClass = 'PUBLIC'
MERGE (snap:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:pubmed-29184669-2026-10-04'})
  ON CREATE SET snap.id = 'pubmed-29184669-2026-10-04', snap.artifactType = 'SourceSnapshot', snap.canonicalUri = 'https://pubmed.ncbi.nlm.nih.gov/29184669/',
                snap.retrievedAt = datetime('2026-10-04T00:56:00Z'), snap.observedAt = datetime('2026-10-04T00:56:00Z'), snap.contentHash = 'synthetic:pubmed-29184669-2026-10-04',
                snap.contentHashBasis = 'SYNTHETIC_FIXTURE', snap.captureCompleteness = 'PARTIAL_EXCERPT', snap.createdAt = datetime('2026-10-04T01:20:00Z'), snap.privacyClass = 'PUBLIC'
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc)
MERGE (a:Assertion {uid: 'hu:assertion:nct02678611-nrpt-administered-as-basis'})
  ON CREATE SET a.id = 'nct02678611-nrpt-administered-as-basis', a.predicate = 'ADMINISTERED_AS_COMMERCIAL_PRODUCT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.valueString = 'Basis', a.recordedAt = datetime('2026-10-04T01:20:00Z'), a.contentHash = 'sha256:synthetic-administered-as-basis',
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:20:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(si)
MERGE (a)-[:SUPPORTED_BY]->(loc);

// 3. The current Basis variant and the formulation version observed on 2026-07-10 (start UNKNOWN -> OBSERVATION_ONLY, null bound).
MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:basis-us-capsule-standard'})
  ON CREATE SET v.id = 'basis-us-capsule-standard', v.entityType = 'ProductVariant', v.name = 'Basis - US capsules', v.createdAt = datetime('2026-10-04T01:20:00Z'), v.privacyClass = 'PUBLIC'
MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:basis-us-current-2026-07-10'})
  ON CREATE SET f.id = 'basis-us-current-2026-07-10', f.stateType = 'FormulationVersion', f.payloadHash = 'sha256:synthetic-basis-us-current-2026-07-10',
                f.versionName = 'Basis current US label observed 2026-07-10', f.createdAt = datetime('2026-10-04T01:20:00Z'), f.privacyClass = 'PUBLIC'
MERGE (lsrc:Source:Entity {uid: 'hu:source:elysium-basis-supplement-facts'})
  ON CREATE SET lsrc.id = 'elysium-basis-supplement-facts', lsrc.entityType = 'Source', lsrc.canonicalUri = 'https://www.elysiumhealth.com/pages/basis-supplement-facts',
                lsrc.sourceKind = 'MANUFACTURER_LABEL_PAGE', lsrc.createdAt = datetime('2026-10-04T01:20:00Z'), lsrc.privacyClass = 'PUBLIC'
MERGE (lsnap:SourceSnapshot:InformationArtifact {uid: 'hu:snapshot:elysium-basis-label-2026-07-10'})
  ON CREATE SET lsnap.id = 'elysium-basis-label-2026-07-10', lsnap.artifactType = 'SourceSnapshot', lsnap.retrievedAt = datetime('2026-07-10T00:00:00Z'),
                lsnap.observedAt = datetime('2026-07-10T00:00:00Z'), lsnap.contentHash = 'synthetic:elysium-basis-label-2026-07-10', lsnap.contentHashBasis = 'SYNTHETIC_FIXTURE',
                lsnap.captureCompleteness = 'UNKNOWN', lsnap.createdAt = datetime('2026-10-04T01:20:00Z'), lsnap.privacyClass = 'PUBLIC'
MERGE (lloc:SourceLocator:InformationArtifact {uid: 'hu:locator:elysium-basis-label-supplement-facts-panel-2026-07-10'})
  ON CREATE SET lloc.id = 'elysium-basis-label-supplement-facts-panel-2026-07-10', lloc.artifactType = 'SourceLocator', lloc.selectorKind = 'SECTION',
                lloc.section = 'Supplement Facts', lloc.createdAt = datetime('2026-10-04T01:20:00Z'), lloc.privacyClass = 'PUBLIC'
MERGE (lsrc)-[:HAS_SNAPSHOT]->(lsnap)
MERGE (lsnap)-[:HAS_LOCATOR]->(lloc)
MERGE (a:Assertion {uid: 'hu:assertion:w09-basis-variant-has-formulation-2026-07-10'})
  ON CREATE SET a.id = 'w09-basis-variant-has-formulation-2026-07-10', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'ACCEPTED', a.polarity = 'POSITIVE',
                a.validFromBasis = 'OBSERVATION_ONLY', a.validToBasis = 'UNKNOWN', a.recordedAt = datetime('2026-10-04T01:20:00Z'),
                a.contentHash = 'sha256:synthetic-basis-hfv', a.createdAt = datetime('2026-10-04T01:20:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (a)-[:SUPPORTED_BY]->(lloc)
MERGE (v)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:w09-basis-variant-has-formulation-2026-07-10'}]->(f)
  ON CREATE SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFromBasis = 'OBSERVATION_ONLY', e.validToBasis = 'UNKNOWN';

// 4. SYNTHETIC minimal pair: a variant whose formulation start is stated (2015-06, MONTH) and end unknown.
MERGE (v:ProductVariant:Entity {uid: 'hu:product-variant:synthetic-known-start-variant'})
  ON CREATE SET v.id = 'synthetic-known-start-variant', v.entityType = 'ProductVariant', v.name = 'SYNTHETIC variant with dated formulation', v.createdAt = datetime('2026-10-04T01:20:00Z'), v.privacyClass = 'PUBLIC'
MERGE (f:FormulationVersion:VersionedState {uid: 'hu:formulation:synthetic-known-start-2015-06'})
  ON CREATE SET f.id = 'synthetic-known-start-2015-06', f.stateType = 'FormulationVersion', f.payloadHash = 'sha256:synthetic-known-start-2015-06',
                f.versionName = 'SYNTHETIC formulation stated to start 2015-06', f.createdAt = datetime('2026-10-04T01:20:00Z'), f.privacyClass = 'PUBLIC'
MERGE (a:Assertion {uid: 'hu:assertion:synthetic-known-start-variant-has-formulation'})
  ON CREATE SET a.id = 'synthetic-known-start-variant-has-formulation', a.predicate = 'HAS_FORMULATION_VERSION', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
                a.validFrom = datetime('2015-06-01T00:00:00Z'), a.validFromPrecision = 'MONTH', a.validFromBasis = 'STATED_BY_SOURCE', a.validToBasis = 'UNKNOWN',
                a.recordedAt = datetime('2026-10-04T01:20:00Z'), a.contentHash = 'sha256:synthetic-known-start-hfv', a.createdAt = datetime('2026-10-04T01:20:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(v)
MERGE (a)-[:HAS_OBJECT]->(f)
MERGE (v)-[e:HAS_FORMULATION_VERSION {relationshipUid: 'hu:rel:synthetic-known-start-variant-has-formulation'}]->(f)
  ON CREATE SET e.assertionUid = a.uid, e.recordedFrom = a.recordedAt, e.validFrom = a.validFrom, e.validFromPrecision = 'MONTH', e.validFromBasis = 'STATED_BY_SOURCE', e.validToBasis = 'UNKNOWN';

// 5. Capture-fidelity adjudication for the real assertions of this file.
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:nct02678611-conducted-during', 'hu:assertion:nct02678611-nrpt-administered-as-basis', 'hu:assertion:w09-basis-variant-has-formulation-2026-07-10']
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-07-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-07-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:20:00Z'), j.recordedAt = datetime('2026-10-04T01:20:00Z'), j.createdAt = datetime('2026-10-04T01:20:00Z'), j.privacyClass = 'PUBLIC'
MERGE (j)-[:EVALUATES]->(a);

// 6. NRPT arms' components (paper Methods; INHERITED quote from round 0002 / study-vs-product-mismatch.cypher:
//    "250 mg of NR (2 capsules x 125 mg)", "50 mg of PT"). Mass basis UNSPECIFIED: the paper says "NR", not salt vs cation.
//    Material: the trial-time NR whose supplier is UNRESOLVED (competing ResolutionHypothesis records live in the inherited fixture).
UNWIND [
  {ic: 'hu:intervention-component:nct02678611-1x-nr', mat: 'hu:material:nct02678611-nr-as-supplied', matName: 'NR as administered in NCT02678611 (supplier unresolved)', qty: 250.0, txt: '250 mg of NR (2 capsules x 125 mg)'},
  {ic: 'hu:intervention-component:nct02678611-1x-pt', mat: 'hu:material:nct02678611-pt-as-supplied', matName: 'Pterostilbene as administered in NCT02678611 (supplier unresolved)', qty: 50.0, txt: '50 mg of PT (2 capsules x 25 mg)'}
] AS r
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'})
MERGE (mat:IngredientMaterial:Entity {uid: r.mat})
  ON CREATE SET mat.id = split(r.mat, ':')[2], mat.entityType = 'IngredientMaterial', mat.name = r.matName, mat.createdAt = datetime('2026-10-04T01:20:00Z'), mat.privacyClass = 'PUBLIC'
MERGE (ic:InterventionComponent:VersionedState {uid: r.ic})
  ON CREATE SET ic.id = split(r.ic, ':')[2], ic.stateType = 'InterventionComponent', ic.payloadHash = 'sha256:synthetic-' + split(r.ic, ':')[2],
                ic.quantity = r.qty, ic.unitCode = 'mg/d', ic.quantityBasis = 'PER_DAY', ic.massBasis = 'UNSPECIFIED', ic.quantityStatus = 'REPORTED',
                ic.verbatimDoseText = r.txt, ic.createdAt = datetime('2026-10-04T01:20:00Z'), ic.privacyClass = 'PUBLIC'
MERGE (si)-[:HAS_INTERVENTION_COMPONENT]->(ic)
MERGE (a:Assertion {uid: 'hu:assertion:uses-material-' + split(r.ic, ':')[2]})
  ON CREATE SET a.id = 'uses-material-' + split(r.ic, ':')[2], a.predicate = 'USES_INTERVENTION_MATERIAL', a.status = 'PROPOSED', a.polarity = 'POSITIVE',
                a.recordedAt = datetime('2026-10-04T01:20:00Z'), a.contentHash = 'sha256:synthetic-uses-material-' + split(r.ic, ':')[2],
                a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:20:00Z'), a.privacyClass = 'PUBLIC'
MERGE (a)-[:HAS_SUBJECT]->(ic)
MERGE (a)-[:HAS_OBJECT]->(mat)
MERGE (ic)-[u:USES_INTERVENTION_MATERIAL]->(mat)
  ON CREATE SET u.relationshipUid = 'hu:rel:uses-material-' + split(r.ic, ':')[2], u.assertionUid = a.uid, u.recordedFrom = a.recordedAt,
                u.validFromBasis = 'UNKNOWN', u.validToBasis = 'UNKNOWN', u.asReportedName = 'NRPT';
