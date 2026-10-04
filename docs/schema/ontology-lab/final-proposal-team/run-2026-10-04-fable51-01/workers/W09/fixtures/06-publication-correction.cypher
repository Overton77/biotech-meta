// =====================================================================================================================
// W09 fixture 06: Publication correction = Publication CORRECTS Publication + W00 SourceRevisionEvent (round 0007), CQ-EV-05.
// Real (PubMed MCP 2026-10-04): PMID 29184669 (article types ["Journal Article"], published 2017-11-24) and PMID 30155270
// ("Erratum: Author Correction: ...", article types ["Journal Article","Published Erratum"], published 2018-08-20; abstract
// "[This corrects the article DOI: 10.1038/s41514-017-0016-9.]"); PMC6102308 full text of the notice (complete). The notice
// states (1) reference 20 was replaced and (2) a sentence naming Elysium Health as provider of the placebo and NRPT was
// added, "corrected in the PDF and HTML versions of the article". No pre-correction capture of the article exists in this
// run: PRIOR_SNAPSHOT is absent (unknown), never invented.
// publicationKind: AUTHOR_CORRECTION (journal designation); PubMed's "Published Erratum" maps to revisionKind ERRATUM.
// Expected: QS-W09-06 returns the correction with its event; V-W09-04 0 rows; V-W09-06 0 rows; no assertion deleted.
// =====================================================================================================================

// 1. Work-level publications.
MERGE (art:Publication:InformationArtifact {uid: 'hu:publication:pmid-29184669'})
  ON CREATE SET art.id = 'pmid-29184669', art.artifactType = 'Publication', art.publicationKind = 'ARTICLE',
                art.name = 'Repeat dose NRPT (nicotinamide riboside and pterostilbene) increases NAD+ levels in humans safely and sustainably: a randomized, double-blind, placebo-controlled study',
                art.doi = '10.1038/s41514-017-0016-9', art.pmid = '29184669', art.pmcid = 'PMC5701244', art.venueName = 'NPJ aging and mechanisms of disease',
                art.publishedAt = datetime('2017-11-24T00:00:00Z'), art.publishedAtPrecision = 'DAY', art.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (cor:Publication:InformationArtifact {uid: 'hu:publication:pmid-30155270'})
  ON CREATE SET cor.id = 'pmid-30155270', cor.artifactType = 'Publication', cor.publicationKind = 'AUTHOR_CORRECTION',
                cor.name = 'Author Correction: Repeat dose NRPT (nicotinamide riboside and pterostilbene) increases NAD+ levels in humans safely and sustainably',
                cor.doi = '10.1038/s41514-018-0027-1', cor.pmid = '30155270', cor.pmcid = 'PMC6102308', cor.venueName = 'NPJ aging and mechanisms of disease',
                cor.publishedAt = datetime('2018-08-20T00:00:00Z'), cor.publishedAtPrecision = 'DAY', cor.createdAt = datetime('2026-10-04T01:15:00Z');

