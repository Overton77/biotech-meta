// =====================================================================================================================
// fable-w5-validators.cypher -- Wave 5 validator corrections compiled from the Challenger reports
// (validation/challengers/CH-W09W10-study-transfer, CH-W23-privacy, CH-W16-protocols, CH-W21W22-media, CH-W00-kernel; dispositions in
// reports/08-challenger-resolution-matrix.md), run-2026-10-04-fable51-01, Opus 5.5 worker, 2026-10-04.
//
// Contract: one statement per correction; each statement returns rows ONLY on violations (zero rows = valid). Statements
// marked "(review)" return review-queue rows that are violations of a method rule that cannot be checked as a hard
// structural rule (they still return zero rows on the valid fixtures). Every statement binds its own variables; nothing
// crosses ';'. Every row carries `check` = its V-F5 id.
// Parameters: validation/validation-params.json merged with validation/fable-w5-params.json (list keys unioned).
// Not covered here, because Fable fixes them in the SDL / operations / fixtures (cross-reference only): CH-P-02, CH-P-04
// (vector indexes), CH-P-12 (operations section 7), CH-P-16, CH-P-17/CH-R-12 (DiagnosticResult label), CH-P-18, CH-R-04,
// CH-R-05 (DERIVED_FROM_PROTOCOL field), CH-R-13 (HAS_STEP migration and fixture), CH-S-18, and the kernel items CH-K-08a/09 (gen-params),
// CH-K-10b/13 (generated-label-checks.cypher), CH-K-16a/b (operations 5b), CH-K-18a-d (operations 6a/7), CH-K-19 (99-normalize).
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

// ------------------------------------------------- protocols (W16) ----------------------------------------------------

// V-F5-29 -- resolves CH-R-01; replaces the deny-list of V-534p (edge and property halves); rule: an adherence-, adoption- or follows-like edge (type =~ (?i).*(ADHER|ADOPT|FOLLOW).*) from a Person to a Protocol, ProtocolEdition or ProtocolStep exists only as the projection of the person's own source-supported REPORTS_PRACTICE Assertion of the same predicate (never derived), and no adherence/adoption/deviation-like property sits on a public protocol record.
MATCH (p:Person)-[r]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND type(r) =~ '(?i).*(ADHER|ADOPT|FOLLOW).*'
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH p, r, x, a
WHERE a IS NULL OR r.derivationRule IS NOT NULL OR r.projectionOfAssertionUid IS NOT NULL OR a.predicate <> type(r)
   OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(p) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(x) } OR NOT EXISTS { (a)-[:ASSERTED_BY]->(p) }
   OR NOT EXISTS { (a)-[:SUPPORTED_BY]->(:SourceLocator) } OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
RETURN 'V-F5-29' AS check, 'ADHERENCE_LIKE_EDGE_WITHOUT_LICENSING_ASSERTION' AS violation, p.uid AS item, type(r) + ' -> ' + x.uid AS detail
UNION
MATCH (n)
WHERE n:Protocol OR n:ProtocolEdition OR n:ProtocolStep
WITH n, [k IN keys(n) WHERE k =~ '(?i).*(adher|adopt|follow|deviat|omit).*'] AS ks
WHERE size(ks) > 0
RETURN 'V-F5-29' AS check, 'ADHERENCE_LIKE_PROPERTY_ON_PUBLIC_PROTOCOL' AS violation, n.uid AS item, reduce(s = '', k IN ks | s + k + ' ') AS detail;

// V-F5-30 -- resolves CH-R-02; replaces V-528p and extends V-531p; rule: DEPENDS_ON fails closed: a loop through any dependency that is not symmetric (null or unknown kind counts as ordering) is a cycle; every dependency names a StepDependencyKind; a pair is never both CONCURRENT_WITH and ordered.
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
MATCH p = (s)-[:DEPENDS_ON*1..25]->(s)
WHERE any(r IN relationships(p) WHERE NOT coalesce(r.dependencyKind, '-') IN ['CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH'])
RETURN DISTINCT 'V-F5-30' AS check, 'DEPENDENCY_CYCLE' AS violation, e.uid AS item, s.stepKey AS detail
UNION
MATCH (a:ProtocolStep)-[d:DEPENDS_ON]->(b)
WHERE d.dependencyKind IS NULL OR NOT d.dependencyKind IN ['REQUIRES_PRIOR_COMPLETION', 'REQUIRES_RESULT_OF', 'CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH']
RETURN 'V-F5-30' AS check, 'DEPENDENCY_KIND_MISSING_OR_UNKNOWN' AS violation, a.uid AS item, coalesce(d.dependencyKind, 'null') + ' -> ' + b.uid AS detail
UNION
MATCH (a:ProtocolStep)-[c:DEPENDS_ON {dependencyKind: 'CONCURRENT_WITH'}]-(b:ProtocolStep), (a)-[o:DEPENDS_ON]-(b)
WHERE o <> c AND NOT coalesce(o.dependencyKind, '-') IN ['CONCURRENT_WITH', 'MUTUALLY_EXCLUSIVE_WITH'] AND elementId(a) < elementId(b)
RETURN DISTINCT 'V-F5-30' AS check, 'CONCURRENT_AND_ORDERED' AS violation, a.uid AS item, b.uid AS detail;

// V-F5-31 -- (review) resolves CH-R-03; extends V-529b; rule: when a verbatim schedule field (scheduleText, frequencyText, timingText) states a range ("3-6 months", "three to six months", "q3-6 mo"), the stored bounds are not collapsed (min = max) and, for source-unit bounds, both stored bounds appear as that range (digits or number words).
MATCH (n)
WHERE n:ProtocolStep OR n:MeasurementPlan
UNWIND [k IN ['scheduleText', 'frequencyText', 'timingText'] WHERE n[k] IS :: STRING] AS k
WITH n, k, n[k] AS txt, '(\\d+|' + reduce(acc = '', w IN $numberWords | acc + CASE WHEN acc = '' THEN '' ELSE '|' END + w) + ')' AS num
WHERE txt =~ ('(?is).*\\b(q\\s*)?' + num + '\\s*(-|–|to)\\s*' + num + '\\s*(days?|d|weeks?|wks?|months?|mos?|years?|yrs?)\\b.*')
WITH n, k, txt, toInteger(coalesce(n.cadenceIntervalMin, n.cadenceMinDays)) AS mn, toInteger(coalesce(n.cadenceIntervalMax, n.cadenceMaxDays)) AS mx
WHERE mn IS NOT NULL AND mx IS NOT NULL
  AND (mn = mx
       OR (n.cadenceIntervalMin IS NOT NULL
           AND NOT txt =~ ('(?is).*\\b(q\\s*)?(' + toString(mn) + CASE WHEN mn >= 0 AND mn < size($numberWords) THEN '|' + $numberWords[mn] ELSE '' END
                           + ')\\s*(-|–|to)\\s*(' + toString(mx) + CASE WHEN mx >= 0 AND mx < size($numberWords) THEN '|' + $numberWords[mx] ELSE '' END + ')\\b.*')))
