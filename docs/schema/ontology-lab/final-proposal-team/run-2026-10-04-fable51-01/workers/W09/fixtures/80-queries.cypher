// =====================================================================================================================
// W09 queries: inherited validators (V-2xx, verbatim from neo4j/validation.cypher), proposed W09 validators (V-W09-xx and
// the proposed V-217i / V-221r replacements), and CQ query shapes (QS-W09-xx) with literal parameters for the fixtures.
// Run on Neo4j 5.26.31 Community (embedded harness) on 2026-10-04; expected rows are in 06-fixtures-and-queries.md.
// Zero rows = valid for V-*; QS-* return answers.
// =====================================================================================================================

// V-201 (INV-201, FI-201) verbatim.
MATCH (s)-[r]->(p)
WHERE (s:Study OR s:StudyArm OR s:StudyIntervention OR s:StudyResult OR s:Publication)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion)
RETURN s.uid AS studySide, type(r) AS rel, p.uid AS commercialTarget;

// V-202 (R1) verbatim.
MATCH (ic:InterventionComponent)-[u:USES_INTERVENTION_MATERIAL]->(v:ProductVariant)
WHERE u.asReportedName IS NULL
RETURN ic.uid AS component, v.uid AS variantWithoutReportedName;

// V-210 (INV-208) verbatim.
MATCH (s:Study)
WHERE (s.overallStatus IS NOT NULL OR s.enrollmentCount IS NOT NULL OR s.hasResults IS NOT NULL)
      AND s.projectionOfRegistrationVersionUid IS NULL
   OR s.pmid IS NOT NULL OR s.doi IS NOT NULL OR s.evidenceLevel IS NOT NULL
RETURN s.uid AS studyWithMisplacedFields;

// V-211 verbatim.
MATCH (rv:RegistrationVersion)
OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
WITH rv, count(r) AS owners
WHERE owners <> 1 OR rv.observedAt IS NULL
RETURN rv.uid AS registrationVersion, owners;

// V-211r (PROPOSED, W09-CR-03): frozen V-211 counts paths, so a registration version with two recorded-time episodes
// (closed e1 + re-bounded e1b, the round 0007 shape) reports owners = 2. Count distinct registrations instead.
MATCH (rv:RegistrationVersion)
OPTIONAL MATCH (r:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv)
WITH rv, count(DISTINCT r) AS owners
WHERE owners <> 1 OR rv.observedAt IS NULL
RETURN rv.uid AS registrationVersion, owners;

// V-212 (FI-203) verbatim, informational.
MATCH (s:Study)-[:REGISTERED_AS]->(:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv:RegistrationVersion {resultsPosted: false}),
      (pub:Publication {publicationKind: 'ARTICLE'})-[:REPORTS_ON]->(s)
RETURN s.uid AS study, rv.observedAt AS observedAt, pub.pmid AS resultsArticle;

// V-213 (INV-209) verbatim.
MATCH (r:StudyResult)
WHERE r.isClinicallyMeaningful IS NOT NULL AND r.interpretationUid IS NULL
RETURN r.uid AS resultWithUnattributedMeaningfulness;

// V-215 (INV-206) verbatim.
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT {inputRole: 'CONFIRMATORY'}]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE r.analysisKind <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind = 'WITHIN_ARM_CHANGE'
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
RETURN syn.uid AS synthesis, r.uid AS nonPrimaryConfirmatory, p.uid AS nullPrimary;

// V-215r (PROPOSED, W09-CR-04): INV-206 in full. After a NOT_SIGNIFICANT primary prespecified result, any secondary, subgroup,
// exploratory, post hoc or within-arm result of the same study may enter a synthesis only as SUPPORTIVE or
// HYPOTHESIS_GENERATING (frozen V-215 checks CONFIRMATORY only and misses INDEPENDENT_REPLICATION). SAFETY analyses exempt.
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE (r.analysisKind IN ['SECONDARY_PRESPECIFIED', 'SUBGROUP_PRESPECIFIED', 'SUBGROUP_POST_HOC', 'EXPLORATORY'] OR r.comparisonKind = 'WITHIN_ARM_CHANGE')
  AND NOT inc.inputRole IN ['SUPPORTIVE', 'HYPOTHESIS_GENERATING']
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
RETURN syn.uid AS synthesis, r.uid AS nonPrimaryInput, inc.inputRole AS role, p.uid AS nullPrimary;

