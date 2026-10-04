// =====================================================================================================================
// fable-w5-validators.cypher -- Wave 5 validator corrections compiled from the Challenger reports
// (validation/challengers/CH-W09W10-study-transfer, CH-W23-privacy, CH-W16-protocols, CH-W21W22-media; CH-W00-kernel see
// reports/08-challenger-resolution-matrix.md), run-2026-10-04-fable51-01, Opus 5.5 worker, 2026-10-04.
//
// Contract: one statement per correction; each statement returns rows ONLY on violations (zero rows = valid). Statements
// marked "(review)" return review-queue rows that are violations of a method rule that cannot be checked as a hard
// structural rule (they still return zero rows on the valid fixtures). Every statement binds its own variables; nothing
// crosses ';'. Every row carries `check` = its V-F5 id.
// Parameters: validation/validation-params.json merged with validation/fable-w5-params.json (list keys unioned).
// Not covered here, because Fable fixes them in the SDL / operations / fixtures (cross-reference only): CH-P-02, CH-P-04
// (vector indexes), CH-P-12 (operations section 7), CH-P-16, CH-P-17/CH-R-12 (DiagnosticResult label), CH-P-18, CH-R-04,
// CH-R-05 (DERIVED_FROM_PROTOCOL field), CH-R-13 (HAS_STEP migration and fixture), CH-S-18.
// Retired by this file: kernel V-423 (superseded by V-W21-06 and now by V-F5-47, CL-016), V-201 (-> V-F5-01),
// V-218 (-> V-F5-08), V-215r (-> V-F5-07), V-203 (-> V-F5-05, in addition to the count check), W10-V08 (-> V-F5-06),
// W10-V14 (-> V-F5-18 + V-F5-20), V-604 (-> V-F5-43), V-605 (-> V-F5-41 + V-F5-42), V-W21-06 (-> V-F5-47).
// Tested on embedded Neo4j 5.26.31 Community instances c3, c4, c5; results in reports/08-challenger-resolution-matrix.md.
// =====================================================================================================================

// ------------------------------------------------- study transfer (W09/W10) -------------------------------------------

// V-F5-01 -- resolves CH-S-01, CH-S-02; replaces V-201; rule: no relationship in either direction between a study-side record and a commercial identity, except InterventionComponent -USES_INTERVENTION_MATERIAL-> ProductVariant|ProductLot.
// (V-201r verbatim as tested by the study-transfer Challenger.)
MATCH (s)-[r]-(p)
WHERE (s:Study OR s:StudyArm OR s:StudyIntervention OR s:InterventionComponent OR s:StudyResult OR s:Publication OR s:Dataset
       OR s:OutcomeDefinition OR s:StudyPopulation OR s:RegistrationVersion OR s:TrialRegistration OR s:ProtocolVersion)
  AND (p:Product OR p:ProductVariant OR p:FormulationVersion OR p:PackageConfiguration OR p:ProductLot OR p:MerchantListing
       OR p:Offer OR p:ConsumerBrand OR p:Bundle)
  AND NOT (s:InterventionComponent AND type(r) = 'USES_INTERVENTION_MATERIAL' AND startNode(r) = s AND (p:ProductVariant OR p:ProductLot))
RETURN DISTINCT 'V-F5-01' AS check, s.uid AS studySide, type(r) AS rel, p.uid AS commercial;

// V-F5-02 -- resolves CH-S-02a; extends V-W09-03; rule: USES_INTERVENTION_MATERIAL goes from an InterventionComponent to IngredientMaterial, ProductVariant or ProductLot only (catalog range).
MATCH (ic)-[u:USES_INTERVENTION_MATERIAL]->(m)
WHERE NOT ic:InterventionComponent OR NOT (m:IngredientMaterial OR m:ProductVariant OR m:ProductLot)
RETURN 'V-F5-02' AS check, ic.uid AS component, labels(m) AS targetLabels, m.uid AS target;

// V-F5-03 -- resolves CH-S-03; extends V-202; rule: a ProductVariant used as intervention material is pinned to the formulation as administered: the use carries a known validFrom covered by a current HAS_FORMULATION_VERSION episode of that variant with a known start (or names asAdministeredFormulationVersionUid of that variant).
MATCH (ic:InterventionComponent)-[u:USES_INTERVENTION_MATERIAL]->(v:ProductVariant)
WHERE NOT EXISTS { MATCH (v)-[:HAS_FORMULATION_VERSION]->(f:FormulationVersion) WHERE f.uid = u.asAdministeredFormulationVersionUid }
  AND (u.validFrom IS NULL
       OR NOT EXISTS { MATCH (v)-[h:HAS_FORMULATION_VERSION]->(:FormulationVersion)
                       WHERE h.recordedTo IS NULL AND h.validFrom IS NOT NULL AND h.validFrom <= u.validFrom
                         AND (h.validTo IS NULL OR u.validFrom < h.validTo) })
