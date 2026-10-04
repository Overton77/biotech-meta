// W23 fixture 04: uid redirect after a shared identity merge, read from a private record's stored uid (load 00 first).
// CQ-RC-04, CQ-ID-01 (identity), OPEN-QUESTIONS P0 item 8. The private snapshot (decided 2026-04-10) holds the uid that
// existed then; the shared graph merges the duplicate on 2026-05-01. The private record is never rewritten; the old uid
// stays resolvable; resolution is as of a recorded viewpoint.
// SEAM-DEPENDENT: the redirect record shape (redirectKind, survivingUid, retiredUid on an EquivalenceAssessment, and an
// equivalenceKind for duplicate records) is requested of W00 in W23-SR-06; values below are the requested shape.
// V-432 tests a relationship named COMPARES while the catalog edge is COMPARES_IDENTITIES: one V-432 row is EXPECTED
// here and is reported to W00 (W23-SR-07), not hidden by writing both names.

MERGE (d:ProductVariant:Entity {uid: 'hu:product-variant:w23-sleepwell-capsule-listing-dup'})
SET d.id = 'w23-sleepwell-capsule-listing-dup', d.entityType = 'PRODUCT_VARIANT', d.name = 'SleepWell Magnesium 60 caps (listing record, synthetic)',
    d.jurisdiction = 'US', d.privacyClass = 'PUBLIC', d.maturity = 'DEPRECATED', d.createdAt = datetime('2026-02-01T00:00:00Z');

MATCH (d:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-capsule-listing-dup'}), (c:ProductVariant {uid: 'hu:product-variant:w23-sleepwell-us-capsule'})
MERGE (e:EquivalenceAssessment:EvidenceAssessment {uid: 'hu:assessment:w23-merge-capsule-dup'})
SET e.id = 'w23-merge-capsule-dup', e.assessmentType = 'EQUIVALENCE', e.methodVersion = 'identity-merge-review-1', e.status = 'ACCEPTED',
    e.equivalenceKind = 'SAME_WORK_DIFFERENT_NAME', e.redirectKind = 'DUPLICATE_MERGE', e.survivingUid = c.uid, e.retiredUid = d.uid,
    e.rationale = 'Synthetic: the listing record and the label record name the same US capsule variant.',
    e.recordedAt = datetime('2026-05-01T12:00:00Z'), e.createdAt = datetime('2026-05-01T12:00:00Z'), e.privacyClass = 'PUBLIC'
MERGE (e)-[:COMPARES_IDENTITIES]->(d)
MERGE (e)-[:COMPARES_IDENTITIES]->(c);

// Q-RD-1: resolve the uid a private snapshot holds, as of the decision viewpoint R = 2026-04-10T09:00Z.
// Expected: one row; heldUidResolvable true; resolvedUid = the duplicate uid itself; redirectRecord null (merge recorded later).
MATCH (old {uid: 'hu:product-variant:w23-sleepwell-capsule-listing-dup'})
OPTIONAL MATCH (e:EquivalenceAssessment)-[:COMPARES_IDENTITIES]->(old)
WHERE e.status = 'ACCEPTED' AND e.redirectKind = 'DUPLICATE_MERGE' AND e.retiredUid = old.uid
  AND e.recordedAt <= datetime('2026-04-10T09:00:00Z')
WITH old, e ORDER BY e.recordedAt DESC LIMIT 1
OPTIONAL MATCH (survivor {uid: e.survivingUid})
RETURN old.uid AS heldUid, old IS NOT NULL AS heldUidResolvable, coalesce(survivor.uid, old.uid) AS resolvedUid,
       e.uid AS redirectRecord, e.recordedAt AS redirectRecordedAt;

// Q-RD-2: the same uid resolved at R = now (2026-10-04). Expected: one row; heldUidResolvable true (old node kept);
// resolvedUid = hu:product-variant:w23-sleepwell-us-capsule; redirectRecord hu:assessment:w23-merge-capsule-dup.
MATCH (old {uid: 'hu:product-variant:w23-sleepwell-capsule-listing-dup'})
OPTIONAL MATCH (e:EquivalenceAssessment)-[:COMPARES_IDENTITIES]->(old)
WHERE e.status = 'ACCEPTED' AND e.redirectKind = 'DUPLICATE_MERGE' AND e.retiredUid = old.uid
  AND e.recordedAt <= datetime('2026-10-04T00:00:00Z')
WITH old, e ORDER BY e.recordedAt DESC LIMIT 1
OPTIONAL MATCH (survivor {uid: e.survivingUid})
RETURN old.uid AS heldUid, old IS NOT NULL AS heldUidResolvable, coalesce(survivor.uid, old.uid) AS resolvedUid,
       e.uid AS redirectRecord, e.recordedAt AS redirectRecordedAt;

// Q-RD-3: redirect chains terminate and never point at a private uid (the private store follows at most 5 hops).
// Expected: zero rows.
MATCH p = (a)<-[:COMPARES_IDENTITIES]-(e:EquivalenceAssessment)
WHERE e.redirectKind = 'DUPLICATE_MERGE' AND (e.survivingUid STARTS WITH 'hu:private-' OR e.retiredUid STARTS WITH 'hu:private-'
      OR e.survivingUid = e.retiredUid OR NOT EXISTS { MATCH (s {uid: e.survivingUid}) } OR NOT EXISTS { MATCH (r {uid: e.retiredUid}) })
RETURN e.uid AS malformedRedirect;