// 2. Rendition Sources (W00) of each work, their snapshots and locators.
UNWIND [
  {src: 'hu:source:doi-10.1038-s41514-017-0016-9', uri: 'https://doi.org/10.1038/s41514-017-0016-9', kind: 'PEER_REVIEWED_PUBLICATION', pub: 'hu:publication:pmid-29184669'},
  {src: 'hu:source:pmc5701244', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', kind: 'PEER_REVIEWED_PUBLICATION', pub: 'hu:publication:pmid-29184669'},
  {src: 'hu:source:doi-10.1038-s41514-018-0027-1', uri: 'https://doi.org/10.1038/s41514-018-0027-1', kind: 'CORRECTION_NOTICE', pub: 'hu:publication:pmid-30155270'},
  {src: 'hu:source:pmc6102308', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6102308/', kind: 'CORRECTION_NOTICE', pub: 'hu:publication:pmid-30155270'},
  {src: 'hu:source:pubmed-30155270', uri: 'https://pubmed.ncbi.nlm.nih.gov/30155270/', kind: null, pub: 'hu:publication:pmid-30155270'}
] AS r
MATCH (p:Publication {uid: r.pub})
MERGE (src:Source:Entity {uid: r.src})
  ON CREATE SET src.id = split(r.src, ':')[2], src.entityType = 'Source', src.canonicalUri = r.uri, src.sourceKind = r.kind, src.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (src)-[:RENDITION_OF]->(p);

UNWIND [
  {src: 'hu:source:pmc6102308', snap: 'hu:snapshot:pmc6102308-2026-10-04', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6102308/', comp: 'COMPLETE', pub: datetime('2018-08-20T00:00:00Z'),
   loc: 'hu:locator:pmc6102308-provider-sentence', exact: 'The matched placebo pills and the investigational product (NRPT) were provided by Elysium Health (New York, NY).'},
  {src: 'hu:source:pmc6102308', snap: 'hu:snapshot:pmc6102308-2026-10-04', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6102308/', comp: 'COMPLETE', pub: datetime('2018-08-20T00:00:00Z'),
   loc: 'hu:locator:pmc6102308-reference-20-original', exact: 'The original version of the published article contained an incorrect citation for reference 20'},
  {src: 'hu:source:pmc6102308', snap: 'hu:snapshot:pmc6102308-2026-10-04', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6102308/', comp: 'COMPLETE', pub: datetime('2018-08-20T00:00:00Z'),
   loc: 'hu:locator:pmc6102308-reference-20-replacement', exact: 'The citation for reference 20 has been changed to'},
  {src: 'hu:source:pmc6102308', snap: 'hu:snapshot:pmc6102308-2026-10-04', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC6102308/', comp: 'COMPLETE', pub: datetime('2018-08-20T00:00:00Z'),
   loc: 'hu:locator:pmc6102308-corrected-in-pdf-html', exact: 'This has now been corrected in the PDF and HTML versions of the article.'},
  {src: 'hu:source:pubmed-30155270', snap: 'hu:snapshot:pubmed-30155270-2026-10-04', uri: 'https://pubmed.ncbi.nlm.nih.gov/30155270/', comp: 'PARTIAL_EXCERPT', pub: null,
   loc: 'hu:locator:pubmed-30155270-corrects-link', exact: '[This corrects the article DOI: 10.1038/s41514-017-0016-9.]'},
  {src: 'hu:source:pmc5701244', snap: 'hu:snapshot:pmc5701244-2026-10-04', uri: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5701244/', comp: 'PARTIAL_EXCERPT', pub: null,
   loc: 'hu:locator:pmc5701244-data-availability', exact: 'The datasets generated and/or analyzed during this study are available from the corresponding author on reasonable request.'}
] AS r
MATCH (src:Source {uid: r.src})
MERGE (snap:SourceSnapshot:InformationArtifact {uid: r.snap})
  ON CREATE SET snap.id = split(r.snap, ':')[2], snap.artifactType = 'SourceSnapshot', snap.canonicalUri = r.uri, snap.retrievedAt = datetime('2026-10-04T01:00:00Z'),
                snap.observedAt = datetime('2026-10-04T01:00:00Z'), snap.publishedAt = r.pub, snap.contentHash = 'synthetic:' + r.snap, snap.contentHashBasis = 'SYNTHETIC_FIXTURE',
                snap.captureCompleteness = r.comp, snap.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (loc:SourceLocator:InformationArtifact {uid: r.loc})
  ON CREATE SET loc.id = split(r.loc, ':')[2], loc.artifactType = 'SourceLocator', loc.uri = r.uri, loc.selectorKind = 'TEXT_QUOTE', loc.exact = r.exact, loc.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (src)-[:HAS_SNAPSHOT]->(snap)
MERGE (snap)-[:HAS_LOCATOR]->(loc);

// 3. The W00 SourceRevisionEvent: ERRATUM revising the article's doi rendition; announced in the notice snapshot; the
//    resulting content is the 2026 PMC capture of the article (captured years later); no prior snapshot (unknown).
MATCH (art:Source {uid: 'hu:source:doi-10.1038-s41514-017-0016-9'}), (notice:SourceSnapshot {uid: 'hu:snapshot:pmc6102308-2026-10-04'}),
      (after:SourceSnapshot {uid: 'hu:snapshot:pmc5701244-2026-10-04'})
MERGE (ev:SourceRevisionEvent:Occurrence {uid: 'hu:source-revision:pmid-29184669-author-correction-2018'})
  ON CREATE SET ev.id = 'pmid-29184669-author-correction-2018', ev.occurrenceType = 'SourceRevisionEvent', ev.revisionKind = 'ERRATUM',
                ev.occurredAt = null, ev.occurredAtPrecision = null,      // the publisher's revision instant is not stated; the notice was published 2018-08-20
                ev.recordedAt = datetime('2026-10-04T01:15:00Z'), ev.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (ev)-[:REVISES_SOURCE]->(art)
MERGE (ev)-[:ANNOUNCED_IN]->(notice)
MERGE (ev)-[:RESULTING_SNAPSHOT]->(after);

// 4. CORRECTS (asserted, publication level) naming the event; plus W00's source-level CORRECTS_SOURCE assertion.
MATCH (cor:Publication {uid: 'hu:publication:pmid-30155270'}), (art:Publication {uid: 'hu:publication:pmid-29184669'}),
      (loc:SourceLocator {uid: 'hu:locator:pubmed-30155270-corrects-link'}), (ev:SourceRevisionEvent {uid: 'hu:source-revision:pmid-29184669-author-correction-2018'}),
      (nsrc:Source {uid: 'hu:source:doi-10.1038-s41514-018-0027-1'}), (asrc:Source {uid: 'hu:source:doi-10.1038-s41514-017-0016-9'})
MERGE (a:Assertion {uid: 'hu:assertion:corrects-30155270-29184669'})
  ON CREATE SET a.id = 'corrects-30155270-29184669', a.predicate = 'CORRECTS', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.recordedAt = datetime('2026-10-04T01:15:00Z'),
                a.contentHash = 'sha256:synthetic-corrects-30155270', a.validFrom = datetime('2018-08-20T00:00:00Z'), a.validFromPrecision = 'DAY', a.validFromBasis = 'PUBLICATION_PROXY',
                a.validToBasis = 'UNKNOWN', a.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a)-[:HAS_SUBJECT]->(cor)
MERGE (a)-[:HAS_OBJECT]->(art)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (cor)-[e:CORRECTS]->(art)
  ON CREATE SET e.relationshipUid = 'hu:rel:corrects-30155270-29184669', e.assertionUid = a.uid, e.recordedFrom = a.recordedAt,
                e.validFrom = a.validFrom, e.validFromPrecision = 'DAY', e.validFromBasis = 'PUBLICATION_PROXY', e.validToBasis = 'UNKNOWN',
                e.sourceRevisionEventUid = ev.uid
MERGE (s:Assertion {uid: 'hu:assertion:corrects-source-doi-30155270-doi-29184669'})
  ON CREATE SET s.id = 'corrects-source-doi-30155270-doi-29184669', s.predicate = 'CORRECTS_SOURCE', s.status = 'ACCEPTED', s.polarity = 'POSITIVE',
                s.recordedAt = datetime('2026-10-04T01:15:00Z'), s.contentHash = 'sha256:synthetic-corrects-source-30155270', s.validFromBasis = 'UNKNOWN', s.validToBasis = 'UNKNOWN',
                s.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (s)-[:HAS_SUBJECT]->(nsrc)
MERGE (s)-[:HAS_OBJECT]->(asrc)
MERGE (s)-[:SUPPORTED_BY]->(loc);

// 5. Content added by the correction: who provided the investigational product (W01 predicate PROVIDES_INVESTIGATIONAL_PRODUCT;
//    the original article was silent, so nothing is superseded; this is NOT SUPPLIES_INGREDIENT_MATERIAL, FI-202).
MATCH (loc:SourceLocator {uid: 'hu:locator:pmc6102308-provider-sentence'}), (arm:StudyArm {uid: 'hu:arm:nct02678611-nrpt-1x'})
MERGE (org:Organization:Entity {uid: 'hu:org:elysium-health-inc'})
  ON CREATE SET org.id = 'elysium-health-inc', org.entityType = 'Organization', org.name = 'Elysium Health', org.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (si:StudyIntervention:VersionedState {uid: 'hu:intervention:nct02678611-nrpt-1x'})
  ON CREATE SET si.id = 'nct02678611-nrpt-1x', si.stateType = 'StudyIntervention', si.payloadHash = 'sha256:synthetic-si-nct02678611-nrpt-1x',
                si.name = 'NRPT 1X: 2 NRPT capsules + 2 placebo capsules daily', si.route = 'ORAL', si.dosageForm = 'CAPSULE', si.dosesPerDay = 1, si.durationIso = 'P8W',
                si.registryInterventionType = null, si.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a:Assertion {uid: 'hu:assertion:elysium-provides-nct02678611-nrpt-1x'})
  ON CREATE SET a.id = 'elysium-provides-nct02678611-nrpt-1x', a.predicate = 'PROVIDES_INVESTIGATIONAL_PRODUCT', a.status = 'ACCEPTED', a.polarity = 'POSITIVE', a.predicateClass = 'ROLE',
                a.recordedAt = datetime('2026-10-04T01:15:00Z'), a.contentHash = 'sha256:synthetic-elysium-provides-1x', a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN',
                a.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a)-[:HAS_SUBJECT]->(org)