RETURN 'V-F5-03' AS check, ic.uid AS component, v.uid AS variant, u.validFrom AS usedFrom,
       CASE WHEN u.validFrom IS NULL THEN 'VARIANT_USE_WITHOUT_VALID_FROM' ELSE 'NO_FORMULATION_EPISODE_COVERS_USE' END AS violation;

// V-F5-04 -- resolves CH-S-04b; new (W10-V17); rule: each flat applicability field equals the verdict of its dimension node (identityMatch=MATERIAL_IDENTITY, doseMatch=DOSE|EXPOSURE, routeMatch=ROUTE, scheduleMatch=SCHEDULE, durationMatch=DURATION, populationMatch=POPULATION, outcomeMatch=OUTCOME_RELEVANCE); a flat value without its dimension node is a violation.
MATCH (ea:EvidenceApplicability)
OPTIONAL MATCH (ea)-[:HAS_DIMENSION]->(d)
WITH ea, collect(d) AS ds
WITH ea, [m IN [['identityMatch', ['MATERIAL_IDENTITY']], ['doseMatch', ['DOSE', 'EXPOSURE']], ['routeMatch', ['ROUTE']],
                ['scheduleMatch', ['SCHEDULE']], ['durationMatch', ['DURATION']], ['populationMatch', ['POPULATION']],
                ['outcomeMatch', ['OUTCOME_RELEVANCE']]] |
          {field: m[0], flat: ea[m[0]], dims: [x IN ds WHERE x.dimension IN m[1] | x.verdict]}] AS pairs
WITH ea, [p IN pairs WHERE p.flat IS NOT NULL AND (size(p.dims) = 0 OR any(v IN p.dims WHERE v IS NULL OR v <> p.flat))] AS diverging
WHERE size(diverging) > 0
RETURN 'V-F5-04' AS check, ea.uid AS applicability, ea.status AS status, diverging;

// V-F5-05 -- resolves CH-S-05; replaces V-203 (adds the label test); rule: HAS_EVIDENCE_TARGET ends on a StudyIntervention or an Assertion, never a whole Study or any other record.
MATCH (ea:EvidenceApplicability)-[:HAS_EVIDENCE_TARGET]->(t)
WHERE NOT (t:StudyIntervention OR t:Assertion)
RETURN 'V-F5-05' AS check, ea.uid AS applicability, labels(t) AS targetLabels, t.uid AS target;

// V-F5-06 -- resolves CH-S-06a; replaces W10-V08 (extends it); rule: a classification compared with a context classification must concern the same biomarker (CLASSIFIES_BIOMARKER or the outcome's MEASURES_BIOMARKER), and a FULL context match needs equal contextDiseaseOrUse and contextInterventionMechanism.
MATCH (ec:EndpointClassification)-[:COMPARED_WITH_CONTEXT]->(ctx:EndpointClassification)
WITH ec, ctx,
     [(ec)-[:CLASSIFIES_BIOMARKER]->(b) | b.uid] + [(ec)-[:CLASSIFIES_OUTCOME]->(:OutcomeDefinition)-[:MEASURES_BIOMARKER]->(b) | b.uid] AS ecBiomarkers,
     [(ctx)-[:CLASSIFIES_BIOMARKER]->(b) | b.uid] + [(ctx)-[:CLASSIFIES_OUTCOME]->(:OutcomeDefinition)-[:MEASURES_BIOMARKER]->(b) | b.uid] AS ctxBiomarkers
