// Run run-2026-10-04-fable51-01, worker W01 (Opus 5.5). Queries and W01 validation checks.
// Each statement is self-contained (literal probes; no parameters). Expected rows are in 06-fixtures-and-queries.md.
// Q-W01-* are competency-question shapes; V-W01-* are validation checks (zero rows = valid on the positive fixtures).

// Q-W01-01 (CQ-AX-18, CQ-CL-05 time part, CQ-TM-04): was the role in force at V, as recorded at R?
// Precision-aware classes (round 0007 section 9): a bound is the first instant of its precision period, so
// V inside the start or end period is POSSIBLE; an open end is KNOWN only up to the latest witness
// (publishedAt of the supporting snapshot, else observedAt; W01-SR-08).
UNWIND [
  {k: 'P01 Rubin board, V inside start year', p: 'hu:person:steven-rubin', o: 'hu:org:niagen-bioscience-inc', v: '2017-05-15T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P02 Rubin board, V after start year', p: 'hu:person:steven-rubin', o: 'hu:org:niagen-bioscience-inc', v: '2018-02-01T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P03 Yu board, V=2017-05-15', p: 'hu:person:wendy-yu', o: 'hu:org:niagen-bioscience-inc', v: '2017-05-15T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P04 Yu board, V=2017-10-01', p: 'hu:person:wendy-yu', o: 'hu:org:niagen-bioscience-inc', v: '2017-10-01T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P05 Sinclair-Segterra, V inside end year', p: 'hu:person:david-a-sinclair', o: 'hu:org:segterra', v: '2017-06-15T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P06 Sinclair-Segterra, V=2018-06-01 now', p: 'hu:person:david-a-sinclair', o: 'hu:org:segterra', v: '2018-06-01T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P07 Sinclair-Segterra, V=2018-06-01 as recorded before the fix', p: 'hu:person:david-a-sinclair', o: 'hu:org:segterra', v: '2018-06-01T00:00:00Z', r: '2026-10-03T13:00:00Z'},
  {k: 'P08 Sinclair-Segterra, V=episode 52 air date', p: 'hu:person:david-a-sinclair', o: 'hu:org:segterra', v: '2021-12-27T09:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P09 Jaksch, V=2020-01-01', p: 'hu:person:frank-jaksch-jr', o: 'hu:org:niagen-bioscience-inc', v: '2020-01-01T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P10 Jaksch, V inside end month', p: 'hu:person:frank-jaksch-jr', o: 'hu:org:niagen-bioscience-inc', v: '2022-07-15T00:00:00Z', r: '2026-10-04T02:00:00Z'},
  {k: 'P11 Fried, V=2018-03-01', p: 'hu:person:robert-fried', o: 'hu:org:niagen-bioscience-inc', v: '2018-03-01T00:00:00Z', r: '2026-10-04T02:00:00Z'}
] AS probe
MATCH (x {uid: probe.p})-[r:BOARD_MEMBER_OF|EMPLOYED_BY|ADVISES_ORGANIZATION|FOUNDED_ORGANIZATION|INVESTED_IN|HOLDS_EQUITY_IN|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATED_WITH]->(o {uid: probe.o})
WITH probe, r, datetime(probe.v) AS V, datetime(probe.r) AS R
WHERE r.recordedFrom <= R AND (r.recordedTo IS NULL OR R < r.recordedTo)
CALL {
  WITH r, R
  OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})-[:SUPPORTED_BY]->(:SourceLocator)<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
  WHERE sn.retrievedAt <= R
  RETURN max(coalesce(sn.publishedAt, sn.observedAt)) AS witness
}
WITH probe, r, V, witness,
     CASE r.validFromPrecision WHEN 'DECADE' THEN duration('P10Y') WHEN 'YEAR' THEN duration('P1Y') WHEN 'QUARTER' THEN duration('P3M')
       WHEN 'MONTH' THEN duration('P1M') WHEN 'DAY' THEN duration('P1D') ELSE duration('PT0S') END AS fromLen,
     CASE r.validToPrecision WHEN 'DECADE' THEN duration('P10Y') WHEN 'YEAR' THEN duration('P1Y') WHEN 'QUARTER' THEN duration('P3M')
       WHEN 'MONTH' THEN duration('P1M') WHEN 'DAY' THEN duration('P1D') ELSE duration('PT0S') END AS toLen