MERGE (a)-[:HAS_OBJECT]->(si)
MERGE (a)-[:SUPPORTED_BY]->(loc)
MERGE (aa:Assertion {uid: 'hu:assertion:assigns-nct02678611-nrpt-1x'})
  ON CREATE SET aa.id = 'assigns-nct02678611-nrpt-1x', aa.predicate = 'ASSIGNS_INTERVENTION', aa.status = 'ACCEPTED', aa.polarity = 'POSITIVE', aa.recordedAt = datetime('2026-10-04T01:15:00Z'),
                aa.contentHash = 'sha256:synthetic-assigns-1x', aa.validFromBasis = 'UNKNOWN', aa.validToBasis = 'UNKNOWN', aa.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (aa)-[:HAS_SUBJECT]->(arm)
MERGE (aa)-[:HAS_OBJECT]->(si)
MERGE (aa)-[:SUPPORTED_BY]->(loc)
MERGE (arm)-[e:ASSIGNS_INTERVENTION]->(si)
  ON CREATE SET e.relationshipUid = 'hu:rel:assigns-nct02678611-nrpt-1x', e.assertionUid = aa.uid, e.recordedFrom = aa.recordedAt, e.validFromBasis = 'UNKNOWN', e.validToBasis = 'UNKNOWN';