// V-216 (FI-207) verbatim.
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r:StudyResult {comparisonKind: 'WITHIN_ARM_CHANGE'})
WHERE inc.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION']
RETURN syn.uid AS synthesis, r.uid AS withinArmResult, inc.inputRole AS role;

// V-217 (INV-207) verbatim (frozen).
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod IS NULL OR (ae.participantsAffected = 0 AND ae.collectionMethod = 'NOT_DESCRIBED')
RETURN ae.uid AS aeResult, ae.participantsAffected AS affected, ae.collectionMethod AS method;

// V-217r (PROPOSED, W09-CR-01): hard rule. A reported AE row needs a collection method; a zero needs one too.
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod IS NULL
RETURN ae.uid AS aeResultWithoutCollectionMethod, ae.eventCount AS eventCount, ae.participantsAffected AS affected;

// V-217i (PROPOSED, W09-CR-01): informational. Reported zeros whose collection method the source does not describe; answers
// must say "zero reported; collection method not described". Rows expected for the Basis and ENERGIZE serious-AE zeros.
MATCH (ae:AdverseEventResult)
WHERE ae.collectionMethod = 'NOT_DESCRIBED' AND (ae.participantsAffected = 0 OR ae.eventCount = 0)
RETURN ae.uid AS zeroWithUndescribedCollection, ae.collectionMethodText AS sourceWording;

// V-218 (CQ-ST-07) verbatim.
MATCH (syn:EvidenceSynthesis)-[i1:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r1:StudyResult),
      (syn)-[i2:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r2:StudyResult)
WHERE r1.uid < r2.uid
MATCH (r1)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s1:Study),
      (r2)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s2:Study)
WHERE s1 = s2
   OR EXISTS { MATCH (s1)-[:PRODUCED_DATASET]->(ds:Dataset)<-[:ANALYZES_DATASET]-(:Publication)-[:REPORTS_ON]->(s2) }
   OR EXISTS { MATCH (s1)-[:PRODUCED_DATASET]->(ds:Dataset)<-[:PRODUCED_DATASET]-(s2) }
RETURN syn.uid AS synthesis, r1.uid AS result1, r2.uid AS result2;

// V-221 (R1) verbatim (frozen).
MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
WHERE arm.armType <> 'PLACEBO_COMPARATOR'
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
WITH si, ic
WHERE ic IS NULL
   OR ic.massBasis IS NULL OR ic.quantityBasis IS NULL
   OR (ic.quantity IS NULL AND coalesce(ic.quantityStatus, '') <> 'NOT_REPORTED')
   OR (ic.quantity IS NOT NULL AND ic.unitCode IS NULL)
RETURN si.uid AS intervention, ic.uid AS incompleteComponent;