WITH probe, r, V, witness,
     CASE
       WHEN r.validFrom IS NOT NULL AND V < r.validFrom THEN 'KNOWN_NOT_VALID'
       WHEN r.validTo IS NOT NULL AND V >= r.validTo + toLen THEN 'KNOWN_NOT_VALID'
       WHEN r.validTo IS NOT NULL AND V >= r.validTo THEN 'POSSIBLE_END_PRECISION'
       WHEN r.validFrom IS NULL THEN 'POSSIBLE_START_UNKNOWN'
       WHEN V < r.validFrom + fromLen THEN 'POSSIBLE_START_PRECISION'
       WHEN r.validTo IS NOT NULL THEN 'KNOWN'
       WHEN witness IS NOT NULL AND V <= witness THEN 'KNOWN_OPEN_END_WITNESSED'
       ELSE 'POSSIBLE_OPEN_END_STALE'
     END AS validityClass
RETURN probe.k AS probe, type(r) AS role, r.roleTitleVerbatim AS asPrinted, r.assertionUid AS assertionUid, validityClass,
       CASE WHEN validityClass = 'KNOWN_NOT_VALID' THEN 'no' WHEN validityClass STARTS WITH 'KNOWN' THEN 'yes' ELSE 'possibly' END AS answer
ORDER BY probe, role, assertionUid;

// Q-W01-02 (forbidden implication [ADVISES_ORGANIZATION, ENDORSES_PRODUCT]; CQ-AX-18 'advising is not endorsing'):
// advisory and endorsement are counted separately; an endorsement edge must cite an ENDORSES_PRODUCT assertion.
UNWIND ['hu:person:david-a-sinclair', 'hu:person:w01-synthetic-endorser'] AS pu
MATCH (p:Person {uid: pu})
OPTIONAL MATCH (p)-[e:ENDORSES_PRODUCT]->(x)
OPTIONAL MATCH (ea:Assertion {uid: e.assertionUid})
WITH p, count { (p)-[:ADVISES_ORGANIZATION]->() } AS advisoryEdges, collect(x.uid) AS endorsed, collect(ea.predicate) AS endorsementPremises
RETURN p.uid AS person, advisoryEdges, endorsed, endorsementPremises
ORDER BY person;

// Q-W01-03 (CQ-EC-02): brand versus legal entity -- what kind of identity is each name, and who (if anyone) is a projected owner?
UNWIND ['hu:brand:tru-niagen', 'hu:brand:insidetracker', 'hu:brand:w01-synthetic-sleepwell', 'hu:org:niagen-bioscience-inc', 'hu:org:chromadex-inc', 'hu:org:segterra'] AS u
MATCH (n {uid: u})
OPTIONAL MATCH (owner)-[ob:OWNS_BRAND]->(n)
OPTIONAL MATCH (oa:Assertion {predicate: 'OWNS_BRAND'})-[:HAS_OBJECT]->(n)
RETURN n.uid AS uid, n.name AS name, n:ConsumerBrand AS isBrand, n:LegalEntity AS isLegalEntity, n:Organization AS isOrganization,
       collect(DISTINCT owner.uid) AS projectedOwners, collect(DISTINCT oa.status) AS ownsBrandAssertionStatuses
ORDER BY uid;

// Q-W01-04 (CQ-EC-C01, CQ-TM-01): legal name and ticker of one registered entity as of a valid date, as recorded at R.
UNWIND ['2024-06-01T00:00:00Z', '2025-03-19T00:00:00Z', '2025-06-01T00:00:00Z'] AS vs
MATCH (le:LegalEntity {uid: 'hu:org:niagen-bioscience-inc'})-[h:HAS_STATE]->(s:OrganizationSnapshot)
WITH vs, datetime(vs) AS V, datetime('2026-10-04T02:00:00Z') AS R, h, s
WHERE h.recordedFrom <= R AND (h.recordedTo IS NULL OR R < h.recordedTo)
  AND (h.validFrom IS NULL OR h.validFrom <= V) AND (h.validTo IS NULL OR V < h.validTo)
