// W15 competency queries over fixtures 00-06 (positive load). Expected rows: 06-fixtures-and-queries.md section 4.
// Parameters are inlined as literals (WITH ... AS $name) so the file runs without a params file; each statement is self-contained.

// Q-W15-01 CQ-CM-01 (Essential): who hosts the listing, who placed / sells / fulfils each offer, who earns affiliate compensation,
// as observed when. Unknown roles stay null ("not displayed"), never inferred from another role.
WITH 'hu:listing:amazon-us-b0fs82b35k' AS listingUid
MATCH (ml:MerchantListing {uid: listingUid})-[:HAS_OFFER]->(off:Offer)
OPTIONAL MATCH (h:Organization)-[hr:HOSTS_LISTING]->(ml) WHERE hr.recordedTo IS NULL
OPTIONAL MATCH (s:Organization)-[sr:SELLER_OF_RECORD_FOR]->(off) WHERE sr.recordedTo IS NULL
OPTIONAL MATCH (sa:Assertion {uid: sr.assertionUid})
OPTIONAL MATCH (f:Organization)-[fr:FULFILLS_OFFER]->(off) WHERE fr.recordedTo IS NULL
OPTIONAL MATCH (lo:Organization)-[lr:LISTS_OFFER]->(off) WHERE lr.recordedTo IS NULL
OPTIONAL MATCH (aff)-[ar:AFFILIATE_FOR_OFFER]->(off) WHERE ar.recordedTo IS NULL
RETURN 'Q-W15-01' AS q, ml.merchantListingId AS listing, off.uid AS offer,
       collect(DISTINCT h.name) AS hostedBy, collect(DISTINCT s.name) AS sellerOfRecord, collect(DISTINCT sa.status) AS sellerAssertionStatus,
       collect(DISTINCT f.name) AS fulfilledBy, collect(DISTINCT lo.name) AS listedBy, collect(DISTINCT aff.name) AS affiliates,
       toString(off.lastObservedAt) AS lastObservedAt;

// Q-W15-02 CQ-CM-01 minimal pair: does the organization SELL the item, and which other roles does it hold? (Amazon on B0FS82B35K hosts and
// fulfils but does not sell; on B000QSNYGI it is seller of record of its own retail offer.)
UNWIND ['hu:org:amazon-marketplace-us', 'hu:org:seller-account-amazon-tru-niagen'] AS orgUid
MATCH (o:Organization {uid: orgUid})
OPTIONAL MATCH (o)-[sp:SELLS_PRODUCT]->(v)
WITH o, collect(DISTINCT v.name) AS sells
OPTIONAL MATCH (o)-[r:HOSTS_LISTING|FULFILLS_OFFER|SELLER_OF_RECORD_FOR|LISTS_OFFER]->(x)
OPTIONAL MATCH (x)<-[:HAS_OFFER]-(xl:MerchantListing)
RETURN 'Q-W15-02' AS q, o.name AS organization, sells AS sellsProduct_derivedFromSellerOfRecordOnly,
       collect(DISTINCT type(r) + ' @ ' + coalesce(x.merchantListingId, xl.merchantListingId)) AS roles
ORDER BY organization;

// Q-W15-03 CQ-CM-03 (Essential): every observed price of an offer, by kind, with time and capture method. Kinds are never averaged;
// the coupon text without an amount produces no COUPON_ADJUSTED row.
WITH 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new' AS offerUid
MATCH (:Offer {uid: offerUid})-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation)
RETURN 'Q-W15-03' AS q, p.priceKind AS priceKind, p.amount AS amount, p.currency AS currency, p.unitCode AS perUnit,
       toString(p.observedAt) AS observedAt, p.availabilityObserved AS availability, p.conditionText AS condition, p.captureMethod AS captureMethod
ORDER BY priceKind, amount;

// Q-W15-03b CQ-CM-03: disagreeing captures of one offer stay side by side (Shopify plan JSON vs rendered page; Walmart LLM quote vs
// structured data).
UNWIND ['hu:offer:truniagen-shopify-41905353850949', 'hu:offer:walmart-us-1038593372-sports-med'] AS offerUid
MATCH (off:Offer {uid: offerUid})-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation)
WHERE p.priceKind IN ['ONE_TIME', 'SUBSCRIPTION'] AND p.createdAt <= datetime('2026-10-05T00:00:00Z')
OPTIONAL MATCH (sp:SubscriptionPlan {uid: p.subscriptionPlanUid})
RETURN 'Q-W15-03b' AS q, off.uid AS offer, p.priceKind AS priceKind, p.amount AS amount, p.captureMethod AS captureMethod,
       sp.planName AS plan, sp.priceAdjustmentText AS planDeclaredAdjustment, p.conditionText AS condition, toString(p.observedAt) AS observedAt
