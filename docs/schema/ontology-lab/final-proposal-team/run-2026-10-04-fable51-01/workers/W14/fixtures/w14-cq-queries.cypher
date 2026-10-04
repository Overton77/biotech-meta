// W14 fixture 4b: competency-question queries (read-only; literal parameters inline so each statement runs alone).
// Load order: w14-ip-core.cypher, w14-ip-minimal-pairs.cypher; expected rows are in 06-fixtures-and-queries.md (Q-01..Q-12).

// Q-01 CQ-IP-C01: which granted claims are asserted to cover the material Niagen (or the substance it realizes) in the US
// as of D = 2026-10-04, and are they enforceable then? Rows are returned with the reason flags, never silently filtered.
WITH datetime('2026-10-04T00:00:00Z') AS d, 'US' AS j
MATCH (m:BrandedIngredientMaterial {uid: 'hu:material:niagen'})
OPTIONAL MATCH (m)-[rs:REALIZES_SUBSTANCE]->(sub) WHERE rs.recordedTo IS NULL
WITH d, j, m, collect(sub) AS subs
WITH d, j, [m] + subs AS targets
MATCH (g:GrantedPatent {jurisdiction: j})-[:HAS_PATENT_CLAIM]->(c:PatentClaim)
MATCH (a:Assertion {predicate: 'PATENT_CLAIMS'})-[:HAS_SUBJECT]->(subj) WHERE (subj = g OR subj = c) AND a.recordedTo IS NULL
MATCH (a)-[:HAS_OBJECT]->(tgt) WHERE tgt IN targets
MATCH (a)-[:ASSERTED_BY]->(who)
WITH d, g, c, a, who, subj,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(g) WHERE r.recordedTo IS NULL AND s.statusKind = 'GRANTED_IN_FORCE'
           AND (r.validFrom IS NULL OR r.validFrom <= d) AND (r.validTo IS NULL OR d < r.validTo) } AS patentInForce,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(g) WHERE r.recordedTo IS NULL AND s.statusKind IN ['EXPIRED', 'LAPSED', 'SURRENDERED', 'CANCELLED']
           AND r.validFrom IS NOT NULL AND r.validFrom <= d AND (r.validTo IS NULL OR d < r.validTo) } AS patentTerminated,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(c) WHERE r.recordedTo IS NULL AND s.statusKind IN ['CLAIM_HELD_INVALID', 'CLAIM_HELD_UNPATENTABLE', 'CLAIM_CANCELLED']
           AND r.validFrom IS NOT NULL AND r.validFrom <= d AND (r.validTo IS NULL OR d < r.validTo) } AS claimHeldInvalid
RETURN g.patentNumber AS patent, c.claimNumber AS claim, CASE WHEN subj:PatentClaim THEN 'claim' ELSE 'patent' END AS coverageLevel,
       who.name AS coverageAsserter, a.assertionBasis AS basis, patentInForce, patentTerminated, claimHeldInvalid,
       (patentInForce AND NOT patentTerminated AND NOT claimHeldInvalid) AS enforceableAsOfD
ORDER BY claim, coverageLevel;

// Q-02 CQ-IP-C01 at D = 2022-06-01 (before the captured appellate holding) and D = 2026-12-01 (after the displayed adjusted expiration).
UNWIND [datetime('2022-06-01T00:00:00Z'), datetime('2026-12-01T00:00:00Z')] AS d
MATCH (g:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})-[:HAS_PATENT_CLAIM]->(c:PatentClaim {claimNumber: 1})
RETURN d,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(g) WHERE r.recordedTo IS NULL AND s.statusKind = 'GRANTED_IN_FORCE'
           AND (r.validFrom IS NULL OR r.validFrom <= d) AND (r.validTo IS NULL OR d < r.validTo) } AS patentInForce,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(g) WHERE r.recordedTo IS NULL AND s.statusKind IN ['EXPIRED', 'LAPSED', 'SURRENDERED', 'CANCELLED']
           AND r.validFrom IS NOT NULL AND r.validFrom <= d } AS patentTerminated,
  EXISTS { MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(c) WHERE r.recordedTo IS NULL AND s.statusKind STARTS WITH 'CLAIM_HELD'
           AND r.validFrom IS NOT NULL AND r.validFrom <= d } AS claimHeldInvalid
ORDER BY d;

// Q-03 CQ-IP-C02: who licenses US 8,197,807 (directly, through a named claim, or through a family the license states it covers),
// from whom, on what terms, valid at D = 2026-10-04 in current recorded time.
WITH datetime('2026-10-04T00:00:00Z') AS d
MATCH (g:GrantedPatent {uid: 'hu:granted-patent:us-8197807'})
MATCH (l:PatentLicense)-[cov:LICENSE_COVERS]->(t)
WHERE cov.recordedTo IS NULL
  AND EXISTS { MATCH (a:Assertion {uid: cov.assertionUid, predicate: 'LICENSE_COVERS'}) }
  AND (t = g OR (t:PatentClaim AND EXISTS { MATCH (g)-[:HAS_PATENT_CLAIM]->(t) })
       OR (t:PatentFamily AND EXISTS { MATCH (t)-[:FAMILY_HAS_APPLICATION]->(:PatentApplication)-[:APPLICATION_GRANTED_AS]->(g) }))
