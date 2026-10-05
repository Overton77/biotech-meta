// W14 fixture 4a: proposed validators V-W14-01..V-W14-14 (read-only). Each statement is independent.
// Expected counts after loading w14-ip-core + w14-ip-minimal-pairs ONLY: every V-W14 = 0 rows except the informational
// V-W14-11 (2 rows) and V-W14-13 (1 row). After also loading w14-ip-negative: V-W14-01 = 1, V-W14-02 = 1, V-W14-03 = 1,
// V-W14-05 = 1, V-W14-07 = 1, V-W14-08 = 1, V-W14-09 = 1, V-W14-12 = 1 (see 06-fixtures-and-queries.md).

// V-W14-01: [LICENSES_PATENT, OWNS_STUDY] -- no study role (edge or assertion) may be derived from an IP-rights assertion.
MATCH (o)-[r:OWNS_STUDY|SPONSORS_STUDY|FUNDS_STUDY|EXECUTES_STUDY]->(s)
WHERE any(u IN coalesce(r.derivedFromAssertionUids, []) + [coalesce(r.projectionOfAssertionUid, '')]
          WHERE EXISTS { MATCH (x:Assertion {uid: u}) WHERE x.predicate IN ['LICENSES_PATENT', 'GRANTS_PATENT_LICENSE', 'LICENSE_COVERS', 'ASSIGNED_PATENT', 'OWNS_TRADEMARK', 'PATENT_CLAIMS'] })
RETURN 'V-W14-01' AS check, type(r) AS kind, o.uid AS subjectUid, s.uid AS objectUid
UNION ALL
MATCH (a:Assertion)-[:DERIVED_FROM_ASSERTION*1..3]->(x:Assertion)
WHERE a.predicate IN ['OWNS_STUDY', 'SPONSORS_STUDY', 'FUNDS_STUDY', 'EXECUTES_STUDY']
  AND x.predicate IN ['LICENSES_PATENT', 'GRANTS_PATENT_LICENSE', 'LICENSE_COVERS', 'ASSIGNED_PATENT', 'OWNS_TRADEMARK', 'PATENT_CLAIMS']
RETURN 'V-W14-01' AS check, a.predicate AS kind, a.uid AS subjectUid, x.uid AS objectUid;

// V-W14-02: [PATENT_CLAIMS, PROVES_EFFICACY] -- no efficacy or outcome assertion/edge may rest on what a patent claims.
MATCH (a:Assertion)-[:DERIVED_FROM_ASSERTION*1..3]->(x:Assertion {predicate: 'PATENT_CLAIMS'})
WHERE a.predicate IN ['PROVES_EFFICACY', 'IMPROVES_OUTCOME', 'HAS_EFFECT_ON', 'SUPPORTS_EFFICACY', 'AFFECTS_MECHANISM', 'INFLUENCES_OUTCOME']
RETURN 'V-W14-02' AS check, a.uid AS assertionUid, x.uid AS premiseUid
UNION ALL
MATCH ()-[r:AFFECTS_MECHANISM|INFLUENCES_OUTCOME|IMPROVES_OUTCOME]->()
WHERE any(u IN coalesce(r.derivedFromAssertionUids, []) + [coalesce(r.projectionOfAssertionUid, '')]
          WHERE EXISTS { MATCH (x:Assertion {uid: u, predicate: 'PATENT_CLAIMS'}) })
RETURN 'V-W14-02' AS check, type(r) AS assertionUid, coalesce(r.projectionOfAssertionUid, r.derivationRule) AS premiseUid;

// V-W14-03: every W14 asserted edge cites one Assertion whose predicate, subject and object equal the edge (V-101/V-505 specialised),
// and recordedFrom >= assertion.recordedAt.
MATCH (s)-[r:APPLICATION_GRANTED_AS|LICENSE_COVERS|MARKETED_UNDER_MARK|OWNS_TRADEMARK|ASSIGNED_PATENT|LICENSES_PATENT|GRANTS_PATENT_LICENSE|IP_STATUS_OF]->(o)
OPTIONAL MATCH (a:Assertion {uid: r.assertionUid})
OPTIONAL MATCH (a)-[:HAS_SUBJECT]->(asub)
OPTIONAL MATCH (a)-[:HAS_OBJECT]->(aobj)
WITH s, r, o, a, asub, aobj
WHERE r.assertionUid IS NULL OR r.recordedFrom IS NULL OR a IS NULL OR a.predicate <> type(r)
   OR asub IS NULL OR aobj IS NULL OR asub <> s OR aobj <> o OR r.recordedFrom < a.recordedAt