// 6. Content changed by the correction: reference 20. The original citation (known only through the notice) is a
//    recorded assertion; the corrected citation SUPERSEDES it with SOURCE_CORRECTION and the event uid. Old one kept.
MATCH (art:Publication {uid: 'hu:publication:pmid-29184669'}), (lo:SourceLocator {uid: 'hu:locator:pmc6102308-reference-20-original'}),
      (ln:SourceLocator {uid: 'hu:locator:pmc6102308-reference-20-replacement'}), (ev:SourceRevisionEvent {uid: 'hu:source-revision:pmid-29184669-author-correction-2018'})
MERGE (old:Assertion {uid: 'hu:assertion:pmid-29184669-reference-20-original'})
  ON CREATE SET old.id = 'pmid-29184669-reference-20-original', old.predicate = 'CITES_AS_REFERENCE', old.status = 'SUPERSEDED', old.polarity = 'POSITIVE',
                old.valueString = 'ref 20: Hubbard BP, Sinclair DA. Measurement of sirtuin enzyme activity using a substrate-agnostic fluorometric nicotinamide assay (2013)',
                old.recordedAt = datetime('2026-10-04T01:15:00Z'), old.recordedTo = datetime('2026-10-04T01:15:01Z'), old.contentHash = 'sha256:synthetic-ref20-original',
                old.validFrom = datetime('2017-11-24T00:00:00Z'), old.validFromPrecision = 'DAY', old.validFromBasis = 'PUBLICATION_PROXY', old.validToBasis = 'UNKNOWN',
                old.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (new:Assertion {uid: 'hu:assertion:pmid-29184669-reference-20-corrected'})
  ON CREATE SET new.id = 'pmid-29184669-reference-20-corrected', new.predicate = 'CITES_AS_REFERENCE', new.status = 'ACCEPTED', new.polarity = 'POSITIVE',
                new.valueString = 'ref 20: Cheng Y et al. SIRT1 activation by pterostilbene attenuates the skeletal muscle oxidative stress injury ... (2016)',
                new.recordedAt = datetime('2026-10-04T01:15:01Z'), new.contentHash = 'sha256:synthetic-ref20-corrected',
                new.validFrom = datetime('2017-11-24T00:00:00Z'), new.validFromPrecision = 'DAY', new.validFromBasis = 'PUBLICATION_PROXY', new.validToBasis = 'UNKNOWN',
                new.createdAt = datetime('2026-10-04T01:15:01Z')