WITH ec, ctx, ecBiomarkers, ctxBiomarkers,
     [v IN [
        CASE WHEN size(ecBiomarkers) = 0 OR size(ctxBiomarkers) = 0 OR none(b IN ecBiomarkers WHERE b IN ctxBiomarkers)
             THEN 'COMPARED_CONTEXT_CLASSIFIES_ANOTHER_BIOMARKER' END,
        CASE WHEN ec.contextMatch = 'FULL' AND (coalesce(ec.contextDiseaseOrUse, '-') <> coalesce(ctx.contextDiseaseOrUse, '~')
                  OR coalesce(ec.contextInterventionMechanism, '-') <> coalesce(ctx.contextInterventionMechanism, '~'))
             THEN 'FULL_MATCH_WITH_DIFFERENT_CONTEXT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-06' AS check, ec.uid AS classification, ctx.uid AS comparedContext, ecBiomarkers, ctxBiomarkers, violations;

// V-F5-07 -- resolves CH-S-08; replaces V-215r and W10-V11 (V-215r2); rule: after a NOT_SIGNIFICANT primary prespecified result, every other result of that study (analysisKind null counts as non-primary; an Assertion input is resolved to the StudyResult it is about) enters only as SUPPORTIVE or HYPOTHESIS_GENERATING.
MATCH (syn:EvidenceSynthesis)-[inc:INCLUDES_RESULT]->(x)
WHERE NOT coalesce(inc.inputRole, '-') IN ['SUPPORTIVE', 'HYPOTHESIS_GENERATING']
OPTIONAL MATCH (x)-[:HAS_SUBJECT|HAS_OBJECT]->(viaAssertion:StudyResult)
WITH syn, inc, x, CASE WHEN x:StudyResult THEN [x] ELSE collect(viaAssertion) END AS results
UNWIND results AS r
MATCH (r)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(st:Study)
WHERE coalesce(r.analysisKind, 'UNKNOWN') <> 'PRIMARY_PRESPECIFIED' OR r.comparisonKind = 'WITHIN_ARM_CHANGE'
MATCH (st)-[:DEFINES_OUTCOME]->(:OutcomeDefinition)<-[:RESULT_FOR]-(p:StudyResult {analysisKind: 'PRIMARY_PRESPECIFIED', statisticalConclusion: 'NOT_SIGNIFICANT'})
WHERE p <> r
RETURN DISTINCT 'V-F5-07' AS check, syn.uid AS synthesis, x.uid AS input, r.uid AS resolvedResult,
       coalesce(r.analysisKind, 'UNKNOWN') AS analysisKind, inc.inputRole AS role, p.uid AS nullPrimary;

// V-F5-08 -- resolves CH-S-09; replaces V-218; rule: two INDEPENDENT_REPLICATION inputs of one synthesis never share a study or a dataset (PRODUCED by the study or ANALYZED by its publications), independent of uid order.
// (V-218r verbatim as tested by the study-transfer Challenger.)
MATCH (syn:EvidenceSynthesis)-[:INCLUDES_RESULT {inputRole: 'INDEPENDENT_REPLICATION'}]->(r:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(s:Study)
OPTIONAL MATCH (s)-[:PRODUCED_DATASET]->(d1:Dataset)
OPTIONAL MATCH (s)<-[:REPORTS_ON]-(:Publication)-[:ANALYZES_DATASET]->(d2:Dataset)
WITH syn, r, s, collect(DISTINCT d1.uid) + collect(DISTINCT d2.uid) AS ds
WITH syn, collect({r: r.uid, s: s.uid, ds: ds}) AS inputs
UNWIND inputs AS a
UNWIND inputs AS b
WITH syn, a, b WHERE a.r < b.r AND (a.s = b.s OR any(x IN a.ds WHERE x IN b.ds))
RETURN 'V-F5-08' AS check, syn.uid AS synthesis, a.r AS result1, b.r AS result2;

// V-F5-09 -- resolves CH-S-10; extends V-W00-15 (V-W09-14); rule: after the cutover no Study writes EVALUATES, and every LEGACY_EVALUATES edge carries the stamp of the one-time migration (migrationRunId and migratedAt); a stampless legacy edge is a laundered new write.
MATCH (s:Study)-[e:EVALUATES|LEGACY_EVALUATES]->(x)
WHERE type(e) = 'EVALUATES' OR e.migrationRunId IS NULL OR e.migratedAt IS NULL
RETURN 'V-F5-09' AS check, type(e) AS rel, s.uid AS study, x.uid AS target,
       CASE type(e) WHEN 'EVALUATES' THEN 'REJECT_WRITE_USE_ASSIGNS_INTERVENTION_PATH' ELSE 'LEGACY_EDGE_WITHOUT_MIGRATION_STAMP' END AS violation;

// V-F5-10 -- resolves CH-S-11; extends V-W09-11 and V-112r (V-W09-11r); rule: a derived SPONSORED_BY/OPERATED_BY/INVESTIGATED_BY names rule inverse-of:<P>@n where P is the registered premise, cites at least one live Assertion of predicate P whose subject is the edge end and whose object is the edge start; REPORTS_SAFETY_SIGNAL is rule ss-study/v1 citing its SafetySignal, which is based on the study or on a result of it.
MATCH (x)-[r:SPONSORED_BY|OPERATED_BY|INVESTIGATED_BY]->(y)
WITH x, y, r, coalesce($derivedEdgePremises[type(r)], '<unregistered>') AS premise, coalesce(r.derivedFromAssertionUids, []) AS inputs
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN inputs
WITH x, y, r, premise, inputs, collect(a) AS found
WITH x, y, r, [v IN [
        CASE WHEN NOT x:Study THEN 'START_IS_NOT_A_STUDY' END,
        CASE WHEN r.assertionUid IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL THEN 'DERIVED_EDGE_WRITTEN_AS_ASSERTED' END,
        CASE WHEN r.derivationRule IS NULL OR NOT r.derivationRule =~ ('inverse-of:' + premise + '@[0-9]+') THEN 'RULE_DOES_NOT_NAME_REGISTERED_PREMISE' END,
        CASE WHEN size(inputs) = 0 THEN 'NO_DERIVATION_INPUTS' END,
        CASE WHEN size(found) < size(inputs) THEN 'DERIVATION_INPUT_MISSING' END,
        CASE WHEN any(a IN found WHERE a.predicate <> premise) THEN 'INPUT_PREDICATE_IS_NOT_THE_RULE_PREMISE' END,
        CASE WHEN any(a IN found WHERE NOT EXISTS { (a)-[:HAS_SUBJECT]->(y) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(x) }) THEN 'INPUT_IS_NOT_THE_INVERSE_OF_THE_EDGE' END,
        CASE WHEN any(a IN found WHERE coalesce(a.status, '-') IN ['REJECTED', 'SUPERSEDED']) THEN 'INPUT_NOT_LIVE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-10' AS check, type(r) AS rel, x.uid AS startUid, y.uid AS endUid, violations
UNION
MATCH (x)-[r:REPORTS_SAFETY_SIGNAL]->(y)
WITH x, y, r, [v IN [
        CASE WHEN NOT x:Study OR NOT y:SafetySignal THEN 'WRONG_ENDPOINTS' END,
        CASE WHEN r.assertionUid IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL THEN 'DERIVED_EDGE_WRITTEN_AS_ASSERTED' END,
        CASE WHEN coalesce(r.derivationRule, '-') <> 'ss-study/v1' THEN 'RULE_IS_NOT_SS_STUDY_V1' END,
        CASE WHEN NOT y.uid IN coalesce(r.derivedFromAssessmentUids, []) THEN 'SIGNAL_NOT_CITED' END,
        CASE WHEN NOT (EXISTS { (y)-[:SIGNAL_BASED_ON]->(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:StudyResult)-[:RESULT_FOR_ARM]->(:StudyArm)<-[:HAS_ARM]-(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:StudyResult)-[:RESULT_FOR]->(:OutcomeDefinition)<-[:DEFINES_OUTCOME]-(x) }
                    OR EXISTS { MATCH (y)-[:SIGNAL_BASED_ON]->(:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(sr:StudyResult)-[:RESULT_FOR_ARM]->(:StudyArm)<-[:HAS_ARM]-(x) })
             THEN 'SIGNAL_NOT_BASED_ON_THIS_STUDY' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-10' AS check, type(r) AS rel, x.uid AS startUid, y.uid AS endUid, violations;

// V-F5-11 -- resolves CH-S-12a; extends V-508r (V-W09-15); rule: a registration has at most one current-recorded HAS_REGISTRATION_VERSION episode with an open valid end (the ingester re-bounds the previous episode).
MATCH (t)-[h1:HAS_REGISTRATION_VERSION]->(v1), (t)-[h2:HAS_REGISTRATION_VERSION]->(v2)
WHERE elementId(h1) < elementId(h2) AND v1 <> v2
  AND h1.recordedTo IS NULL AND h2.recordedTo IS NULL AND h1.validTo IS NULL AND h2.validTo IS NULL
RETURN 'V-F5-11' AS check, t.uid AS registration, v1.uid AS version1, v2.uid AS version2;

// V-F5-12 -- resolves CH-S-12b; new (V-W09-16, generalized to $episodeTypes); rule: an episode is never recorded before the observation or retrieval of the version it attaches, and a version is never observed or retrieved after it was created (recorded time is service-assigned, never backdated).
MATCH (s)-[r]->(t)
WHERE type(r) IN $episodeTypes AND r.recordedFrom IS NOT NULL
WITH s, r, t, coalesce(t.observedAt, t.retrievedAt) AS observed
WHERE (observed IS NOT NULL AND r.recordedFrom < observed)
   OR (t.createdAt IS NOT NULL AND observed IS NOT NULL AND observed > t.createdAt)
RETURN 'V-F5-12' AS check, type(r) AS rel, coalesce(r.relationshipUid, elementId(r)) AS episode, s.uid AS subject, t.uid AS version,
       r.recordedFrom AS recordedFrom, observed, t.createdAt AS versionCreatedAt,
       CASE WHEN observed IS NOT NULL AND r.recordedFrom < observed THEN 'RECORDED_BEFORE_OBSERVED' ELSE 'OBSERVED_AFTER_CREATED' END AS violation;

// V-F5-13 -- resolves CH-S-13; new (V-W09-17); rule: every OutcomeDefinition has exactly one DEFINES_OUTCOME parent (instruments of another study are separate OutcomeDefinitions).
MATCH (od:OutcomeDefinition)
WITH od, [(st)-[:DEFINES_OUTCOME]->(od) | st.uid] AS parents
WHERE size(parents) <> 1
RETURN 'V-F5-13' AS check, od.uid AS outcomeDefinition, parents;

// V-F5-14 -- resolves CH-S-14; extends W10-V13 (W10-V13b + W10-V07s); rule: at most one ACCEPTED synthesis with recordedTo null per claim, and SUPERSEDES closes the older synthesis at the newer recordedAt with status SUPERSEDED.
MATCH (s:EvidenceSynthesis)-[:ASSESSES_CLAIM]->(c)
WHERE s.status = 'ACCEPTED' AND s.recordedTo IS NULL
WITH c, collect(s.uid) AS current
WHERE size(current) > 1
RETURN 'V-F5-14' AS check, 'TWO_CURRENT_ACCEPTED_SYNTHESES' AS violation, c.uid AS item, current AS detail
UNION
MATCH (n:EvidenceSynthesis)-[:SUPERSEDES]->(o:EvidenceSynthesis)
WHERE o.recordedTo IS NULL OR n.recordedAt IS NULL OR o.recordedTo <> n.recordedAt OR coalesce(o.status, '-') <> 'SUPERSEDED'
RETURN 'V-F5-14' AS check, 'SUPERSEDED_VERSION_NOT_CLOSED' AS violation, o.uid AS item, [n.uid, coalesce(o.status, 'null'), toString(o.recordedTo)] AS detail;

// V-F5-15 -- resolves CH-S-15; extends V-102/V-103 to nodes (V-102r); rule: a node's recordedTo is never earlier than its own recordedAt and never at or before its recordedFrom.
MATCH (n)
WHERE n.recordedTo IS NOT NULL
  AND ((n.recordedAt IS NOT NULL AND n.recordedTo < n.recordedAt) OR (n.recordedFrom IS NOT NULL AND n.recordedTo <= n.recordedFrom))
RETURN 'V-F5-15' AS check, labels(n) AS labels, n.uid AS item, n.recordedAt AS recordedAt, n.recordedFrom AS recordedFrom, n.recordedTo AS recordedTo;

// V-F5-16 -- resolves CH-S-17; new (W10-V20); rule: every EvidenceSynthesis assesses exactly one claim (exactly one ASSESSES_CLAIM edge).
MATCH (s:EvidenceSynthesis)
WITH s, [(s)-[:ASSESSES_CLAIM]->(c) | c.uid] AS claims
WHERE size(claims) <> 1
RETURN 'V-F5-16' AS check, s.uid AS synthesis, s.status AS status, claims;

// V-F5-17 -- (review) resolves CH-S-07 partially (DEFERRED as a hard rule); new (W10-V19 review queue); rule: a current ACCEPTED SUPPORTED synthesis needs at least one CONFIRMATORY or INDEPENDENT_REPLICATION input that is SIGNIFICANT_FAVORABLE (or a POSITIVE Assertion), and a TRIGGERED_BY STRENGTHENED trigger must itself be such an input.
MATCH (s:EvidenceSynthesis {verdict: 'SUPPORTED', status: 'ACCEPTED'})
WHERE s.recordedTo IS NULL
OPTIONAL MATCH (s)-[i:INCLUDES_RESULT]->(x)
WHERE i.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION']
WITH s, [y IN collect(x) WHERE (y:StudyResult AND y.statisticalConclusion = 'SIGNIFICANT_FAVORABLE') OR (y:Assertion AND y.polarity = 'POSITIVE')] AS favorable
OPTIONAL MATCH (s)-[t:TRIGGERED_BY {effectOnVerdict: 'STRENGTHENED'}]->(trig)
WITH s, favorable, [tg IN collect(trig) WHERE NOT EXISTS { MATCH (s)-[j:INCLUDES_RESULT]->(tg) WHERE j.inputRole IN ['CONFIRMATORY', 'INDEPENDENT_REPLICATION'] } | tg.uid] AS weakTriggers
WHERE size(favorable) = 0 OR size(weakTriggers) > 0
RETURN 'V-F5-17' AS check, s.uid AS synthesis, size(favorable) AS favorableStrongInputs, weakTriggers,
       'REVIEW_VERDICT_NOT_CARRIED_BY_CONFIRMATORY_INPUTS' AS violation;

// ------------------------------------------------- privacy and access (W23) -------------------------------------------
// The private-token regex is derived in Cypher from $privateUidTokens (literal tokens; regex metacharacters escaped), joined
// as a case-insensitive, word-bounded alternation, OR an e-mail address. Every STRING and LIST<STRING> property is tested.

// V-F5-18 -- resolves CH-S-16, CH-P-05, CH-P-07d, CH-P-07e, CH-P-11, CH-R-07a; replaces the STARTS WITH branches of V-521r and W10-V14 (node side); rule: no shared node holds, in any string or list-of-string property, a private-store uid token (anywhere in the value, any case), an e-mail address, or a birth-date / record-number pattern ($personalDataPatterns).
WITH '(?is)(.*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c)))
     + ').*|.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*)' AS re
MATCH (n)
WHERE NOT n:PrivateRecord
WITH n, re, [k IN keys(n) WHERE
        (n[k] IS :: STRING AND (n[k] =~ re OR any(p IN $personalDataPatterns WHERE n[k] =~ p)))
     OR (n[k] IS :: LIST<STRING> AND any(x IN n[k] WHERE x =~ re OR any(p IN $personalDataPatterns WHERE x =~ p)))] AS hits
WHERE size(hits) > 0
RETURN 'V-F5-18' AS check, labels(n) AS labels, n.uid AS item, hits AS properties;

// V-F5-19 -- resolves CH-P-07a, CH-P-07b, CH-P-07c; replaces the relationship branches of V-521r and V-W23-10; rule: no relationship between shared nodes holds a private-store uid token or an e-mail address in any string or list-of-string property (derived, asserted and structural edges alike).
WITH '(?is)(.*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c)))
     + ').*|.*[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}.*)' AS re
MATCH (x)-[r]->(y)
WHERE NOT x:PrivateRecord AND NOT y:PrivateRecord
WITH x, r, y, [k IN keys(r) WHERE (r[k] IS :: STRING AND r[k] =~ re) OR (r[k] IS :: LIST<STRING> AND any(v IN r[k] WHERE v =~ re))] AS hits
WHERE size(hits) > 0
RETURN 'V-F5-19' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS item, x.uid AS fromUid, y.uid AS toUid, hits AS properties;

// V-F5-20 -- resolves CH-R-07b (and the list key of CH-P-07d); extends V-534p and W10-V14 (key allow-list); rule: no shared node carries a private-store property name ($privateOnlyPropertyNames or a pcs*/personal*/userContext*/privateStore* key), and Observation and ProtocolResult carry only their SDL properties ($observationAllowedKeys, $protocolResultAllowedKeys).
MATCH (n)
WHERE NOT n:PrivateRecord
WITH n, [k IN keys(n) WHERE k IN $privateOnlyPropertyNames OR k =~ '(?i)^(pcs|personal|usercontext|privatestore).*'] AS privateKeys,
     CASE WHEN n:Observation THEN [k IN keys(n) WHERE NOT k IN $observationAllowedKeys]
          WHEN n:ProtocolResult THEN [k IN keys(n) WHERE NOT k IN $protocolResultAllowedKeys]
          ELSE [] END AS undeclaredKeys
WHERE size(privateKeys) > 0 OR size(undeclaredKeys) > 0
RETURN 'V-F5-20' AS check, labels(n) AS labels, n.uid AS item, privateKeys, undeclaredKeys;

// V-F5-21 -- resolves CH-P-10, CH-R-06 (public-identity half); new; rule: every Person and PseudonymousActor is the asserter, subject, object or attributed speaker of at least one Assertion SUPPORTED_BY a locator in a snapshot of a public Source (canonicalUri not on $privateSourceUriPatterns); a BellLabs user is never minted as a Person.
MATCH (p)
WHERE (p:Person OR p:PseudonymousActor) AND NOT p:PrivateRecord
  AND NOT EXISTS {
    MATCH (a:Assertion)-[:ASSERTED_BY|HAS_SUBJECT|HAS_OBJECT|ATTRIBUTES_TO]->(p)
    MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
    WHERE src.canonicalUri IS NOT NULL AND NOT any(pat IN $privateSourceUriPatterns WHERE src.canonicalUri =~ pat)
  }
RETURN 'V-F5-21' AS check, labels(p) AS labels, p.uid AS item, p.privacyClass AS privacyClass, 'ACTOR_WITHOUT_PUBLIC_SOURCE_ASSERTION' AS violation;

// V-F5-22 -- resolves CH-P-09, CH-R-06 (record half); replaces V-W23-05 ENDPOINT_NOT_PUBLIC (compiled) and adds V-W16-06; rule: RECORDS and POSTS_RESULT connect two PUBLIC records and their authorizing assertion is supported only by snapshots of public-web Sources (never an operator application, upload or media-store Source, never an upload SourceKind).
MATCH (x)-[e:RECORDS|POSTS_RESULT]->(y)
OPTIONAL MATCH (a:Assertion {uid: e.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WITH x, e, y, collect(DISTINCT src) AS sources
WITH x, e, y, sources, [v IN [
        CASE WHEN coalesce(x.privacyClass, '-') <> 'PUBLIC' THEN 'RECORDER_NOT_PUBLIC' END,
        CASE WHEN coalesce(y.privacyClass, '-') <> 'PUBLIC' THEN 'RECORD_NOT_PUBLIC' END,
        CASE WHEN size(sources) = 0 THEN 'NO_SOURCE_SNAPSHOT_SUPPORT' END,
        CASE WHEN any(s IN sources WHERE s.canonicalUri IS NULL OR any(pat IN $privateSourceUriPatterns WHERE s.canonicalUri =~ pat)
                                      OR coalesce(s.sourceKind, '-') IN $privateUploadSourceKinds) THEN 'SUPPORTED_BY_OPERATOR_OR_UPLOAD_SOURCE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-22' AS check, type(e) AS relType, x.uid AS fromUid, y.uid AS toUid, violations;

// V-F5-23 -- resolves CH-P-05, CH-P-06, CH-P-13, CH-P-14 (detection); replaces V-121 (compiles V-W23-01a and extends V-W23-02); rule: a shared AnswerRecord is INTERNAL, never OWNER_PRIVATE or computed with private context, carries no free-text name/description, and a PUBLIC_ANSWER record cites only PUBLIC records outside the excluded INTERNAL layer.
MATCH (r:AnswerRecord)
WITH r, [v IN [
        CASE WHEN r.accessTier IS NULL OR NOT r.accessTier IN ['PUBLIC_ANSWER', 'OPERATOR_AUDIT', 'AGENT_PROJECTION'] THEN 'TIER_NOT_SHAREABLE' END,
        CASE WHEN coalesce(r.privateContext, '-') <> 'EXCLUDED' THEN 'PRIVATE_CONTEXT_NOT_EXCLUDED' END,
        CASE WHEN coalesce(r.privacyClass, '-') <> 'INTERNAL' THEN 'ANSWER_RECORD_NOT_INTERNAL' END,
        CASE WHEN r.name IS NOT NULL OR r.description IS NOT NULL OR r.userUid IS NOT NULL OR r.ownerUid IS NOT NULL OR r.questionText IS NOT NULL
             THEN 'FREE_TEXT_OR_ASKER_FIELD_ON_ANSWER_RECORD' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-23' AS check, r.uid AS answerRecord, null AS cited, violations
UNION
MATCH (r:AnswerRecord {accessTier: 'PUBLIC_ANSWER'})-[:CITES_ASSERTION|CITES_ASSESSMENT]->(x)
WHERE coalesce(x.privacyClass, '-') <> 'PUBLIC' OR any(l IN labels(x) WHERE l IN $publicAnswerExcludedLabels)
RETURN 'V-F5-23' AS check, r.uid AS answerRecord, x.uid AS cited, ['PUBLIC_ANSWER_CITES_NON_PUBLIC_RECORD'] AS violations;

// V-F5-24 -- resolves CH-P-03, CH-P-04 (embedding provenance); extends V-119 and V-W23-04; rule: searchFields name only public shared properties ($publicSearchFields, never $privateOnlyPropertyNames) that the node actually stores, and a node with searchText or searchEmbedding declares its searchFields.
MATCH (n)
WHERE n.searchFields IS NOT NULL OR n.searchText IS NOT NULL OR n.searchEmbedding IS NOT NULL
WITH n, [f IN coalesce(n.searchFields, []) WHERE NOT f IN $publicSearchFields OR f IN $privateOnlyPropertyNames] AS notAllowed,
     [f IN coalesce(n.searchFields, []) WHERE n[f] IS NULL] AS notStored
WHERE size(notAllowed) > 0 OR size(notStored) > 0
   OR ((n.searchText IS NOT NULL OR n.searchEmbedding IS NOT NULL) AND size(coalesce(n.searchFields, [])) = 0)
RETURN 'V-F5-24' AS check, labels(n) AS labels, n.uid AS item, notAllowed, notStored, n.searchEmbedding IS NOT NULL AS hasEmbedding;

// V-F5-25 -- resolves CH-P-01 (graph half; the tier sub-schema is Fable's); new; rule: a PUBLIC Assertion never has an INTERNAL subject or object, nor one of the excluded INTERNAL-layer types ($publicAnswerExcludedLabels), so a PUBLIC trace cannot step into lineage or policy.
MATCH (a:Assertion)-[h:HAS_SUBJECT|HAS_OBJECT]->(t)
WHERE a.privacyClass = 'PUBLIC'
  AND (t.privacyClass = 'INTERNAL' OR any(l IN labels(t) WHERE l IN $publicAnswerExcludedLabels))
RETURN 'V-F5-25' AS check, a.uid AS assertion, type(h) AS rel, labels(t) AS targetLabels, t.uid AS target, t.privacyClass AS targetClass;

// V-F5-26 -- resolves CH-P-12 (validator half; the operations section 7 respelling is Fable's); replaces V-113, V-115, V-116 (recognizer); rule: a node is private when it is :PrivateRecord, its uid contains a private-store token, or its privacyClass is set to anything but PUBLIC/INTERNAL (so 'PRIVATE-PERSONAL', 'PRIVATE_PERSONAL' and 'private-personal' are all recognised); no shared node points at it, it carries no shared-indexed label and no search text or embedding.
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS re
MATCH (s)-[r]->(p)
WHERE (p:PrivateRecord OR coalesce(p.uid, '') =~ re OR (p.privacyClass IS NOT NULL AND NOT p.privacyClass IN ['PUBLIC', 'INTERNAL']))
  AND NOT (s:PrivateRecord OR coalesce(s.uid, '') =~ re OR (s.privacyClass IS NOT NULL AND NOT s.privacyClass IN ['PUBLIC', 'INTERNAL']))
RETURN 'V-F5-26' AS check, 'SHARED_NODE_POINTS_AT_PRIVATE_NODE' AS violation, s.uid AS item, type(r) + ' -> ' + coalesce(p.uid, elementId(p)) AS detail
UNION
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS re
MATCH (p)
WHERE (p:PrivateRecord OR coalesce(p.uid, '') =~ re OR (p.privacyClass IS NOT NULL AND NOT p.privacyClass IN ['PUBLIC', 'INTERNAL']))
  AND (any(l IN labels(p) WHERE l IN $sharedIndexedLabels) OR p.searchText IS NOT NULL OR p.searchEmbedding IS NOT NULL)
RETURN 'V-F5-26' AS check, 'PRIVATE_NODE_IN_SHARED_SEARCH_SURFACE' AS violation, coalesce(p.uid, elementId(p)) AS item, toString(p.privacyClass) AS detail;

// V-F5-27 -- resolves CH-P-11; extends V-W23-06; rule: a CohortParticipant carries no name or description, and its participantToken is not an e-mail address, URL, phone number or social handle.
MATCH (cp:CohortParticipant)
WITH cp, [v IN [
        CASE WHEN cp.name IS NOT NULL OR cp.description IS NOT NULL THEN 'PARTICIPANT_HAS_FREE_TEXT_IDENTITY' END,
        CASE WHEN coalesce(cp.participantToken, '') =~ '(?is).*(@|https?://|www\\.|\\+?\\d[\\d ().-]{6,}\\d).*' THEN 'TOKEN_LOOKS_LIKE_CONTACT_OR_HANDLE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-27' AS check, cp.uid AS item, cp.participantToken AS participantToken, violations;

// V-F5-28 -- resolves CH-P-08 partially (the cross-store copy audit is DEFERRED to the PCS); compiles V-532p and tightens it; rule: every PUBLIC Observation is the subject or object of its own Assertion SUPPORTED_BY a locator in a SourceSnapshot (attribution per observation, never by inclusion in a ProtocolResult).
MATCH (o:Observation)
WHERE NOT o:PrivateRecord AND o.privacyClass = 'PUBLIC'
  AND NOT EXISTS { MATCH (a:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(o)
                   WHERE EXISTS { MATCH (a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot) } }
RETURN 'V-F5-28' AS check, o.uid AS observation, 'OBSERVATION_WITHOUT_OWN_SOURCE_ATTRIBUTION' AS violation;