RETURN 'V-W14-03' AS check, type(r) AS relType, r.relationshipUid AS relationshipUid, r.assertionUid AS assertionUid, a.predicate AS citedPredicate;

// V-W14-04: endpoint types of W14 relationship types.
MATCH (s)-[r:APPLICATION_GRANTED_AS|LICENSE_COVERS|MARKETED_UNDER_MARK|OWNS_TRADEMARK|ASSIGNED_PATENT|LICENSES_PATENT|GRANTS_PATENT_LICENSE|IP_STATUS_OF|FAMILY_HAS_APPLICATION|HAS_PATENT_CLAIM]->(o)
WITH s, r, o, CASE type(r)
  WHEN 'APPLICATION_GRANTED_AS' THEN s:PatentApplication AND o:GrantedPatent
  WHEN 'LICENSE_COVERS' THEN s:PatentLicense AND (o:PatentFamily OR o:PatentApplication OR o:GrantedPatent OR o:PatentClaim)
  WHEN 'MARKETED_UNDER_MARK' THEN s:BrandedIngredientMaterial AND o:Trademark
  WHEN 'OWNS_TRADEMARK' THEN s:Organization AND o:Trademark
  WHEN 'ASSIGNED_PATENT' THEN s:Organization AND (o:PatentFamily OR o:PatentApplication OR o:GrantedPatent)
  WHEN 'LICENSES_PATENT' THEN s:Organization AND o:PatentLicense
  WHEN 'GRANTS_PATENT_LICENSE' THEN s:Organization AND o:PatentLicense
  WHEN 'IP_STATUS_OF' THEN s:IpRightStatus AND (o:PatentApplication OR o:GrantedPatent OR o:PatentClaim OR o:Trademark)
  WHEN 'FAMILY_HAS_APPLICATION' THEN s:PatentFamily AND o:PatentApplication
  WHEN 'HAS_PATENT_CLAIM' THEN (s:PatentApplication OR s:GrantedPatent) AND o:PatentClaim
  ELSE false END AS ok
WHERE NOT ok
RETURN 'V-W14-04' AS check, type(r) AS relType, labels(s) AS fromLabels, labels(o) AS toLabels;

// V-W14-05: license coverage is exactly what a LICENSE_COVERS assertion names (never family membership, never another predicate).
MATCH (l:PatentLicense)-[r:LICENSE_COVERS]->(t)
WHERE NOT EXISTS { MATCH (a:Assertion {uid: r.assertionUid, predicate: 'LICENSE_COVERS'})-[:HAS_OBJECT]->(t) }
RETURN 'V-W14-05' AS check, l.uid AS licenseUid, t.uid AS targetUid, r.assertionUid AS citedAssertionUid;

// V-W14-06: every PatentClaim has exactly one parent publication (application or grant).
MATCH (c:PatentClaim)
OPTIONAL MATCH (p)-[:HAS_PATENT_CLAIM]->(c)
WITH c, count(p) AS parents
WHERE parents <> 1
RETURN 'V-W14-06' AS check, c.uid AS claimUid, parents;

// V-W14-07: claim-level status kinds only on claims, patent-level kinds never on claims, and no claim status derived from a
// patent- or application-level status assertion.
MATCH (st:IpRightStatus)-[:IP_STATUS_OF]->(t)
WHERE (st.statusKind STARTS WITH 'CLAIM_') <> (t:PatentClaim)
RETURN 'V-W14-07' AS check, st.uid AS statusUid, st.statusKind AS statusKind, t.uid AS targetUid
UNION ALL
MATCH (a:Assertion {predicate: 'IP_STATUS_OF'})-[:HAS_OBJECT]->(:PatentClaim)
MATCH (a)-[:DERIVED_FROM_ASSERTION*1..3]->(x:Assertion {predicate: 'IP_STATUS_OF'})-[:HAS_OBJECT]->(xo)
WHERE NOT xo:PatentClaim
RETURN 'V-W14-07' AS check, a.uid AS statusUid, 'derived-from-patent-level' AS statusKind, xo.uid AS targetUid;

// V-W14-08: an office identifier attached to an IP right must be scoped to that right's jurisdiction
// ([SHARED_IDENTIFIER_SCHEME_VALUE_ACROSS_ISSUERS, SAME_IDENTITY]; a related property's number is not this right's identifier).
MATCH (n)-[r:HAS_IDENTIFIER]->(i:Identifier)
WHERE (n:PatentApplication OR n:GrantedPatent OR n:Trademark) AND i.jurisdiction IS NOT NULL AND i.jurisdiction <> n.jurisdiction
RETURN 'V-W14-08' AS check, n.uid AS rightUid, n.jurisdiction AS rightJurisdiction, i.scheme AS scheme, i.value AS value, i.jurisdiction AS identifierJurisdiction;