RETURN 'V-F5-31' AS check, n.uid AS item, k AS textField, txt AS text, mn AS storedMin, mx AS storedMax,
       CASE WHEN mn = mx THEN 'RANGE_COLLAPSED' ELSE 'RANGE_NARROWED_OR_ALTERED' END AS violation;

// V-F5-32 -- resolves CH-R-05 (validator half; DERIVED_FROM_PROTOCOL is Fable's SDL fix); extends V-530p (V-530q); rule: an edition attached to a Protocol is never asserted on a THIRD_PARTY_* basis, never asserted by anyone other than the protocol's author, and (when authorship is sourced) its support comes from the author's own Source or an archived copy of it.
MATCH (p:Protocol)-[h:HAS_PROTOCOL_EDITION]->(e)
OPTIONAL MATCH (a:Assertion {uid: h.assertionUid})
WITH p, h, e, a,
     [(au:Assertion)-[:HAS_SUBJECT]->(p) WHERE au.predicate IN ['AUTHORED_PROTOCOL', 'AUTHORED_PROTOCOL_EDITION'] AND NOT coalesce(au.status, '-') IN ['REJECTED', 'SUPERSEDED'] | au] AS auths
WITH p, h, e, a,
     reduce(acc = [], l IN [au IN auths | [(au)-[:HAS_OBJECT]->(o) | o.uid]] | acc + l) AS authors,
     reduce(acc = [], l IN [au IN auths | [(au)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) | s]] | acc + l) AS ownSources,
     CASE WHEN a IS NULL THEN [] ELSE [(a)-[:ASSERTED_BY]->(w) | w.uid] END AS asserters,
     CASE WHEN a IS NULL THEN [] ELSE [(a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(s:Source) | s] END AS editionSources
WITH p, e, [v IN [
        CASE WHEN a IS NOT NULL AND coalesce(a.assertionBasis, '') STARTS WITH 'THIRD_PARTY' THEN 'EDITION_ASSERTED_ON_THIRD_PARTY_BASIS' END,
        CASE WHEN size(authors) > 0 AND any(w IN asserters WHERE NOT w IN authors) THEN 'EDITION_ASSERTED_BY_NON_AUTHOR' END,
        CASE WHEN size(ownSources) > 0 AND size(editionSources) > 0
                  AND none(s IN editionSources WHERE any(o IN ownSources WHERE s = o OR EXISTS { (s)-[:ARCHIVED_COPY_OF]->(o) }
                                                       OR (s.canonicalUri IS NOT NULL AND o.canonicalUri IS NOT NULL AND s.canonicalUri CONTAINS o.canonicalUri)))
             THEN 'EDITION_NOT_FROM_PROTOCOL_OWN_SOURCE' END,
        CASE WHEN coalesce(e.changeProvenance, '') = 'THIRD_PARTY_REPORTED' THEN 'EDITION_FROM_THIRD_PARTY_REPORT' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-32' AS check, p.uid AS protocol, e.uid AS edition, violations;

// V-F5-33 -- resolves CH-R-08; replaces V-536p (V-536q); rule: ABOUT_CONDITION is the projection of a matching ABOUT_CONDITION Assertion (same subject and object) that is not CALCULATED, names no derivationRule, and has no DERIVED_FROM_ASSERTION input (transitively) whose predicate is a premise of a forbidden implication concluding CONDITION_PRESENT, INDICATES_CONDITION or ABOUT_CONDITION.
MATCH (o)-[r:ABOUT_CONDITION]->(c)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH o, r, c, a, [pr IN $implicationPairs WHERE pr[1] IN ['CONDITION_PRESENT', 'INDICATES_CONDITION', 'ABOUT_CONDITION'] | pr[0]] AS premises
WITH o, c, [v IN [
        CASE WHEN a IS NULL OR r.derivationRule IS NOT NULL THEN 'CONDITION_NOT_ASSERTED' END,
        CASE WHEN a IS NOT NULL AND (a.predicate <> 'ABOUT_CONDITION' OR NOT EXISTS { (a)-[:HAS_SUBJECT]->(o) } OR NOT EXISTS { (a)-[:HAS_OBJECT]->(c) })
             THEN 'ASSERTION_DOES_NOT_MATCH_EDGE' END,
        CASE WHEN a IS NOT NULL AND (a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL) THEN 'LICENSED_BY_CALCULATED_ASSERTION' END,
        CASE WHEN a IS NOT NULL AND EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION*1..5]->(inp:Assertion) WHERE inp.predicate IN premises }
             THEN 'THRESHOLD_TRIGGER_AMONG_INPUTS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-33' AS check, o.uid AS observation, c.uid AS condition, violations;

// V-F5-34 -- resolves CH-R-09; extends V-534p and V-112 (V-534q); rule: a deviation/non-adherence-like edge or Assertion about a protocol record is only the person's own source-supported REPORTS_PRACTICE statement (never CALCULATED, never asserted by an Agent or another party), and is never derived from a statement about an OPTIONAL step; every step attached to an edition states requirementLevel and requirementBasis from their enums.
MATCH (p)-[r]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND type(r) =~ '(?i).*(DEVIAT|NON_?ADHER|OMIT|SKIP).*'
WITH p, r, x, coalesce(r.derivedFromAssertionUids, []) + [u IN [r.projectionOfAssertionUid, r.assertionUid] WHERE u IS NOT NULL] AS cited
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN cited
WITH p, r, x, collect(a) AS licences
WITH p, r, x, [v IN [
        CASE WHEN any(a IN licences WHERE EXISTS { MATCH (a)-[:HAS_SUBJECT|HAS_OBJECT]->(:ProtocolStep {requirementLevel: 'OPTIONAL'}) }
                                      OR EXISTS { MATCH (a)-[:DERIVED_FROM_ASSERTION*1..5]->(:Assertion)-[:HAS_SUBJECT|HAS_OBJECT]->(:ProtocolStep {requirementLevel: 'OPTIONAL'}) })
             THEN 'DEVIATION_DERIVED_FROM_OPTIONAL_STEP' END,
        CASE WHEN size(licences) = 0 OR r.derivationRule IS NOT NULL
                  OR any(a IN licences WHERE a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
                                         OR NOT EXISTS { (a)-[:ASSERTED_BY]->(p) })
             THEN 'NOT_A_SELF_REPORTED_PRACTICE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-34' AS check, type(r) AS kind, p.uid AS item, x.uid AS target, violations
UNION
MATCH (a:Assertion)-[:HAS_OBJECT]->(x)
WHERE (x:Protocol OR x:ProtocolEdition OR x:ProtocolStep) AND a.predicate =~ '(?i)(.*DEVIAT.*|(NON_)?ADHER.*|.*OMIT.*|.*SKIP.*)'
  AND (a.basisKind = 'CALCULATED' OR a.derivationRule IS NOT NULL OR coalesce(a.speechAct, '-') <> 'REPORTS_PRACTICE'
       OR NOT EXISTS { MATCH (a)-[:ASSERTED_BY]->(w)<-[:HAS_SUBJECT]-(a) } OR EXISTS { (a)-[:ASSERTED_BY]->(:Agent) })
RETURN 'V-F5-34' AS check, a.predicate AS kind, a.uid AS item, x.uid AS target, ['CALCULATED_OR_THIRD_PARTY_ADHERENCE_VERDICT'] AS violations
UNION
MATCH (e:ProtocolEdition)-[:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE s.requirementLevel IS NULL OR s.requirementBasis IS NULL
   OR NOT s.requirementLevel IN ['ESSENTIAL', 'RECOMMENDED', 'OPTIONAL', 'CONDITIONAL', 'NOT_STATED']
   OR NOT s.requirementBasis IN ['STATED_BY_SOURCE', 'EDITORIAL_INFERENCE', 'NOT_STATED']
RETURN 'V-F5-34' AS check, 'STEP_REQUIREMENT' AS kind, s.uid AS item, e.uid AS target, ['REQUIREMENT_LEVEL_OR_BASIS_MISSING'] AS violations;

// V-F5-35 -- resolves CH-R-10; new (V-543p + V-543b); rule: two editions of one Protocol never share a payloadHash under one canonicalization version, and two editions with an identical ordered list of (stepKey, step payloadHash) are a cosmetic split (review).
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(e1:ProtocolEdition), (p)-[:HAS_PROTOCOL_EDITION]->(e2:ProtocolEdition)
WHERE elementId(e1) < elementId(e2) AND e1.payloadHash = e2.payloadHash
  AND coalesce(e1.payloadCanonicalizationVersion, '-') = coalesce(e2.payloadCanonicalizationVersion, '-')
RETURN 'V-F5-35' AS check, 'EDITIONS_SHARE_PAYLOAD_HASH' AS violation, p.uid AS item, [e1.uid, e2.uid] AS editions
UNION
MATCH (p:Protocol)-[:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition)
WITH p, e, COLLECT { MATCH (e)-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep) WITH o, s ORDER BY o.orderIndex, s.stepKey RETURN s.stepKey + '|' + coalesce(s.payloadHash, '-') } AS signature
WHERE size(signature) > 0
WITH p, signature, collect(e.uid) AS editions
WHERE size(editions) > 1
RETURN 'V-F5-35' AS check, 'IDENTICAL_STEP_LIST_COSMETIC_SPLIT' AS violation, p.uid AS item, editions;

// V-F5-36 -- resolves CH-R-11; new (V-525q); rule: every HAS_PROTOCOL_STEP carries an orderIndex, unique within the edition unless the two steps are linked by CONCURRENT_WITH.
MATCH (e:ProtocolEdition)-[o:HAS_PROTOCOL_STEP]->(s:ProtocolStep)
WHERE o.orderIndex IS NULL
RETURN 'V-F5-36' AS check, 'ORDER_INDEX_MISSING' AS violation, e.uid AS item, s.stepKey AS detail
UNION
MATCH (e:ProtocolEdition)-[o1:HAS_PROTOCOL_STEP]->(s1:ProtocolStep), (e)-[o2:HAS_PROTOCOL_STEP]->(s2:ProtocolStep)
WHERE elementId(o1) < elementId(o2) AND o1.orderIndex = o2.orderIndex
  AND NOT EXISTS { (s1)-[:DEPENDS_ON {dependencyKind: 'CONCURRENT_WITH'}]-(s2) }
RETURN 'V-F5-36' AS check, 'DUPLICATE_ORDER_INDEX' AS violation, e.uid AS item, s1.stepKey + ' = ' + s2.stepKey AS detail;

// V-F5-37 -- resolves CH-R-12d (the DiagnosticResult label half is Fable's); extends V-112r (licence half of V-302r); rule: a COMPARED_TO citing derivedFromAssessmentUids cites live ComparabilityAssessments with verdict COMPARABLE or COMPARABLE_WITH_CONVERSION that compare exactly the two producing versions of its endpoints.
MATCH (x)-[r:COMPARED_TO]->(y)
WHERE size(coalesce(r.derivedFromAssessmentUids, [])) > 0
UNWIND r.derivedFromAssessmentUids AS au
OPTIONAL MATCH (ca:EvidenceAssessment {uid: au})
WITH x, y, au, ca,
     [(x)-[:PRODUCED_BY_ASSAY_VERSION|COMPUTED_BY_ALGORITHM_VERSION]->(v) | v] + [(y)-[:PRODUCED_BY_ASSAY_VERSION|COMPUTED_BY_ALGORITHM_VERSION]->(v) | v] AS versions
WITH x, y, au, [v IN [
        CASE WHEN ca IS NULL OR NOT ca:ComparabilityAssessment THEN 'LICENCE_IS_NOT_A_COMPARABILITY_ASSESSMENT' END,
        CASE WHEN ca IS NOT NULL AND NOT coalesce(ca.verdict, '-') IN ['COMPARABLE', 'COMPARABLE_WITH_CONVERSION'] THEN 'LICENCE_VERDICT_DOES_NOT_PERMIT_COMPARISON' END,
        CASE WHEN ca IS NOT NULL AND (coalesce(ca.status, '-') IN ['REJECTED', 'SUPERSEDED'] OR ca.recordedTo IS NOT NULL) THEN 'LICENCE_NOT_CURRENT' END,
        CASE WHEN ca IS NOT NULL AND size(versions) > 0
                  AND (any(v IN versions WHERE NOT EXISTS { (ca)-[:COMPARES]->(v) }) OR COUNT { (ca)-[:COMPARES]->() } <> 2)
             THEN 'LICENCE_COMPARES_OTHER_VERSIONS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-37' AS check, x.uid AS fromUid, y.uid AS toUid, au AS licence, violations;

// V-F5-38 -- resolves CH-R-13 (validator half; migration and fixture are Fable's), CH-K-18b detection; new (V-544p); rule: HAS_STEP starts only at a ManufacturingProcess, and HAS_PROTOCOL_STEP is only ProtocolEdition -> ProtocolStep.
MATCH (a)-[r:HAS_STEP]->(b)
WHERE NOT a:ManufacturingProcess
RETURN 'V-F5-38' AS check, 'HAS_STEP_OUTSIDE_MANUFACTURING' AS violation, a.uid AS fromUid, b.uid AS toUid
UNION
MATCH (a)-[r:HAS_PROTOCOL_STEP]->(b)
WHERE NOT (a:ProtocolEdition AND b:ProtocolStep)
RETURN 'V-F5-38' AS check, 'HAS_PROTOCOL_STEP_WRONG_DOMAIN' AS violation, a.uid AS fromUid, b.uid AS toUid;

// V-F5-39 -- resolves CH-R-14; replaces V-542p (V-542q); rule: Protocol.currentSteps (HAS_CURRENT_PROTOCOL_STEP) are the steps of ONE edition of the protocol and their stepKeys are unique.
MATCH (p:Protocol)-[:HAS_CURRENT_PROTOCOL_STEP]->(s:ProtocolStep)
WITH p, collect(s) AS steps
WITH p, steps, [x IN steps | x.stepKey] AS keys
WITH p, steps, [k IN keys WHERE size([y IN keys WHERE y = k]) > 1] AS duplicated
WHERE size(duplicated) > 0
   OR NOT EXISTS { MATCH (p)-[:HAS_PROTOCOL_EDITION]->(e:ProtocolEdition) WHERE all(s IN steps WHERE EXISTS { (e)-[:HAS_PROTOCOL_STEP]->(s) }) }
RETURN 'V-F5-39' AS check, p.uid AS protocol, size(steps) AS currentSteps,
       reduce(acc = [], k IN duplicated | CASE WHEN k IN acc THEN acc ELSE acc + k END) AS duplicatedStepKeys;

// V-F5-40 -- resolves CH-R-15; extends V-539p and V-012 (V-545p); rule: HAS_PROTOCOL_EDITION goes from a Protocol to a ProtocolEdition that is not also a ProtocolVersion, and no node is both ProtocolEdition and ProtocolVersion.
MATCH (p)-[h:HAS_PROTOCOL_EDITION]->(e)
WHERE NOT p:Protocol OR NOT e:ProtocolEdition OR e:ProtocolVersion
RETURN 'V-F5-40' AS check, 'EDITION_TARGET_NOT_A_PROTOCOL_EDITION' AS violation, e.uid AS item, labels(e) AS labels
UNION
MATCH (n:ProtocolEdition:ProtocolVersion)
RETURN 'V-F5-40' AS check, 'PROTOCOL_EDITION_COLLAPSED_WITH_PROTOCOL_VERSION' AS violation, n.uid AS item, labels(n) AS labels;

// ------------------------------------------------- media and claims (W21/W22) -----------------------------------------

// V-F5-41 -- resolves CH-M-01, CH-M-02; replaces V-605 (allow-list form) and constrains MEDIA-EV-1; rule: EVIDENCES starts only at a MediaAsset whose generationMode is CAPTURED or EXTRACTED, that is neither synthetic nor edited, whose ORIGINAL rendition (and the asset itself) is not the output of a MEDIA_TRANSFORMATION (a BellLabs edit), and whose supporting snapshot is not on an operator store.
MATCH (m)-[e:EVIDENCES]->(x)
OPTIONAL MATCH (m)-[:HAS_MEDIA_VARIANT]->(o:MediaVariant {variantKind: 'ORIGINAL'})
WITH m, x, collect(o) AS originals
WITH m, x, [v IN [
        CASE WHEN NOT m:MediaAsset THEN 'EVIDENCING_NODE_IS_NOT_A_MEDIA_ASSET' END,
        CASE WHEN NOT coalesce(m.generationMode, 'UNKNOWN') IN ['CAPTURED', 'EXTRACTED'] THEN 'GENERATION_MODE_NOT_CAPTURED_OR_EXTRACTED' END,
        CASE WHEN coalesce(m.isSynthetic, false) OR coalesce(m.isEdited, false) THEN 'SYNTHETIC_OR_EDITED_ASSET' END,
        CASE WHEN EXISTS { (m)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'MEDIA_TRANSFORMATION'}) }
                  OR any(o IN originals WHERE EXISTS { (o)-[:WAS_GENERATED_BY]->(:Activity {activityKind: 'MEDIA_TRANSFORMATION'}) })
             THEN 'ORIGINAL_IS_A_BELLLABS_EDIT' END,
        CASE WHEN EXISTS { MATCH (x)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
                           WHERE any(pat IN $privateSourceUriPatterns WHERE coalesce(src.canonicalUri, '') =~ pat) }
             THEN 'SUPPORT_SNAPSHOT_ON_OPERATOR_STORE' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-41' AS check, m.uid AS evidencingAsset, x.uid AS evidenced, violations;

// V-F5-42 -- resolves CH-M-03; replaces V-605 branch 2 (keys on bytes, not edge names) and adds V-617; rule: no MediaAsset keeps the pre-CL-014 HAS_VARIANT edge, and no snapshot whose bytes equal a rendition of a GENERATED or synthetic asset backs a non-media assertion.
MATCH (m:MediaAsset)-[r:HAS_VARIANT]->(v)
RETURN 'V-F5-42' AS check, 'LEGACY_HAS_VARIANT_ON_MEDIA_ASSET' AS violation, m.uid AS item, v.uid AS detail
UNION
MATCH (m:MediaAsset)-[:HAS_VARIANT|HAS_MEDIA_VARIANT]->(v:MediaVariant)
WHERE (m.generationMode = 'GENERATED' OR coalesce(m.isSynthetic, false)) AND v.contentHash IS NOT NULL
MATCH (ss:SourceSnapshot {contentHash: v.contentHash})-[:HAS_LOCATOR]->(:SourceLocator)<-[:SUPPORTED_BY]-(x:Assertion)
WHERE NOT x.predicate IN ['DEPICTS', 'EXPLAINS', 'VISUALIZES', 'ANNOTATES_SUBJECT', 'HAS_RIGHTS_RECORD']
RETURN DISTINCT 'V-F5-42' AS check, 'GENERATED_BYTES_SUPPORT_NON_MEDIA_ASSERTION' AS violation, m.uid AS item, x.uid AS detail;

// V-F5-43 -- resolves CH-M-04; replaces V-604 (V-604r); rule: an EVIDENCES edge names MEDIA-EV-1 and its input assertion, and the full MEDIA-EV-1 path exists: assertion -> IMAGE_REGION locator hanging from a SourceSnapshot whose bytes equal the ORIGINAL rendition of the evidencing asset that carries the annotated region (or the panel's own region).
MATCH (m)-[e:EVIDENCES]->(x)
WHERE e.derivationRule IS NULL OR NOT x.uid IN coalesce(e.derivedFromAssertionUids, [])
   OR NOT (
     EXISTS { MATCH (x)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(ann:MediaAnnotation)<-[:HAS_ANNOTATION]-(v:MediaVariant {variantKind: 'ORIGINAL'})<-[:HAS_MEDIA_VARIANT]-(m)
              MATCH (ss:SourceSnapshot)-[:HAS_LOCATOR]->(l)
              WHERE l.mediaAnnotationUid = ann.uid AND v.contentHash = ss.contentHash }
     OR EXISTS { MATCH (x)-[:SUPPORTED_BY]->(l:SourceLocator {selectorKind: 'IMAGE_REGION'})-[:LOCATES_REGION]->(:MediaAnnotation)<-[:FROM_ANNOTATION]-(m)
                 MATCH (:SourceSnapshot)-[:HAS_LOCATOR]->(l) })
RETURN 'V-F5-43' AS check, m.uid AS evidencingAsset, x.uid AS evidenced, e.derivationRule AS rule;

// V-F5-44 -- resolves CH-M-06; extends V-W21-01 (V-W21-01b); rule: two locators on snapshots of DIFFERENT renditions of one Episode never carry the same media start, end and time basis (a rendition's timecode is never copied to another rendition).
MATCH (ep:Episode)<-[:RENDITION_OF]-(s1:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l1:SourceLocator),
      (ep)<-[:RENDITION_OF]-(s2:Source)-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(l2:SourceLocator)
WHERE s1 <> s2 AND elementId(l1) < elementId(l2) AND l1.mediaStartSeconds IS NOT NULL
  AND l1.mediaStartSeconds = l2.mediaStartSeconds AND coalesce(l1.mediaEndSeconds, -1.0) = coalesce(l2.mediaEndSeconds, -1.0)
  AND coalesce(l1.mediaTimeBasis, '-') = coalesce(l2.mediaTimeBasis, '-')
RETURN 'V-F5-44' AS check, ep.uid AS episode, l1.uid AS locator1, s1.sourceKind AS rendition1, l2.uid AS locator2, s2.sourceKind AS rendition2,
       l1.mediaStartSeconds AS mediaStartSeconds, l1.mediaTimeBasis AS basis;

// V-F5-45 -- (review) resolves CH-M-07; new (V-W21-13); rule: an assertion that is INSTANCE_OF a Claim and reports someone else's speech act (reportedSpeechAct set, or ATTRIBUTES_TO someone other than its asserter) is a retelling and must carry RETELLS, or it is counted as first-hand.
MATCH (a:Assertion)-[:INSTANCE_OF]->(c:Claim)
WHERE NOT EXISTS { (a)-[:RETELLS]->() } AND coalesce(a.speechAct, '-') <> 'QUESTIONS'
  AND (a.reportedSpeechAct IS NOT NULL OR EXISTS { MATCH (a)-[:ATTRIBUTES_TO]->(w) WHERE NOT EXISTS { (a)-[:ASSERTED_BY]->(w) } })
RETURN 'V-F5-45' AS check, a.uid AS assertion, c.uid AS claim, a.reportedSpeechAct AS reportedSpeechAct, 'UNLINKED_RETELLING' AS violation;

// V-F5-46 -- resolves CH-M-08; new (V-W21-14); rule: two live (not SUPERSEDED/REJECTED) instances of one Claim with the same asserter and container that share a locator, an equal quoteHash, or an overlapping media span on one snapshot are one utterance captured twice.
MATCH (a1:Assertion)-[:INSTANCE_OF]->(c:Claim)<-[:INSTANCE_OF]-(a2:Assertion)
WHERE elementId(a1) < elementId(a2)
  AND NOT coalesce(a1.status, '-') IN ['SUPERSEDED', 'REJECTED'] AND NOT coalesce(a2.status, '-') IN ['SUPERSEDED', 'REJECTED']
  AND EXISTS { MATCH (a1)-[:ASSERTED_BY]->(w)<-[:ASSERTED_BY]-(a2) }
  AND EXISTS { MATCH (a1)-[:OCCURS_IN]->(k)<-[:OCCURS_IN]-(a2) }
  AND (EXISTS { MATCH (a1)-[:SUPPORTED_BY]->(:SourceLocator)<-[:SUPPORTED_BY]-(a2) }
       OR (a1.quoteHash IS NOT NULL AND a1.quoteHash = a2.quoteHash)
       OR EXISTS { MATCH (a1)-[:SUPPORTED_BY]->(l1:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)-[:HAS_LOCATOR]->(l2:SourceLocator)<-[:SUPPORTED_BY]-(a2)
                   WHERE l1.mediaStartSeconds IS NOT NULL AND l2.mediaStartSeconds IS NOT NULL
                     AND l1.mediaStartSeconds < coalesce(l2.mediaEndSeconds, l2.mediaStartSeconds + 0.001)
                     AND l2.mediaStartSeconds < coalesce(l1.mediaEndSeconds, l1.mediaStartSeconds + 0.001) })
RETURN 'V-F5-46' AS check, c.uid AS claim, a1.uid AS occurrence1, a2.uid AS occurrence2, 'DUPLICATE_CAPTURE_OF_ONE_UTTERANCE' AS violation;

// V-F5-47 -- resolves CH-M-09, CH-M-10, CH-M-17; replaces kernel V-423 (RETIRED: it fires on the valid fx07 projection; CL-016) and V-W21-06/V-423r; rule: a RECOMMENDS edge derives from exactly one live Assertion asserted by the start node whose own speechAct is RECOMMENDS with polarity POSITIVE, that is not a sponsor read (segmentKind/assertionBasis SPONSOR_READ or OCCURS_IN_SEGMENT a SPONSOR_READ segment), and whose subject or object is the end node; the legacy assertionUid is accepted only as the migration fallback V-W00-02r reports.
MATCH (p)-[rec:RECOMMENDS]->(x)
WITH p, x, rec, coalesce(rec.derivedFromAssertionUids, CASE WHEN rec.assertionUid IS NULL THEN [] ELSE [rec.assertionUid] END) AS cited
WHERE size(cited) <> 1
   OR (rec.assertionUid IS NULL AND rec.derivationRule IS NULL)
   OR NOT EXISTS {
     MATCH (a:Assertion)-[:ASSERTED_BY]->(p)
     WHERE a.uid = cited[0] AND a.speechAct = 'RECOMMENDS' AND NOT coalesce(a.status, '-') IN ['REJECTED', 'SUPERSEDED']
       AND coalesce(a.polarity, 'UNKNOWN') = 'POSITIVE'
       AND coalesce(a.segmentKind, '-') <> 'SPONSOR_READ' AND coalesce(a.assertionBasis, '-') <> 'SPONSOR_READ'
       AND NOT EXISTS { (a)-[:OCCURS_IN_SEGMENT]->(:EpisodeSegment {segmentType: 'SPONSOR_READ'}) }
       AND (EXISTS { (a)-[:HAS_SUBJECT]->(x) } OR EXISTS { (a)-[:HAS_OBJECT]->(x) })
   }
RETURN 'V-F5-47' AS check, p.uid AS recommenderUid, x.uid AS recommendedUid, cited;

// V-F5-48 -- resolves CH-M-11; extends V-W21-02 (V-W21-02b); rule: an occurrence whose media-time locator lies inside the delimiting interval of a SPONSOR_READ segment on the same rendition carries segmentKind SPONSOR_READ and OCCURS_IN_SEGMENT that segment.
MATCH (a:ClaimOccurrence)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
WHERE l.mediaStartSeconds IS NOT NULL
MATCH (g:EpisodeSegment {segmentType: 'SPONSOR_READ'})-[:DELIMITED_BY]->(d:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src)
WITH a, l, g, min(d.mediaStartSeconds) AS segStart, max(coalesce(d.mediaEndSeconds, d.mediaStartSeconds)) AS segEnd
WHERE l.mediaStartSeconds >= segStart AND l.mediaStartSeconds < segEnd
  AND (coalesce(a.segmentKind, '-') <> 'SPONSOR_READ' OR NOT EXISTS { (a)-[:OCCURS_IN_SEGMENT]->(g) })
RETURN 'V-F5-48' AS check, a.uid AS occurrence, l.mediaStartSeconds AS at, g.uid AS sponsorSegment, segStart, segEnd;

// V-F5-49 -- resolves CH-M-12; extends V-W21-08 (V-W21-08b interim form); rule: when a span cited by a live quantitative assertion is re-anchored non-exactly (FUZZY, or textChange SUBSTANTIVE) and the numbers or quantity words differ between the cited and the re-anchored text, the assertion has a SUPERSEDES {SOURCE_CORRECTION} successor.
MATCH (cur:SourceLocator)-[ra:REANCHORS]->(old:SourceLocator)<-[:SUPPORTED_BY]-(a:Assertion)
WHERE (coalesce(ra.anchorMatch, '-') <> 'EXACT' OR ra.textChange = 'SUBSTANTIVE')
  AND NOT coalesce(a.status, '-') IN ['SUPERSEDED', 'REJECTED']
  AND (a.valueNumber IS NOT NULL OR a.quantity IS NOT NULL OR a.valueString IS NOT NULL)
  AND NOT EXISTS { MATCH (:Assertion)-[s:SUPERSEDES]->(a) WHERE s.supersessionKind = 'SOURCE_CORRECTION' }
WITH a, old, cur, ra,
     [t IN split(reduce(x = toLower(coalesce(old.exact, '')), c IN [',', '.', ';', ':', '!', '?', '(', ')', '"', '\'', '-', '/', '–'] | replace(x, c, ' ')), ' ')
        WHERE t =~ '\\d+' OR t IN $numberWords OR t IN $quantityWords] AS oldNums,
     [t IN split(reduce(x = toLower(coalesce(cur.exact, '')), c IN [',', '.', ';', ':', '!', '?', '(', ')', '"', '\'', '-', '/', '–'] | replace(x, c, ' ')), ' ')
        WHERE t =~ '\\d+' OR t IN $numberWords OR t IN $quantityWords] AS newNums
WHERE ra.textChange = 'SUBSTANTIVE' OR any(t IN oldNums WHERE NOT t IN newNums) OR any(t IN newNums WHERE NOT t IN oldNums)
RETURN 'V-F5-49' AS check, a.uid AS assertion, old.uid AS citedLocator, cur.uid AS reanchoredLocator, oldNums, newNums,
       'SUBSTANTIVE_CHANGE_WITHOUT_SOURCE_CORRECTION' AS violation;

// V-F5-50 -- resolves CH-M-13; new (V-W19-xx); rule: a bibliographic record is never a rendition of a work, and an abstract-only rendition (BIBLIOGRAPHIC_RECORD kind or $abstractOnlyUriPatterns) never claims renditionCoverage FULL.
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, w, [v IN [
        CASE WHEN s.sourceKind = 'BIBLIOGRAPHIC_RECORD' THEN 'BIBLIOGRAPHIC_RECORD_AS_RENDITION' END,
        CASE WHEN s.renditionCoverage = 'FULL' AND (s.sourceKind = 'BIBLIOGRAPHIC_RECORD' OR any(pat IN $abstractOnlyUriPatterns WHERE coalesce(s.canonicalUri, '') =~ pat))
             THEN 'FULL_COVERAGE_ON_ABSTRACT_ONLY_RENDITION' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-50' AS check, s.uid AS rendition, w.uid AS work, violations;

// V-F5-51 -- resolves CH-M-14; new (V-618, Community form of media_rights_record_*_exists); rule: every MediaRightsRecord states rightsStatus, statementKind and statementScope (unknown rights are never permission).
MATCH (r:MediaRightsRecord)
WHERE r.rightsStatus IS NULL OR r.statementKind IS NULL OR r.statementScope IS NULL
RETURN 'V-F5-51' AS check, r.uid AS rightsRecord, r.rightsStatus AS rightsStatus, r.statementKind AS statementKind, r.statementScope AS statementScope;

// V-F5-52 -- resolves CH-M-15; extends V-608b; rule: a DISPLAY_MEDIA use never displays an asset whose current rights record forbids commercial use (unless the PolicyVersion's useClass is NON_COMMERCIAL), and a non-ORIGINAL rendition is displayed only when a current record allows derivatives (or the status is PUBLIC_DOMAIN / HELD_BY_OPERATOR).
MATCH (act:Activity)-[u:AUTHORIZED_BY]->(pv:PolicyVersion)
WHERE u.useKind = 'DISPLAY_MEDIA'
MATCH (act)-[:USED]->(v:MediaVariant)<-[:HAS_MEDIA_VARIANT]-(m:MediaAsset)
OPTIONAL MATCH (m)-[h:HAS_RIGHTS_RECORD]->(r:MediaRightsRecord)
WHERE h.recordedTo IS NULL AND h.validTo IS NULL
WITH act, pv, v, m, collect(r) AS records
WITH act, v, m, [x IN [
        CASE WHEN any(r IN records WHERE r.commercialUseAllowed = false) AND coalesce(pv.useClass, 'COMMERCIAL') = 'COMMERCIAL' THEN 'COMMERCIAL_USE_NOT_PERMITTED' END,
        CASE WHEN coalesce(v.variantKind, '-') <> 'ORIGINAL'
                  AND NOT any(r IN records WHERE r.derivativesAllowed = true OR r.rightsStatus IN ['PUBLIC_DOMAIN', 'HELD_BY_OPERATOR'])
             THEN 'DERIVATIVE_DISPLAY_NOT_PERMITTED' END
     ] WHERE x IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-52' AS check, act.uid AS activity, m.uid AS asset, v.variantKind AS displayedRendition, violations;

// V-F5-53 -- resolves CH-M-16; promotes W19 Q-03 (CL-003 R3); rule: a Source renders at most one work, and RENDITION_OF ends on an Episode or Publication (never another Source).
MATCH (s:Source)-[:RENDITION_OF]->(w)
WITH s, collect(DISTINCT w) AS works
WHERE size(works) > 1 OR any(w IN works WHERE w:Source OR NOT (w:Episode OR w:Publication))
RETURN 'V-F5-53' AS check, s.uid AS rendition, [w IN works | w.uid] AS works;

// ------------------------------------------------- kernel (W00) -------------------------------------------------------

// V-F5-54 -- resolves CH-K-01a; replaces V-504 first branch (all asserted edge types, not five episode types); rule: an edge that names its authorizing assertion is never recorded before that assertion was recorded nor before any snapshot supporting the assertion was retrieved.
MATCH (x)-[r]->(y)
WHERE r.assertionUid IS NOT NULL AND r.recordedFrom IS NOT NULL
MATCH (a:Assertion {uid: r.assertionUid})
WITH r, a, [(a)-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(s:SourceSnapshot) WHERE s.retrievedAt IS NOT NULL AND s.retrievedAt > r.recordedFrom | s.uid] AS laterSnapshots
WHERE (a.recordedAt IS NOT NULL AND r.recordedFrom < a.recordedAt) OR size(laterSnapshots) > 0
RETURN 'V-F5-54' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS episode, a.uid AS assertion,
       r.recordedFrom AS recordedFrom, a.recordedAt AS assertionRecordedAt, laterSnapshots;

// V-F5-55 -- resolves CH-K-02b; new (V-504b); rule: a record WAS_GENERATED_BY an Activity is never recorded before that activity started (PROV-O generation inside the activity; recorded time is never backdated).
MATCH (x)-[:WAS_GENERATED_BY]->(act:Activity)
WITH x, act, coalesce(x.recordedAt, x.recordedFrom) AS recorded
WHERE recorded IS NOT NULL AND act.startedAt IS NOT NULL AND recorded < act.startedAt
RETURN 'V-F5-55' AS check, x.uid AS item, act.uid AS activity, recorded, act.startedAt AS activityStartedAt;

// V-F5-56 -- resolves CH-K-03a; new (V-507c); rule: a SOURCE_CORRECTION or SOURCE_REVISION supersession that names a sourceRevisionEventUid resolves to a SourceRevisionEvent, and one that names none never has the fact-ending shape (same object and validFrom, the older open-ended, the newer only closing validTo), which must be VALIDITY_BOUNDED.
MATCH (n:Assertion)-[s:SUPERSEDES]->(o:Assertion)
WHERE s.supersessionKind IN ['SOURCE_CORRECTION', 'SOURCE_REVISION']
WITH n, s, o,
     s.sourceRevisionEventUid IS NOT NULL AND NOT EXISTS { MATCH (:SourceRevisionEvent {uid: s.sourceRevisionEventUid}) } AS unresolved,
     s.sourceRevisionEventUid IS NULL
       AND [(n)-[:HAS_OBJECT]->(x) | x.uid] = [(o)-[:HAS_OBJECT]->(x) | x.uid]
       AND coalesce(toString(n.validFrom), '-') = coalesce(toString(o.validFrom), '-')
       AND coalesce(toString(n.valueNumber), '-') = coalesce(toString(o.valueNumber), '-')
       AND coalesce(n.valueString, '-') = coalesce(o.valueString, '-')
       AND o.validTo IS NULL AND n.validTo IS NOT NULL AS endingShape
WHERE unresolved OR endingShape
RETURN 'V-F5-56' AS check, n.uid AS newer, o.uid AS older, s.supersessionKind AS kind,
       CASE WHEN unresolved THEN 'SOURCE_REVISION_EVENT_MISSING' ELSE 'FACT_ENDING_RECORDED_AS_CORRECTION' END AS violation;

// V-F5-57 -- resolves CH-K-04; compiles packet V-W00-06; rule: an Assertion is immutable after commit (INV-501/INV-504 analogue): updatedAt never exceeds createdAt; a change of valid time is a new assertion that SUPERSEDES the old one.
MATCH (a:Assertion)
WHERE a.updatedAt IS NOT NULL AND a.createdAt IS NOT NULL AND a.updatedAt > a.createdAt
RETURN 'V-F5-57' AS check, a.uid AS assertion, a.createdAt AS createdAt, a.updatedAt AS updatedAt, 'ASSERTION_EDITED_IN_PLACE' AS violation;

// V-F5-58 -- resolves CH-K-05b, CH-K-05c, CH-K-05d, CH-K-05e; replaces V-104 and V-502 (all temporal properties of all nodes and relationships); rule: no temporal value is a sentinel: year >= 9000, year <= 1, or the Unix epoch 1970-01-01T00:00Z (open and unknown bounds are null).
WITH ['validFrom', 'validTo', 'recordedAt', 'recordedFrom', 'recordedTo', 'effectiveFrom', 'effectiveTo', 'startedAt', 'endedAt', 'observedAt',
      'retrievedAt', 'publishedAt', 'reviewedAt', 'createdAt', 'updatedAt', 'derivedAt', 'reportedAt', 'intervalStart', 'intervalEnd',
      'recordedAsOf', 'validAt', 'evidenceCutoff', 'migratedAt'] AS tk
MATCH (n)
WITH n, [k IN keys(n) WHERE k IN tk AND (n[k] IS :: DATE OR n[k] IS :: ZONED DATETIME OR n[k] IS :: LOCAL DATETIME)
                            AND (n[k].year >= 9000 OR n[k].year <= 1 OR (n[k].year = 1970 AND n[k].month = 1 AND n[k].day = 1
                                 AND (n[k] IS :: DATE OR (n[k].hour = 0 AND n[k].minute = 0 AND n[k].second = 0))))] AS sentinels
WHERE size(sentinels) > 0
RETURN 'V-F5-58' AS check, 'NODE' AS kind, coalesce(n.uid, elementId(n)) AS item, sentinels
UNION
WITH ['validFrom', 'validTo', 'recordedAt', 'recordedFrom', 'recordedTo', 'effectiveFrom', 'effectiveTo', 'startedAt', 'endedAt', 'observedAt',
      'retrievedAt', 'publishedAt', 'reviewedAt', 'createdAt', 'updatedAt', 'derivedAt', 'reportedAt', 'evidencePublishedAt'] AS tk
MATCH ()-[r]->()
WITH r, [k IN keys(r) WHERE k IN tk AND (r[k] IS :: DATE OR r[k] IS :: ZONED DATETIME OR r[k] IS :: LOCAL DATETIME)
                            AND (r[k].year >= 9000 OR r[k].year <= 1 OR (r[k].year = 1970 AND r[k].month = 1 AND r[k].day = 1
                                 AND (r[k] IS :: DATE OR (r[k].hour = 0 AND r[k].minute = 0 AND r[k].second = 0))))] AS sentinels
WHERE size(sentinels) > 0
RETURN 'V-F5-58' AS check, 'RELATIONSHIP' AS kind, coalesce(r.relationshipUid, elementId(r)) AS item, sentinels;

// V-F5-59 -- resolves CH-K-06; compiles packet V-W00-01 (generalizes V-410's asserter half to every Assertion); rule: an Assertion has at most one ASSERTED_BY (INV-003, contract A.3).
MATCH (a:Assertion)-[:ASSERTED_BY]->(w)
WITH a, collect(DISTINCT coalesce(w.uid, elementId(w))) AS asserters, count(*) AS edges
WHERE edges > 1
RETURN 'V-F5-59' AS check, a.uid AS assertion, asserters, edges;

// V-F5-60 -- resolves CH-K-07b, CH-K-07c; new (V-402b); rule: every SourceSnapshot belongs to exactly one Source (one incoming HAS_SNAPSHOT) and that Source has a canonicalUri, so every locator is reproducible from a retrieval endpoint.
MATCH (s:SourceSnapshot)
WITH s, [(src)-[:HAS_SNAPSHOT]->(s) | src] AS sources
WHERE size(sources) <> 1 OR NOT sources[0]:Source OR sources[0].canonicalUri IS NULL
RETURN 'V-F5-60' AS check, s.uid AS snapshot, [x IN sources | x.uid] AS sources,
       CASE WHEN size(sources) = 0 THEN 'SNAPSHOT_WITHOUT_SOURCE' WHEN size(sources) > 1 THEN 'SNAPSHOT_CLAIMED_BY_SEVERAL_SOURCES'
            ELSE 'SOURCE_WITHOUT_CANONICAL_URI' END AS violation;

// V-F5-61 -- resolves CH-K-11b, CH-K-11c; replaces V-117 (V-117r) and compiles V-W00-08; rule: the live id is read from the property of the node's own type (Document documentId, DocumentTextVersion documentTextVersionId, Segmentation segmentationId, Chunk chunkId, otherwise id); every uid-bearing archetype node has it, it equals the uid's opaque segment, and a Document-family node carries no stray `id` that differs from its alias.
MATCH (n)
WHERE n.uid IS NOT NULL AND NOT n:PrivateRecord
  AND (n:Entity OR n:VersionedState OR n:Occurrence OR n:InformationArtifact OR n:Assertion OR n:EvidenceAssessment)
WITH n, CASE WHEN n:Document THEN n.documentId WHEN n:DocumentTextVersion THEN n.documentTextVersionId WHEN n:Segmentation THEN n.segmentationId
             WHEN n:Chunk THEN n.chunkId ELSE n.id END AS liveId,
     (n:Document OR n:DocumentTextVersion OR n:Segmentation OR n:Chunk) AS aliased
WITH n, liveId, [v IN [
        CASE WHEN liveId IS NULL THEN 'LIVE_ID_MISSING' END,
        CASE WHEN liveId IS NOT NULL AND NOT n.uid ENDS WITH (':' + liveId) THEN 'LIVE_ID_DIFFERS_FROM_UID_SEGMENT' END,
        CASE WHEN aliased AND n.id IS NOT NULL AND n.id <> coalesce(liveId, '') THEN 'STRAY_ID_DIFFERS_FROM_ALIAS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-F5-61' AS check, labels(n) AS labels, n.uid AS uid, liveId, violations;

// V-F5-62 -- resolves CH-K-12b, CH-K-12c; replaces V-W00-16 (V-W00-16r); rule: the uid token is the registered token of the node's own domain label (archetype labels count only when the node has no tokened domain label); a 0.2.0 alias token is a migration item only when $uidAliasTokenLabels maps it to one of the node's labels, otherwise it is a violation.
MATCH (n)
WHERE n.uid IS NOT NULL AND n.uid STARTS WITH 'hu:' AND NOT n.uid STARTS WITH 'hu:private-' AND NOT n:PrivateRecord
WITH n, split(n.uid, ':')[1] AS token,
     [l IN labels(n) WHERE NOT l IN ['Entity', 'VersionedState', 'Occurrence', 'InformationArtifact', 'Assertion', 'EvidenceAssessment'] AND $uidTypeTokens[l] IS NOT NULL | $uidTypeTokens[l]] AS domainTokens,
     [l IN labels(n) WHERE $uidTypeTokens[l] IS NOT NULL | $uidTypeTokens[l]] AS anyTokens
WITH n, token, CASE WHEN size(domainTokens) > 0 THEN domainTokens ELSE anyTokens END AS expected
WHERE NOT token IN expected
  AND NOT any(l IN coalesce($uidAliasTokenLabels[token], []) WHERE l IN labels(n))
RETURN 'V-F5-62' AS check, n.uid AS uid, labels(n) AS labels, token, expected,
       CASE WHEN token IN $uidAliasTokens THEN 'ALIAS_TOKEN_OF_ANOTHER_TYPE' WHEN size(expected) = 0 THEN 'LABEL_HAS_NO_TOKEN'
            ELSE 'TOKEN_NOT_REGISTERED_FOR_PRIMARY_LABEL' END AS violation;

// V-F5-63 -- resolves CH-K-14b, CH-K-14c; extends V-102/V-103/V-501 to every interval pair on nodes and relationships, and V-506/V-507 to strict order; rule: every half-open interval is non-empty (from < to) for (validFrom, validTo), (recordedAt, recordedTo), (recordedFrom, recordedTo), (effectiveFrom, effectiveTo), (startedAt, endedAt), (intervalStart, intervalEnd); a superseding assertion is recorded strictly after the one it supersedes.
WITH [['validFrom', 'validTo'], ['recordedAt', 'recordedTo'], ['recordedFrom', 'recordedTo'], ['effectiveFrom', 'effectiveTo'], ['startedAt', 'endedAt'], ['intervalStart', 'intervalEnd']] AS pairs
MATCH (n)
WITH n, [p IN pairs WHERE n[p[0]] IS NOT NULL AND n[p[1]] IS NOT NULL AND n[p[0]] >= n[p[1]] | p[0] + '>=' + p[1]] AS empty
WHERE size(empty) > 0
RETURN 'V-F5-63' AS check, 'NODE_INTERVAL_EMPTY' AS violation, coalesce(n.uid, elementId(n)) AS item, empty AS detail
UNION
WITH [['validFrom', 'validTo'], ['recordedFrom', 'recordedTo'], ['effectiveFrom', 'effectiveTo']] AS pairs
MATCH ()-[r]->()
WITH r, [p IN pairs WHERE r[p[0]] IS NOT NULL AND r[p[1]] IS NOT NULL AND r[p[0]] >= r[p[1]] | p[0] + '>=' + p[1]] AS empty
WHERE size(empty) > 0
RETURN 'V-F5-63' AS check, 'RELATIONSHIP_INTERVAL_EMPTY' AS violation, coalesce(r.relationshipUid, elementId(r)) AS item, empty AS detail
UNION
MATCH (n:Assertion)-[:SUPERSEDES]->(o:Assertion)
WHERE n.recordedAt IS NOT NULL AND o.recordedAt IS NOT NULL AND n.recordedAt <= o.recordedAt
RETURN 'V-F5-63' AS check, 'SUPERSESSION_NOT_STRICTLY_LATER' AS violation, n.uid AS item, [o.uid] AS detail;

// V-F5-64 -- resolves CH-K-15; new (V-514c); rule: every Assertion predicate is a controlled string registered in the catalog ($registeredPredicates = catalog assertedPredicates and relationship names, final SDL relationship types, W00 predicate-registry REGISTERED/CANDIDATE/CONFIRMED).
MATCH (a:Assertion)
WHERE a.predicate IS NULL OR NOT a.predicate IN $registeredPredicates
RETURN 'V-F5-64' AS check, a.uid AS assertion, a.predicate AS predicate, 'PREDICATE_NOT_REGISTERED' AS violation;

// V-F5-65 -- resolves CH-K-17c; new (V-101b); rule: a relationshipUid is a stable audit id: it names exactly one relationship across ALL relationship types (the per-type constraints cannot see cross-type reuse or types without a constraint).
MATCH ()-[r]->()
WHERE r.relationshipUid IS NOT NULL
WITH r.relationshipUid AS relationshipUid, collect(type(r)) AS types
WHERE size(types) > 1
RETURN 'V-F5-65' AS check, relationshipUid, types;