MATCH (lee)-[le:LICENSES_PATENT]->(l)
WHERE le.recordedTo IS NULL AND (le.validFrom IS NULL OR le.validFrom <= d) AND (le.validTo IS NULL OR d < le.validTo)
OPTIONAL MATCH (lor)-[lo:GRANTS_PATENT_LICENSE]->(l) WHERE lo.recordedTo IS NULL
RETURN l.uid AS license, lee.name AS licensee, lor.name AS licensor, l.exclusive AS exclusive, l.fieldOfUse AS fieldOfUse,
       l.fieldOfUseReportedStatus AS fieldStatus, l.territory AS territory, l.territoryJurisdictions AS territoryCodes,
       le.validFrom AS validFrom, le.validTo AS validTo, le.validToBasis AS validToBasis, head(labels(t)) AS coveredVia;

// Q-04 CQ-IP-C02 (synthetic family-level coverage) at D = 2023-06-01 and D = 2026-10-04 for the synthetic US grant.
UNWIND [datetime('2023-06-01T00:00:00Z'), datetime('2026-10-04T00:00:00Z')] AS d
MATCH (g:GrantedPatent {uid: 'hu:granted-patent:syn-us-a'})
MATCH (l:PatentLicense)-[cov:LICENSE_COVERS]->(t:PatentFamily)-[:FAMILY_HAS_APPLICATION]->(:PatentApplication)-[:APPLICATION_GRANTED_AS]->(g)
WHERE cov.recordedTo IS NULL AND EXISTS { MATCH (a:Assertion {uid: cov.assertionUid, predicate: 'LICENSE_COVERS'}) }
MATCH (lee)-[le:LICENSES_PATENT]->(l)
WHERE le.recordedTo IS NULL AND (le.validFrom IS NULL OR le.validFrom <= d) AND (le.validTo IS NULL OR d < le.validTo)
OPTIONAL MATCH (lor)-[lo:GRANTS_PATENT_LICENSE]->(l) WHERE lo.recordedTo IS NULL
RETURN d, l.uid AS license, lee.name AS licensee, lor.name AS licensor, l.fieldOfUse AS fieldOfUse, l.territoryJurisdictions AS territoryCodes,
       l.territoryReportedStatus AS territoryStatus, le.validTo AS validTo, le.validToBasis AS validToBasis
ORDER BY d, license;

// Q-05 failing case for "licensor = assignee": the naive inference names the assignee; the asserted licensor of the sublicense differs.
MATCH (l:PatentLicense)-[:LICENSE_COVERS]->(t)<-[:ASSIGNED_PATENT]-(asg)
OPTIONAL MATCH (lor)-[:GRANTS_PATENT_LICENSE]->(l)
RETURN l.uid AS license, asg.name AS naiveLicensorFromAssignee, lor.name AS assertedLicensor, asg = lor AS sameParty
ORDER BY license;

// Q-06 CQ-IP-C03: does holding a license (or a claim's subject matter) yield a study role or an efficacy finding? Expected: no.
MATCH (o:LegalEntity {uid: 'hu:org:chromadex-inc'})-[:LICENSES_PATENT]->(l:PatentLicense)
OPTIONAL MATCH (o)-[r:OWNS_STUDY|SPONSORS_STUDY|FUNDS_STUDY]->(:Study) WHERE r.assertionUid IS NOT NULL
WITH count(DISTINCT l) AS licensesHeld, count(r) AS assertedStudyRoles
OPTIONAL MATCH (x:Assertion {predicate: 'PROVES_EFFICACY', status: 'ACCEPTED'})
RETURN licensesHeld, assertedStudyRoles, count(x) AS acceptedEfficacyAssertions;

// Q-07 CQ-IP-C04: for the branded material Niagen -- the mark, its owner and status at D = 2026-10-04, and who supplies the
// material (owner and supplier are separate asserted roles).
WITH datetime('2026-10-04T00:00:00Z') AS d
MATCH (m:BrandedIngredientMaterial {uid: 'hu:material:niagen'})-[mu:MARKETED_UNDER_MARK]->(tm:Trademark)
WHERE mu.recordedTo IS NULL
OPTIONAL MATCH (own)-[ow:OWNS_TRADEMARK]->(tm)
  WHERE ow.recordedTo IS NULL AND (ow.validFrom IS NULL OR ow.validFrom <= d) AND (ow.validTo IS NULL OR d < ow.validTo)
