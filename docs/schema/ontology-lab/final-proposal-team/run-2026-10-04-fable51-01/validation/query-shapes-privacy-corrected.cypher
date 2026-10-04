// =====================================================================================================================
// query-shapes-privacy-corrected.cypher -- PUBLIC_ANSWER forms of QS-5b, QS-6a and QS-8 (validation/query-shapes-extracted.cypher)
// and the corrected corroboration count Q04-1 (workers/W21/fixtures/fx04-...queries.cypher). run-2026-10-04-fable51-01, 2026-10-04.
// Resolves CH-P-15a/b/c/d, CH-P-12 (query half), CH-P-01/02 (traversal half) and CH-M-07/CH-M-08 (count half).
// F-W5-11: the instance test is an ALLOW-LIST on every node of the path: privacyClass = 'PUBLIC' exactly (null, INTERNAL,
// 'private-personal', 'PRIVATE-PERSONAL', 'synthetic' all fail closed), never :PrivateRecord, never a label of the INTERNAL layer
// ($publicAnswerExcludedLabels), and no uid carrying a private-store token ($privateUidTokens, escaped into one regex). An edge
// that states a privacyClass must state PUBLIC. Temporal parameters are coerced with datetime() (the shipped shapes compared a
// datetime with the string in validation-params.json, which is null and silently drops every recorded-time filter).
// Parameters: validation-params.json + fable-w5-params.json + qs-params.json; QS-5b adds $rootUid, $allowedLabels, $allowedRelTypes,
// $maxRelationships; QS-8 adds $indexName, $phrase, $limit. Every statement is standalone.
// =====================================================================================================================

// QS-5b (privacy-corrected, F-W5-11)
// Data query a compiler emits from a purpose-bound projection request; the quantifier bound {1,3} is the compiler's literal.
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS privateUid
MATCH (root {uid: $rootUid})
WHERE root.privacyClass = 'PUBLIC' AND NOT root:PrivateRecord AND NOT root.uid =~ privateUid
  AND none(l IN labels(root) WHERE l IN $publicAnswerExcludedLabels)
  AND any(l IN labels(root) WHERE l IN $allowedLabels)
MATCH p = (root)((a)-[r]->(b)
               WHERE b.privacyClass = 'PUBLIC' AND NOT b:PrivateRecord
                 AND none(l IN labels(b) WHERE l IN $publicAnswerExcludedLabels)
                 AND coalesce(r.privacyClass, 'PUBLIC') = 'PUBLIC'
                 AND type(r) IN $allowedRelTypes
                 AND any(l IN labels(b) WHERE l IN $allowedLabels)
                 AND (r.recordedFrom IS NULL
                      OR (r.recordedFrom <= datetime($recordedAsOf) AND (r.recordedTo IS NULL OR datetime($recordedAsOf) < r.recordedTo)))
                 AND (r.validFrom IS NULL OR r.validFrom <= datetime($validAt))
                 AND (r.validTo IS NULL OR datetime($validAt) < r.validTo)){1,3}(leaf)
WITH p, privateUid
WHERE none(n IN nodes(p) WHERE coalesce(n.uid, '') =~ privateUid)
RETURN [n IN nodes(p) | n.uid] AS nodeUids,
       [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT $maxRelationships;

// QS-6a (privacy-corrected, F-W5-11)
// Shared-graph traversal (both directions, every hop allow-listed) that cannot enter private, INTERNAL or unclassified records;
// $privateRelTypes stays as defence in depth. $maxHops is the compiler-substituted literal 2.
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS privateUid
MATCH (s {uid: $uid})
WHERE s.privacyClass = 'PUBLIC' AND NOT s:PrivateRecord AND NOT s.uid =~ privateUid
  AND none(l IN labels(s) WHERE l IN $publicAnswerExcludedLabels)
MATCH p = (s)(()-[r]-(n)
              WHERE n.privacyClass = 'PUBLIC' AND NOT n:PrivateRecord
                AND none(l IN labels(n) WHERE l IN $publicAnswerExcludedLabels)
                AND coalesce(r.privacyClass, 'PUBLIC') = 'PUBLIC'
                AND NOT type(r) IN $privateRelTypes){1,2}
WITH p, privateUid
WHERE none(x IN nodes(p) WHERE coalesce(x.uid, '') =~ privateUid)
RETURN DISTINCT [x IN nodes(p) | x.uid] AS nodeUids, [rel IN relationships(p) | type(rel)] AS relTypes
LIMIT 500;

// QS-8 (privacy-corrected, F-W5-11)
// Free text to candidate identities. The index has no instance filter, so the allow-list is applied to every hit BEFORE ranking and
// LIMIT (a hit is a candidate, never an identity). Open ResolutionHypothesis records are INTERNAL and are not joined in the
// PUBLIC_ANSWER form; the operator form keeps the hypothesis join behind OPERATOR_AUDIT.
WITH '(?is).*\\b(' + reduce(acc = '', t IN $privateUidTokens |
        acc + CASE WHEN acc = '' THEN '' ELSE '|' END
            + reduce(e = t, c IN ['\\', '.', '+', '*', '?', '(', ')', '[', ']', '{', '}', '|', '^', '$'] | replace(e, c, '\\' + c))) + ').*' AS privateUid
CALL db.index.fulltext.queryNodes($indexName, $phrase) YIELD node, score
WITH node, score, privateUid
WHERE node.privacyClass = 'PUBLIC' AND NOT node:PrivateRecord AND NOT coalesce(node.uid, '') =~ privateUid
  AND none(l IN labels(node) WHERE l IN $publicAnswerExcludedLabels)
WITH node, score
ORDER BY score DESC
LIMIT $limit
RETURN node.uid AS catalogUid,
       coalesce(node.id, node.documentId, node.chunkId, node.documentTextVersionId, node.segmentationId) AS liveId,
       labels(node) AS labels,
       node.name AS name,
       score AS indexScore
ORDER BY indexScore DESC;

// Q04-1 (corroboration-corrected, CH-M-07, CH-M-08)
// Per Claim: live instances (SUPERSEDED and REJECTED excluded), first-hand instances (no RETELLS, no reportedSpeechAct, no
// ATTRIBUTES_TO anyone but the asserter, not a QUESTIONS act), and independent first-hand lines counted by DISTINCT asserter, so a
// second capture of one utterance, a speaker's talk plus his own slide, and an unlinked retelling never raise independent support.
MATCH (c:Claim)
OPTIONAL MATCH (a:Assertion)-[:INSTANCE_OF]->(c)
WHERE NOT coalesce(a.status, '-') IN ['SUPERSEDED', 'REJECTED']
WITH c, collect(DISTINCT a) AS live
WITH c, live,
     [x IN live WHERE NOT EXISTS { (x)-[:RETELLS]->() } AND x.reportedSpeechAct IS NULL AND coalesce(x.speechAct, '-') <> 'QUESTIONS'
                  AND NOT EXISTS { MATCH (x)-[:ATTRIBUTES_TO]->(w) WHERE NOT EXISTS { (x)-[:ASSERTED_BY]->(w) } }] AS firstHand
UNWIND (CASE WHEN size(firstHand) = 0 THEN [null] ELSE firstHand END) AS f
OPTIONAL MATCH (f)-[:ASSERTED_BY]->(who)
WITH c, live, firstHand, collect(DISTINCT who.uid) AS asserters
RETURN c.claimText AS claim, size(live) AS liveInstances, size(firstHand) AS firstHandInstances,
       size(live) - size(firstHand) AS secondHandInstances,
       size(asserters) AS independentFirstHandLines, asserters AS firstHandAsserters
ORDER BY claim;