RETURN vs AS validAt, s.legalName AS legalName, s.canonicalTicker AS ticker,
       CASE WHEN h.validFrom IS NULL THEN 'START_UNKNOWN' ELSE 'STATED' END AS startClass, h.assertionUid AS authorizedBy
ORDER BY validAt;

// Q-W01-05 (CQ-EC-02 similar names): every registered entity whose current or past legal name mentions ChromaDex stays a distinct
// identity; the relation between them is an asserted PARENT_OF, not a merge.
MATCH (le:LegalEntity)
OPTIONAL MATCH (le)-[:HAS_STATE]->(s:OrganizationSnapshot)
WITH le, [x IN collect(s.legalName) + [le.legalName] WHERE x IS NOT NULL] AS names
WHERE any(nm IN names WHERE nm CONTAINS 'ChromaDex')
OPTIONAL MATCH (le)-[po:PARENT_OF]->(child:LegalEntity)
RETURN le.uid AS uid, names AS legalNamesSeen, collect(child.uid) AS subsidiaries
ORDER BY uid;

// Q-W01-06 (CQ-EC-C02): control versus investment around Niagen Bioscience, Inc.
MATCH (n:Organization {uid: 'hu:org:niagen-bioscience-inc'})
RETURN n.uid AS organization,
       [(p)-[:PARENT_OF]->(n) | p.uid] AS controllingParents,
       [(n)-[:PARENT_OF]->(c) | c.uid] AS subsidiaries,
       [(h)-[e:HOLDS_EQUITY_IN]->(n) | h.uid + ' (' + coalesce(e.stakeClassVerbatim, 'stake not stated') + ')'] AS equityHolders,
       [(i)-[:INVESTED_IN]->(n) | i.uid] AS investors;

// Q-W01-07 (CQ-MF-01): who manufactures, distributes or owns the brand of a product, and at which site; the label's place of
// business is not the manufacturing site.
MATCH (p:Product {uid: 'hu:product:w01-synthetic-sleepwell-capsules'})
OPTIONAL MATCH (m:Organization)-[:MANUFACTURES_PRODUCT]->(p)
OPTIONAL MATCH (m)-[fr:OPERATES_FACILITY]->(plant:Facility) WHERE fr.facilityRole = 'MANUFACTURING_SITE'
OPTIONAL MATCH (d:Organization)-[dr:DISTRIBUTES_PRODUCT]->(p)
OPTIONAL MATCH (d)-[:OPERATES_FACILITY]->(office:Facility)
RETURN collect(DISTINCT m.uid) AS manufacturers, collect(DISTINCT plant.uid) AS manufacturingSites,
       collect(DISTINCT d.uid) AS distributors, collect(DISTINCT dr.roleTitleVerbatim) AS distributorAsPrinted,
       collect(DISTINCT office.uid) AS distributorSites;

// Q-W01-08 (CQ-EC-01): one-hop neighbourhood of a person at V (episode 52 air date), as recorded at R; expired roles drop out,
// imprecise ones are labelled. Only asserted role edges are traversed (never name similarity).
WITH datetime('2021-12-27T09:00:00Z') AS V, datetime('2026-10-04T02:00:00Z') AS R
MATCH (s:Person {uid: 'hu:person:david-a-sinclair'})-[r:BOARD_MEMBER_OF|EMPLOYED_BY|ADVISES_ORGANIZATION|FOUNDED_ORGANIZATION|INVESTED_IN|HOLDS_EQUITY_IN|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATED_WITH]->(o)
WHERE r.recordedFrom <= R AND (r.recordedTo IS NULL OR R < r.recordedTo)
WITH V, r, o,
     CASE r.validToPrecision WHEN 'YEAR' THEN duration('P1Y') WHEN 'MONTH' THEN duration('P1M') WHEN 'DAY' THEN duration('P1D') ELSE duration('PT0S') END AS toLen