MERGE (old)-[:HAS_SUBJECT]->(art)
MERGE (new)-[:HAS_SUBJECT]->(art)
MERGE (old)-[:SUPPORTED_BY]->(lo)
MERGE (new)-[:SUPPORTED_BY]->(ln)
MERGE (new)-[:SUPERSEDES {supersessionKind: 'SOURCE_CORRECTION', recordedAt: datetime('2026-10-04T01:15:01Z'), sourceRevisionEventUid: ev.uid}]->(old);

// 7. Article REPORTS_ON the study; dataset available on request (data availability statement).
MATCH (art:Publication {uid: 'hu:publication:pmid-29184669'}), (st:Study {uid: 'hu:study:nct02678611-basis-nrpt'}), (loc:SourceLocator {uid: 'hu:locator:pmc5701244-data-availability'})
MERGE (ds:Dataset:Entity {uid: 'hu:dataset:nct02678611-participant-data'})
  ON CREATE SET ds.id = 'nct02678611-participant-data', ds.entityType = 'Dataset', ds.name = 'NCT02678611 participant-level data', ds.datasetKind = 'TRIAL_PARTICIPANT_DATA',
                ds.accessLevel = 'ON_REQUEST', ds.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a1:Assertion {uid: 'hu:assertion:reports-on-29184669-nct02678611'})
  ON CREATE SET a1.id = 'reports-on-29184669-nct02678611', a1.predicate = 'REPORTS_ON', a1.status = 'ACCEPTED', a1.polarity = 'POSITIVE', a1.recordedAt = datetime('2026-10-04T01:15:00Z'),
                a1.contentHash = 'sha256:synthetic-reports-on-29184669', a1.validFromBasis = 'UNKNOWN', a1.validToBasis = 'UNKNOWN', a1.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a1)-[:HAS_SUBJECT]->(art)
MERGE (a1)-[:HAS_OBJECT]->(st)
MERGE (a1)-[:SUPPORTED_BY]->(loc)
MERGE (art)-[e1:REPORTS_ON]->(st)
  ON CREATE SET e1.relationshipUid = 'hu:rel:reports-on-29184669-nct02678611', e1.assertionUid = a1.uid, e1.recordedFrom = a1.recordedAt, e1.validFromBasis = 'UNKNOWN', e1.validToBasis = 'UNKNOWN'