// V-221r (PROPOSED, W09-CR-02): null armType is checked; sham/no-intervention arms exempt; a component needs bases only when
// its amount is REPORTED; a definition-only intervention (FOLLOWS_INTERVENTION_DEFINITION, no component) is complete;
// a device component needs its device target and quantityStatus NOT_APPLICABLE.
MATCH (arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
WHERE NOT coalesce(arm.armType, 'UNKNOWN') IN ['PLACEBO_COMPARATOR', 'SHAM_COMPARATOR', 'NO_INTERVENTION']
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
WITH si, ic, EXISTS { MATCH (si)-[:FOLLOWS_INTERVENTION_DEFINITION]->() } AS hasDefinition
WITH si, ic, hasDefinition,
     CASE WHEN ic IS NULL THEN null ELSE EXISTS { MATCH (ic)-[:USES_INTERVENTION_DEVICE]->(:Device) } END AS isDevice
WHERE (ic IS NULL AND NOT hasDefinition)
   OR (ic IS NOT NULL AND isDevice AND coalesce(ic.quantityStatus, '') <> 'NOT_APPLICABLE')
   OR (ic IS NOT NULL AND NOT isDevice AND ic.quantityStatus IS NULL AND ic.quantity IS NULL)
   OR (ic IS NOT NULL AND NOT isDevice AND coalesce(ic.quantityStatus, 'REPORTED') = 'REPORTED'
       AND (ic.quantity IS NULL OR ic.unitCode IS NULL OR ic.quantityBasis IS NULL OR ic.massBasis IS NULL))
RETURN si.uid AS intervention, ic.uid AS incompleteComponent;

// V-223 (CQ-ST-04) verbatim, informational.
MATCH (a:Assertion {predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:HAS_SUBJECT]->(od:OutcomeDefinition)
WITH od, collect(DISTINCT a.valueString) AS priorities
WHERE size(priorities) > 1
RETURN od.uid AS outcome, priorities;

// V-W09-01: derived isStatisticallySignificant agrees with statisticalConclusion (StudyResult and AdverseEventResult).
MATCH (r:StudyResult)
WITH r, CASE r.statisticalConclusion WHEN 'SIGNIFICANT_FAVORABLE' THEN true WHEN 'SIGNIFICANT_UNFAVORABLE' THEN true WHEN 'NOT_SIGNIFICANT' THEN false ELSE null END AS expected
WHERE r.isStatisticallySignificant IS NOT NULL AND (expected IS NULL OR r.isStatisticallySignificant <> expected)
RETURN r.uid AS resultWithInconsistentDerivedSignificance, r.statisticalConclusion AS conclusion, r.isStatisticallySignificant AS stored;

// V-W09-02: the Study registry cache names a RegistrationVersion of one of its own registrations and matches it.
MATCH (s:Study) WHERE s.projectionOfRegistrationVersionUid IS NOT NULL
OPTIONAL MATCH (s)-[:REGISTERED_AS]->(:TrialRegistration)-[:HAS_REGISTRATION_VERSION]->(rv:RegistrationVersion {uid: s.projectionOfRegistrationVersionUid})
WITH s, rv WHERE rv IS NULL OR coalesce(s.overallStatus, '') <> coalesce(rv.overallStatus, '') OR coalesce(s.enrollmentCount, -1) <> coalesce(rv.enrollmentCount, -1)
RETURN s.uid AS studyWithStaleOrForeignRegistryCache;

// V-W09-03: an InterventionComponent targets at most one administered thing (material, variant, lot or device).
MATCH (ic:InterventionComponent)
OPTIONAL MATCH (ic)-[:USES_INTERVENTION_MATERIAL|USES_INTERVENTION_DEVICE]->(t)
WITH ic, count(DISTINCT t) AS targets
WHERE targets > 1
RETURN ic.uid AS componentWithSeveralTargets, targets;

// V-W09-04: CORRECTS/RETRACTS name an existing SourceRevisionEvent of a matching kind that revises a rendition of the target.
MATCH (n:Publication)-[e:CORRECTS|RETRACTS]->(p:Publication)
OPTIONAL MATCH (ev:SourceRevisionEvent {uid: e.sourceRevisionEventUid})-[:REVISES_SOURCE]->(:Source)-[:RENDITION_OF]->(p)
WITH n, e, p, ev
WHERE ev IS NULL
   OR (type(e) = 'CORRECTS' AND NOT ev.revisionKind IN ['ERRATUM', 'CORRECTED_AND_REPUBLISHED'])
   OR (type(e) = 'RETRACTS' AND ev.revisionKind <> 'RETRACTION')
RETURN n.uid AS notice, type(e) AS rel, p.uid AS target, e.sourceRevisionEventUid AS namedEvent;

// V-W09-05 (FI REGISTRY_RESULTS_NOT_POSTED -> RESULTS_UNPUBLISHED): no "results unpublished" assertion rests on registry flags only.
MATCH (a:Assertion {predicate: 'RESULTS_UNPUBLISHED'})
WHERE NOT EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) WHERE s.sourceKind <> 'REGULATORY_RECORD' }
RETURN a.uid AS unpublishedInferredFromRegistryOnly;

// V-W09-06 (W00 FI CORRECTS_SOURCE -> FACT_CEASED, publication view): a supersession driven by an erratum/retraction is never VALIDITY_BOUNDED.
MATCH (n)-[s:SUPERSEDES]->(o)
WHERE s.supersessionKind = 'VALIDITY_BOUNDED' AND s.sourceRevisionEventUid IS NOT NULL
MATCH (ev:SourceRevisionEvent {uid: s.sourceRevisionEventUid}) WHERE ev.revisionKind IN ['ERRATUM', 'CORRECTED_AND_REPUBLISHED', 'RETRACTION']
RETURN n.uid AS newer, o.uid AS older, ev.revisionKind AS revision;