OPTIONAL MATCH (st:IpRightStatus)-[sr:IP_STATUS_OF]->(tm)
  WHERE sr.recordedTo IS NULL AND (sr.validFrom IS NULL OR sr.validFrom <= d) AND (sr.validTo IS NULL OR d < sr.validTo)
OPTIONAL MATCH (sup)-[sp:SUPPLIES_INGREDIENT_MATERIAL]->(m) WHERE sp.recordedTo IS NULL
OPTIONAL MATCH (mua:Assertion {uid: mu.assertionUid})-[:ASSERTED_BY]->(markAsserter)
RETURN tm.markText AS mark, tm.jurisdiction AS jurisdiction, tm.registrationNumber AS registration, collect(DISTINCT own.name) AS owners,
       collect(DISTINCT st.statusKind) AS statusesAtD, collect(DISTINCT sup.name) AS suppliers, markAsserter.name AS markUseAsserter;

// Q-08 CQ-IP-C04 lapsed mark: synthetic EXAMPLEMARK status at three dates.
UNWIND [datetime('2020-01-01T00:00:00Z'), datetime('2021-07-06T00:00:00Z'), datetime('2026-10-04T00:00:00Z')] AS d
MATCH (tm:Trademark {uid: 'hu:trademark:syn-us-examplemark'})
OPTIONAL MATCH (st:IpRightStatus)-[sr:IP_STATUS_OF]->(tm)
  WHERE sr.recordedTo IS NULL AND sr.validFrom <= d AND (sr.validTo IS NULL OR d < sr.validTo)
RETURN d, collect(st.statusKind) AS statusesAtD
ORDER BY d;

// Q-09 CQ-IP-C05: family structure under its stated definition -- applications by jurisdiction, grants, current statuses.
MATCH (f:PatentFamily)-[:FAMILY_HAS_APPLICATION]->(a:PatentApplication)
OPTIONAL MATCH (a)-[:APPLICATION_GRANTED_AS]->(g:GrantedPatent)
OPTIONAL MATCH (s:IpRightStatus)-[r:IP_STATUS_OF]->(a) WHERE r.recordedTo IS NULL
RETURN f.uid AS family, f.familyDefinition AS definition, a.jurisdiction AS jurisdiction, a.applicationNumber AS application,
       g.patentNumber AS grant, collect(s.statusKind) AS applicationStatuses
ORDER BY family, jurisdiction;

// Q-10 CQ-EC-01: IP neighbourhood of ChromaDex, Inc. valid at V = 2026-10-04, current recorded time.
WITH datetime('2026-10-04T00:00:00Z') AS v
MATCH (o:LegalEntity {uid: 'hu:org:chromadex-inc'})-[r:OWNS_TRADEMARK|LICENSES_PATENT|ASSIGNED_PATENT|GRANTS_PATENT_LICENSE]->(x)
WHERE r.recordedTo IS NULL AND (r.validFrom IS NULL OR r.validFrom <= v) AND (r.validTo IS NULL OR v < r.validTo)
OPTIONAL MATCH (x)-[c:LICENSE_COVERS]->(t) WHERE c.recordedTo IS NULL
RETURN type(r) AS role, x.uid AS node, r.validFrom AS validFrom, r.validFromBasis AS validFromBasis, collect(t.officeKey) AS covers
ORDER BY role, node;

// Q-11 temporal correction (MP-5): the in-force episode for the synthetic grant as believed at two recorded times, at valid date 2035-06-01.
UNWIND [datetime('2026-10-04T01:25:00Z'), datetime('2026-10-04T01:35:00Z')] AS rt
MATCH (g:GrantedPatent {uid: 'hu:granted-patent:syn-us-b'})
MATCH (s:IpRightStatus {statusKind: 'GRANTED_IN_FORCE'})-[r:IP_STATUS_OF]->(g)
WHERE r.recordedFrom <= rt AND (r.recordedTo IS NULL OR rt < r.recordedTo)
RETURN rt AS asRecordedAt, s.uid AS state, r.validTo AS validTo, r.validToBasis AS validToBasis,
       (r.validFrom <= datetime('2035-06-01T00:00:00Z') AND (r.validTo IS NULL OR datetime('2035-06-01T00:00:00Z') < r.validTo)) AS inForceOn20350601
ORDER BY asRecordedAt;

// Q-12 CQ-EC-02 / identity: same digits across issuers and same markText across jurisdictions stay distinct identities.
MATCH (i:Identifier) WHERE i.value IN ['8197807', '1336169']
OPTIONAL MATCH (n)-[:HAS_IDENTIFIER]->(i)
RETURN i.scheme AS scheme, i.issuer AS issuer, i.value AS value, collect(n.uid) AS identifies
UNION ALL
MATCH (t:Trademark {markText: 'NIAGEN'})
RETURN 'Trademark' AS scheme, t.jurisdiction AS issuer, t.officeKey AS value, [t.uid] AS identifies;