// V-W14-09: legal status is never a stored property of an IP artifact/entity (catalog 0.2.0 `status` is retired into IpRightStatus).
MATCH (n)
WHERE (n:PatentFamily OR n:PatentApplication OR n:GrantedPatent OR n:PatentClaim OR n:Trademark) AND n.status IS NOT NULL
RETURN 'V-W14-09' AS check, n.uid AS uid, n.status AS legacyStatus;

// V-W14-10: officeKey present, well formed (<jurisdiction>:<A-Z0-9>) and unique per primary label.
MATCH (n)
WHERE (n:PatentApplication OR n:GrantedPatent OR n:Trademark)
  AND (n.officeKey IS NULL OR NOT n.officeKey STARTS WITH n.jurisdiction + ':' OR NOT n.officeKey =~ '[A-Z]{2}:[A-Z0-9]+')
RETURN 'V-W14-10' AS check, n.uid AS uid, n.officeKey AS officeKey, 1 AS duplicates
UNION ALL
MATCH (n)
WHERE n:PatentApplication OR n:GrantedPatent OR n:Trademark
WITH head([l IN labels(n) WHERE l IN ['PatentApplication', 'GrantedPatent', 'Trademark']]) AS label, n.officeKey AS officeKey, collect(n.uid) AS uids
WHERE size(uids) > 1
RETURN 'V-W14-10' AS check, label AS uid, officeKey, size(uids) AS duplicates;

// V-W14-11 (informational): granted patents with no (or several) captured APPLICATION_GRANTED_AS; unknown, not absent.
MATCH (g:GrantedPatent)
OPTIONAL MATCH (a:PatentApplication)-[r:APPLICATION_GRANTED_AS]->(g)
WITH g, count(r) AS n
WHERE n <> 1
RETURN 'V-W14-11' AS check, g.uid AS grantUid, n AS applicationLinks;

// V-W14-12: no commercial role is derived from trademark ownership ([OWNS_TRADEMARK, MARKETS_PRODUCT|SUPPLIES_INGREDIENT_MATERIAL|MANUFACTURES_PRODUCT]).
MATCH (a:Assertion)-[:DERIVED_FROM_ASSERTION*1..3]->(x:Assertion {predicate: 'OWNS_TRADEMARK'})
WHERE a.predicate IN ['MARKETS_PRODUCT', 'SUPPLIES_INGREDIENT_MATERIAL', 'MANUFACTURES_PRODUCT', 'DISTRIBUTES_PRODUCT', 'LABELS_PRODUCT', 'SELLS_PRODUCT']
RETURN 'V-W14-12' AS check, a.uid AS assertionUid, a.predicate AS predicate, x.uid AS premiseUid;

// V-W14-13 (informational): license terms unknown (value null and no reportedStatus) -- must surface as unknown, never as unrestricted.
MATCH (l:PatentLicense)
WHERE (l.fieldOfUse IS NULL AND l.fieldOfUseReportedStatus IS NULL)
   OR (l.territory IS NULL AND l.territoryReportedStatus IS NULL)
   OR (l.exclusive IS NULL AND l.exclusivityReportedStatus IS NULL)
RETURN 'V-W14-13' AS check, l.uid AS licenseUid, l.fieldOfUse IS NULL AS fieldUnknown, l.territory IS NULL AS territoryUnknown, l.exclusive IS NULL AS exclusivityUnknown;

// V-W14-14: an in-force/registered status and a terminal status on the same right may not DEFINITELY overlap in valid time within
// current recorded time (TM-R5 applied to IP_STATUS_OF); possible overlaps with unknown bounds go to review, not here.
MATCH (s1:IpRightStatus)-[r1:IP_STATUS_OF]->(t)<-[r2:IP_STATUS_OF]-(s2:IpRightStatus)
WHERE s1.statusKind IN ['GRANTED_IN_FORCE', 'REGISTERED', 'RENEWED']
  AND s2.statusKind IN ['EXPIRED', 'LAPSED', 'CANCELLED', 'WITHDRAWN', 'ABANDONED', 'SURRENDERED']
  AND r1.recordedTo IS NULL AND r2.recordedTo IS NULL
  AND r1.validFrom IS NOT NULL AND r2.validFrom IS NOT NULL AND r1.validTo IS NOT NULL
  AND r2.validFrom < r1.validTo
  AND (r1.validFrom <= r2.validFrom OR (r2.validTo IS NOT NULL AND r1.validFrom < r2.validTo))
RETURN 'V-W14-14' AS check, t.uid AS rightUid, s1.statusKind AS liveKind, s2.statusKind AS terminalKind;