ORDER BY offer, priceKind, observedAt;

// Q-W15-04 CQ-CM-02 (Foundational): which offers existed for the Tru Niagen 300mg variant (directly, via a package, via a bundle
// component) on date D, and is each listing-to-item identity RESOLVED (LISTING_FOR + ACCEPTED SAME_ITEM match), ASSERTED_ONLY
// (LISTING_FOR without an accepted match), or UNRESOLVED (no LISTING_FOR; candidate CommerceMatch only)?
WITH 'hu:product-variant:tru-niagen-300mg-us-capsule' AS variantUid, datetime('2026-10-04T12:00:00Z') AS D
MATCH (v:ProductVariant {uid: variantUid})
CALL {
  WITH v
  MATCH (ml:MerchantListing)-[lf:LISTING_FOR]->(t)
  WHERE lf.recordedTo IS NULL AND (t = v OR EXISTS { MATCH (v)-[:HAS_PACKAGE_CONFIGURATION]->(t) }
        OR EXISTS { MATCH (t:Bundle)-[:HAS_BUNDLE_COMPONENT]->(:BundleComponent)-[:COMPONENT_PRODUCT]->(c) WHERE c = v OR EXISTS { MATCH (v)-[:HAS_PACKAGE_CONFIGURATION]->(c) } })
  OPTIONAL MATCH (a:Assertion {uid: lf.assertionUid})
  RETURN ml, t, CASE WHEN EXISTS { MATCH (cm:CommerceMatch {status: 'ACCEPTED', matchOutcome: 'SAME_ITEM'})-[:MATCHES_COMMERCE_ITEM]->(ml) WHERE EXISTS { MATCH (cm)-[:MATCHES_COMMERCE_ITEM]->(t) } }
                     THEN 'RESOLVED' ELSE 'ASSERTED_ONLY (' + a.status + ')' END AS identityState
  UNION
  WITH v
  MATCH (cm:CommerceMatch {matchKind: 'LISTING_TO_ITEM'})-[:MATCHES_COMMERCE_ITEM]->(ml:MerchantListing)
  WHERE cm.matchOutcome IN ['UNRESOLVED', 'NOT_DETERMINABLE'] AND NOT EXISTS { MATCH (ml)-[:LISTING_FOR]->() }
    AND EXISTS { MATCH (cm)-[:MATCHES_COMMERCE_ITEM]->(c) WHERE c = v OR EXISTS { MATCH (v)-[:HAS_PACKAGE_CONFIGURATION]->(c) } }
  RETURN ml, null AS t, 'UNRESOLVED (candidate only)' AS identityState
}
MATCH (ml)-[:HAS_OFFER]->(off:Offer)
OPTIONAL MATCH (off)-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation) WHERE p.observedAt <= D
WITH D, ml, t, identityState, off, max(p.observedAt) AS lastObservedBeforeD, min(p.observedAt) AS firstObserved
RETURN 'Q-W15-04' AS q, ml.marketplace AS marketplace, ml.merchantListingId AS listing, labels(t)[0] AS listedItemType, identityState,
       off.uid AS offer, toString(firstObserved) AS firstObserved, toString(lastObservedBeforeD) AS lastObservedBeforeD
ORDER BY marketplace, listing;

