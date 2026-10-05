// W23 fixture 13 (queries): three public-tier instance filters over the same 1..2-hop neighbourhood of PUBLIC assertion A2.
// Load 00 then 13-use-authorization-negative. No label allow-list here on purpose: the instance filter alone is compared.

// Q-FO-1 (application-style DENY-list, null defaulted to public): admits every node whose class is not 'INTERNAL',
// treating a missing class as public. Expected: one row; leaksUnclassifiedPolicy true, leaksUnclassifiedLineage true
// (the same fail-open shape Neo4j documents for DENY rules on null or misspelled criteria).
MATCH (s {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MATCH p = (s)(()-[r]-(n) WHERE coalesce(n.privacyClass, 'PUBLIC') <> 'INTERNAL'){1,2}
UNWIND nodes(p) AS m
WITH collect(DISTINCT m.uid) AS reached
RETURN 'hu:policy-version:w23-unclassified-draft' IN reached AS leaksUnclassifiedPolicy,
       'hu:activity:w23-unclassified-legacy-run' IN reached AS leaksUnclassifiedLineage, size(reached) AS reachedNodes;

// Q-FO-2 (Cypher DENY-list without coalesce): null <> 'INTERNAL' is null, so WHERE drops the node. Expected: one row; both
// false. Cypher's three-valued logic happens to fail closed here, but the same rule ported to application code or to a
// Neo4j RBAC DENY does not; it is not a safe pattern to rely on.
MATCH (s {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MATCH p = (s)(()-[r]-(n) WHERE n.privacyClass <> 'INTERNAL'){1,2}
UNWIND nodes(p) AS m
WITH collect(DISTINCT m.uid) AS reached
RETURN 'hu:policy-version:w23-unclassified-draft' IN reached AS leaksUnclassifiedPolicy,
       'hu:activity:w23-unclassified-legacy-run' IN reached AS leaksUnclassifiedLineage, size(reached) AS reachedNodes;

// Q-FO-3 (W23 rule: ALLOW-list): admits a node only when privacyClass = 'PUBLIC'. Expected: one row; both false.
MATCH (s {uid: 'hu:assertion:w23-a2-variant-fv-a1c'})
MATCH p = (s)(()-[r]-(n) WHERE n.privacyClass = 'PUBLIC'){1,2}
UNWIND nodes(p) AS m
WITH collect(DISTINCT m.uid) AS reached
RETURN 'hu:policy-version:w23-unclassified-draft' IN reached AS leaksUnclassifiedPolicy,
       'hu:activity:w23-unclassified-legacy-run' IN reached AS leaksUnclassifiedLineage, size(reached) AS reachedNodes;