WHERE NOT (r.validFrom IS NOT NULL AND V < r.validFrom) AND NOT (r.validTo IS NOT NULL AND V >= r.validTo + toLen)
RETURN type(r) AS tie, o.uid AS organization, r.roleTitleVerbatim AS asPrinted, r.validFrom AS validFrom, r.validFromPrecision AS fromPrecision
ORDER BY tie;

// Q-W01-09 (identity collision; CQ-CL-07): one token value, two issuers, two participants; no Person is linked.
MATCH (c:CohortParticipant)-[:HAS_IDENTIFIER]->(i:Identifier {scheme: 'PARTICIPANT_TOKEN', value: 'P03'})
RETURN i.issuer AS issuer, c.uid AS participant, count { (c)--(:Person) } AS personLinks
ORDER BY issuer;

// ---------------------------------------------------------------------------------------------------------------
// W01 validation checks (proposed V-W01-01 .. V-W01-12). Zero rows on the positive fixtures.
// ---------------------------------------------------------------------------------------------------------------

// V-W01-01: person-to-company and company-to-company role edges target an Organization, never a ConsumerBrand.
MATCH (x)-[r:BOARD_MEMBER_OF|EMPLOYED_BY|ADVISES_ORGANIZATION|FOUNDED_ORGANIZATION|INVESTED_IN|HOLDS_EQUITY_IN|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATED_WITH|PARENT_OF|CONTRACT_MANUFACTURES_FOR]->(y)
WHERE NOT y:Organization OR y:ConsumerBrand
RETURN 'V-W01-01' AS check, type(r) AS relType, x.uid AS fromUid, y.uid AS toUid, labels(y) AS targetLabels;

