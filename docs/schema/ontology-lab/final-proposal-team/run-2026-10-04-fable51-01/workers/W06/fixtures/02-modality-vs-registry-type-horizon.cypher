// =====================================================================================================================
// W06 fixture 02: modality classification versus registry intervention type; concept component versus study-specific
// co-intervention (HORIZON, NCT06597656).
//   - Treatment delandistrogene moxeparvovec (SRP-9001): modalities [GENE_THERAPY] (registry brief title: "A Gene
//     Transfer Therapy"); registry InterventionType GENETIC sits on the StudyIntervention (W09), not on the Treatment.
//   - exa-cel (fixture 01) is registry type BIOLOGICAL yet modalities [CELL_THERAPY, GENE_THERAPY]: a registry type
//     is never mapped onto TreatmentModality.
//   - HORIZON arm receives two StudyInterventions: the gene therapy (GENETIC) and "Plasmapheresis" (PROCEDURE). The
//     plasmapheresis FOLLOWS_INTERVENTION_DEFINITION therapeutic plasma exchange (the brief title equates the two); it is NOT
//     written as USES_COMPONENT of the delandistrogene concept, because the only source is one trial (V-W06-06).
// Requires fixtures 00 and 03 (procedure node is created here with MERGE as well, so order does not matter).
// Rule: every statement binds its own nodes by uid; no variable crosses a ';'.
// =====================================================================================================================

MERGE (t:Treatment:Entity {uid: 'hu:treatment:delandistrogene-moxeparvovec'})
SET t.id = 'delandistrogene-moxeparvovec', t.entityType = 'Treatment', t.name = 'delandistrogene moxeparvovec (SRP-9001)',
    t.modalities = ['GENE_THERAPY'], t.modality = 'GENE_THERAPY', t.treatmentClass = 'AAVrh74-vector gene transfer therapy',
    t.privacyClass = 'PUBLIC', t.maturity = 'PROVISIONAL', t.createdAt = datetime('2026-10-04T02:00:00Z'), t.updatedAt = datetime('2026-10-04T02:00:00Z');

MERGE (p:Procedure:Entity {uid: 'hu:procedure:therapeutic-plasma-exchange'})
SET p.id = 'therapeutic-plasma-exchange', p.entityType = 'Procedure', p.name = 'therapeutic plasma exchange (TPE; plasmapheresis with plasma replacement)',
    p.procedureType = 'apheresis', p.privacyClass = 'PUBLIC', p.maturity = 'PROVISIONAL',
    p.createdAt = datetime('2026-10-04T02:00:00Z'), p.updatedAt = datetime('2026-10-04T02:00:00Z');

MERGE (s:Study:Entity {uid: 'hu:study:nct06597656'})
SET s.entityType = 'Study', s.name = 'HORIZON (NCT06597656)', s.privacyClass = 'PUBLIC', s.createdAt = datetime('2026-10-04T02:00:00Z');

MERGE (a:StudyArm:VersionedState {uid: 'hu:arm:nct06597656-tpe-then-gene-therapy'})
SET a.stateType = 'StudyArm', a.name = 'Plasmapheresis then delandistrogene moxeparvovec (arm name not captured; SYNTHETIC label)',
    a.payloadHash = 'sha256:' + 'synthetic-hu:arm:nct06597656-tpe-then-gene-therapy', a.privacyClass = 'PUBLIC', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z');

UNWIND [
  {uid: 'hu:intervention:nct06597656-delandistrogene', name: 'delandistrogene moxeparvovec', type: 'GENETIC'},
  {uid: 'hu:intervention:nct06597656-plasmapheresis', name: 'Plasmapheresis', type: 'PROCEDURE'}
] AS x
MERGE (si:StudyIntervention:VersionedState {uid: x.uid})
SET si.stateType = 'StudyIntervention', si.name = x.name, si.registryInterventionType = x.type,
    si.payloadHash = 'sha256:' + 'synthetic-' + x.uid, si.privacyClass = 'PUBLIC', si.createdAt = datetime('2026-10-04T02:00:00Z');

MATCH (s:Study {uid: 'hu:study:nct06597656'}), (a:StudyArm {uid: 'hu:arm:nct06597656-tpe-then-gene-therapy'})
MERGE (s)-[:HAS_ARM]->(a);

