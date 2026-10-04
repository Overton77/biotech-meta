// W23 fixture 10 (queries): traversal and search behaviour with the QS-6 leaks present (load 00 then 10-leak-probe-qs6).

// Q-L-1 (naive, the failure QS-6 prevents): undirected 1..2-hop expansion from the SleepWell variant with no private test.
// Expected: one row; reachesCalmRootProduct true and privateOnPath true (co-interest inferred through the private bridge).
MATCH p = (s {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})-[*1..2]-(n)
WITH collect(DISTINCT n.uid) AS reached, collect(DISTINCT [x IN nodes(p) WHERE x.uid STARTS WITH 'hu:private-' | x.uid]) AS priv
RETURN 'hu:product:w23-calmroot' IN reached AS reachesCalmRootProduct,
       size([l IN priv WHERE size(l) > 0]) > 0 AS privateOnPath;

// Q-L-2 (QS-6a guarded, query-shapes.md, $maxHops literal 2, $privateRelTypes from validation-params.json): the same
// start. Expected: one row; reachesCalmRootProduct false; privateUidsOnPaths [] (every hop tests the uid prefix,
// privacyClass and the fixture label, in both directions).
MATCH (s {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})
WHERE NOT (s.uid STARTS WITH 'hu:private-' OR s.privacyClass = 'private-personal' OR s:PrivateRecord)
MATCH p = (s)(()-[r]-(n) WHERE NOT (n.uid STARTS WITH 'hu:private-' OR n.privacyClass = 'private-personal' OR n:PrivateRecord)){1,2}
WHERE none(rel IN relationships(p) WHERE type(rel) IN ['HAS_CONTEXT_VERSION', 'HAS_GOAL', 'HAS_GOAL_VERSION', 'HAS_PROTOCOL_IN_USE',
      'HAS_ADOPTION_VERSION', 'HAS_DEVIATION', 'HAS_SHARING_GRANT', 'HAS_OPTION', 'FOR_REQUEST', 'USED_CONTEXT_VERSION',
      'HAS_CRITERION_VALUE', 'RESPONDS_TO'])
WITH collect(DISTINCT p) AS paths
RETURN any(p IN paths WHERE any(x IN nodes(p) WHERE x.uid = 'hu:product:w23-calmroot')) AS reachesCalmRootProduct,
       [p IN paths WHERE any(x IN nodes(p) WHERE x.uid STARTS WITH 'hu:private-') | [x IN nodes(p) | x.uid]] AS privateUidsOnPaths,
       any(p IN paths WHERE any(x IN nodes(p) WHERE x.uid = 'hu:product-variant:w23-calmroot-us-powder')) AS reachesCalmRootVariantViaLeakedSharedEdge;

// Q-L-2b (QS-6a guard with an ALLOW-list instead of the QS-6a deny-style test): admits only privacyClass 'PUBLIC'.
// Expected: one row; the upper-case 'PRIVATE_PERSONAL' measurement (which the QS-6a test lets through because it compares
// with 'private-personal' only and its uid would be the sole guard) is also excluded; reachesPrivate false.
MATCH (s {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})
MATCH p = (s)(()-[r]-(n) WHERE n.privacyClass = 'PUBLIC' AND NOT n.uid STARTS WITH 'hu:private-'){1,2}
WITH collect(DISTINCT p) AS paths
RETURN any(p IN paths WHERE any(x IN nodes(p) WHERE x.uid = 'hu:product:w23-calmroot')) AS reachesCalmRootProduct,
       any(p IN paths WHERE any(x IN nodes(p) WHERE x.uid STARTS WITH 'hu:private-' OR coalesce(x.privacyClass, '-') <> 'PUBLIC')) AS reachesPrivate;

// Q-L-3 (search surface leak): the shared fulltext index returns the private goal text. Expected: one row,
// hu:private-user-goal-version:w23-leak-g1. This is the leak V-W23-04 reports from index metadata alone.
CALL db.index.fulltext.queryNodes('w23_leak_goal_search', 'night shifts') YIELD node, score
RETURN node.uid AS hitUid, labels(node) AS labels, score > 0 AS matched;

// Q-L-4 (index metadata, the input V-115's $sharedIndexedLabels must be derived from): labels covered by fulltext indexes.
// Expected: one row for w23_leak_goal_search with labelsOrTypes [UserGoalVersion, Product].
SHOW FULLTEXT INDEXES YIELD name, labelsOrTypes, properties, state
WHERE name = 'w23_leak_goal_search'
RETURN name, labelsOrTypes, properties, state;
