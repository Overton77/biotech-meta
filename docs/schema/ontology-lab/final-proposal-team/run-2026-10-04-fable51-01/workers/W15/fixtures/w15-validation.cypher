// W15 validation queries (zero rows = valid unless marked informational). Run after the catalog suite
// (docs/schema/neo4j/validation.cypher with validation/validation-params.json), which already supplies V-326a, V-326b, V-326c,
// V-327, V-328, V-329 and V-112 for this module. Expected rows per fixture: 06-fixtures-and-queries.md section 3.
// Each statement is self-contained; no variable crosses a ';'.

// V-W15-01 (INV-306, catalog SELLS_PRODUCT note): SELLS_PRODUCT is derived only from ACCEPTED SELLER_OF_RECORD_FOR assertions of the
// same organization, and its target is reached through that offer's listing by a current LISTING_FOR whose listing-to-item identity is
// licensed by an ACCEPTED SAME_ITEM CommerceMatch named in derivedFromAssessmentUids. Closes the gap V-326c leaves (right predicate,
// wrong or unresolved product).
MATCH (o:Organization)-[s:SELLS_PRODUCT]->(p)
WITH o, s, p, coalesce(s.derivedFromAssertionUids, []) AS ins
OPTIONAL MATCH (a:Assertion) WHERE a.uid IN ins
WITH o, s, p, ins, collect(a) AS inputs
WITH o, s, p, ins, inputs,
  [v IN [
    CASE WHEN size(ins) = 0 THEN 'NO_SELLER_OF_RECORD_INPUT' END,
    CASE WHEN size(inputs) < size(ins) THEN 'INPUT_ASSERTION_MISSING' END,
    CASE WHEN any(a IN inputs WHERE a.predicate <> 'SELLER_OF_RECORD_FOR' OR a.status <> 'ACCEPTED'
                  OR NOT EXISTS { MATCH (a)-[:HAS_SUBJECT]->(o) }) THEN 'INPUT_NOT_ACCEPTED_SELLER_OF_RECORD_OF_THIS_ORGANIZATION' END,
    CASE WHEN size(inputs) > 0 AND NOT any(a IN inputs WHERE EXISTS {
        MATCH (a)-[:HAS_OBJECT]->(:Offer)<-[:HAS_OFFER]-(ml:MerchantListing)-[lf:LISTING_FOR]->(t)
        WHERE lf.recordedTo IS NULL
          AND (t = p OR EXISTS { MATCH (p)-[:HAS_PACKAGE_CONFIGURATION]->(t) } OR EXISTS { MATCH (p)-[:HAS_VARIANT]->(t) }
               OR EXISTS { MATCH (p)-[:HAS_VARIANT]->(:ProductVariant)-[:HAS_PACKAGE_CONFIGURATION]->(t) })
          AND EXISTS { MATCH (cm:CommerceMatch)-[:MATCHES_COMMERCE_ITEM]->(ml)
                       WHERE cm.status = 'ACCEPTED' AND cm.matchKind = 'LISTING_TO_ITEM' AND cm.matchOutcome = 'SAME_ITEM'
                         AND cm.uid IN coalesce(s.derivedFromAssessmentUids, [])
                         AND EXISTS { MATCH (cm)-[:MATCHES_COMMERCE_ITEM]->(t) } } })
         THEN 'TARGET_NOT_REACHED_THROUGH_RESOLVED_LISTING' END
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-W15-01' AS check, o.uid AS organizationUid, p.uid AS targetUid, ins AS inputs, violations;

// V-W15-02 (asserted_edge profile for every W15 asserted relationship; V-101 lists only some of them): the edge carries
// relationshipUid, assertionUid, recordedFrom and both bases. Faithfulness to the assertion is V-W00-11.
MATCH ()-[r]->()
WHERE type(r) IN ['LISTING_FOR', 'HOSTS_LISTING', 'LISTS_OFFER', 'SELLER_OF_RECORD_FOR', 'FULFILLS_OFFER', 'AFFILIATE_FOR_OFFER',
                  'USES_SUBSCRIPTION_PLAN', 'COMPONENT_PRODUCT', 'INVENTORY_INSTANCE_OF', 'UNIT_FROM_LOT', 'LISTS_PROCEDURE',
                  'IMPLEMENTS_PANEL', 'AVAILABLE_IN']
  AND (r.relationshipUid IS NULL OR r.assertionUid IS NULL OR r.recordedFrom IS NULL OR r.validFromBasis IS NULL OR r.validToBasis IS NULL)
RETURN 'V-W15-02' AS check, type(r) AS relType, coalesce(r.relationshipUid, elementId(r)) AS edge;

// V-W15-03 (CQ-AX-06; extends V-329): a materialized price/availability projection names an existing PriceObservation reachable from
// the record, agrees with it, and never claims an observation later than the latest one.
MATCH (n)
WHERE (n:MerchantListing OR n:Offer) AND (n.priceAmount IS NOT NULL OR n.availabilityStatus IS NOT NULL OR n.lastObservedAt IS NOT NULL)
OPTIONAL MATCH (po:PriceObservation {uid: n.projectedFromPriceObservationUid})
WITH n, po,
  CASE WHEN po IS NULL THEN false
       WHEN n:Offer THEN EXISTS { MATCH (n)-[:HAS_PRICE_OBSERVATION]->(po) }
       ELSE EXISTS { MATCH (n)-[:HAS_OFFER]->(:Offer)-[:HAS_PRICE_OBSERVATION]->(po) } END AS reachable
CALL {
  WITH n
  OPTIONAL MATCH (n)-[:HAS_OFFER|HAS_PRICE_OBSERVATION*1..2]->(x:PriceObservation)
  RETURN max(x.observedAt) AS latest
}
WITH n, po, reachable, latest,
  [v IN [
    CASE WHEN n.projectedFromPriceObservationUid IS NULL THEN 'PROJECTION_WITHOUT_BACKING_OBSERVATION' END,
    CASE WHEN n.projectedFromPriceObservationUid IS NOT NULL AND NOT reachable THEN 'BACKING_OBSERVATION_NOT_REACHABLE' END,
    CASE WHEN po IS NOT NULL AND n:MerchantListing AND n.priceAmount IS NOT NULL AND n.priceAmount <> po.amount THEN 'PRICE_DIFFERS_FROM_BACKING_OBSERVATION' END,
    CASE WHEN po IS NOT NULL AND n.priceKindProjected IS NOT NULL AND n.priceKindProjected <> po.priceKind THEN 'PRICE_KIND_DIFFERS' END,
    CASE WHEN n.lastObservedAt IS NOT NULL AND (latest IS NULL OR n.lastObservedAt > latest) THEN 'LAST_OBSERVED_AFTER_LATEST_OBSERVATION' END
  ] WHERE v IS NOT NULL] AS violations
WHERE size(violations) > 0
RETURN 'V-W15-03' AS check, labels(n) AS labels, coalesce(n.uid, n.id) AS item, violations;

// V-W15-04 (forbidden [LISTING_TITLE_AMOUNT, LABEL_DECLARED_AMOUNT]; INV-307 neighbourhood): a label-declared amount comes from a
// LabelSnapshot only, and never from a listing-title assertion.
MATCH (qd:QuantityDeclaration)
WHERE NOT EXISTS { MATCH (:LabelSnapshot)-[:HAS_DECLARATION]->(:LabelDeclaration)-[:HAS_QUANTITY_DECLARATION]->(qd) }
RETURN 'V-W15-04' AS check, 'QUANTITY_DECLARATION_NOT_FROM_LABEL_SNAPSHOT' AS violation, qd.uid AS item
UNION
MATCH (qd:QuantityDeclaration)-[:DERIVED_FROM_ASSERTION]->(t:Assertion {predicate: 'LISTING_TITLE_AMOUNT'})
RETURN 'V-W15-04' AS check, 'QUANTITY_DECLARATION_DERIVED_FROM_LISTING_TITLE' AS violation, qd.uid + ' <- ' + t.uid AS item;

// V-W15-05 (informational, review queue; CQ-CM-01/02): unknowns stay visible. Rows are not violations.
MATCH (off:Offer)
WHERE NOT EXISTS { MATCH (:Organization)-[:SELLER_OF_RECORD_FOR]->(off) }
RETURN 'V-W15-05 (informational)' AS check, 'SELLER_OF_RECORD_NOT_CAPTURED' AS finding, off.uid AS item
UNION
MATCH (ml:MerchantListing)
WHERE NOT EXISTS { MATCH (ml)-[:LISTING_FOR]->() } AND NOT EXISTS { MATCH (ml)-[:LISTS_PROCEDURE|IMPLEMENTS_PANEL]->() }
RETURN 'V-W15-05 (informational)' AS check,
       CASE WHEN EXISTS { MATCH (:CommerceMatch {matchKind: 'LISTING_TO_ITEM'})-[:MATCHES_COMMERCE_ITEM]->(ml) } THEN 'LISTING_IDENTITY_UNRESOLVED'
            ELSE 'LISTING_IDENTITY_NOT_ASSESSED' END AS finding, ml.uid AS item;

// V-W15-06 (INV-306 + FINANCIAL_INTEREST rule): commerce roles and affiliate ties are never a premise of SELLS_PRODUCT or
// ENDORSES_PRODUCT, whether cited as projection or among derivation inputs (V-112 checks only the pairs passed as parameters).
MATCH (x)-[r:SELLS_PRODUCT|ENDORSES_PRODUCT]->(y)
WITH x, y, r, [u IN (coalesce(r.derivedFromAssertionUids, []) + CASE WHEN r.projectionOfAssertionUid IS NULL THEN [] ELSE [r.projectionOfAssertionUid] END) | u] AS cited
MATCH (a:Assertion) WHERE a.uid IN cited
  AND a.predicate IN ['HOSTS_LISTING', 'LISTS_OFFER', 'FULFILLS_OFFER', 'AFFILIATE_FOR_OFFER', 'LISTING_FOR', 'USES_SUBSCRIPTION_PLAN',
                      'SPONSORS_CONTENT', 'RECEIVES_COMPENSATION_FROM']
RETURN 'V-W15-06' AS check, type(r) AS derivedType, x.uid AS fromUid, y.uid AS toUid, a.predicate AS forbiddenPremise, a.uid AS premiseUid;

// V-W15-07 (OPEN-QUESTIONS quality/commerce 5): recalled / expired / counterfeit / gray-market status is never a property of a commerce
// or product record; it is a CommerceMatch candidate, and such a candidate carries supporting locators.
MATCH (n)
WHERE (n:Offer OR n:MerchantListing OR n:InventoryItem OR n:IndividualUnit OR n:ProductVariant OR n:Product OR n:PackageConfiguration OR n:ProductLot)
  AND any(k IN keys(n) WHERE toLower(k) IN ['isgraymarket', 'graymarket', 'greymarket', 'isgreymarket', 'recalled', 'isrecalled', 'recallstatus',
                                             'counterfeit', 'iscounterfeit', 'counterfeitsuspected', 'expired', 'isexpired', 'unauthorized',
                                             'isunauthorized', 'authorizedseller', 'isauthorizedseller'])
RETURN 'V-W15-07' AS check, 'RISK_STATUS_AS_PROPERTY' AS violation, labels(n) AS labels, n.uid AS item,
       [k IN keys(n) WHERE toLower(k) IN ['isgraymarket', 'graymarket', 'greymarket', 'isgreymarket', 'recalled', 'isrecalled', 'recallstatus',
        'counterfeit', 'iscounterfeit', 'counterfeitsuspected', 'expired', 'isexpired', 'unauthorized', 'isunauthorized', 'authorizedseller', 'isauthorizedseller']] AS keysFound
UNION
MATCH (cm:CommerceMatch)
WHERE cm.matchKind IN ['RECALL_SCOPE', 'AUTHORIZED_CHANNEL'] AND NOT EXISTS { MATCH (cm)-[:SUPPORTED_BY]->(:SourceLocator) }
RETURN 'V-W15-07' AS check, 'RISK_CANDIDATE_WITHOUT_LOCATOR' AS violation, labels(cm) AS labels, cm.uid AS item, [] AS keysFound;

// V-W15-08 (CQ-CM-03 reproducibility): a price observation names a locator in a snapshot that displayed it at that instant
// (legacy migrated observations are reported separately as informational).
MATCH (po:PriceObservation)
OPTIONAL MATCH (l:SourceLocator {uid: po.sourceLocatorUid})<-[:HAS_LOCATOR]-(sn:SourceSnapshot)
WITH po, l, sn,
  CASE WHEN po.captureMethod = 'LEGACY_MIGRATION' THEN 'LEGACY_UNLOCATED (informational)'
       WHEN po.sourceLocatorUid IS NULL OR l IS NULL THEN 'PRICE_WITHOUT_LOCATOR'
       WHEN sn.observedAt IS NOT NULL AND sn.observedAt <> po.observedAt THEN 'OBSERVED_AT_DIFFERS_FROM_SNAPSHOT'
  END AS violation
WHERE violation IS NOT NULL
RETURN 'V-W15-08' AS check, violation, po.uid AS item;

// V-W15-09 (identity of listings): (marketplace, merchantListingId) names one MerchantListing (the operations file adds the composite
// uniqueness constraint; this query finds pre-constraint duplicates during migration).
MATCH (a:MerchantListing), (b:MerchantListing)
WHERE a.marketplace = b.marketplace AND a.merchantListingId = b.merchantListingId AND a.uid < b.uid
RETURN 'V-W15-09' AS check, a.marketplace AS marketplace, a.merchantListingId AS merchantListingId, [a.uid, b.uid] AS duplicates;

// V-W15-10 (D-012, V-113..V-116 for commerce): no private purchase, private subscription or private unit enters the shared graph.
MATCH (n)
WHERE (n:Offer OR n:PriceObservation OR n:SubscriptionPlan OR n:IndividualUnit OR n:InventoryItem OR n:AffiliateLink OR n:MerchantListing OR n:CommerceMatch)
  AND (n.uid STARTS WITH 'hu:private-' OR n:PrivateRecord OR n.privacyClass = 'PRIVATE_PERSONAL'
       OR any(k IN keys(n) WHERE k IN ['purchaserUid', 'personUid', 'buyerUid', 'userUid', 'orderId', 'subscriberUid'])
       OR (n:IndividualUnit AND (n.acquisitionContext IS NULL OR NOT n.acquisitionContext IN ['PUBLIC_TESTING_PURCHASE', 'RECALL_NOTICE_EXHIBIT', 'REGULATORY_SAMPLE', 'OTHER_PUBLIC'])))
RETURN 'V-W15-10' AS check, labels(n) AS labels, n.uid AS item;

// V-W15-11 (informational review queue; CQ-CM-03): near-simultaneous observations of one offer and kind that disagree. Both are
// kept; answers show both with captureMethod. Never averaged, never silently dropped.
MATCH (off:Offer)-[:HAS_PRICE_OBSERVATION]->(a:PriceObservation), (off)-[:HAS_PRICE_OBSERVATION]->(b:PriceObservation)
WHERE a.uid < b.uid AND a.priceKind = b.priceKind AND a.amount <> b.amount
  AND coalesce(a.subscriptionPlanUid, '-') = coalesce(b.subscriptionPlanUid, '-')
  AND (coalesce(a.captureMethod, '-') <> coalesce(b.captureMethod, '-') OR coalesce(a.conditionText, '-') = coalesce(b.conditionText, '-'))
  AND abs(duration.inSeconds(a.observedAt, b.observedAt).seconds) <= 600
RETURN 'V-W15-11 (informational)' AS check, off.uid AS offerUid, a.priceKind AS priceKind,
       [a.amount, b.amount] AS amounts, [a.captureMethod, b.captureMethod] AS captureMethods, [toString(a.observedAt), toString(b.observedAt)] AS observedAt;