// V-W09-07: derived OutcomeDefinition.priority projects a registry-sourced DECLARES_OUTCOME_PRIORITY assertion about it.
MATCH (od:OutcomeDefinition) WHERE od.priority IS NOT NULL
OPTIONAL MATCH (a:Assertion {uid: od.priorityAssertionUid, predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:HAS_SUBJECT]->(od)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH od, a, collect(src.sourceKind) AS kinds
WHERE a IS NULL OR a.valueString <> od.priority OR NOT 'REGULATORY_RECORD' IN kinds
RETURN od.uid AS outcomeWithUngroundedPriority;

// V-W09-08: an AdverseEventResult has exactly one INTERVENTION arm.
MATCH (ae:AdverseEventResult)
OPTIONAL MATCH (ae)-[r:RESULT_FOR_ARM]->(:StudyArm) WHERE r.armRole = 'INTERVENTION'
WITH ae, count(r) AS n WHERE n <> 1
RETURN ae.uid AS aeResultArmCount, n;

// V-W09-09 (warning): materialized doi/pmid on a Publication without the matching Identifier record.
MATCH (p:Publication) WHERE p.doi IS NOT NULL
  AND NOT EXISTS { MATCH (p)-[:HAS_IDENTIFIER]->(i:Identifier {scheme: 'DOI'}) WHERE toLower(i.value) = toLower(p.doi) }
RETURN p.uid AS publicationWithoutDoiIdentifier;

// V-W09-10: asserted W09 edges carry the asserted_edge profile (INV-101).
MATCH ()-[e:REGISTERED_AS|ASSIGNS_INTERVENTION|USES_INTERVENTION_MATERIAL|USES_INTERVENTION_DEVICE|FOLLOWS_INTERVENTION_DEFINITION|REPORTS_ON|PRODUCED_DATASET|ANALYZES_DATASET|CORRECTS|RETRACTS|INVESTIGATES|STUDIED_IN]->()
WHERE e.assertionUid IS NULL OR e.recordedFrom IS NULL OR e.relationshipUid IS NULL OR e.validFromBasis IS NULL OR e.validToBasis IS NULL
   OR (type(e) = 'ANALYZES_DATASET' AND e.analysisRole IS NULL)
RETURN type(e) AS rel, e.relationshipUid AS edge;

// V-W09-11: derived study role projections cite their rule and inputs (INV-104); never written as asserted.
MATCH (:Study)-[d:SPONSORED_BY|OPERATED_BY|INVESTIGATED_BY]->()
WHERE d.assertionUid IS NOT NULL OR (d.projectionOfAssertionUid IS NULL AND (d.derivationRule IS NULL OR size(coalesce(d.derivedFromAssertionUids, [])) = 0))
RETURN type(d) AS rel, d.derivationRule AS rule;

// QS-W09-01 (CQ-ST-08, CQ-ST-C03): registry versions believed at R about V (bitemporal episode slice). Literal R/V for the
// synthetic registration: R = 2026-10-04, V = 2026-06-01 -> v1 (validTo 2026-08-15 known); change V to 2026-09-01 -> v2.
MATCH (reg:TrialRegistration {uid: 'hu:trial-registration:synthetic-demo-001'})-[e:HAS_REGISTRATION_VERSION]->(rv:RegistrationVersion)
WITH rv, e, datetime('2026-10-04T02:00:00Z') AS R, datetime('2026-06-01T00:00:00Z') AS V
WHERE e.recordedFrom <= R AND (e.recordedTo IS NULL OR R < e.recordedTo)
WITH rv, e, V,
     CASE WHEN e.validFrom IS NOT NULL AND e.validFrom > V THEN 'EXCLUDED'
          WHEN e.validTo IS NOT NULL AND e.validTo <= V THEN 'EXCLUDED'
          WHEN e.validFrom IS NULL AND e.validTo IS NULL THEN 'UNKNOWN_BOTH_BOUNDS'
          WHEN e.validFrom IS NULL THEN 'UNKNOWN_START'
          WHEN e.validTo IS NOT NULL THEN 'KNOWN_WITHIN'
          WHEN rv.observedAt >= V THEN 'OPEN_END_SUPPORTED' ELSE 'OPEN_END_STALE' END AS validityClass
WHERE validityClass <> 'EXCLUDED'
RETURN rv.uid AS version, rv.overallStatus AS status, rv.resultsPosted AS resultsPosted, rv.enrollmentCount AS enrollment,
       rv.enrollmentCountType AS enrollmentType, validityClass, rv.observedAt AS observedAt, rv.versionDate AS versionDate;

// QS-W09-02 (CQ-ST-01, CQ-ST-C01, CQ-ST-C02): what each arm received, whatever the intervention kind.
MATCH (:Study {uid: 'hu:study:nct02582593-tnirs-older-adults'})-[:HAS_ARM]->(arm:StudyArm)-[:ASSIGNS_INTERVENTION]->(si:StudyIntervention)
OPTIONAL MATCH (si)-[:HAS_INTERVENTION_COMPONENT]->(ic:InterventionComponent)
OPTIONAL MATCH (ic)-[u:USES_INTERVENTION_MATERIAL|USES_INTERVENTION_DEVICE]->(t)
OPTIONAL MATCH (si)-[:FOLLOWS_INTERVENTION_DEFINITION]->(def)
RETURN arm.name AS arm, arm.armType AS armType, si.route AS route, si.dosageForm AS form, si.schedule AS schedule, si.durationIso AS duration,
       ic.quantity AS quantity, ic.unitCode AS unit, ic.quantityBasis AS quantityBasis, ic.massBasis AS massBasis, ic.quantityStatus AS quantityStatus,
       ic.verbatimDoseText AS verbatim, [l IN labels(t) WHERE NOT l IN ['Entity', 'VersionedState']][0] AS targetKind, t.name AS target, u.asReportedName AS asReported, def.name AS definition
ORDER BY arm;

// QS-W09-03 (CQ-ST-05): when the primary is null, list the favorable non-primary findings and how syntheses use them.
MATCH (st:Study {uid: 'hu:study:nct03464500-atlas'})-[:DEFINES_OUTCOME]->(pod:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED'})
WHERE p.statisticalConclusion = 'NOT_SIGNIFICANT'
MATCH (st)-[:DEFINES_OUTCOME]->(od:OutcomeDefinition)<-[:RESULT_FOR]-(r:StudyResult)
WHERE r.statisticalConclusion = 'SIGNIFICANT_FAVORABLE' AND (r.analysisKind <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind <> 'BETWEEN_ARM')
OPTIONAL MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(r)
RETURN p.uid AS nullPrimary, od.name AS outcome, r.uid AS favorableResult, r.analysisKind AS analysisKind, r.comparisonKind AS comparisonKind,
       r.multiplicityAdjusted AS multiplicityAdjusted, syn.uid AS synthesis, inc.inputRole AS inputRole
ORDER BY favorableResult;

// QS-W09-04 (CQ-ST-04): per-source priority of each outcome (registry vs paper) and the derived registered priority.
MATCH (od:OutcomeDefinition)<-[:HAS_SUBJECT]-(a:Assertion {predicate: 'DECLARES_OUTCOME_PRIORITY'})-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
RETURN od.name AS outcome, src.canonicalUri AS source, src.sourceKind AS sourceKind, a.valueString AS declaredPriority, od.priority AS derivedRegisteredPriority
ORDER BY outcome, sourceKind;

// QS-W09-05 (CQ-ST-06): AE rows per arm with collection method, and studies with no AE record (not reported, never zero).
MATCH (st:Study)
OPTIONAL MATCH (st)-[:HAS_ARM]->(arm:StudyArm)<-[:RESULT_FOR_ARM]-(ae:AdverseEventResult)
WITH st, collect(CASE WHEN ae IS NULL THEN null ELSE {arm: arm.name, term: ae.eventTerm, seriousness: ae.seriousness, affected: ae.participantsAffected,
     events: ae.eventCount, atRisk: ae.participantsAtRisk, method: ae.collectionMethod, wording: ae.collectionMethodText} END) AS rows
RETURN st.uid AS study, CASE WHEN size(rows) = 0 THEN 'NO_AE_RECORD_CAPTURED' ELSE 'AE_ROWS_CAPTURED' END AS aeReporting, size(rows) AS aeRows,
       [x IN rows WHERE x.seriousness = 'SERIOUS'] AS seriousRows
ORDER BY study;

// QS-W09-06 (CQ-EV-05): corrections/retractions of a publication, the revision event, and assertions superseded by it.
MATCH (n:Publication)-[e:CORRECTS|RETRACTS]->(p:Publication {pmid: '29184669'})
MATCH (ev:SourceRevisionEvent {uid: e.sourceRevisionEventUid})
OPTIONAL MATCH (ev)-[:ANNOUNCED_IN]->(ann:SourceSnapshot)
OPTIONAL MATCH (newer:Assertion)-[s:SUPERSEDES {sourceRevisionEventUid: ev.uid}]->(older:Assertion)
RETURN n.pmid AS notice, n.publicationKind AS noticeKind, type(e) AS rel, ev.revisionKind AS revisionKind, ann.publishedAt AS announcedAt,
       ev.recordedAt AS learnedAt, older.uid AS supersededAssertion, s.supersessionKind AS supersession, newer.uid AS replacingAssertion;

// QS-W09-07 (CQ-ST-07): publication pairs that are NOT independent (shared study or dataset).
MATCH (p1:Publication)-[:REPORTS_ON|ANALYZES_DATASET]->(x)<-[:REPORTS_ON|ANALYZES_DATASET]-(p2:Publication)
WHERE p1.uid < p2.uid
RETURN p1.pmid AS pub1, p2.pmid AS pub2, collect(DISTINCT [l IN labels(x) WHERE l IN ['Study', 'Dataset']][0]) AS sharedThrough;

// QS-W09-08 (CQ-AX-05): independence count of studies behind a synthesis's results: lines by study/dataset; shared sponsors flagged.
MATCH (syn:EvidenceSynthesis {uid: 'hu:synthesis:ua-muscle-performance-replication-v1'})-[:INCLUDES_RESULT]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
OPTIONAL MATCH (st)-[:PRODUCED_DATASET]->(ds:Dataset)
OPTIONAL MATCH (st)-[:SPONSORED_BY]->(org:Organization)
WITH syn, collect(DISTINCT coalesce(ds.uid, st.uid)) AS lines, collect(DISTINCT st.uid) AS studies, collect(DISTINCT [st.uid, org.name]) AS pairs
UNWIND pairs AS pr
WITH syn, lines, studies, pr[1] AS sponsor, count(DISTINCT pr[0]) AS nStudies
WITH syn, lines, studies, collect(CASE WHEN sponsor IS NOT NULL AND nStudies > 1 THEN sponsor END) AS sharedSponsors
RETURN syn.uid AS synthesis, size(lines) AS independentLinesLowerBound, studies, sharedSponsors;

// QS-W09-09 (CQ-ID-02): which formulation of a variant applied during the study's conduct window (QS-2b-interval adapted).
MATCH (:Study {uid: 'hu:study:nct02678611-basis-nrpt'})<-[:HAS_SUBJECT]-(c:Assertion {predicate: 'STUDY_CONDUCTED_DURING'})
MATCH (v:ProductVariant)-[r:HAS_FORMULATION_VERSION]->(f:FormulationVersion)
WHERE v.uid IN ['hu:product-variant:basis-us-capsule-standard', 'hu:product-variant:synthetic-known-start-variant']
  AND r.recordedFrom <= datetime('2026-10-04T02:00:00Z') AND (r.recordedTo IS NULL OR datetime('2026-10-04T02:00:00Z') < r.recordedTo)
WITH v, f, r, c.validFrom AS iStart, c.validTo AS iEnd,
     CASE WHEN r.validTo IS NOT NULL AND r.validTo <= c.validFrom THEN 'EXCLUDED'
          WHEN r.validFrom IS NOT NULL AND r.validFrom >= c.validTo THEN 'EXCLUDED'
          WHEN r.validFrom IS NULL THEN 'OVERLAP_START_UNKNOWN'
          WHEN r.validFrom <= c.validFrom AND r.validTo IS NULL THEN 'COVERS_INTERVAL_IF_STILL_TRUE'
          WHEN r.validFrom <= c.validFrom AND r.validTo >= c.validTo THEN 'COVERS_INTERVAL'
          ELSE 'PARTIAL_OVERLAP' END AS overlapClass
WHERE overlapClass <> 'EXCLUDED'
RETURN v.uid AS variant, f.uid AS formulation, overlapClass, r.validFrom AS formulationFrom, r.validFromBasis AS fromBasis, iStart, iEnd
ORDER BY variant;

// QS-W09-10 (CQ-ID-01, CQ-EV-04 precondition): how a study intervention relates to a marketed product name -- only via
// assertions, never an edge; reports the absence of any direct study-side edge.
MATCH (si:StudyIntervention {uid: 'hu:intervention:nct02678611-nrpt-1x'})
OPTIONAL MATCH (a:Assertion {predicate: 'ADMINISTERED_AS_COMMERCIAL_PRODUCT'})-[:HAS_SUBJECT]->(si)
OPTIONAL MATCH (a)-[:SUPPORTED_BY]->(l:SourceLocator)
RETURN si.uid AS intervention, a.valueString AS reportedCommercialName, l.exact AS quote,
       EXISTS { MATCH (si)-[]->(:Product|ProductVariant|FormulationVersion) } AS hasDirectCommercialEdge;

// QS-W09-12 (CQ-EV-03): studies behind a set of results grouped by design kind.
MATCH (r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WITH st.studyKind AS kind, collect(DISTINCT st.uid) AS studies
RETURN kind, size(studies) AS studyCount, studies ORDER BY kind;