UNWIND ['hu:intervention:nct06597656-delandistrogene', 'hu:intervention:nct06597656-plasmapheresis'] AS siUid
MATCH (arm:StudyArm {uid: 'hu:arm:nct06597656-tpe-then-gene-therapy'}), (si:StudyIntervention {uid: siUid}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct06597656-interventions'}), (sp:Organization {uid: 'hu:org:sarepta-therapeutics'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-' + substring(siUid, 16) + '-assigned'})
SET a.predicate = 'ASSIGNS_INTERVENTION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(arm)
MERGE (a)-[:HAS_OBJECT]->(si)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (arm)-[r:ASSIGNS_INTERVENTION {relationshipUid: 'hu:rel:w06-' + substring(siUid, 16) + '-assigned'}]->(si)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (si:StudyIntervention {uid: 'hu:intervention:nct06597656-delandistrogene'}), (t:Treatment {uid: 'hu:treatment:delandistrogene-moxeparvovec'}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct06597656-interventions'}), (sp:Organization {uid: 'hu:org:sarepta-therapeutics'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-nct06597656-delandistrogene-instantiates'})
SET a.predicate = 'FOLLOWS_INTERVENTION_DEFINITION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(si)
MERGE (a)-[:HAS_OBJECT]->(t)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (si)-[r:FOLLOWS_INTERVENTION_DEFINITION {relationshipUid: 'hu:rel:w06-nct06597656-delandistrogene-instantiates'}]->(t)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (si:StudyIntervention {uid: 'hu:intervention:nct06597656-plasmapheresis'}), (p:Procedure {uid: 'hu:procedure:therapeutic-plasma-exchange'}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct06597656-title'}), (sp:Organization {uid: 'hu:org:sarepta-therapeutics'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-nct06597656-plasmapheresis-instantiates-tpe'})
SET a.predicate = 'FOLLOWS_INTERVENTION_DEFINITION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'IDENTITY', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(si)
MERGE (a)-[:HAS_OBJECT]->(p)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (si)-[r:FOLLOWS_INTERVENTION_DEFINITION {relationshipUid: 'hu:rel:w06-nct06597656-plasmapheresis-instantiates-tpe'}]->(p)
SET r.assertionUid = a.uid, r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');

MATCH (t:Treatment {uid: 'hu:treatment:delandistrogene-moxeparvovec'}), (c:Condition {uid: 'hu:condition:duchenne-muscular-dystrophy'}),
      (l:SourceLocator {uid: 'hu:locator:ctgov-nct06597656-interventions'}), (sp:Organization {uid: 'hu:org:sarepta-therapeutics'})
MERGE (a:Assertion {uid: 'hu:assertion:w06-delandistrogene-targets-dmd'})
SET a.predicate = 'TARGETS_CONDITION', a.status = 'ACCEPTED', a.recordedAt = datetime('2026-10-04T02:00:00Z'),
    a.polarity = 'POSITIVE', a.predicateClass = 'OTHER', a.speechAct = 'STATES', a.assertionBasis = 'UNSTATED',
    a.validFromBasis = 'UNKNOWN', a.validToBasis = 'UNKNOWN', a.privacyClass = 'PUBLIC', a.createdAt = datetime('2026-10-04T02:00:00Z')
MERGE (a)-[:HAS_SUBJECT]->(t)
MERGE (a)-[:HAS_OBJECT]->(c)
MERGE (a)-[:SUPPORTED_BY]->(l)
MERGE (a)-[:ASSERTED_BY]->(sp)
MERGE (t)-[r:TARGETS_CONDITION {relationshipUid: 'hu:rel:w06-delandistrogene-targets-dmd'}]->(c)
SET r.assertionUid = a.uid, r.intentKind = 'TREATMENT', r.intentBasis = 'TRIAL_REGISTRATION',
    r.indicationTextVerbatim = 'Duchenne Muscular Dystrophy', r.patientSubsetText = 'ambulatory males aged 4 to 8 years with pre-existing antibodies to AAVrh74 (this trial only)',
    r.validFromBasis = 'UNKNOWN', r.validToBasis = 'UNKNOWN', r.recordedFrom = datetime('2026-10-04T02:00:00Z');