// V-W01-02: asserted-edge fidelity. A W01 asserted edge cites an existing assertion whose predicate equals the edge type and whose
// subject and object are the edge's endpoints, with equal valid bounds and precisions.
MATCH (x)-[r:BOARD_MEMBER_OF|EMPLOYED_BY|ADVISES_ORGANIZATION|FOUNDED_ORGANIZATION|INVESTED_IN|HOLDS_EQUITY_IN|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATED_WITH|PARENT_OF|OWNS_BRAND|OPERATES_FACILITY|MARKETS_PRODUCT|MANUFACTURES_PRODUCT|DISTRIBUTES_PRODUCT|CONTRACT_MANUFACTURES_FOR|SUPPLIES_INGREDIENT_MATERIAL|ENDORSES_PRODUCT]->(y)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
WITH x, r, y, a,
     [v IN [
       CASE WHEN a IS NULL THEN 'ASSERTION_MISSING' END,
       CASE WHEN a IS NOT NULL AND a.predicate <> type(r) THEN 'PREDICATE_DIFFERS_FROM_EDGE_TYPE' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(x) } THEN 'SUBJECT_IS_NOT_EDGE_START' END,
       CASE WHEN a IS NOT NULL AND NOT EXISTS { MATCH (a)-[:HAS_OBJECT]->(y) } THEN 'OBJECT_IS_NOT_EDGE_END' END,
       CASE WHEN a IS NOT NULL AND (coalesce(toString(a.validFrom), '-') <> coalesce(toString(r.validFrom), '-')
                                 OR coalesce(toString(a.validTo), '-') <> coalesce(toString(r.validTo), '-')
                                 OR coalesce(a.validFromPrecision, '-') <> coalesce(r.validFromPrecision, '-')
                                 OR coalesce(a.validToPrecision, '-') <> coalesce(r.validToPrecision, '-')) THEN 'VALID_TIME_DIFFERS' END
     ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-W01-02' AS check, type(r) AS relType, x.uid AS fromUid, y.uid AS toUid, r.assertionUid AS cited, violations;

// V-W01-03: a ConsumerBrand is never an Organization or LegalEntity (extends V-433).
MATCH (n:ConsumerBrand)
WHERE n:Organization OR n:LegalEntity
RETURN 'V-W01-03' AS check, n.uid AS uid, labels(n) AS labels;

// V-W01-04: a Facility is a physical site: never REMOTE or VIRTUAL, never also an Organization or ConsumerBrand.
MATCH (f:Facility)
WHERE f.facilityKind IN ['REMOTE', 'VIRTUAL'] OR f:Organization OR f:ConsumerBrand
RETURN 'V-W01-04' AS check, f.uid AS uid, f.facilityKind AS facilityKind, labels(f) AS labels;

// V-W01-05: no relationship between a Person and a CohortParticipant (re-identification), and every CohortParticipant
// declares its privacy class.
MATCH (p:Person)-[r]-(c:CohortParticipant)
RETURN 'V-W01-05' AS check, p.uid AS personUid, type(r) AS relType, c.uid AS participantUid
UNION
MATCH (c:CohortParticipant)
WHERE c.privacyClass IS NULL
RETURN 'V-W01-05' AS check, null AS personUid, 'NO_PRIVACY_CLASS' AS relType, c.uid AS participantUid;

// V-W01-06: control is acyclic: no organization is (transitively) its own parent in currently recorded edges.
MATCH p = (o:Organization)-[:PARENT_OF*1..6]->(o)
WHERE all(r IN relationships(p) WHERE r.recordedTo IS NULL)
RETURN 'V-W01-06' AS check, o.uid AS uid, length(p) AS cycleLength;

// V-W01-07: a currently recorded W01 asserted edge projects an ACCEPTED assertion (PROPOSED/DISPUTED/REJECTED never project).
MATCH (x)-[r:BOARD_MEMBER_OF|EMPLOYED_BY|ADVISES_ORGANIZATION|FOUNDED_ORGANIZATION|INVESTED_IN|HOLDS_EQUITY_IN|HAS_IP_INTEREST_IN|RECEIVES_COMPENSATION_FROM|AFFILIATED_WITH|PARENT_OF|OWNS_BRAND|OPERATES_FACILITY|MARKETS_PRODUCT|MANUFACTURES_PRODUCT|DISTRIBUTES_PRODUCT|CONTRACT_MANUFACTURES_FOR|SUPPLIES_INGREDIENT_MATERIAL|ENDORSES_PRODUCT]->(y)
WHERE r.recordedTo IS NULL
MATCH (a:Assertion {uid: r.assertionUid})
WHERE a.status <> 'ACCEPTED'
RETURN 'V-W01-07' AS check, type(r) AS relType, x.uid AS fromUid, y.uid AS toUid, a.status AS assertionStatus;

// V-W01-08: an OrganizationSnapshot is a VersionedState attached by HAS_STATE (never the provenance HAS_SNAPSHOT) with a payloadHash.
MATCH (s:OrganizationSnapshot)
WHERE s.payloadHash IS NULL OR s.stateType IS NULL OR NOT s:VersionedState
   OR EXISTS { MATCH ()-[:HAS_SNAPSHOT]->(s) } OR NOT EXISTS { MATCH (:Organization)-[:HAS_STATE]->(s) }
RETURN 'V-W01-08' AS check, s.uid AS uid;

// V-W01-09 (migration completeness): role flags never live on an Organization (INV-009).
MATCH (o:Organization)
WHERE o.isManufacturer IS NOT NULL OR o.isInvestor IS NOT NULL OR o.isProviderOrganization IS NOT NULL OR o.isResearchOrganization IS NOT NULL
RETURN 'V-W01-09' AS check, o.uid AS uid;

// V-W01-10: compensationKind appears only on RECEIVES_COMPENSATION_FROM.
MATCH ()-[r]->()
WHERE r.compensationKind IS NOT NULL AND type(r) <> 'RECEIVES_COMPENSATION_FROM'
RETURN 'V-W01-10' AS check, type(r) AS relType, r.relationshipUid AS relationshipUid;

// V-W01-11: legalName is set only on LegalEntity-labelled organizations.
MATCH (o:Organization)
WHERE o.legalName IS NOT NULL AND NOT o:LegalEntity
RETURN 'V-W01-11' AS check, o.uid AS uid, o.legalName AS legalName;

// V-W01-12: a board observer is not a board member.
MATCH ()-[r:BOARD_MEMBER_OF]->()
WHERE r.roleType = 'BOARD_OBSERVER'
RETURN 'V-W01-12' AS check, r.relationshipUid AS relationshipUid;