MERGE (a2:Assertion {uid: 'hu:assertion:produced-dataset-nct02678611'})
  ON CREATE SET a2.id = 'produced-dataset-nct02678611', a2.predicate = 'PRODUCED_DATASET', a2.status = 'ACCEPTED', a2.polarity = 'POSITIVE', a2.recordedAt = datetime('2026-10-04T01:15:00Z'),
                a2.contentHash = 'sha256:synthetic-produced-dataset-nct02678611', a2.validFromBasis = 'UNKNOWN', a2.validToBasis = 'UNKNOWN', a2.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a2)-[:HAS_SUBJECT]->(st)
MERGE (a2)-[:HAS_OBJECT]->(ds)
MERGE (a2)-[:SUPPORTED_BY]->(loc)
MERGE (st)-[e2:PRODUCED_DATASET]->(ds)
  ON CREATE SET e2.relationshipUid = 'hu:rel:produced-dataset-nct02678611', e2.assertionUid = a2.uid, e2.recordedFrom = a2.recordedAt, e2.validFromBasis = 'UNKNOWN', e2.validToBasis = 'UNKNOWN'
MERGE (a3:Assertion {uid: 'hu:assertion:analyzes-29184669-ds'})
  ON CREATE SET a3.id = 'analyzes-29184669-ds', a3.predicate = 'ANALYZES_DATASET', a3.valueString = 'PRIMARY_REPORT', a3.status = 'ACCEPTED', a3.polarity = 'POSITIVE',
                a3.recordedAt = datetime('2026-10-04T01:15:00Z'), a3.contentHash = 'sha256:synthetic-analyzes-29184669', a3.validFromBasis = 'UNKNOWN', a3.validToBasis = 'UNKNOWN',
                a3.createdAt = datetime('2026-10-04T01:15:00Z')
MERGE (a3)-[:HAS_SUBJECT]->(art)
MERGE (a3)-[:HAS_OBJECT]->(ds)
MERGE (a3)-[:SUPPORTED_BY]->(loc)
MERGE (art)-[e3:ANALYZES_DATASET]->(ds)
  ON CREATE SET e3.relationshipUid = 'hu:rel:analyzes-29184669-ds', e3.assertionUid = a3.uid, e3.recordedFrom = a3.recordedAt, e3.validFromBasis = 'UNKNOWN', e3.validToBasis = 'UNKNOWN',
                e3.analysisRole = 'PRIMARY_REPORT';

// 8. Capture-fidelity adjudication (the superseded reference assertion keeps its earlier adjudication; status is a cache).
MATCH (a:Assertion) WHERE a.uid IN ['hu:assertion:corrects-30155270-29184669', 'hu:assertion:corrects-source-doi-30155270-doi-29184669', 'hu:assertion:elysium-provides-nct02678611-nrpt-1x',
  'hu:assertion:assigns-nct02678611-nrpt-1x', 'hu:assertion:pmid-29184669-reference-20-corrected', 'hu:assertion:reports-on-29184669-nct02678611',
  'hu:assertion:produced-dataset-nct02678611', 'hu:assertion:analyzes-29184669-ds']
MERGE (j:Adjudication:EvidenceAssessment {uid: 'hu:adjudication:w09-fixture-06-capture-policy'})
  ON CREATE SET j.id = 'w09-fixture-06-capture-policy', j.assessmentType = 'Adjudication', j.adjudicationKind = 'CAPTURE_FIDELITY', j.verdict = 'SUPPORTED',
                j.reviewerType = 'POLICY', j.methodVersion = 'w09-fixture-capture-policy-1', j.status = 'ACCEPTED',
                j.reviewedAt = datetime('2026-10-04T01:16:00Z'), j.recordedAt = datetime('2026-10-04T01:16:00Z'), j.createdAt = datetime('2026-10-04T01:16:00Z')
MERGE (j)-[:EVALUATES]->(a);