// Q-W15-05 CQ-CM-05 + CQ-AX-06 (Foundational): did the offer end, or did observation stop? Bitemporal: valid-time V, recorded-time R.
// Classes: KNOWN_ENDED (a role edge has a stated end <= V), UNKNOWN_START (first observation after V), OPEN_END_SUPPORTED (observed at or
// after V), OPEN_END_STALE (last observation before V: report lastObservedAt, never "current"). Observations count only if recorded by R.
UNWIND [
  {offer: 'hu:offer:walmart-us-1038593372-sports-med', V: datetime('2026-10-04T00:00:00Z'), R: datetime('2026-10-05T00:00:00Z')},
  {offer: 'hu:offer:walmart-us-1038593372-sports-med', V: datetime('2026-10-04T00:00:00Z'), R: datetime('2026-10-13T00:00:00Z')},
  {offer: 'hu:offer:walmart-us-1038593372-sports-med', V: datetime('2026-10-04T01:21:00Z'), R: datetime('2026-10-05T00:00:00Z')},
  {offer: 'hu:offer:walmart-us-1038593372-sports-med', V: datetime('2026-10-20T00:00:00Z'), R: datetime('2026-10-21T00:00:00Z')},
  {offer: 'hu:offer:amazon-us-b0fs82b35k-tru-niagen-new', V: datetime('2026-10-20T00:00:00Z'), R: datetime('2026-10-21T00:00:00Z')}
] AS c
MATCH (off:Offer {uid: c.offer})
OPTIONAL MATCH (off)-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation) WHERE p.createdAt <= c.R
WITH c, off, min(p.observedAt) AS firstObservedAt, max(p.observedAt) AS lastObservedAt
OPTIONAL MATCH (org:Organization)-[sr:SELLER_OF_RECORD_FOR]->(off)
WHERE sr.recordedFrom <= c.R AND (sr.recordedTo IS NULL OR c.R < sr.recordedTo)
WITH c, off, firstObservedAt, lastObservedAt, collect(sr.validTo) AS statedEnds
RETURN 'Q-W15-05' AS q, off.uid AS offer, toString(c.V) AS validAt, toString(c.R) AS recordedAsOf,
       CASE WHEN any(e IN statedEnds WHERE e IS NOT NULL AND e <= c.V) THEN 'KNOWN_ENDED'
            WHEN firstObservedAt IS NULL OR firstObservedAt > c.V THEN 'UNKNOWN_START'
            WHEN lastObservedAt >= c.V THEN 'OPEN_END_SUPPORTED'
            ELSE 'OPEN_END_STALE' END AS validityClass,
       toString(firstObservedAt) AS firstObservedAt, toString(lastObservedAt) AS lastObservedAt
ORDER BY offer, recordedAsOf, validAt;

// Q-W15-06 CQ-CM-04 (Expansion): which pages carry an affiliate link to which listing/offer, held by whom, and where is it disclosed?
WITH 'hu:source:fastlifehacks-rhonda-patrick-supplements' AS sourceUid
MATCH (src:Source {uid: sourceUid})-[:HAS_SNAPSHOT]->(:SourceSnapshot)-[:HAS_LOCATOR]->(loc:SourceLocator)
MATCH (al:AffiliateLink {sourceLocatorUid: loc.uid})-[:LINKS_TO]->(ml:MerchantListing)
OPTIONAL MATCH (ml)-[lf:LISTING_FOR]->(t)
OPTIONAL MATCH (ml)-[:HAS_OFFER]->(off:Offer)<-[ar:AFFILIATE_FOR_OFFER]-(holder)
OPTIONAL MATCH (aa:Assertion {uid: ar.assertionUid})
RETURN 'Q-W15-06' AS q, al.anchorText AS anchorText, al.affiliateProgram AS program, al.trackingParameter + '=' + al.trackingValue AS tracking,
       ml.merchantListingId AS listing, labels(t)[0] AS listingIsFor, holder.name AS affiliate, aa.status AS affiliateAssertionStatus;

// Q-W15-07 CQ-AX-17 (commerce leg, Foundational/Q): offers for the studied variant with latest one-time price and freshness; listing-title
// amounts are returned as merchant claims in their own column, never as the label amount (label amounts come from W04 LabelSnapshots).
WITH 'hu:product-variant:tru-niagen-300mg-us-capsule' AS variantUid
MATCH (v:ProductVariant {uid: variantUid})
MATCH (ml:MerchantListing)-[lf:LISTING_FOR]->(t) WHERE lf.recordedTo IS NULL AND (t = v OR EXISTS { MATCH (v)-[:HAS_PACKAGE_CONFIGURATION]->(t) })
MATCH (ml)-[:HAS_OFFER]->(off:Offer)
OPTIONAL MATCH (off)-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation {priceKind: 'ONE_TIME'})
WITH v, ml, t, off, p ORDER BY p.observedAt DESC
WITH v, ml, t, off, collect(p)[0] AS latest
OPTIONAL MATCH (ta:Assertion {predicate: 'LISTING_TITLE_AMOUNT'})-[:HAS_SUBJECT]->(ml)
OPTIONAL MATCH (ls:LabelSnapshot)-[:LABEL_FOR]->(v)
RETURN 'Q-W15-07' AS q, ml.marketplace AS marketplace, ml.merchantListingId AS listing, t.name AS item, latest.amount AS latestOneTimePrice,
       toString(latest.observedAt) AS lastObservedAt, toString(ta.valueNumber) + ' ' + ta.unitCode + ' (merchant title claim)' AS listingTitleClaim,
       CASE WHEN ls IS NULL THEN 'NO_LABEL_SNAPSHOT_IN_THIS_PACKET (W04 supplies label amounts)' ELSE ls.uid END AS labelAmountSource
ORDER BY marketplace, listing;

// Q-W15-08 listing merge (OPEN-QUESTIONS quality/commerce 3): one listing, several offers, distinct sellers and fulfillers.
WITH 'hu:listing:amazon-us-b000qsnygi' AS listingUid
MATCH (ml:MerchantListing {uid: listingUid})-[:HAS_OFFER]->(off:Offer)
OPTIONAL MATCH (s:Organization)-[:SELLER_OF_RECORD_FOR]->(off)
OPTIONAL MATCH (f:Organization)-[:FULFILLS_OFFER]->(off)
OPTIONAL MATCH (off)-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation {priceKind: 'ONE_TIME'})
RETURN 'Q-W15-08' AS q, count(DISTINCT ml) AS listings, count(DISTINCT off) AS offers, count(DISTINCT s) AS distinctSellers,
       count(DISTINCT f) AS distinctFulfillers, min(p.amount) AS minOneTime, max(p.amount) AS maxOneTime;

// Q-W15-09 OPEN-QUESTIONS quality/commerce 5 (candidate CQ-CM-C03): recall-scope and unauthorized-channel candidates with their support.
MATCH (cm:CommerceMatch) WHERE cm.matchKind IN ['RECALL_SCOPE', 'AUTHORIZED_CHANNEL']
OPTIONAL MATCH (cm)-[:SUPPORTED_BY]->(l:SourceLocator)<-[:HAS_LOCATOR]-(:SourceSnapshot)<-[:HAS_SNAPSHOT]-(src:Source)
OPTIONAL MATCH (cm)-[:MATCHES_COMMERCE_ITEM]->(x)
RETURN 'Q-W15-09' AS q, cm.matchKind AS kind, cm.matchOutcome AS outcome, cm.status AS status,
       collect(DISTINCT labels(x)[0]) AS comparedTypes, collect(DISTINCT src.sourceKind) AS supportKinds
ORDER BY kind, outcome;

// Q-W15-10 CQ-CM-02/03: subscription plans an offer can be bought under, with the plan's own declared adjustment and the observed
// subscription prices (the plan never stands in for a price).
WITH 'hu:offer:truniagen-shopify-41905353850949' AS offerUid
MATCH (off:Offer {uid: offerUid})-[u:USES_SUBSCRIPTION_PLAN]->(sp:SubscriptionPlan)
OPTIONAL MATCH (off)-[:HAS_PRICE_OBSERVATION]->(p:PriceObservation {priceKind: 'SUBSCRIPTION', subscriptionPlanUid: sp.uid})
RETURN 'Q-W15-10' AS q, sp.sellingPlanId AS sellingPlanId, sp.planName AS plan, sp.interval + ' x' + toString(sp.intervalCount) AS cadence,
       sp.priceAdjustmentText AS declaredAdjustment, collect(p.amount + ' (' + p.captureMethod + ')') AS observedSubscriptionPrices
ORDER BY sellingPlanId;

// Q-W15-11 CQ-AX-14 (commerce): seller display accounts and the legal entities they may belong to (hypotheses, not identities).
MATCH (h:ResolutionHypothesis)-[:PROPOSES_MATCH]->(acct:Organization)
WHERE h.resolutionType IN ['SELLER_ACCOUNT_OPERATED_BY_LEGAL_ENTITY', 'STORE_OPERATED_BY_LEGAL_ENTITY'] AND NOT acct:LegalEntity
MATCH (h)-[:PROPOSES_MATCH]->(le:LegalEntity)
OPTIONAL MATCH (acct)-[:HAS_IDENTIFIER]->(i:Identifier)
RETURN 'Q-W15-11' AS q, acct.name AS sellerAccount, i.scheme + ':' + i.value AS marketplaceId, le.name AS candidateLegalEntity,
       h.resolutionStatus AS resolution, h.score AS score
ORDER BY sellerAccount;
